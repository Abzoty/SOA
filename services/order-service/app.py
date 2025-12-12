from flask import Flask, request, jsonify
from flask_cors import CORS
from datetime import datetime

import mysql
import requests

app = Flask(__name__)
CORS(app)

DB_CONFIG = {
    'host': 'localhost',
    'user': 'ecommerce_user',
    'password': 'Ecomm@2024Secure',
    'database': 'ecommerce_system'
}

PRICING_SERVICE_URL = "http://localhost:5003"
INVENTORY_SERVICE_URL = "http://localhost:5002"

def get_db_connection():
    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        return conn
    except mysql.connector.Error as err:
        print(f"Database connection error: {err}")
        return None

@app.route('/health', methods=['GET'])
def health_check():
    return jsonify({
        'status': 'healthy',
        'service': 'Order Service',
        'timestamp': datetime.now().isoformat()
    }), 200

@app.route('/api/orders/create', methods=['POST'])
def create_order():
    try:
        data = request.get_json()
        
        # Validate required fields
        if not data or 'customer_id' not in data or 'products' not in data:
            return jsonify({'error': 'Missing required fields'}), 400
        
        products = data['products']
        region = data['region'] if 'region' in data else 'default'

        #get total amount from pricing service + validate stock
        pricing_response = requests.post(f"{PRICING_SERVICE_URL}/api/pricing/calculate", 
                                        json={
                                                'products': products,
                                                'region': region
                                            })
        if pricing_response.status_code != 200:
            return jsonify({'error': 'Pricing calculation failed'}), 500
        data = pricing_response.json()

        if not data or 'subtotal' not in data or 'tax_rate' not in data or 'tax_amount' not in data or 'total' not in data not in data:
            return jsonify({'error': 'Pricing calculation failed'}), 500

        order = {
            'customer_id': data['customer_id'],
            'subtotal': data['subtotal'],
            'tax_rate': data['tax_rate'],
            'tax_amount': data,
            'total': data['total'],
            'status': 'pending',
            'created_at': datetime.now().isoformat()
        }

        
        # add order to database
        conn = get_db_connection()
        if conn:
            cursor = conn.cursor()

            # Check User existence
            cursor.execute(
                "SELECT * FROM customers WHERE customer_id = %s",
                (order['customer_id'],)
            )
            customer = cursor.fetchone()
            
            if not customer:
                return jsonify({'error': 'Customer not found'}), 404

            # Insert order
            cursor.execute(
                "INSERT INTO orders (customer_id, subtotal, tax_rate, tax_amount, total, status, created_at) VALUES (%s, %s, %s, %s, %s, %s, %s)",
                (order['customer_id'], order['subtotal'], order['tax_rate'], order['tax_amount'], order['total'], order['status'], order['created_at'])
            )
            conn.commit()

            # Get the last inserted order ID
            cursor.execute("SELECT LAST_INSERT_ID()")
            order_id = cursor.fetchone()[0]

            # Insert order items
            for product in products:
                cursor.execute(
                    "INSERT INTO order_items (order_id, product_id, quantity) VALUES (%s, %s, %s)",
                    (order_id, product['product_id'], product['quantity'])
                )
                conn.commit()

            cursor.close()
            conn.close()

            # update order items stock in inventory service
            inv_response = requests.put(
                f"{INVENTORY_SERVICE_URL}/api/inventory/update",
                json={'products': products}
            )
            if inv_response.status_code != 200:
                print(f"Warning: Failed to update inventory for products")
        
        return jsonify({
            'success': True,
            'order': order
        }), 201
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/orders/<int:order_id>', methods=['GET'])
def get_order(order_id):
    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'Database connection failed'}), 500
    
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute(
            "SELECT * FROM orders WHERE customer_id = %s",
            (order_id,)
        )
        order = cursor.fetchone()
        
        if not order:
            return jsonify({'error': 'Order not found'}), 404
        
        return jsonify(order), 200
        
    except mysql.connector.Error as err:
        return jsonify({'error': str(err)}), 500
    finally:
        cursor.close()
        conn.close()

# Integrate with Customer Service to get order history
@app.route('/api/orders/customer/<int:customer_id>', methods=['GET'])
def get_customer_orders(customer_id):
    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'Database connection failed'}), 500
    
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute(
            "SELECT * FROM orders WHERE customer_id = %s",
            (customer_id,)
        )
        orders = cursor.fetchall()
        
        return jsonify({'orders': orders}), 200
        
    except mysql.connector.Error as err:
        return jsonify({'error': str(err)}), 500
    finally:
        cursor.close()
        conn.close()

if __name__ == '__main__':
    print("Order Service starting on port 5001...")
    app.run(host='0.0.0.0', port=5001, debug=True)