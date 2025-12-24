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
        'service': 'Pricing Service',
        'timestamp': datetime.now().isoformat()
    }), 200

@app.route('/api/pricing/calculate', methods=['POST'])
def calculate_pricing():
    data = request.get_json()
    
    if not data or 'products' not in data:
        return jsonify({'error': 'Missing products list'}), 400
    
    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'Database connection failed'}), 500
    
    try:
        cursor = conn.cursor(dictionary=True)
        items = []
        subtotal = 0
        
        for product in data['products']:
            product_id = product['product_id']
            quantity = product['quantity']
            unit_price = float(product['unit_price'])
            product_name = product.get('product_name', f'Product {product_id}')
            
            cursor.execute(
                "SELECT discount_percentage FROM pricing_rules WHERE product_id = %s AND min_quantity <= %s ORDER BY min_quantity DESC LIMIT 1",
                (product_id, quantity)
            )
            discount_rule = cursor.fetchone()
            
            discount_percentage = float(discount_rule['discount_percentage']) if discount_rule else 0
            discount_amount = (unit_price * quantity * discount_percentage) / 100
            item_total = (unit_price * quantity) - discount_amount
            
            items.append({
                'product_id': product_id,
                'product_name': product_name,
                'quantity': quantity,
                'unit_price': unit_price,
                'discount_percentage': discount_percentage,
                'discount_amount': round(discount_amount, 2),
                'item_total': round(item_total, 2)
            })
            
            subtotal += item_total
        
        region = data.get('region', 'Cairo')
        cursor.execute("SELECT tax_rate FROM tax_rates WHERE region = %s", (region,))
        tax_rule = cursor.fetchone()
        tax_rate = float(tax_rule['tax_rate']) if tax_rule else 0
        
        tax_amount = (subtotal * tax_rate) / 100
        total = subtotal + tax_amount
        
        return jsonify({
            'items': items,
            'subtotal': round(subtotal, 2),
            'tax_rate': tax_rate,
            'tax_amount': round(tax_amount, 2),
            'total': round(total, 2)
        }), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    finally:
        cursor.close()
        conn.close()

if __name__ == '__main__':
    print("Pricing Service starting on port 5003...")
    app.run(host='0.0.0.0', port=5003, debug=True)