import 'package:flutter/material.dart';

// Landing Page - 产品介绍首页 (参照 v0 设计，优化视觉效果)
class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _BrandColors.gradientStart,
      body: Stack(
        children: [
          // 全局温暖背景
          const _WarmBackground(),
          // 内容
          SingleChildScrollView(
            child: Column(
              children: [
                // Navigation Bar
                const _NavBar(),
                // Hero Section
                const _HeroSection(),
                // Pain Points Section
                const _PainPointsSection(),
                // How It Works Section
                const _HowItWorksSection(),
                // Features Section (新增特色功能区)
                const _FeaturesSection(),
                // Demo Section
                const _DemoSection(),
                // Pricing Section
                const _PricingSection(),
                // FAQ Section
                const _FAQSection(),
                // Footer
                const _Footer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 温暖的全局背景
class _WarmBackground extends StatelessWidget {
  const _WarmBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFDF8F3), // 温暖的奶油色
            Color(0xFFFAF5EF), // 稍深的米色
            Color(0xFFF5EDE3), // 更深的暖色
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // 右上角装饰圆
          Positioned(
            top: -150,
            right: -150,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFE8DDD0).withValues(alpha: 0.6),
                    const Color(0xFFE8DDD0).withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          // 左侧装饰圆
          Positioned(
            top: 300,
            left: -200,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFD4E8E4).withValues(alpha: 0.4),
                    const Color(0xFFD4E8E4).withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          // 右下装饰圆
          Positioned(
            bottom: 200,
            right: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFE5D9C9).withValues(alpha: 0.5),
                    const Color(0xFFE5D9C9).withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          // 中间偏左的小装饰圆
          Positioned(
            top: 800,
            left: 100,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFD0E0DC).withValues(alpha: 0.3),
                    const Color(0xFFD0E0DC).withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 品牌色彩常量 - 参考 v0 设计
// Style: Warm & Professional | Colors: Deep Teal + Warm Cream
class _BrandColors {
  // 深青绿主色调 - 专业、可信赖
  static const Color primary = Color(0xFF115E59);       // Teal-800
  static const Color primaryLight = Color(0xFF0F766E); // Teal-700
  static const Color primaryDark = Color(0xFF134E4A);  // Teal-900
  
  // CTA 使用与主色相同 (深青绿)
  static const Color accent = Color(0xFF14B8A6);       // Teal-500 for accents
  static const Color cta = Color(0xFF115E59);          // Deep Teal for CTAs
  static const Color ctaDark = Color(0xFF134E4A);      // Teal-900
  
  // 状态色
  static const Color success = Color(0xFF115E59);      // Teal (与主色一致)
  static const Color warning = Color(0xFFF59E0B);      // Amber-500
  static const Color info = Color(0xFF0D9488);         // Teal-600
  
  // 温暖的米色/奶油色背景
  static const Color gradientStart = Color(0xFFFDF8F3); // Warm Cream
  static const Color gradientEnd = Color(0xFFFAF5EF);   // Light Cream
  static const Color surfaceLight = Color(0xFFFEFCFA);  // Off-white
  static const Color cardBg = Color(0xFFFFFDF9);        // Card background
  
  // 文字色
  static const Color textPrimary = Color(0xFF1F2937);   // Gray-800
  static const Color textSecondary = Color(0xFF6B7280); // Gray-500
}

// 导航栏 - 浮动毛玻璃效果
class _NavBar extends StatelessWidget {
  const _NavBar();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 800;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
        horizontal: isWide ? 40 : 16,
        vertical: 16,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 32 : 20,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: _BrandColors.primary.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_BrandColors.primary, _BrandColors.accent],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.calendar_today_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'FollowUP',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _BrandColors.primary,
                ),
              ),
            ],
          ),
          // Navigation Links
          if (isWide)
            Row(
              children: [
                _NavLink(label: '使用流程', onTap: () {}),
                const SizedBox(width: 8),
                _NavLink(label: '功能特点', onTap: () {}),
                const SizedBox(width: 8),
                _NavLink(label: '价格方案', onTap: () {}),
                const SizedBox(width: 24),
                Container(
                  decoration: BoxDecoration(
                    color: _BrandColors.primary,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.pushNamed(context, '/login'),
                      borderRadius: BorderRadius.circular(24),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: Text(
                          'Get Started',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            IconButton(
              icon: const Icon(Icons.menu_rounded),
              onPressed: () => _showMobileMenu(context),
            ),
        ],
      ),
    );
  }

  void _showMobileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            _MobileMenuItem(
              icon: Icons.play_circle_outline,
              label: '使用流程',
              onTap: () => Navigator.pop(context),
            ),
            _MobileMenuItem(
              icon: Icons.star_outline,
              label: '功能特点',
              onTap: () => Navigator.pop(context),
            ),
            _MobileMenuItem(
              icon: Icons.diamond_outlined,
              label: '价格方案',
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  color: _BrandColors.primary,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/login');
                    },
                    borderRadius: BorderRadius.circular(24),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Text(
                          'Get Started',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _MobileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MobileMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _BrandColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: _BrandColors.primary, size: 20),
      ),
      title: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

class _NavLink extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _NavLink({required this.label, required this.onTap});

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: _isHovered 
                ? _BrandColors.primary.withValues(alpha: 0.08) 
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              color: _isHovered 
                  ? _BrandColors.primary 
                  : Theme.of(context).colorScheme.onSurface,
              fontWeight: _isHovered ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

// Hero 区域 - 现代渐变背景
class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 900;

    return Container(
      width: double.infinity,
      // 背景由全局 _WarmBackground 提供
      child: Stack(
        children: [
          // 主要内容
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? 80 : 24,
              vertical: isWide ? 80 : 48,
            ),
            child: isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: _HeroContent(isWide: isWide),
                      ),
                      const SizedBox(width: 64),
                      Expanded(
                        child: _HeroImage(),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      _HeroContent(isWide: isWide),
                      const SizedBox(height: 48),
                      _HeroImage(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _HeroContent extends StatelessWidget {
  final bool isWide;

  const _HeroContent({required this.isWide});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: isWide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        // AI 标签
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _BrandColors.primary.withValues(alpha: 0.15),
                _BrandColors.accent.withValues(alpha: 0.15),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _BrandColors.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: _BrandColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 12),
              ),
              const SizedBox(width: 8),
              const Text(
                '你的 AI 日历助手',
                style: TextStyle(
                  color: _BrandColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        // 主标题 - Teal 渐变
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [_BrandColors.textPrimary, _BrandColors.primary, _BrandColors.primaryLight],
          ).createShader(bounds),
          child: Text(
            '不再错过\n每一个重要时刻',
            textAlign: isWide ? TextAlign.left : TextAlign.center,
            style: (isWide ? theme.textTheme.displaySmall : theme.textTheme.headlineLarge)?.copyWith(
              fontWeight: FontWeight.w900,
              height: 1.15,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(height: 20),
        // 副标题
        Text(
          'FollowUP 将照片、文字或语音转换为日历事件，\n让你不再为日程烦恼，专注于真正重要的事情。',
          textAlign: isWide ? TextAlign.left : TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.7,
            fontSize: 17,
          ),
        ),
        const SizedBox(height: 36),
        // CTA 按钮组 - Deep Teal
        Wrap(
          spacing: 16,
          runSpacing: 12,
          alignment: isWide ? WrapAlignment.start : WrapAlignment.center,
          children: [
            // 主按钮 - 深青绿实心
            Container(
              decoration: BoxDecoration(
                color: _BrandColors.primary,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.pushNamed(context, '/login'),
                  borderRadius: BorderRadius.circular(24),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                    child: Text(
                      'Try the Demo',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // 次按钮 - 透明边框
            Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _BrandColors.primary,
                  width: 1.5,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(24),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                    child: Text(
                      'See how it works',
                      style: TextStyle(
                        color: _BrandColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        // 信任指标
        Wrap(
          spacing: 24,
          runSpacing: 12,
          alignment: isWide ? WrapAlignment.start : WrapAlignment.center,
          children: [
            _TrustBadge(icon: Icons.lock_outline, text: '隐私优先'),
            _TrustBadge(icon: Icons.flash_on, text: '30秒完成'),
            _TrustBadge(icon: Icons.credit_card_off_outlined, text: '免费开始'),
          ],
        ),
      ],
    );
  }
}

class _TrustBadge extends StatelessWidget {
  final IconData icon;
  final String text;

  const _TrustBadge({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: _BrandColors.success),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _HeroImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      constraints: const BoxConstraints(maxWidth: 480),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: _BrandColors.primary.withValues(alpha: 0.15),
            blurRadius: 60,
            offset: const Offset(0, 30),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            children: [
              // 输入类型选择
              Row(
                children: [
                  _InputTypeChip(icon: Icons.photo_outlined, label: '图片', isSelected: true),
                  const SizedBox(width: 10),
                  _InputTypeChip(icon: Icons.text_fields, label: '文字', isSelected: false),
                  const SizedBox(width: 10),
                  _InputTypeChip(icon: Icons.mic_none, label: '语音', isSelected: false),
                ],
              ),
              const SizedBox(height: 24),
              // 事件预览卡片
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _BrandColors.primary.withValues(alpha: 0.08),
                      _BrandColors.accent.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _BrandColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _BrandColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.event, color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '团队晚餐',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '下周五',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: _BrandColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _BrandColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '已识别',
                            style: TextStyle(
                              color: _BrandColors.success,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _EventDetailRow(icon: Icons.access_time, text: '19:00 - 21:00'),
                    const SizedBox(height: 10),
                    _EventDetailRow(icon: Icons.location_on_outlined, text: '橄榄园餐厅 · 主街店'),
                    const SizedBox(height: 10),
                    _EventDetailRow(icon: Icons.note_outlined, text: '记得带 Sarah 的生日卡'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // 添加按钮 - Deep Teal
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _BrandColors.primary,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(24),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_today_rounded, color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Add to Calendar',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InputTypeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;

  const _InputTypeChip({
    required this.icon,
    required this.label,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: isSelected
            ? const LinearGradient(
                colors: [_BrandColors.primary, _BrandColors.primaryDark],
              )
            : null,
        color: isSelected ? null : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : Colors.grey[600],
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[600],
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _EventDetailRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _EventDetailRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[500]),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}

// 痛点区域
class _PainPointsSection extends StatelessWidget {
  const _PainPointsSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 800;

    final painPoints = [
      _PainPoint(icon: Icons.photo_library_outlined, title: '活动海报截图', color: const Color(0xFFEC4899)),
      _PainPoint(icon: Icons.chat_bubble_outline, title: '消息中的日期', color: const Color(0xFFF59E0B)),
      _PainPoint(icon: Icons.insert_invitation_outlined, title: '传单和邀请函', color: const Color(0xFF8B5CF6)),
      _PainPoint(icon: Icons.record_voice_over_outlined, title: '语音备忘录', color: const Color(0xFF06B6D4)),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 80 : 24,
        vertical: 80,
      ),
      child: Column(
        children: [
          // 标题
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _BrandColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Text(
              '问题所在',
              style: TextStyle(
                color: _BrandColors.warning,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '生活中的事件来得太快',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Text(
              '重要日期以截图、海报、消息或语音备忘的形式出现。\n手动添加到日历？既繁琐又容易遗忘。',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.7,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 48),
          // 痛点卡片网格
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: painPoints.map((p) => _PainPointCard(painPoint: p, isWide: isWide)).toList(),
          ),
          const SizedBox(height: 48),
          // 解决方案提示
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _BrandColors.primary.withValues(alpha: 0.1),
                  _BrandColors.accent.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: _BrandColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: _BrandColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lightbulb_outline, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 12),
                Text(
                  '你需要一个更简单的方式',
                  style: TextStyle(
                    color: _BrandColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PainPoint {
  final IconData icon;
  final String title;
  final Color color;

  _PainPoint({required this.icon, required this.title, required this.color});
}

class _PainPointCard extends StatefulWidget {
  final _PainPoint painPoint;
  final bool isWide;

  const _PainPointCard({required this.painPoint, required this.isWide});

  @override
  State<_PainPointCard> createState() => _PainPointCardState();
}

class _PainPointCardState extends State<_PainPointCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: widget.isWide ? 180 : (MediaQuery.of(context).size.width - 68) / 2,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _isHovered 
              ? widget.painPoint.color.withValues(alpha: 0.08)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isHovered 
                ? widget.painPoint.color.withValues(alpha: 0.3)
                : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: widget.painPoint.color.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: widget.painPoint.color.withValues(alpha: _isHovered ? 0.15 : 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                widget.painPoint.icon,
                size: 28,
                color: widget.painPoint.color,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.painPoint.title,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: _isHovered ? widget.painPoint.color : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 使用流程区域
class _HowItWorksSection extends StatelessWidget {
  const _HowItWorksSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 900;

    final steps = [
      _Step(number: '1', title: '捕获', description: '拍照、输入或说话', icon: Icons.camera_alt_outlined, color: const Color(0xFF3B82F6)),
      _Step(number: '2', title: '理解', description: 'AI 智能处理', icon: Icons.psychology_outlined, color: const Color(0xFF8B5CF6)),
      _Step(number: '3', title: '确认', description: '查看并编辑', icon: Icons.check_circle_outline, color: const Color(0xFF10B981)),
      _Step(number: '4', title: '完成', description: '添加到日历', icon: Icons.event_available_outlined, color: const Color(0xFFEC4899)),
    ];

    return Container(
      width: double.infinity,
      // 透明背景，使用全局背景
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 80 : 24,
        vertical: 80,
      ),
      child: Column(
        children: [
          // 标题
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _BrandColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Text(
              '使用流程',
              style: TextStyle(
                color: _BrandColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '从捕获到日历的智能路径',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            '无需手动输入，无需担心遗忘，只需捕获即可',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 56),
          // 步骤展示
          isWide
              ? _buildWideSteps(steps, theme)
              : _buildNarrowSteps(steps, theme),
          const SizedBox(height: 56),
          // 底部标语 - 深青绿
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 20),
            decoration: BoxDecoration(
              color: _BrandColors.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bolt, color: Colors.white, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'From Capture to Calendar in under 30 seconds.',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Simple, secure, and seamless.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWideSteps(List<_Step> steps, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(steps.length * 2 - 1, (index) {
        if (index.isOdd) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Icon(
              Icons.arrow_forward_rounded,
              color: _BrandColors.primary.withValues(alpha: 0.4),
              size: 28,
            ),
          );
        }
        return _StepCard(step: steps[index ~/ 2]);
      }),
    );
  }

  Widget _buildNarrowSteps(List<_Step> steps, ThemeData theme) {
    return Column(
      children: List.generate(steps.length * 2 - 1, (index) {
        if (index.isOdd) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Icon(
              Icons.arrow_downward_rounded,
              color: _BrandColors.primary.withValues(alpha: 0.4),
              size: 24,
            ),
          );
        }
        return _StepCard(step: steps[index ~/ 2]);
      }),
    );
  }
}

class _Step {
  final String number;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  _Step({
    required this.number,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class _StepCard extends StatefulWidget {
  final _Step step;

  const _StepCard({required this.step});

  @override
  State<_StepCard> createState() => _StepCardState();
}

class _StepCardState extends State<_StepCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 160,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isHovered 
                ? widget.step.color.withValues(alpha: 0.3)
                : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered 
                  ? widget.step.color.withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: _isHovered ? 20 : 10,
              offset: Offset(0, _isHovered ? 10 : 4),
            ),
          ],
        ),
        transform: _isHovered 
            ? Matrix4.translationValues(0, -4, 0) 
            : Matrix4.identity(),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        widget.step.color,
                        widget.step.color.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: widget.step.color.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(widget.step.icon, color: Colors.white, size: 26),
                ),
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: widget.step.color, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        widget.step.number,
                        style: TextStyle(
                          color: widget.step.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              widget.step.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.step.description,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 特色功能区域 (新增)
class _FeaturesSection extends StatelessWidget {
  const _FeaturesSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 900;

    final features = [
      _Feature(
        icon: Icons.lock_outline,
        title: '隐私优先',
        description: '无需强制注册账户，你的数据安全存储',
        color: const Color(0xFF10B981),
      ),
      _Feature(
        icon: Icons.psychology_outlined,
        title: '智能识别',
        description: 'AI 自动提取日期、时间、地点等关键信息',
        color: _BrandColors.primary,
      ),
      _Feature(
        icon: Icons.tune,
        title: '完全掌控',
        description: '确认前可随时编辑和修改识别结果',
        color: const Color(0xFFF59E0B),
      ),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 80 : 24,
        vertical: 80,
      ),
      child: Column(
        children: [
          // 标题
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _BrandColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Text(
              '功能亮点',
              style: TextStyle(
                color: _BrandColors.success,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '减少心理负担，更专注生活',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Text(
              'FollowUP 悄悄管理你的日程，让你的心思专注于真正重要的事情',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 56),
          // 功能卡片
          isWide
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: features.map((f) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: _FeatureCard(feature: f),
                  )).toList(),
                )
              : Column(
                  children: features.map((f) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _FeatureCard(feature: f),
                  )).toList(),
                ),
        ],
      ),
    );
  }
}

class _Feature {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  _Feature({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}

class _FeatureCard extends StatefulWidget {
  final _Feature feature;

  const _FeatureCard({required this.feature});

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 900;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: isWide ? 280 : double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: _isHovered 
              ? widget.feature.color.withValues(alpha: 0.05)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _isHovered 
                ? widget.feature.color.withValues(alpha: 0.3)
                : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: widget.feature.color.withValues(alpha: 0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        transform: _isHovered 
            ? Matrix4.translationValues(0, -4, 0) 
            : Matrix4.identity(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: widget.feature.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                widget.feature.icon,
                size: 28,
                color: widget.feature.color,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.feature.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.feature.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 演示区域
class _DemoSection extends StatefulWidget {
  const _DemoSection();

  @override
  State<_DemoSection> createState() => _DemoSectionState();
}

class _DemoSectionState extends State<_DemoSection> {
  int _selectedTab = 0;
  final _textController = TextEditingController(
    text: '团队晚餐，下周五晚上7点，在主街的橄榄园餐厅。别忘了带 Sarah 的生日卡！',
  );
  bool _showResult = false;
  bool _isExtracting = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _extractEvent() async {
    setState(() => _isExtracting = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    setState(() {
      _isExtracting = false;
      _showResult = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 900;

    return Container(
      width: double.infinity,
      // 透明背景，使用全局背景
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 80 : 24,
        vertical: 80,
      ),
      child: Column(
        children: [
          // 标题
          const SizedBox.shrink(),
          const SizedBox(height: 20),
          Text(
            'Try it yourself',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'See how FollowUP transforms messy input into clean calendar events.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: _BrandColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          // 演示卡片
          Container(
            constraints: const BoxConstraints(maxWidth: 900),
            child: isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildInputSection(theme)),
                      const SizedBox(width: 24),
                      Expanded(child: _buildResultSection(theme)),
                    ],
                  )
                : Column(
                    children: [
                      _buildInputSection(theme),
                      const SizedBox(height: 24),
                      _buildResultSection(theme),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _BrandColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.edit_note, color: _BrandColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                '输入',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Tab 切换
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(child: _DemoTab(label: '文字', icon: Icons.text_fields, isSelected: _selectedTab == 0, onTap: () => setState(() => _selectedTab = 0))),
                Expanded(child: _DemoTab(label: '图片', icon: Icons.photo_outlined, isSelected: _selectedTab == 1, onTap: () => setState(() => _selectedTab = 1))),
                Expanded(child: _DemoTab(label: '语音', icon: Icons.mic_none, isSelected: _selectedTab == 2, onTap: () => setState(() => _selectedTab = 2))),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // 输入区域
          if (_selectedTab == 0)
            TextField(
              controller: _textController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: '输入包含事件信息的文字...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: _BrandColors.primary, width: 2),
                ),
              ),
            )
          else if (_selectedTab == 1)
            Container(
              height: 140,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey[200]!,
                  style: BorderStyle.solid,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _BrandColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add_photo_alternate_outlined, size: 32, color: _BrandColors.primary),
                    ),
                    const SizedBox(height: 12),
                    Text('点击上传图片', style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ),
            )
          else
            Container(
              height: 140,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _BrandColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.mic_outlined, size: 32, color: _BrandColors.primary),
                    ),
                    const SizedBox(height: 12),
                    Text('点击开始录音', style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                color: _BrandColors.primary,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _isExtracting ? null : _extractEvent,
                  borderRadius: BorderRadius.circular(24),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isExtracting)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        else
                          const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          _isExtracting ? 'Extracting...' : 'Extract Event',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _BrandColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.event_available, color: _BrandColors.success, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                '事件预览',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_showResult)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _BrandColors.primary.withValues(alpha: 0.08),
                    _BrandColors.accent.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _BrandColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _BrandColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.event, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '团队晚餐',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _BrandColors.success.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                '已成功识别',
                                style: TextStyle(
                                  color: _BrandColors.success,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _EventDetailRow(icon: Icons.access_time, text: '下周五 19:00'),
                  const SizedBox(height: 10),
                  _EventDetailRow(icon: Icons.location_on_outlined, text: '主街橄榄园餐厅'),
                  const SizedBox(height: 10),
                  _EventDetailRow(icon: Icons.note_outlined, text: '带 Sarah 的生日卡'),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: _BrandColors.primary,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {},
                        borderRadius: BorderRadius.circular(24),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.calendar_today_rounded, color: Colors.white, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Add to Calendar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              height: 220,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 48, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text(
                      '提取的事件将在这里显示',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DemoTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _DemoTab({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? _BrandColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 定价区域
class _PricingSection extends StatelessWidget {
  const _PricingSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 1000;

    return Container(
      width: double.infinity,
      // 透明背景，使用全局背景
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 80 : 24,
        vertical: 80,
      ),
      child: Column(
        children: [
          // 标题
          const SizedBox.shrink(),
          const SizedBox(height: 20),
          Text(
            'Simple, transparent pricing',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Start free, upgrade when you need more. No hidden fees, cancel anytime.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: _BrandColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 56),
          // 定价卡片
          isWide
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PricingCard(
                      title: 'Free',
                      subtitle: 'Perfect for trying out FollowUP',
                      price: '\$0',
                      period: '/month',
                      features: const [
                        '10 event captures per month',
                        'Text and photo input',
                        'ICS file export',
                        'Basic AI extraction',
                      ],
                      buttonText: 'Get Started',
                      isPopular: false,
                      onTap: () => Navigator.pushNamed(context, '/login'),
                    ),
                    const SizedBox(width: 24),
                    // Pro 卡片带 Most Popular 徽章
                    Column(
                      children: [
                        // Most Popular 徽章
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: _BrandColors.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Most Popular',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _PricingCard(
                          title: 'Pro',
                          subtitle: 'For individuals who want peace of mind',
                          price: '\$4.99',
                          period: '/month',
                          features: const [
                            'Unlimited event captures',
                            'Text, photo, and voice input',
                            'Direct calendar sync',
                            'Advanced AI with smart suggestions',
                            'Priority processing',
                            'Email reminders',
                          ],
                          buttonText: 'Start Free Trial',
                          isPopular: true,
                          onTap: () => Navigator.pushNamed(context, '/login'),
                        ),
                      ],
                    ),
                    const SizedBox(width: 24),
                    _PricingCard(
                      title: 'Family',
                      subtitle: 'Share calm with your loved ones',
                      price: '\$9.99',
                      period: '/month',
                      features: const [
                        'Everything in Pro',
                        'Up to 5 family members',
                        'Shared family calendar',
                        'Delegate event creation',
                        'Family activity insights',
                        'Priority support',
                      ],
                      buttonText: 'Start Free Trial',
                      isPopular: false,
                      onTap: () => Navigator.pushNamed(context, '/login'),
                    ),
                  ],
                )
              : Column(
                  children: [
                    // Most Popular 徽章
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: _BrandColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Most Popular',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _PricingCard(
                      title: 'Pro',
                      subtitle: 'For individuals who want peace of mind',
                      price: '\$4.99',
                      period: '/month',
                      features: const [
                        'Unlimited event captures',
                        'Text, photo, and voice input',
                        'Direct calendar sync',
                        'Advanced AI with smart suggestions',
                        'Priority processing',
                        'Email reminders',
                      ],
                      buttonText: 'Start Free Trial',
                      isPopular: true,
                      onTap: () => Navigator.pushNamed(context, '/login'),
                    ),
                    const SizedBox(height: 24),
                    _PricingCard(
                      title: 'Free',
                      subtitle: 'Perfect for trying out FollowUP',
                      price: '\$0',
                      period: '/month',
                      features: const [
                        '10 event captures per month',
                        'Text and photo input',
                        'ICS file export',
                        'Basic AI extraction',
                      ],
                      buttonText: 'Get Started',
                      isPopular: false,
                      onTap: () => Navigator.pushNamed(context, '/login'),
                    ),
                    const SizedBox(height: 24),
                    _PricingCard(
                      title: 'Family',
                      subtitle: 'Share calm with your loved ones',
                      price: '\$9.99',
                      period: '/month',
                      features: const [
                        'Everything in Pro',
                        'Up to 5 family members',
                        'Shared family calendar',
                        'Delegate event creation',
                        'Family activity insights',
                        'Priority support',
                      ],
                      buttonText: 'Start Free Trial',
                      isPopular: false,
                      onTap: () => Navigator.pushNamed(context, '/login'),
                    ),
                  ],
                ),
          const SizedBox(height: 40),
          Text(
            'All plans include a 14-day free trial. No credit card required.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: _BrandColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PricingCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String price;
  final String period;
  final List<String> features;
  final String buttonText;
  final bool isPopular;
  final VoidCallback onTap;

  const _PricingCard({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.period,
    required this.features,
    required this.buttonText,
    required this.isPopular,
    required this.onTap,
  });

  @override
  State<_PricingCard> createState() => _PricingCardState();
}

class _PricingCardState extends State<_PricingCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 1000;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: isWide ? 300 : double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: _BrandColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.isPopular 
                ? _BrandColors.primary 
                : const Color(0xFFE5E7EB),
            width: widget.isPopular ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Most Popular 徽章已移至卡片外部
            Text(
              widget.title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  widget.price,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: widget.isPopular ? _BrandColors.primary : _BrandColors.textPrimary,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    widget.period,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: _BrandColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            ...widget.features.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: _BrandColors.success.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 14,
                      color: _BrandColors.success,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      f,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 20),
            // 按钮 - Popular 使用实心深青绿，其他使用边框
            SizedBox(
              width: double.infinity,
              child: widget.isPopular
                  ? Container(
                      decoration: BoxDecoration(
                        color: _BrandColors.primary,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: widget.onTap,
                          borderRadius: BorderRadius.circular(24),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Center(
                              child: Text(
                                widget.buttonText,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F0E8), // 米色背景
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: const Color(0xFFE5DDD0),
                          width: 1,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: widget.onTap,
                          borderRadius: BorderRadius.circular(24),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Center(
                              child: Text(
                                widget.buttonText,
                                style: const TextStyle(
                                  color: _BrandColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// FAQ 区域
class _FAQSection extends StatelessWidget {
  const _FAQSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 800;

    final faqs = [
      _FAQ(
        question: 'FollowUP 如何提取事件信息？',
        answer: 'FollowUP 使用先进的 AI 技术分析你的文字、图片或语音输入，自动识别日期、时间、地点和事件标题等关键信息，然后生成格式化的日历事件。',
      ),
      _FAQ(
        question: '可以导出到哪些日历？',
        answer: '你可以导出 ICS 文件，该格式兼容几乎所有主流日历应用，包括 Apple Calendar、Google Calendar、Outlook 等。专业版还支持直接同步到你的日历账户。',
      ),
      _FAQ(
        question: '我的数据安全吗？',
        answer: '我们非常重视隐私保护。你的数据在传输和存储时都经过加密，我们不会将你的信息分享给第三方。你可以随时删除你的数据。',
      ),
      _FAQ(
        question: '需要创建账户吗？',
        answer: '免费版不需要创建账户，你可以直接使用基本功能。如果需要同步和更多高级功能，建议注册账户。',
      ),
      _FAQ(
        question: 'FollowUP 支持哪些语言？',
        answer: '目前我们支持中文、英文、日文等多种语言的事件识别。我们正在不断扩展语言支持。',
      ),
      _FAQ(
        question: '如果 AI 识别错误怎么办？',
        answer: '在添加到日历之前，你可以查看并编辑所有识别的信息。如果有误，只需手动修改即可。我们的 AI 会不断学习改进。',
      ),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 80 : 24,
        vertical: 80,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF06B6D4).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Text(
              '常见问题',
              style: TextStyle(
                color: Color(0xFF06B6D4),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '还有疑问？',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            '关于 FollowUP 你需要知道的一切',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: faqs.map((f) => _FAQItem(faq: f)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _FAQ {
  final String question;
  final String answer;

  _FAQ({required this.question, required this.answer});
}

class _FAQItem extends StatefulWidget {
  final _FAQ faq;

  const _FAQItem({required this.faq});

  @override
  State<_FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<_FAQItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isExpanded 
              ? _BrandColors.primary.withValues(alpha: 0.3)
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: _isExpanded
            ? [
                BoxShadow(
                  color: _BrandColors.primary.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.faq.question,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _isExpanded ? _BrandColors.primary : null,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.125 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _isExpanded 
                            ? _BrandColors.primary.withValues(alpha: 0.1)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.add,
                        size: 18,
                        color: _isExpanded ? _BrandColors.primary : Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Text(
                widget.faq.answer,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.7,
                ),
              ),
            ),
            crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}

// 页脚
class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 800;

    return Container(
      width: double.infinity,
      // 透明背景，使用全局背景
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 80 : 24,
        vertical: 56,
      ),
      child: Column(
        children: [
          // CTA 区域 - 深青绿背景
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: _BrandColors.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Text(
                  'Ready to get started?',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Let FollowUP manage your schedule, free your mind.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.pushNamed(context, '/login'),
                      borderRadius: BorderRadius.circular(24),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        child: Text(
                          'Start for Free',
                          style: TextStyle(
                            color: _BrandColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 56),
          // Logo 和描述
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_BrandColors.primary, _BrandColors.accent],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.calendar_today_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'FollowUP',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _BrandColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            '将生活中的瞬间转化为日历事件\n让你不再为记住事情而烦恼',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Divider(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
          const SizedBox(height: 24),
          // 底部链接
          Wrap(
            spacing: 32,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              _FooterLink(label: '隐私政策', onTap: () {}),
              _FooterLink(label: '服务条款', onTap: () {}),
              _FooterLink(label: '联系我们', onTap: () {}),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            '© 2026 FollowUP. All rights reserved.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterLink extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _FooterLink({required this.label, required this.onTap});

  @override
  State<_FooterLink> createState() => _FooterLinkState();
}

class _FooterLinkState extends State<_FooterLink> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            color: _isHovered 
                ? _BrandColors.primary 
                : Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: _isHovered ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
          child: Text(widget.label),
        ),
      ),
    );
  }
}
