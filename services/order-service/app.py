from flask import Flask, request, jsonify
from flask_cors import CORS
from datetime import datetime

import mysql.connector
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
CUSTOMER_SERVICE_URL = "http://localhost:5004"
NOTIFICATION_SERVICE_URL = "http://localhost:5005"

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
    req = request.get_json()
    if not req or 'customer_id' not in req or 'products' not in req:
        return jsonify({'error': 'Missing required fields'}), 400

    customer_id = int(req['customer_id'])
    products = req['products']
    region = req.get('region', 'default')

    # Input validation for products
    for p in products:
        if 'product_id' not in p or 'quantity' not in p:
            return jsonify({'error': 'Each product must include product_id and quantity'}), 400

    # Call pricing service
    try:
        pricing_resp = requests.post(
            f"{PRICING_SERVICE_URL}/api/pricing/calculate",
            json={'products': products, 'region': region},
            timeout=5
        )
    except requests.RequestException as e:
        return jsonify({'error': f'Pricing service unavailable: {str(e)}'}), 502

    if pricing_resp.status_code != 200:
        return jsonify({'error': 'Pricing calculation failed', 'details': pricing_resp.text}), pricing_resp.status_code

    pricing_data = pricing_resp.json()
    required_keys = {'subtotal', 'tax_rate', 'tax_amount', 'total', 'items'}
    if not required_keys.issubset(pricing_data.keys()):
        return jsonify({'error': 'Invalid pricing response'}), 500

    # Verify customer exists
    try:
        cust_resp = requests.get(f"{CUSTOMER_SERVICE_URL}/api/customers/{customer_id}", timeout=3)
    except requests.RequestException as e:
        return jsonify({'error': f'Customer service unavailable: {str(e)}'}), 502

    if cust_resp.status_code != 200:
        return jsonify({'error': 'Customer not found'}), 404

    # Start DB transaction: insert order and items, but do NOT commit until inventory update succeeds
    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'Database connection failed'}), 500

    try:
        cursor = conn.cursor()
        created_at = datetime.now().isoformat()

        # Insert order
        cursor.execute(
            "INSERT INTO orders (customer_id, subtotal, tax_rate, tax_amount, total, created_at) VALUES (%s, %s, %s, %s, %s,  %s)",
            (customer_id, pricing_data['subtotal'], pricing_data['tax_rate'], pricing_data['tax_amount'], pricing_data['total'], created_at)
        )
        # get last id in a DB-agnostic way for mysql
        cursor.execute("SELECT LAST_INSERT_ID()")
        order_id = cursor.fetchone()[0]

        # Insert order items
        for product in products:
            # pricing service returns adjusted quantity and item totals
            cursor.execute(
                "INSERT INTO order_items (order_id, product_id, quantity) VALUES (%s, %s, %s)",
                (order_id, product['product_id'], product['quantity'])
            )

        # Attempt to update inventory (reserve)
        try:
            inv_resp = requests.put(
                f"{INVENTORY_SERVICE_URL}/api/inventory/update",
                json={'products': [{'product_id': it['product_id'], 'quantity': it['quantity']} for it in pricing_data['items']]},
                timeout=5
            )
        except requests.RequestException as e:
            conn.rollback()
            return jsonify({'error': f'Inventory service unavailable: {str(e)}'}), 502

        if inv_resp.status_code != 200:
            # Inventory update failed -> rollback
            conn.rollback()
            return jsonify({'error': 'Failed to reserve inventory', 'details': inv_resp.text}), 400

        # All good -> commit
        conn.commit()
        cursor.close()
        conn.close()

        order = {
            'order_id': order_id,
            'customer_id': customer_id,
            'subtotal': pricing_data['subtotal'],
            'tax_rate': pricing_data['tax_rate'],
            'tax_amount': pricing_data['tax_amount'],
            'total': pricing_data['total'],
            'created_at': created_at
        }

        # Create Notification request
        try:
            requests.post(
                f"{NOTIFICATION_SERVICE_URL}/api/notifications/send",
                json={'order_id': order_id, 'customer_id': customer_id}
            )
        except requests.RequestException as e:
            return jsonify({'error': f'Notification service unavailable: {str(e)}'}), 502

        return jsonify({'success': True, 'order': order}), 201

    except Exception as e:
        conn.rollback()
        return jsonify({'error': str(e)}), 500
    finally:
        try:
            cursor.close()
            conn.close()
        except:
            pass

@app.route('/api/orders/<int:order_id>', methods=['GET'])
def get_order(order_id):
    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'Database connection failed'}), 500
    
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute(
            "SELECT * FROM orders WHERE order_id = %s",
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