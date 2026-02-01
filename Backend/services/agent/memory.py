"""
Conversation Memory Management - Store conversation history in database
"""
import uuid
from datetime import datetime
from typing import List, Optional
from sqlalchemy.orm import Session

from models import Conversation
from logging_config import get_logger

logger = get_logger(__name__)


class ConversationMemory:
    """Conversation memory manager"""
    
    def __init__(self, db: Session, user_id: int, session_id: Optional[str] = None):
        """
        Initialize conversation memory
        
        Args:
            db: Database session
            user_id: User ID
            session_id: Session ID (optional, auto-generated if not provided)
        """
        self.db = db
        self.user_id = user_id
        self.session_id = session_id or str(uuid.uuid4())
        self._conversation: Optional[Conversation] = None
        
        # Load or create conversation
        self._load_or_create()
    
    def _load_or_create(self):
        """Load existing conversation or create new one"""
        self._conversation = self.db.query(Conversation).filter(
            Conversation.session_id == self.session_id,
            Conversation.user_id == self.user_id,
        ).first()
        
        if self._conversation is None:
            logger.debug(f"Creating new conversation: session_id={self.session_id}, user_id={self.user_id}")
            self._conversation = Conversation(
                session_id=self.session_id,
                user_id=self.user_id,
                messages=[],
            )
            self.db.add(self._conversation)
            self.db.commit()
            self.db.refresh(self._conversation)
        else:
            logger.debug(f"Loaded existing conversation: session_id={self.session_id}, messages_count={len(self._conversation.messages)}")
    
    def add_message(self, role: str, content: str):
        """
        Add message to conversation history
        
        Args:
            role: Message role (user/assistant)
            content: Message content
        """
        message = {
            "role": role,
            "content": content,
            "timestamp": datetime.utcnow().isoformat(),
        }
        
        # Update message list
        messages = list(self._conversation.messages) if self._conversation.messages else []
        messages.append(message)
        self._conversation.messages = messages
        self._conversation.updated_at = datetime.utcnow()
        
        self.db.commit()
        logger.debug(f"Added message: role={role}, content_length={len(content)}")
    
    def get_messages(self, limit: int = 10) -> List[dict]:
        """
        Get recent conversation messages
        
        Args:
            limit: Maximum number of messages to return
            
        Returns:
            List of messages
        """
        messages = self._conversation.messages or []
        return messages[-limit:] if len(messages) > limit else messages
    
    def get_formatted_history(self, limit: int = 10) -> str:
        """
        Get formatted conversation history (for prompt)
        
        Args:
            limit: Maximum number of messages to return
            
        Returns:
            Formatted conversation history string
        """
        messages = self.get_messages(limit)
        if not messages:
            return "(No conversation history)"
        
        formatted = []
        for msg in messages:
            role = "User" if msg["role"] == "user" else "Assistant"
            formatted.append(f"{role}: {msg['content']}")
        
        return "\n".join(formatted)
    
    def clear(self):
        """Clear conversation history"""
        self._conversation.messages = []
        self._conversation.updated_at = datetime.utcnow()
        self.db.commit()
        logger.debug(f"Cleared conversation: session_id={self.session_id}")
    
    @property
    def conversation_id(self) -> str:
        """Return session ID"""
        return self.session_id
