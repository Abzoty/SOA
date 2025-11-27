import requests

def test_inventory_service():
    base_url = "http://localhost:5002"
    
    print("Testing health check...")
    response = requests.get(f"{base_url}/health")
    print(f"Status: {response.status_code}")
    print(f"Response: {response.json()}\n")
    
    print("Testing list inventory...")
    response = requests.get(f"{base_url}/api/inventory/list")
    print(f"Status: {response.status_code}")
    print(f"Response: {response.json()}\n")
    
    print("Testing check specific product...")
    response = requests.get(f"{base_url}/api/inventory/check/1")
    print(f"Status: {response.status_code}")
    print(f"Response: {response.json()}")

if __name__ == "__main__":
    test_inventory_service()