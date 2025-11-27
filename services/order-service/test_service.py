import requests

def test_order_service():
    base_url = "http://localhost:5001"
    
    # Test health check
    print("Testing health check...")
    response = requests.get(f"{base_url}/health")
    print(f"Status: {response.status_code}")
    print(f"Response: {response.json()}\n")
    
    # Test create order
    print("Testing create order...")
    order_data = {
        "customer_id": 1,
        "products": [
            {"product_id": 1, "quantity": 2}
        ],
        "total_amount": 1999.98
    }
    response = requests.post(f"{base_url}/api/orders/create", json=order_data)
    print(f"Status: {response.status_code}")
    print(f"Response: {response.json()}\n")
    
    if response.status_code == 201:
        order_id = response.json()['order']['order_id']
        
        # Test get order
        print(f"Testing get order {order_id}...")
        response = requests.get(f"{base_url}/api/orders/{order_id}")
        print(f"Status: {response.status_code}")
        print(f"Response: {response.json()}")

if __name__ == "__main__":
    test_order_service()