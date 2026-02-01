"""
Clear Database Data Script

Clears all data from tables while preserving table structure.
Useful for clean testing.
"""
from sqlalchemy import text
from database import engine, SessionLocal
from config import settings
from logging_config import get_logger

logger = get_logger(__name__)


def is_postgres() -> bool:
    """Check if database is PostgreSQL"""
    return settings.DATABASE_URL.startswith("postgresql")


def clear_all_data():
    """
    Clear all data from all tables
    
    This function is idempotent and can be safely run multiple times.
    Tables are cleared in the correct order to respect foreign key constraints.
    """
    db = SessionLocal()
    try:
        if is_postgres():
            logger.info("Clearing PostgreSQL database data...")
            
            # Clear data in correct order (respecting foreign key constraints)
            # 1. Clear conversations (references users)
            db.execute(text("TRUNCATE TABLE conversations CASCADE"))
            logger.info("Cleared conversations table")
            
            # 2. Clear events (references users)
            db.execute(text("TRUNCATE TABLE events CASCADE"))
            logger.info("Cleared events table")
            
            # 3. Clear users (no dependencies)
            db.execute(text("TRUNCATE TABLE users CASCADE"))
            logger.info("Cleared users table")
            
            db.commit()
            logger.info("Successfully cleared all PostgreSQL data")
            
        else:
            # SQLite
            logger.info("Clearing SQLite database data...")
            
            # SQLite doesn't support TRUNCATE, use DELETE instead
            # Disable foreign key checks temporarily for SQLite
            db.execute(text("PRAGMA foreign_keys = OFF"))
            
            # Clear data in correct order
            db.execute(text("DELETE FROM conversations"))
            logger.info("Cleared conversations table")
            
            db.execute(text("DELETE FROM events"))
            logger.info("Cleared events table")
            
            db.execute(text("DELETE FROM users"))
            logger.info("Cleared users table")
            
            # Reset auto-increment counters (SQLite specific)
            db.execute(text("DELETE FROM sqlite_sequence WHERE name IN ('users', 'events', 'conversations')"))
            
            # Re-enable foreign key checks
            db.execute(text("PRAGMA foreign_keys = ON"))
            
            db.commit()
            logger.info("Successfully cleared all SQLite data")
            
    except Exception as e:
        logger.error(f"Error clearing database: {e}", exc_info=True)
        db.rollback()
        raise
    finally:
        db.close()


def main():
    """Main function"""
    print("[CLEAR] Clearing database data...")
    print("[WARNING] This will delete all data from all tables!")
    
    try:
        clear_all_data()
        print("[OK] Database data cleared successfully")
        print("[INFO] Table structures are preserved. You can now run init_db.py to repopulate with sample data.")
    except Exception as e:
        print(f"[ERROR] Failed to clear database: {e}")
        raise


if __name__ == "__main__":
    main()
