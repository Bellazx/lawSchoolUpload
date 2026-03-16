"""
后端配置文件
请根据实际环境修改以下配置项
"""
import os

# 数据库配置
SQLSERVER_HOST = os.getenv('DB_HOST', '10.119.13.123')
SQLSERVER_PORT = int(os.getenv('DB_PORT', 1433))
SQLSERVER_USER = os.getenv('DB_USER', 'dzx')
SQLSERVER_PASSWORD = os.getenv('DB_PASSWORD', 'dzx950829')
SQLSERVER_DATABASE = os.getenv('DB_NAME', 'readerDB')

# API配置（外部接口）
API_URL = os.getenv('API_URL', 'http://10.119.4.239/docaffiresinterface')
API_USERCODE = os.getenv('API_USERCODE', 'dingzixuan')
API_PWD = os.getenv('API_PWD', 'F3F8828238A7F0DDD445FE58BAF94AB3')
API_KEY = os.getenv('API_KEY', 'sjtulibt')

# 授权用户列表（根据实际需要修改）
AUTHORIZED_USERS = os.getenv('AUTHORIZED_USERS', '08212,64900').split(',')

# Session密钥（建议修改为复杂的随机字符串）
# 可以使用以下命令生成：python3 -c "import secrets; print(secrets.token_hex(32))"
SECRET_KEY = os.getenv('SECRET_KEY', 'ad67fa23cf0f0537c2e2baa785f7ba57d5941958855052d96019439efa03f2a6')
# 上传文件配置
UPLOAD_FOLDER = os.path.join(os.path.dirname(__file__), 'uploads')
MAX_CONTENT_LENGTH = 50 * 1024 * 1024  # 50MB

# Flask配置基类
class Config:
    """配置基类"""
    SECRET_KEY = os.getenv('SECRET_KEY', '请修改为一个复杂的随机字符串')
    UPLOAD_FOLDER = os.path.join(os.path.dirname(__file__), 'uploads')
    MAX_CONTENT_LENGTH = 50 * 1024 * 1024  # 50MB
    
    # SQLAlchemy配置 - 使用 pyodbc 连接 SQL Server
    # 优先尝试 ODBC Driver 17，如果不可用则使用 FreeTDS
    import subprocess
    try:
        # 检查 ODBC Driver 17 是否可用
        result = subprocess.run(['odbcinst', '-q', '-d'], capture_output=True, text=True, timeout=2)
        if 'ODBC Driver 17 for SQL Server' in result.stdout:
            driver = 'ODBC+Driver+17+for+SQL+Server'
        else:
            driver = 'FreeTDS'
    except:
        driver = 'FreeTDS'
    
    SQLALCHEMY_DATABASE_URI = (
        f"mssql+pyodbc://{SQLSERVER_USER}:{SQLSERVER_PASSWORD}@"
        f"{SQLSERVER_HOST}:{SQLSERVER_PORT}/{SQLSERVER_DATABASE}?"
        f"driver={driver}&"
        f"TrustServerCertificate=yes"
    )
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    SQLALCHEMY_ENGINE_OPTIONS = {
        'pool_pre_ping': True,
        'pool_recycle': 3600,
    }
    
    # API配置
    API_URL = API_URL
    API_USERCODE = API_USERCODE
    API_PWD = API_PWD
    API_KEY = API_KEY
    
    # 授权用户列表
    AUTHORIZED_USERS = AUTHORIZED_USERS

class DevelopmentConfig(Config):
    """开发环境配置"""
    DEBUG = True
    FLASK_ENV = 'development'

class ProductionConfig(Config):
    """生产环境配置"""
    DEBUG = False
    FLASK_ENV = 'production'

# 配置字典
config = {
    'development': DevelopmentConfig,
    'production': ProductionConfig,
    'default': DevelopmentConfig
}

