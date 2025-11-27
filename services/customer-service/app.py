from flask import Flask, request, jsonify
from flask_cors import CORS
import mysql.connector
import requests
from datetime import datetime

app = Flask(__name__)
CORS(app)

DB_CONFIG = {
    'host': 'localhost',
    'user': 'ecommerce_user',
    'password': 'Ecomm@2024Secure',
    'database': 'ecommerce_system'
}

ORDER_SERVICE_URL = "http://localhost:5001"

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
        'service': 'Customer Service',
        'timestamp': datetime.now().isoformat()
    }), 200

@app.route('/api/customers/<int:customer_id>', methods=['GET'])
def get_customer(customer_id):
    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'Database connection failed'}), 500
    
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute(
            "SELECT * FROM customers WHERE customer_id = %s",
            (customer_id,)
        )
        customer = cursor.fetchone()
        
        if not customer:
            return jsonify({'error': 'Customer not found'}), 404
        
        return jsonify(customer), 200
        
    except mysql.connector.Error as err:
        return jsonify({'error': str(err)}), 500
    finally:
        cursor.close()
        conn.close()

@app.route('/api/customers/list', methods=['GET'])
def list_customers():
    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'Database connection failed'}), 500
    
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT * FROM customers")
        customers = cursor.fetchall()
        
        return jsonify({'customers': customers}), 200
        
    except mysql.connector.Error as err:
        return jsonify({'error': str(err)}), 500
    finally:
        cursor.close()
        conn.close()

@app.route('/api/customers/<int:customer_id>/loyalty', methods=['PUT'])
def update_loyalty(customer_id):
    data = request.get_json()
    
    if not data or 'points_change' not in data:
        return jsonify({'error': 'Missing points_change field'}), 400
    
    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'Database connection failed'}), 500
    
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute(
            "UPDATE customers SET loyalty_points = loyalty_points + %s WHERE customer_id = %s",
            (data['points_change'], customer_id)
        )
        conn.commit()
        
        cursor.execute(
            "SELECT * FROM customers WHERE customer_id = %s",
            (customer_id,)
        )
        customer = cursor.fetchone()
        
        return jsonify({
            'success': True,
            'customer': customer
        }), 200
        
    except mysql.connector.Error as err:
        conn.rollback()
        return jsonify({'error': str(err)}), 500
    finally:
        cursor.close()
        conn.close()

if __name__ == '__main__':
    print("Customer Service starting on port 5004...")
    app.run(host='0.0.0.0', port=5004, debug=True)