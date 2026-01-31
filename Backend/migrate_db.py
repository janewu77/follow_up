"""
数据库迁移脚本 - 添加缺失的列

用于修复旧数据库表结构，添加新字段。
"""
from sqlalchemy import text
from database import engine, SessionLocal
from logging_config import get_logger

logger = get_logger(__name__)


def migrate_events_table():
    """
    迁移 events 表，添加缺失的列
    
    这个函数是幂等的，可以安全地多次运行。
    如果列已存在，不会重复添加。
    """
    db = SessionLocal()
    try:
        # 检查 events 表是否存在
        result = db.execute(text("""
            SELECT name FROM sqlite_master 
            WHERE type='table' AND name='events'
        """))
        events_table_exists = result.scalar() is not None
        
        if events_table_exists:
            # 检查 source_thumbnail 列是否存在（通过尝试查询来判断）
            try:
                db.execute(text("SELECT source_thumbnail FROM events LIMIT 1"))
                logger.debug("source_thumbnail column already exists")
            except Exception:
                # 列不存在，需要添加
                logger.info("Adding source_thumbnail column to events table...")
                db.execute(text("""
                    ALTER TABLE events 
                    ADD COLUMN source_thumbnail TEXT NULL
                """))
                db.commit()
                logger.info("Successfully added source_thumbnail column")
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
