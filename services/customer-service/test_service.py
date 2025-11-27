import requests

def test_customer_service():
    base_url = "http://localhost:5004"
    
    print("Testing health check...")
    response = requests.get(f"{base_url}/health")
    print(f"Status: {response.status_code}")
    print(f"Response: {response.json()}\n")
    
    print("Testing list customers...")
    response = requests.get(f"{base_url}/api/customers/list")
    print(f"Status: {response.status_code}")
    print(f"Response: {response.json()}\n")
    
    print("Testing get specific customer...")
    response = requests.get(f"{base_url}/api/customers/1")
    print(f"Status: {response.status_code}")
    print(f"Response: {response.json()}")

if __name__ == "__main__":
    test_customer_service()