from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import os
from dotenv import load_dotenv
from datetime import datetime
import uuid

# Load environment variables
load_dotenv()

app = FastAPI(
    title="DevOps Assignment API",
    description="Backend API for DevOps Multi-Cloud Assignment",
    version="1.0.0"
)

# Configure CORS
allowed_origins = os.getenv("ALLOWED_ORIGINS", "*").split(",")
app.add_middleware(
    CORSMiddleware,
    allow_origins=allowed_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# In-memory storage for messages
messages_db = []

class Message(BaseModel):
    content: str

class MessageResponse(BaseModel):
    id: str
    content: str
    created_at: str

@app.get("/health")
async def health_check():
    """Health check endpoint for load balancer and container orchestration."""
    return {
        "status": "healthy",
        "timestamp": datetime.utcnow().isoformat(),
        "version": "1.0.0"
    }

@app.get("/api/health")
async def api_health_check():
    """API health check endpoint."""
    return {
        "status": "healthy",
        "message": "Backend is running successfully",
        "timestamp": datetime.utcnow().isoformat()
    }

@app.get("/api/message")
async def get_message():
    """Get a default greeting message."""
    return {
        "message": "You've successfully integrated the backend!",
        "timestamp": datetime.utcnow().isoformat()
    }

@app.get("/api/messages")
async def get_all_messages():
    """Get all stored messages."""
    return {"messages": messages_db, "count": len(messages_db)}

@app.post("/api/message", response_model=MessageResponse)
async def create_message(message: Message):
    """Create a new message."""
    new_message = {
        "id": str(uuid.uuid4()),
        "content": message.content,
        "created_at": datetime.utcnow().isoformat()
    }
    messages_db.append(new_message)
    return new_message

@app.get("/api/message/{message_id}")
async def get_message_by_id(message_id: str):
    """Get a specific message by ID."""
    for msg in messages_db:
        if msg["id"] == message_id:
            return msg
    raise HTTPException(status_code=404, detail="Message not found")

@app.delete("/api/message/{message_id}")
async def delete_message(message_id: str):
    """Delete a message by ID."""
    for i, msg in enumerate(messages_db):
        if msg["id"] == message_id:
            deleted = messages_db.pop(i)
            return {"message": "Message deleted", "deleted": deleted}
    raise HTTPException(status_code=404, detail="Message not found")

# Root endpoint
@app.get("/")
async def root():
    """Root endpoint with API information."""
    return {
        "name": "DevOps Assignment API",
        "version": "1.0.0",
        "docs": "/docs",
        "health": "/health"
    }
