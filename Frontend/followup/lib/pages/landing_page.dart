import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

// Landing Page
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

// Navigation Bar
class _NavBar extends StatelessWidget {
  const _NavBar();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
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
                _NavLink(label: l10n.howItWorksTitle, onTap: () {}),
                const SizedBox(width: 8),
                _NavLink(label: l10n.featuresTitle, onTap: () {}),
                const SizedBox(width: 8),
                _NavLink(label: l10n.pricingTitle, onTap: () {}),
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
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: Text(
                          l10n.getStarted,
                          style: const TextStyle(
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
    final l10n = AppLocalizations.of(context)!;
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
              label: l10n.howItWorksTitle,
              onTap: () => Navigator.pop(context),
            ),
            _MobileMenuItem(
              icon: Icons.star_outline,
              label: l10n.featuresTitle,
              onTap: () => Navigator.pop(context),
            ),
            _MobileMenuItem(
              icon: Icons.diamond_outlined,
              label: l10n.pricingTitle,
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
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Text(
                          l10n.getStarted,
                          style: const TextStyle(
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

// Hero Section with background image
class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isWide = screenWidth > 900;
    final isMedium = screenWidth > 600;

    // Calculate hero height based on screen size
    final heroHeight = isWide 
        ? screenHeight * 0.75 
        : isMedium 
            ? screenHeight * 0.6 
            : screenHeight * 0.5;

    return Container(
      width: double.infinity,
      height: heroHeight,
      child: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/main_picture.png',
              fit: isWide ? BoxFit.cover : BoxFit.cover,
              alignment: isWide 
                  ? Alignment.center 
                  : const Alignment(0.3, 0), // Show more of the right side (phone) on small screens
            ),
          ),
          // Subtle gradient overlay for better text readability on small screens
          if (!isWide)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.7),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          // CTA button at bottom for mobile
          if (!isWide)
            Positioned(
              bottom: 24,
              left: 24,
              right: 24,
              child: Container(
                decoration: BoxDecoration(
                  color: _BrandColors.primary,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: _BrandColors.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.pushNamed(context, '/login'),
                    borderRadius: BorderRadius.circular(24),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.play_arrow_rounded, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            AppLocalizations.of(context)!.tryNow,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
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
}

// Removed unused hero widgets - now using main_picture.png as hero background

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

// Pain Points Section
class _PainPointsSection extends StatelessWidget {
  const _PainPointsSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 800;

    final painPoints = [
      _PainPoint(icon: Icons.photo_library_outlined, title: l10n.painPointPhoto, color: const Color(0xFFEC4899)),
      _PainPoint(icon: Icons.chat_bubble_outline, title: l10n.painPointMessage, color: const Color(0xFFF59E0B)),
      _PainPoint(icon: Icons.insert_invitation_outlined, title: l10n.painPointFlyer, color: const Color(0xFF8B5CF6)),
      _PainPoint(icon: Icons.record_voice_over_outlined, title: l10n.painPointVoice, color: const Color(0xFF06B6D4)),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 80 : 24,
        vertical: 80,
      ),
      child: Column(
        children: [
          // Title
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _BrandColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              l10n.theProblem,
              style: const TextStyle(
                color: _BrandColors.warning,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.painPointsSubtitle,
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
              l10n.painPointsDesc,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.7,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 48),
          // Pain point cards
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: painPoints.map((p) => _PainPointCard(painPoint: p, isWide: isWide)).toList(),
          ),
          const SizedBox(height: 48),
          // Solution hint
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
                  l10n.painPointNeedSimpler,
                  style: const TextStyle(
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

// How It Works Section
class _HowItWorksSection extends StatelessWidget {
  const _HowItWorksSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 900;

    final steps = [
      _Step(number: '1', title: l10n.captureStep, description: l10n.captureStepDesc, icon: Icons.camera_alt_outlined, color: const Color(0xFF3B82F6)),
      _Step(number: '2', title: l10n.understandStep, description: l10n.understandStepDesc, icon: Icons.psychology_outlined, color: const Color(0xFF8B5CF6)),
      _Step(number: '3', title: l10n.confirmStep, description: l10n.confirmStepDesc, icon: Icons.check_circle_outline, color: const Color(0xFF10B981)),
      _Step(number: '4', title: l10n.doneStep, description: l10n.doneStepDesc, icon: Icons.event_available_outlined, color: const Color(0xFFEC4899)),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 80 : 24,
        vertical: 80,
      ),
      child: Column(
        children: [
          // Title
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _BrandColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              l10n.howItWorksTitle,
              style: const TextStyle(
                color: _BrandColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.step1Title,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.step1Desc,
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

// Features Section
class _FeaturesSection extends StatelessWidget {
  const _FeaturesSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 900;

    final features = [
      _Feature(
        icon: Icons.lock_outline,
        title: l10n.featurePrivacyTitle,
        description: l10n.featurePrivacyDesc,
        color: const Color(0xFF10B981),
      ),
      _Feature(
        icon: Icons.psychology_outlined,
        title: l10n.featureSmartTitle,
        description: l10n.featureSmartDesc,
        color: _BrandColors.primary,
      ),
      _Feature(
        icon: Icons.tune,
        title: l10n.featureControlTitle,
        description: l10n.featureControlDesc,
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
          // Title
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _BrandColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              l10n.featuresTitle,
              style: const TextStyle(
                color: _BrandColors.success,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.featureFocusSubtitle,
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
              l10n.featureFocusDesc,
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

// Demo Section
class _DemoSection extends StatefulWidget {
  const _DemoSection();

  @override
  State<_DemoSection> createState() => _DemoSectionState();
}

class _DemoSectionState extends State<_DemoSection> {
  int _selectedTab = 0;
  late TextEditingController _textController;
  bool _showResult = false;
  bool _isExtracting = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context)!;
    if (_textController.text.isEmpty) {
      _textController.text = 'Team dinner next Friday at 7pm at Olive Garden on Main Street. Don\'t forget to bring Sarah\'s birthday card!';
    }
  }

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
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 900;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 80 : 24,
        vertical: 80,
      ),
      child: Column(
        children: [
          // Title
          const SizedBox.shrink(),
          const SizedBox(height: 20),
          Text(
            l10n.demoTitle,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.demoDesc,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: _BrandColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          // Demo cards
          Container(
            constraints: const BoxConstraints(maxWidth: 900),
            child: isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildInputSection(theme, l10n)),
                      const SizedBox(width: 24),
                      Expanded(child: _buildResultSection(theme, l10n)),
                    ],
                  )
                : Column(
                    children: [
                      _buildInputSection(theme, l10n),
                      const SizedBox(height: 24),
                      _buildResultSection(theme, l10n),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection(ThemeData theme, AppLocalizations l10n) {
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
                l10n.demoInputLabel,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Tab switcher
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(child: _DemoTab(label: l10n.demoTextTab, icon: Icons.text_fields, isSelected: _selectedTab == 0, onTap: () => setState(() => _selectedTab = 0))),
                Expanded(child: _DemoTab(label: l10n.demoImageTab, icon: Icons.photo_outlined, isSelected: _selectedTab == 1, onTap: () => setState(() => _selectedTab = 1))),
                Expanded(child: _DemoTab(label: l10n.demoVoiceTab, icon: Icons.mic_none, isSelected: _selectedTab == 2, onTap: () => setState(() => _selectedTab = 2))),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Input area
          if (_selectedTab == 0)
            TextField(
              controller: _textController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: l10n.demoInputPlaceholder,
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
                    Text(l10n.demoClickUpload, style: TextStyle(color: Colors.grey[600])),
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
                    Text(l10n.demoClickRecord, style: TextStyle(color: Colors.grey[600])),
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

  Widget _buildResultSection(ThemeData theme, AppLocalizations l10n) {
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
                l10n.demoEventPreview,
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
                              l10n.demoTeamDinner,
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
                              child: Text(
                                l10n.demoRecognized,
                                style: const TextStyle(
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
                  _EventDetailRow(icon: Icons.access_time, text: l10n.demoNextFriday),
                  const SizedBox(height: 10),
                  _EventDetailRow(icon: Icons.location_on_outlined, text: l10n.demoRestaurant),
                  const SizedBox(height: 10),
                  _EventDetailRow(icon: Icons.note_outlined, text: l10n.demoBirthdayCard),
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
                      l10n.demoExtractedEvent,
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

// FAQ Section
class _FAQSection extends StatelessWidget {
  const _FAQSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 800;

    final faqs = [
      _FAQ(
        question: l10n.faq1Question,
        answer: l10n.faq1Answer,
      ),
      _FAQ(
        question: l10n.faq2Question,
        answer: l10n.faq2Answer,
      ),
      _FAQ(
        question: l10n.faq3Question,
        answer: l10n.faq3Answer,
      ),
      _FAQ(
        question: l10n.faq4Question,
        answer: l10n.faq4Answer,
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
            child: Text(
              l10n.faqTitle,
              style: const TextStyle(
                color: Color(0xFF06B6D4),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.stillHaveQuestions,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.everythingYouNeed,
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

// Footer
class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 800;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 80 : 24,
        vertical: 56,
      ),
      child: Column(
        children: [
          // CTA Section
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
                  l10n.footerCTATitle,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.footerCTASubtitle,
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
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        child: Text(
                          l10n.getStarted,
                          style: const TextStyle(
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
          // Logo and description
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
            l10n.footerDescription,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Divider(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
          const SizedBox(height: 24),
          // Bottom links
          Wrap(
            spacing: 32,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              _FooterLink(label: l10n.footerPrivacy, onTap: () {}),
              _FooterLink(label: l10n.footerTerms, onTap: () {}),
              _FooterLink(label: l10n.footerContact, onTap: () {}),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            l10n.footerCopyright,
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
