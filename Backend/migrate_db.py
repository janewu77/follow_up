"""
数据库迁移脚本 - 添加缺失的列

用于修复旧数据库表结构，添加新字段。
支持的迁移：
- source_thumbnail 列
- conversations 表
- recurrence_rule, recurrence_end, parent_event_id 列（重复事件支持）
"""
from sqlalchemy import text
from database import engine, SessionLocal
from config import settings
from logging_config import get_logger

logger = get_logger(__name__)

# 检查是否为 PostgreSQL
def is_postgres() -> bool:
    return settings.DATABASE_URL.startswith("postgresql")


def migrate_events_table():
    """
    迁移 events 表，添加缺失的列
    
    这个函数是幂等的，可以安全地多次运行。
    如果列已存在，不会重复添加。
    """
    db = SessionLocal()
    try:
        if is_postgres():
            # PostgreSQL: 使用 information_schema 查询
            # 检查 events 表是否存在
            result = db.execute(text("""
                SELECT table_name 
                FROM information_schema.tables 
                WHERE table_schema = 'public' AND table_name = 'events'
            """))
            events_table_exists = result.scalar() is not None
            
            if events_table_exists:
                # Check and add source_thumbnail column
                result = db.execute(text("""
                    SELECT column_name 
                    FROM information_schema.columns 
                    WHERE table_name = 'events' AND column_name = 'source_thumbnail'
                """))
                if result.scalar() is None:
                    logger.info("Adding source_thumbnail column to events table...")
                    db.execute(text("ALTER TABLE events ADD COLUMN source_thumbnail TEXT NULL"))
                    db.commit()
                    logger.info("Successfully added source_thumbnail column")
                
                # Check and add recurrence_rule column
                result = db.execute(text("""
                    SELECT column_name 
                    FROM information_schema.columns 
                    WHERE table_name = 'events' AND column_name = 'recurrence_rule'
                """))
                if result.scalar() is None:
                    logger.info("Adding recurrence_rule column to events table...")
                    db.execute(text("ALTER TABLE events ADD COLUMN recurrence_rule VARCHAR(255) NULL"))
                    db.commit()
                    logger.info("Successfully added recurrence_rule column")
                
                # Check and add recurrence_end column
                result = db.execute(text("""
                    SELECT column_name 
                    FROM information_schema.columns 
                    WHERE table_name = 'events' AND column_name = 'recurrence_end'
                """))
                if result.scalar() is None:
                    logger.info("Adding recurrence_end column to events table...")
                    db.execute(text("ALTER TABLE events ADD COLUMN recurrence_end TIMESTAMP NULL"))
                    db.commit()
                    logger.info("Successfully added recurrence_end column")
                
                # Check and add parent_event_id column
                result = db.execute(text("""
                    SELECT column_name 
                    FROM information_schema.columns 
                    WHERE table_name = 'events' AND column_name = 'parent_event_id'
                """))
                if result.scalar() is None:
                    logger.info("Adding parent_event_id column to events table...")
                    db.execute(text("""
                        ALTER TABLE events 
                        ADD COLUMN parent_event_id INTEGER NULL
                    """))
                    # Add foreign key constraint
                    db.execute(text("""
                        ALTER TABLE events 
                        ADD CONSTRAINT fk_events_parent_event 
                        FOREIGN KEY (parent_event_id) REFERENCES events(id) ON DELETE CASCADE
                    """))
                    # Create index
                    db.execute(text("CREATE INDEX idx_events_parent_event_id ON events(parent_event_id)"))
                    db.commit()
                    logger.info("Successfully added parent_event_id column")
            else:
                logger.debug("events table does not exist yet, will be created by init_db()")
            
            # 检查 conversations 表是否存在
            result = db.execute(text("""
                SELECT table_name 
                FROM information_schema.tables 
                WHERE table_schema = 'public' AND table_name = 'conversations'
            """))
            table_exists = result.scalar() is not None
            
            if not table_exists:
                logger.info("Creating conversations table...")
                from models import Conversation
                from database import Base
                Base.metadata.create_all(bind=engine, tables=[Conversation.__table__])
                logger.info("Successfully created conversations table")
            else:
                logger.debug("conversations table already exists")
        else:
            # SQLite: 使用 sqlite_master 查询
            # 检查 events 表是否存在
            result = db.execute(text("""
                SELECT name FROM sqlite_master 
                WHERE type='table' AND name='events'
            """))
            events_table_exists = result.scalar() is not None
            
            if events_table_exists:
                # Check and add source_thumbnail column
                try:
                    db.execute(text("SELECT source_thumbnail FROM events LIMIT 1"))
                    logger.debug("source_thumbnail column already exists")
                except Exception:
                    logger.info("Adding source_thumbnail column to events table...")
                    db.execute(text("ALTER TABLE events ADD COLUMN source_thumbnail TEXT NULL"))
                    db.commit()
                    logger.info("Successfully added source_thumbnail column")
                
                # Check and add recurrence_rule column
                try:
                    db.execute(text("SELECT recurrence_rule FROM events LIMIT 1"))
                    logger.debug("recurrence_rule column already exists")
                except Exception:
                    logger.info("Adding recurrence_rule column to events table...")
                    db.execute(text("ALTER TABLE events ADD COLUMN recurrence_rule VARCHAR(255) NULL"))
                    db.commit()
                    logger.info("Successfully added recurrence_rule column")
                
                # Check and add recurrence_end column
                try:
                    db.execute(text("SELECT recurrence_end FROM events LIMIT 1"))
                    logger.debug("recurrence_end column already exists")
                except Exception:
                    logger.info("Adding recurrence_end column to events table...")
                    db.execute(text("ALTER TABLE events ADD COLUMN recurrence_end TIMESTAMP NULL"))
                    db.commit()
                    logger.info("Successfully added recurrence_end column")
                
                # Check and add parent_event_id column
                try:
                    db.execute(text("SELECT parent_event_id FROM events LIMIT 1"))
                    logger.debug("parent_event_id column already exists")
                except Exception:
                    logger.info("Adding parent_event_id column to events table...")
                    db.execute(text("ALTER TABLE events ADD COLUMN parent_event_id INTEGER NULL"))
                    # SQLite doesn't support adding foreign key constraints via ALTER TABLE
                    # The constraint will be enforced by SQLAlchemy
                    db.commit()
                    logger.info("Successfully added parent_event_id column")
            else:
                logger.debug("events table does not exist yet, will be created by init_db()")
            
            # 检查 conversations 表是否存在
            result = db.execute(text("""
                SELECT name FROM sqlite_master 
                WHERE type='table' AND name='conversations'
            """))
            table_exists = result.scalar() is not None
            
            if not table_exists:
                logger.info("Creating conversations table...")
                from models import Conversation
                from database import Base
                Base.metadata.create_all(bind=engine, tables=[Conversation.__table__])
                logger.info("Successfully created conversations table")
            else:
                logger.debug("conversations table already exists")
            
    except Exception as e:
        logger.error(f"Migration error: {e}", exc_info=True)
        db.rollback()
        raise
    finally:
        db.close()


def main():
    """主函数"""
    print("[MIGRATE] Starting database migration...")
    try:
        migrate_events_table()
        print("[OK] Database migration completed successfully")
    except Exception as e:
        print(f"[ERROR] Migration failed: {e}")
        raise


if __name__ == "__main__":
    main()
