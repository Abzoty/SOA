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
    customer_name = data.get('customer_name', 'Customer')
    customer_email = data.get('customer_email', 'unknown@example.com')
    
    message = f"Dear {customer_name}, your order #{order_id} has been confirmed and is being processed."
    
    print("="*60)
    print(f"EMAIL SENT TO: {customer_email}")
    print(f"Subject: Order #{order_id} Confirmed")
    print(f"Body: {message}")
    print("="*60)
    
    conn = get_db_connection()
    if conn:
        try:
            cursor = conn.cursor()
            cursor.execute(
                "INSERT INTO notification_log (order_id, customer_id, notification_type, message) VALUES (%s, %s, %s, %s)",
                (order_id, customer_id, 'email', message)
            )
            conn.commit()
            cursor.close()
            conn.close()
        except Exception as e:
            print(f"Failed to log notification: {e}")
    
    return jsonify({
        'success': True,
        'message': 'Notification sent successfully',
        'recipient': customer_email
    }), 200

@app.route('/api/notifications/customer/<int:customer_id>', methods=['GET'])
def get_customer_notifications(customer_id):
    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'Database connection failed'}), 500
    
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute(
            "SELECT * FROM notification_log WHERE customer_id = %s ORDER BY sent_at DESC",
            (customer_id,)
        )
        notifications = cursor.fetchall()
        
        for notif in notifications:
            notif['sent_at'] = notif['sent_at'].isoformat() if notif['sent_at'] else None
        
        return jsonify({'notifications': notifications}), 200
    except mysql.connector.Error as err:
        return jsonify({'error': str(err)}), 500
    finally:
        cursor.close()
        conn.close()

if __name__ == '__main__':
    print("Notification Service starting on port 5005...")
    app.run(host='0.0.0.0', port=5005, debug=True)