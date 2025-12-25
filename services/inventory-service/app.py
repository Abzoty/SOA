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
        'service': 'Inventory Service',
        'timestamp': datetime.now().isoformat()
    }), 200

@app.route('/api/inventory/products', methods=['GET'])
def get_products():
    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'Database connection failed'}), 500
    
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT * FROM inventory WHERE quantity_available > 0")
        products = cursor.fetchall()
        
        for product in products:
            product['unit_price'] = float(product['unit_price'])
        
        return jsonify({'products': products}), 200
    except mysql.connector.Error as err:
        return jsonify({'error': str(err)}), 500
    finally:
        cursor.close()
        conn.close()

@app.route('/api/inventory/check/<int:product_id>', methods=['GET'])
def check_inventory(product_id):
    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'Database connection failed'}), 500
    
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT * FROM inventory WHERE product_id = %s", (product_id,))
        product = cursor.fetchone()
        
        if not product:
            return jsonify({'error': 'Product not found'}), 404
        
        return jsonify({
            'product_id': product['product_id'],
            'product_name': product['product_name'],
            'quantity_available': product['quantity_available'],
            'unit_price': float(product['unit_price']),
            'in_stock': product['quantity_available'] > 0
        }), 200
    except mysql.connector.Error as err:
        return jsonify({'error': str(err)}), 500
    finally:
        cursor.close()
        conn.close()

@app.route('/api/inventory/update', methods=['PUT'])
def update_inventory():
    data = request.get_json()
    if not data or 'products' not in data:
        return jsonify({'error': 'Missing products list'}), 400

    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'Database connection failed'}), 500

    try:
        cursor = conn.cursor()
        for p in data['products']:
            pid = p['product_id']
            qty = int(p['quantity'])
            cursor.execute("SELECT quantity_available FROM inventory WHERE product_id = %s FOR UPDATE", (pid,))
            row = cursor.fetchone()
            if not row:
                conn.rollback()
                return jsonify({'error': f'Product {pid} not found'}), 404
            if row[0] < qty:
                conn.rollback()
                return jsonify({'error': f'Insufficient stock for product {pid}'}), 400

        for p in data['products']:
            pid = p['product_id']
            qty = int(p['quantity'])
            cursor.execute(
                "UPDATE inventory SET quantity_available = quantity_available - %s WHERE product_id = %s",
                (qty, pid)
            )
        conn.commit()
        return jsonify({'success': True}), 200

    except mysql.connector.Error as err:
        conn.rollback()
        return jsonify({'error': str(err)}), 500
    finally:
        cursor.close()
        conn.close()

if __name__ == '__main__':
    print("Inventory Service starting on port 5002...")
    app.run(host='0.0.0.0', port=5002, debug=True)