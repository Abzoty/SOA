import requests

def test_notification_service():
    base_url = "http://localhost:5005"
    
    print("Testing health check...")
    response = requests.get(f"{base_url}/health")
    print(f"Status: {response.status_code}")
    print(f"Response: {response.json()}\n")
    
    print("Testing send notification...")
    notification_data = {
        "order_id": 12345,
        "customer_id": 1
    }
    response = requests.post(f"{base_url}/api/notifications/send", json=notification_data)
    print(f"Status: {response.status_code}")
    print(f"Response: {response.json()}")

if __name__ == "__main__":
    test_notification_service()