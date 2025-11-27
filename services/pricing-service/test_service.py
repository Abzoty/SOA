import requests

def test_pricing_service():
    base_url = "http://localhost:5003"
    
    print("Testing health check...")
    response = requests.get(f"{base_url}/health")
    print(f"Status: {response.status_code}")
    print(f"Response: {response.json()}\n")
    
    print("Testing calculate pricing...")
    pricing_data = {
        "products": [
            {"product_id": 1, "quantity": 2},
            {"product_id": 2, "quantity": 3}
        ],
        "region": "Cairo"
    }
    response = requests.post(f"{base_url}/api/pricing/calculate", json=pricing_data)
    print(f"Status: {response.status_code}")
    print(f"Response: {response.json()}")

if __name__ == "__main__":
    test_pricing_service()