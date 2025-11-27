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

CUSTOMER_SERVICE_URL = "http://localhost:5004"
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
        'service': 'Notification Service',
        'timestamp': datetime.now().isoformat()
    }), 200

@app.route('/api/notifications/send', methods=['POST'])
def send_notification():
    data = request.get_json()
    
    if not data or 'order_id' not in data or 'customer_id' not in data:
        return jsonify({'error': 'Missing required fields'}), 400
    
    order_id = data['order_id']
    customer_id = data['customer_id']
    
    try:
        # Get customer info from Customer Service
        cust_response = requests.get(f"{CUSTOMER_SERVICE_URL}/api/customers/{customer_id}")
        if cust_response.status_code != 200:
            return jsonify({'error': 'Failed to retrieve customer info'}), 500
        
        customer = cust_response.json()
        
        # Generate notification message
        message = f"Dear {customer['name']}, your order #{order_id} has been confirmed and is being processed."
        
        # Simulate sending email
        print("="*60)
        print(f"EMAIL SENT TO: {customer['email']}")
        print(f"Subject: Order #{order_id} Confirmed")
        print(f"Body: {message}")
        print("="*60)
        
        # Log notification to database
        conn = get_db_connection()
        if conn:
            cursor = conn.cursor()
            cursor.execute(
                "INSERT INTO notification_log (order_id, customer_id, notification_type, message) VALUES (%s, %s, %s, %s)",
                (order_id, customer_id, 'email', message)
            )
            conn.commit()
            cursor.close()
            conn.close()
        
        return jsonify({
            'success': True,
            'message': 'Notification sent successfully',
            'recipient': customer['email']
        }), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    print("Notification Service starting on port 5005...")
    app.run(host='0.0.0.0', port=5005, debug=True)