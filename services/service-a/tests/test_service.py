import requests

def test_health_check():
    response = requests.get("http://127.0.0.1:8000/health")
    assert response.status_code == 200
    assert response.json() == {"status": "healthy"}

if __name__ == "__main__":
    print("Running tests...")
    test_health_check()
    print("All tests passed!")