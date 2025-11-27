from flask import Flask, request, jsonify
from flask_cors import CORS
from datetime import datetime
import random

app = Flask(__name__)
CORS(app)

# In-memory storage for testing (Phase 1)
orders = {}

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
        
        # Generate order ID
        order_id = random.randint(10000, 99999)
        
        order = {
            'order_id': order_id,
            'customer_id': data['customer_id'],
            'products': data['products'],
            'total_amount': data.get('total_amount', 0),
            'status': 'pending',
            'created_at': datetime.now().isoformat()
        }
        
        orders[order_id] = order
        
        return jsonify({
            'success': True,
            'order': order
        }), 201
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/orders/<int:order_id>', methods=['GET'])
def get_order(order_id):
    order = orders.get(order_id)
    if not order:
        return jsonify({'error': 'Order not found'}), 404
    return jsonify(order), 200

if __name__ == '__main__':
    print("Order Service starting on port 5001...")
    app.run(host='0.0.0.0', port=5001, debug=True)