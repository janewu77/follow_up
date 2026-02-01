// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'FollowUP';

  @override
  String get login => '登录';

  @override
  String get loginToContinue => '登录以继续';

  @override
  String get loggingIn => '登录中...';

  @override
  String get username => '用户名';

  @override
  String get enterUsername => '请输入用户名';

  @override
  String get password => '密码';

  @override
  String get enterPassword => '请输入密码';

  @override
  String get backToHome => '返回首页';

  @override
  String get testAccount => '测试账号:';

  @override
  String get testAccountAlice => '用户名: alice / 密码: alice123';

  @override
  String get testAccountDemo => '用户名: demo / 密码: demo123';

  @override
  String get home => '首页';

  @override
  String get add => '添加';

  @override
  String get events => '活动';

  @override
  String get logout => '退出登录';

  @override
  String get confirmLogout => '退出登录';

  @override
  String get confirmLogoutMessage => '确定要退出登录吗？';

  @override
  String welcomeBack(String username) {
    return '欢迎回来，$username';
  }

  @override
  String get addEventPrompt => '今天有什么新的活动要添加吗？';

  @override
  String get textRecognition => '文字识别';

  @override
  String get inputDescription => '输入活动描述';

  @override
  String get imageRecognition => '图片识别';

  @override
  String get photoOrUpload => '拍照或上传';

  @override
  String get followedEvents => '关注的活动';

  @override
  String get viewAll => '查看全部';

  @override
  String get noFollowedEvents => '还没有关注的活动';

  @override
  String get addEvent => '添加活动';

  @override
  String get addActivity => '添加活动';

  @override
  String get pasteDescription => '粘贴活动描述，AI 将自动识别时间、地点等信息';

  @override
  String get eventDescription => '活动描述';

  @override
  String get eventDescriptionHint => '例如：下周六晚上7点，汉堡爱乐音乐厅有一场贝多芬音乐会...';

  @override
  String get additionalNote => '补充说明（可选）';

  @override
  String get uploadPoster => '上传活动海报或传单，AI 将自动识别活动信息';

  @override
  String get eventImage => '活动图片';

  @override
  String get recognizeSchedule => '识别日程';

  @override
  String get aiRecognizing => 'AI 正在识别活动信息...';

  @override
  String get schedulePreview => '日程预览';

  @override
  String get editActivity => '编辑活动';

  @override
  String get confirmActivity => '确认活动';

  @override
  String get eventTitle => '活动标题';

  @override
  String get enterEventTitle => '请输入活动标题';

  @override
  String get startTime => '开始时间';

  @override
  String get endTime => '结束时间';

  @override
  String get selectDate => '选择日期';

  @override
  String get selectTime => '选择时间';

  @override
  String get location => '地点';

  @override
  String get eventLocation => '活动地点';

  @override
  String get description => '描述';

  @override
  String get eventDescriptionField => '活动描述...';

  @override
  String get downloadIcs => '下载 ICS';

  @override
  String get saveActivity => '保存活动';

  @override
  String get saving => '保存中...';

  @override
  String get activitySaved => '活动已保存';

  @override
  String multipleEventsDetected(int count) {
    return '识别到 $count 个活动，可左右滑动切换';
  }

  @override
  String get eventList => '活动列表';

  @override
  String get allEvents => '全部活动';

  @override
  String get followed => '已关注';

  @override
  String get noEvents => '还没有活动';

  @override
  String get noFollowedEventsYet => '还没有关注的活动';

  @override
  String get deleteEvent => '删除活动';

  @override
  String get deleteEventConfirm => '确定要删除这个活动吗？此操作不可撤销。';

  @override
  String get delete => '删除';

  @override
  String get cancel => '取消';

  @override
  String get eventDeleted => '活动已删除';

  @override
  String get icsDownloaded => 'ICS 文件已下载';

  @override
  String get downloadFailed => '下载失败';

  @override
  String get fileSaved => '文件已保存';

  @override
  String get pleaseEnterEventDescription => '请输入活动描述';

  @override
  String get pleaseSelectImage => '请选择图片';

  @override
  String get pleaseEnterEventTitle => '请输入活动标题';

  @override
  String get pleaseSelectStartDate => '请选择开始日期';

  @override
  String get landingHeroTitle => '再也不会错过任何活动';

  @override
  String get landingHeroSubtitle =>
      'FollowUP 是您的智能个人助手，帮助您追踪活动。从文字或图片中自动提取活动信息，同步到日历，并获得及时提醒。';

  @override
  String get getStarted => '开始使用';

  @override
  String get learnMore => '了解更多';

  @override
  String get painPointsTitle => '您是否也遇到过这些问题？';

  @override
  String get painPoint1Title => '信息分散';

  @override
  String get painPoint1Desc => '活动信息散落在邮件、聊天和社交媒体中，难以追踪';

  @override
  String get painPoint2Title => '手动输入繁琐';

  @override
  String get painPoint2Desc => '手动将活动输入日历既耗时又容易出错';

  @override
  String get painPoint3Title => '容易遗忘';

  @override
  String get painPoint3Desc => '因为没有及时提醒而错过重要活动';

  @override
  String get howItWorksTitle => '工作原理';

  @override
  String get step1Title => '捕获信息';

  @override
  String get step1Desc => '粘贴文字或上传活动海报/截图';

  @override
  String get step2Title => 'AI 识别';

  @override
  String get step2Desc => '智能提取时间、地点等关键信息';

  @override
  String get step3Title => '一键保存';

  @override
  String get step3Desc => '确认并添加到日历，设置提醒';

  @override
  String get featuresTitle => '核心功能';

  @override
  String get feature1Title => '文字识别';

  @override
  String get feature1Desc => '粘贴活动描述，让 AI 提取信息';

  @override
  String get feature2Title => '图片识别';

  @override
  String get feature2Desc => '上传活动海报或截图，自动解析';

  @override
  String get feature3Title => '日历同步';

  @override
  String get feature3Desc => '导出 ICS 格式，与任何日历应用同步';

  @override
  String get feature4Title => '关注活动';

  @override
  String get feature4Desc => '关注重要活动，获得及时提醒';

  @override
  String get demoTitle => '查看演示';

  @override
  String get demoDesc => '观看 FollowUP 如何将杂乱的活动信息转化为有序的日历条目';

  @override
  String get tryNow => '立即试用';

  @override
  String get pricingTitle => '简单透明的定价';

  @override
  String get pricingFree => '免费版';

  @override
  String get pricingFreePriceDesc => '个人使用';

  @override
  String get pricingFreeFeature1 => '每月10个活动';

  @override
  String get pricingFreeFeature2 => '文字识别';

  @override
  String get pricingFreeFeature3 => '基础日历导出';

  @override
  String get pricingPro => '专业版';

  @override
  String get pricingProPrice => '¥35';

  @override
  String get pricingProPriceDesc => '/月';

  @override
  String get pricingProFeature1 => '无限活动';

  @override
  String get pricingProFeature2 => '图片识别';

  @override
  String get pricingProFeature3 => '优先 AI 处理';

  @override
  String get pricingProFeature4 => '高级提醒';

  @override
  String get mostPopular => '最受欢迎';

  @override
  String get startFreeTrial => '开始免费试用';

  @override
  String get pricingTeam => '团队版';

  @override
  String get pricingTeamPrice => '¥139';

  @override
  String get pricingTeamPriceDesc => '/月';

  @override
  String get pricingTeamFeature1 => '包含专业版全部功能';

  @override
  String get pricingTeamFeature2 => '团队协作';

  @override
  String get pricingTeamFeature3 => '共享日历';

  @override
  String get pricingTeamFeature4 => '管理员控制台';

  @override
  String get contactSales => '联系销售';

  @override
  String get faqTitle => '常见问题';

  @override
  String get faq1Question => 'FollowUP 可以识别哪些类型的活动？';

  @override
  String get faq1Answer =>
      'FollowUP 可以识别大多数活动格式，包括音乐会、会议、社交聚会等。它适用于正式和非正式的活动描述。';

  @override
  String get faq2Question => 'AI 识别的准确率如何？';

  @override
  String get faq2Answer => '我们的 AI 对标准活动格式的识别准确率达到 95% 以上。您可以在保存前随时查看和编辑提取的信息。';

  @override
  String get faq3Question => '可以与 Google 日历或 Apple 日历同步吗？';

  @override
  String get faq3Answer =>
      '可以！将活动导出为 ICS 文件，然后导入到任何日历应用，包括 Google 日历、Apple 日历、Outlook 等。';

  @override
  String get faq4Question => '我的数据安全吗？';

  @override
  String get faq4Answer => '绝对安全。我们使用行业标准加密，绝不与第三方共享您的数据。您的活动安全存储，只有您可以访问。';

  @override
  String get footerTagline => '您的智能活动助手';

  @override
  String get footerProduct => '产品';

  @override
  String get footerFeatures => '功能';

  @override
  String get footerPricing => '定价';

  @override
  String get footerCompany => '公司';

  @override
  String get footerAbout => '关于';

  @override
  String get footerContact => '联系我们';

  @override
  String get footerLegal => '法律';

  @override
  String get footerPrivacy => '隐私';

  @override
  String get footerTerms => '条款';

  @override
  String get footerCopyright => '© 2025 FollowUP. 保留所有权利。';

  @override
  String get signIn => '登录';

  @override
  String get or => '或';

  @override
  String get privacyFirst => '隐私优先';

  @override
  String get quickSetup => '30秒完成';

  @override
  String get freeToStart => '免费开始';

  @override
  String get painPointsSubtitle => '生活中的事件来得太快';

  @override
  String get painPointsDesc => '重要日期以截图、海报、消息或语音备忘的形式出现。\n手动添加到日历？既繁琐又容易遗忘。';

  @override
  String get painPointNeedSimpler => '你需要一个更简单的方式';

  @override
  String get painPointPhoto => '活动海报截图';

  @override
  String get painPointMessage => '消息中的日期';

  @override
  String get painPointFlyer => '传单和邀请函';

  @override
  String get painPointVoice => '语音备忘录';

  @override
  String get captureStep => '捕获';

  @override
  String get captureStepDesc => '拍照、输入或说话';

  @override
  String get understandStep => '理解';

  @override
  String get understandStepDesc => 'AI 智能处理';

  @override
  String get confirmStep => '确认';

  @override
  String get confirmStepDesc => '查看并编辑';

  @override
  String get doneStep => '完成';

  @override
  String get doneStepDesc => '添加到日历';

  @override
  String get featurePrivacyTitle => '隐私优先';

  @override
  String get featurePrivacyDesc => '无需强制注册账户，你的数据安全存储';

  @override
  String get featureSmartTitle => '智能识别';

  @override
  String get featureSmartDesc => 'AI 自动提取日期、时间、地点等关键信息';

  @override
  String get featureControlTitle => '完全掌控';

  @override
  String get featureControlDesc => '确认前可随时编辑和修改识别结果';

  @override
  String get featureFocusSubtitle => '减少心理负担，更专注生活';

  @override
  String get featureFocusDesc => 'FollowUP 悄悄管理你的日程，让你的心思专注于真正重要的事情';

  @override
  String get demoInputLabel => '输入';

  @override
  String get demoTextTab => '文字';

  @override
  String get demoImageTab => '图片';

  @override
  String get demoVoiceTab => '语音';

  @override
  String get demoInputPlaceholder => '输入包含事件信息的文字...';

  @override
  String get demoClickUpload => '点击上传图片';

  @override
  String get demoClickRecord => '点击开始录音';

  @override
  String get demoEventPreview => '事件预览';

  @override
  String get demoTeamDinner => '团队晚餐';

  @override
  String get demoRecognized => '已成功识别';

  @override
  String get demoNextFriday => '下周五 19:00';

  @override
  String get demoRestaurant => '主街橄榄园餐厅';

  @override
  String get demoBirthdayCard => '带 Sarah 的生日卡';

  @override
  String get demoExtractedEvent => '提取的事件将在这里显示';

  @override
  String get demoAddToCalendar => '添加到日历';

  @override
  String get theProblem => '问题所在';

  @override
  String get stillHaveQuestions => '还有疑问？';

  @override
  String get everythingYouNeed => '关于 FollowUP 你需要知道的一切';

  @override
  String get footerCTATitle => '准备好不再错过任何活动了吗？';

  @override
  String get footerCTASubtitle => '免费开始使用 FollowUP，让 AI 管理你的日程';

  @override
  String get footerDescription => '将生活中的瞬间转化为日历事件\n让你不再为记住事情而烦恼';

  @override
  String chatWelcome(String username) {
    return '你好 $username！👋 我是你的 FollowUP 助手。告诉我你想添加的活动，或者粘贴任何包含活动信息的文字。';
  }

  @override
  String get chatStartHint => '开始对话来添加活动';

  @override
  String get chatInputHint => '描述一个活动或粘贴文字...';

  @override
  String get chatProcessing => '我在你的消息中发现了活动信息！需要我提取详情并添加到日历吗？';

  @override
  String get chatExtractEvent => '提取活动';

  @override
  String get chatUploadImage => '上传图片';

  @override
  String get chatViewEvents => '我的活动';

  @override
  String get profile => '个人信息';

  @override
  String get accountInfo => '账户信息';

  @override
  String get userId => '用户 ID';

  @override
  String get registeredAt => '注册时间';

  @override
  String get quickActions => '快捷操作';

  @override
  String get serverConnection => '服务器连接';

  @override
  String get connected => '已连接';

  @override
  String get disconnected => '未连接';

  @override
  String get testing => '测试中...';

  @override
  String get unknown => '未知';

  @override
  String get myEvents => '我的日程';

  @override
  String get aiAssistant => 'AI 助手';

  @override
  String get loadFailed => '加载失败';

  @override
  String get retry => '重试';

  @override
  String get unableToGetUserInfo => '无法获取用户信息';

  @override
  String get sourceTypeImage => '图片';

  @override
  String get sourceTypeText => '文本';

  @override
  String get sourceImage => '来源图片';
}
