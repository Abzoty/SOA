from flask import Flask, request, jsonify
from flask_cors import CORS
import mysql.connector
from datetime import datetime

app = Flask(__name__)
CORS(app)

DB_CONFIG = {
    'host': 'localhost',
    'user': 'ecommerce_user',
    'password': 'Ecomm@2024Secure',
    'database': 'ecommerce_system'
}

def get_db_connection():
    try:
        return mysql.connector.connect(**DB_CONFIG)
    except mysql.connector.Error as err:
        print(f"Database error: {err}")
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
    data = request.get_json()
    
    if not data or 'customer_id' not in data or 'products' not in data or 'total_amount' not in data:
        return jsonify({'error': 'Missing required fields'}), 400
    
    customer_id = int(data['customer_id'])
    products = data['products']
    subtotal = float(data.get('subtotal', 0))
    tax_rate = float(data.get('tax_rate', 0))
    tax_amount = float(data.get('tax_amount', 0))
    total = float(data['total_amount'])
    
    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'Database connection failed'}), 500
    
    try:
        cursor = conn.cursor()
        
        cursor.execute(
            "INSERT INTO orders (customer_id, subtotal, tax_rate, tax_amount, total) VALUES (%s, %s, %s, %s, %s)",
            (customer_id, subtotal, tax_rate, tax_amount, total)
        )
        
        cursor.execute("SELECT LAST_INSERT_ID()")
        order_id = cursor.fetchone()[0]
        
        for product in products:
            cursor.execute(
                "INSERT INTO order_items (order_id, product_id, quantity) VALUES (%s, %s, %s)",
                (order_id, product['product_id'], product['quantity'])
            )
        
        conn.commit()
        
        cursor.execute("SELECT * FROM orders WHERE order_id = %s", (order_id,))
        columns = [desc[0] for desc in cursor.description]
        row = cursor.fetchone()
        order = dict(zip(columns, row))
        order['subtotal'] = float(order['subtotal'])
        order['tax_rate'] = float(order['tax_rate'])
        order['tax_amount'] = float(order['tax_amount'])
        order['total'] = float(order['total'])
        order['created_at'] = order['created_at'].isoformat() if order['created_at'] else None
        
        return jsonify({'success': True, 'order': order}), 201
    except Exception as e:
        conn.rollback()
        return jsonify({'error': str(e)}), 500
    finally:
        cursor.close()
        conn.close()

@app.route('/api/orders/<int:order_id>', methods=['GET'])
def get_order(order_id):
    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'Database connection failed'}), 500
    
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT * FROM orders WHERE order_id = %s", (order_id,))
        order = cursor.fetchone()
        
        if not order:
            return jsonify({'error': 'Order not found'}), 404
        
        order['subtotal'] = float(order['subtotal'])
        order['tax_rate'] = float(order['tax_rate'])
        order['tax_amount'] = float(order['tax_amount'])
        order['total'] = float(order['total'])
        order['created_at'] = order['created_at'].isoformat() if order['created_at'] else None
        
        cursor.execute("SELECT * FROM order_items WHERE order_id = %s", (order_id,))
        order_items = cursor.fetchall()

        order['items'] = order_items

        return jsonify(order), 200
    except mysql.connector.Error as err:
        return jsonify({'error': str(err)}), 500
    finally:
        cursor.close()
        conn.close()

if __name__ == '__main__':
    print("Order Service starting on port 5001...")
    app.run(host='0.0.0.0', port=5001, debug=True)