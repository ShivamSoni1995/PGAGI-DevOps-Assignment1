import pytest
from fastapi.testclient import TestClient
from app.main import app, messages_db

client = TestClient(app)

@pytest.fixture(autouse=True)
def clear_messages():
    """Clear messages before each test."""
    messages_db.clear()
    yield
    messages_db.clear()


class TestHealthEndpoints:
    """Test cases for health check endpoints."""

    def test_health_check(self):
        """Test the main health check endpoint returns healthy status."""
        response = client.get("/health")
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "healthy"
        assert "timestamp" in data
        assert data["version"] == "1.0.0"

    def test_api_health_check(self):
        """Test the API health check endpoint returns healthy status."""
        response = client.get("/api/health")
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "healthy"
        assert data["message"] == "Backend is running successfully"
        assert "timestamp" in data


class TestMessageEndpoints:
    """Test cases for message API endpoints."""

    def test_get_default_message(self):
        """Test getting the default greeting message."""
        response = client.get("/api/message")
        assert response.status_code == 200
        data = response.json()
        assert data["message"] == "You've successfully integrated the backend!"
        assert "timestamp" in data

    def test_create_message(self):
        """Test creating a new message."""
        payload = {"content": "Test message content"}
        response = client.post("/api/message", json=payload)
        assert response.status_code == 200
        data = response.json()
        assert data["content"] == "Test message content"
        assert "id" in data
        assert "created_at" in data

    def test_get_all_messages(self):
        """Test getting all messages."""
        # Create some messages first
        client.post("/api/message", json={"content": "Message 1"})
        client.post("/api/message", json={"content": "Message 2"})
        
        response = client.get("/api/messages")
        assert response.status_code == 200
        data = response.json()
        assert data["count"] == 2
        assert len(data["messages"]) == 2

    def test_get_message_by_id(self):
        """Test getting a specific message by ID."""
        # Create a message first
        create_response = client.post("/api/message", json={"content": "Test message"})
        message_id = create_response.json()["id"]
        
        response = client.get(f"/api/message/{message_id}")
        assert response.status_code == 200
        data = response.json()
        assert data["id"] == message_id
        assert data["content"] == "Test message"

    def test_get_message_not_found(self):
        """Test getting a non-existent message returns 404."""
        response = client.get("/api/message/non-existent-id")
        assert response.status_code == 404
        assert response.json()["detail"] == "Message not found"

    def test_delete_message(self):
        """Test deleting a message."""
        # Create a message first
        create_response = client.post("/api/message", json={"content": "To be deleted"})
        message_id = create_response.json()["id"]
        
        # Delete the message
        response = client.delete(f"/api/message/{message_id}")
        assert response.status_code == 200
        assert response.json()["message"] == "Message deleted"
        
        # Verify it's deleted
        get_response = client.get(f"/api/message/{message_id}")
        assert get_response.status_code == 404

    def test_delete_message_not_found(self):
        """Test deleting a non-existent message returns 404."""
        response = client.delete("/api/message/non-existent-id")
        assert response.status_code == 404


class TestRootEndpoint:
    """Test cases for root endpoint."""

    def test_root_endpoint(self):
        """Test the root endpoint returns API information."""
        response = client.get("/")
        assert response.status_code == 200
        data = response.json()
        assert data["name"] == "DevOps Assignment API"
        assert data["version"] == "1.0.0"
        assert data["docs"] == "/docs"
        assert data["health"] == "/health"
