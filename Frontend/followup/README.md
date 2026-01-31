# FollowUP - 智能日程管理应用

FollowUP 是一款基于 Flutter 开发的跨平台日程管理应用，通过 AI 技术智能识别图片和文字中的活动信息，帮助用户轻松管理日程安排。

## 功能特性

- **图片识别** - 拍摄或上传活动海报、传单，AI 自动提取活动信息
- **文字解析** - 粘贴活动描述文字，智能识别日期、地点、标题等关键信息
- **日历同步** - 一键导出 ICS 文件，同步到 Apple Calendar、Google Calendar 等日历应用
- **活动关注** - 关注感兴趣的活动，方便快速查看和管理
- **响应式设计** - 支持手机和桌面端，自适应不同屏幕尺寸
- **深色模式** - 支持系统级深色/浅色模式切换

## 技术栈

- **框架**: Flutter 3.10+
- **状态管理**: Provider
- **网络请求**: http
- **本地存储**: shared_preferences
- **图片处理**: image_picker
- **日期格式化**: intl

## 项目结构

```
lib/
├── main.dart              # 应用入口
├── config.dart            # API 配置
├── models/                # 数据模型
│   ├── event.dart         # 活动/日程模型
│   └── user.dart          # 用户模型
├── pages/                 # 页面
│   ├── landing_page.dart  # 产品介绍首页
│   ├── login_page.dart    # 登录页面
│   ├── home_page.dart     # 主页
│   ├── input_page.dart    # 输入页面（文字/图片识别）
│   ├── preview_page.dart  # 预览确认页面
│   └── events_page.dart   # 活动列表页面
├── providers/             # 状态管理
│   ├── auth_provider.dart # 认证状态
│   └── events_provider.dart # 活动状态
├── services/              # 服务层
│   ├── api_service.dart   # API 请求封装
│   ├── auth_service.dart  # 认证服务
│   └── mock_service.dart  # Mock 数据服务
├── utils/                 # 工具类
│   ├── date_formatter.dart # 日期格式化
│   └── validators.dart    # 表单验证
└── widgets/               # 可复用组件
    ├── error_dialog.dart  # 错误对话框
    ├── event_card.dart    # 活动卡片
    ├── image_picker_widget.dart # 图片选择器
    ├── input_area.dart    # 输入区域
    └── loading_overlay.dart # 加载遮罩
```

## 环境要求

- Flutter SDK >= 3.10.4
- Dart SDK >= 3.0.0
- iOS: Xcode 14.0+
- Android: Android Studio / Gradle 8.0+
- Web: Chrome 浏览器

## 快速开始

### 1. 安装依赖

```bash
cd Frontend/followup
flutter pub get
```

### 2. 配置后端地址

项目支持通过环境变量配置 API 地址，无需修改代码即可切换环境。

#### 环境配置方式

| 场景 | 命令 |
|------|------|
| 生产环境（默认） | `flutter run -d chrome` |
| 本地开发 | `flutter run -d chrome --dart-define=ENV=dev` |
| 自定义 URL | `flutter run -d chrome --dart-define=API_BASE_URL=http://your-api.com` |

#### 预设环境

- **生产环境** (`ENV=prod`，默认): `https://web-production-d2e00.up.railway.app`
- **开发环境** (`ENV=dev`): `http://localhost:8000`

#### 代码中使用

```dart
import 'config.dart';

// 获取当前 API 地址
String url = ApiConfig.baseUrl;

// 判断当前环境
if (ApiConfig.isDev) {
  print('开发环境');
}

if (ApiConfig.isProd) {
  print('生产环境');
}
```

### 3. 切换 Mock 模式

开发时可使用 Mock 数据，编辑 `lib/services/api_service.dart`：

```dart
class ApiService {
  // 是否使用 Mock 数据（开发时设为 true）
  static bool useMock = true;  // 生产环境设为 false
}
```

### 4. 运行应用

```bash
# 运行 Web 版本
flutter run -d chrome

# 运行 iOS 版本（需要 macOS）
flutter run -d ios

# 运行 Android 版本
flutter run -d android

# 运行桌面版本（macOS）
flutter run -d macos
```

## 构建发布

### Web 版本

```bash
# 生产环境构建（默认）
flutter build web --release

# 开发环境构建
flutter build web --release --dart-define=ENV=dev

# 自定义后端地址构建
flutter build web --release --dart-define=API_BASE_URL=https://your-custom-api.com
```

构建产物位于 `build/web/` 目录。

### iOS 版本

```bash
# 生产环境
flutter build ios --release

# 开发环境
flutter build ios --release --dart-define=ENV=dev
```

### Android 版本

```bash
# 生产环境
flutter build apk --release

# 开发环境
flutter build apk --release --dart-define=ENV=dev

# 或构建 App Bundle
flutter build appbundle --release
```

## 部署

### Vercel 部署

项目已配置 `vercel.json` 支持 Vercel 部署：

1. 构建 Web 版本
2. 将 `build/web/` 目录部署到 Vercel

### 自定义服务器部署

将 `build/web/` 目录下的文件部署到任意静态文件服务器（如 Nginx、Apache）。

## API 接口

应用通过 REST API 与后端通信，主要接口包括：

| 接口 | 方法 | 描述 |
|------|------|------|
| `/api/auth/login` | POST | 用户登录 |
| `/api/parse` | POST | 解析活动信息（文字/图片） |
| `/api/events` | GET | 获取活动列表 |
| `/api/events` | POST | 创建活动 |
| `/api/events/{id}` | DELETE | 删除活动 |
| `/api/events/{id}/follow` | PATCH | 切换关注状态 |
| `/api/events/{id}/ics` | GET | 下载 ICS 日历文件 |

## 路由结构

| 路由 | 页面 | 描述 |
|------|------|------|
| `/` | LandingPage | 产品介绍首页 |
| `/login` | LoginPage | 登录页面 |
| `/home` | HomePage | 主页（需登录） |
| `/input` | InputPage | 输入页面 |
| `/preview` | PreviewPage | 预览确认页面 |
| `/events` | EventsPage | 活动列表页面 |

## 使用流程

1. **首页浏览** - 用户访问产品介绍页面，了解产品功能
2. **登录注册** - 用户登录账号（支持测试账号：test/test123）
3. **添加活动** - 选择文字或图片方式输入活动信息
4. **AI 识别** - 系统自动识别并提取活动详情
5. **预览确认** - 用户查看并编辑识别结果
6. **保存同步** - 保存活动并可导出 ICS 文件到日历

## 开发说明

### 添加新页面

1. 在 `lib/pages/` 创建新页面文件
2. 在 `lib/main.dart` 的 `onGenerateRoute` 中添加路由

### 添加新状态

1. 在 `lib/providers/` 创建新的 Provider
2. 在 `lib/main.dart` 的 `MultiProvider` 中注册

### 代码规范

项目使用 `flutter_lints` 进行代码检查，运行：

```bash
flutter analyze
```

## 许可证

© 2026 FollowUP. Made with AI.
