// API 配置文件
// 
// 使用方法:
// 1. 默认使用生产环境
// 2. 本地开发: flutter run --dart-define=ENV=dev
// 3. 自定义 URL: flutter run --dart-define=API_BASE_URL=http://your-api.com
//
class ApiConfig {
  // 从环境变量读取配置
  static const String _env = String.fromEnvironment('ENV', defaultValue: 'prod');
  static const String _customBaseUrl = String.fromEnvironment('API_BASE_URL');
  
  // 预定义的环境地址
  static const String _devUrl = "http://localhost:8000";
  static const String _prodUrl = "https://web-production-d2e00.up.railway.app";
  
  // 根据环境自动选择 API 地址
  static String get baseUrl {
    // 如果指定了自定义 URL，优先使用
    if (_customBaseUrl.isNotEmpty) {
      return _customBaseUrl;
    }
    // 否则根据环境选择
    return _env == 'dev' ? _devUrl : _prodUrl;
  }
  
  // 当前环境
  static String get environment => _env;
  
  // 是否为开发环境
  static bool get isDev => _env == 'dev';
  
  // 是否为生产环境
  static bool get isProd => _env == 'prod';
  
  // API 超时设置
  static const Duration timeout = Duration(seconds: 30);
}
