import 'dart:math' as math;
import 'package:flutter/material.dart';

// FollowUP 品牌色彩 - 温暖的米色 + 深青绿
class AppColors {
  // 深青绿主色调 - 专业、可信赖
  static const Color primary = Color(0xFF115E59);       // Teal-800
  static const Color primaryLight = Color(0xFF0F766E); // Teal-700
  static const Color primaryDark = Color(0xFF134E4A);  // Teal-900
  
  // 强调色
  static const Color accent = Color(0xFF14B8A6);       // Teal-500
  
  // 状态色
  static const Color success = Color(0xFF10B981);      // Emerald-500
  static const Color warning = Color(0xFFF59E0B);      // Amber-500
  static const Color error = Color(0xFFEF4444);        // Red-500
  static const Color info = Color(0xFF0D9488);         // Teal-600
  
  // 温暖的米色/奶油色背景
  static const Color backgroundStart = Color(0xFFFDF8F3); // 温暖的奶油色
  static const Color backgroundMid = Color(0xFFFAF5EF);   // 稍深的米色
  static const Color backgroundEnd = Color(0xFFF5EDE3);   // 更深的暖色
  static const Color surface = Color(0xFFFEFCFA);         // Off-white
  static const Color cardBg = Color(0xFFFFFDF9);          // Card background
  
  // 文字色
  static const Color textPrimary = Color(0xFF1F2937);   // Gray-800
  static const Color textSecondary = Color(0xFF6B7280); // Gray-500
  static const Color textMuted = Color(0xFF9CA3AF);     // Gray-400
  
  // 边框色
  static const Color border = Color(0xFFE5E7EB);        // Gray-200
  static const Color borderLight = Color(0xFFF3F4F6);   // Gray-100
}

// 温暖背景渐变
class WarmGradient {
  static const LinearGradient background = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.backgroundStart,
      AppColors.backgroundMid,
      AppColors.backgroundEnd,
    ],
    stops: [0.0, 0.5, 1.0],
  );
}

// 温暖背景组件 - 可在任何页面使用
class WarmBackground extends StatelessWidget {
  final Widget child;
  
  const WarmBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: WarmGradient.background,
      ),
      child: Stack(
        children: [
          // 装饰性圆形元素
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
          // 内容
          child,
        ],
      ),
    );
  }
}

// 简单温暖背景 (不带装饰圆)
class SimpleWarmBackground extends StatelessWidget {
  final Widget child;
  
  const SimpleWarmBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: WarmGradient.background,
      ),
      child: child,
    );
  }
}

// 带动画的温暖背景 - 用于聊天页面等
class AnimatedWarmBackground extends StatefulWidget {
  final Widget child;
  
  const AnimatedWarmBackground({super.key, required this.child});

  @override
  State<AnimatedWarmBackground> createState() => _AnimatedWarmBackgroundState();
}

class _AnimatedWarmBackgroundState extends State<AnimatedWarmBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: WarmGradient.background,
      ),
      child: Stack(
        children: [
          // Animated floating shapes
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final animValue = _controller.value;
              
              return Stack(
                children: [
                  // Top-right floating circle - teal tint
                  Positioned(
                    top: -80 + (20 * math.sin(animValue * math.pi)),
                    right: -60 + (15 * math.cos(animValue * math.pi)),
                    child: _AnimatedBubble(
                      size: size.width * 0.5,
                      color: const Color(0xFFD4E8E4).withValues(alpha: 0.4),
                    ),
                  ),
                  
                  // Left floating circle - warm beige
                  Positioned(
                    top: size.height * 0.3 + (25 * math.sin(animValue * math.pi * 0.8)),
                    left: -100 + (10 * math.cos(animValue * math.pi * 0.9)),
                    child: _AnimatedBubble(
                      size: size.width * 0.45,
                      color: const Color(0xFFE8DDD0).withValues(alpha: 0.5),
                    ),
                  ),
                  
                  // Bottom-right floating circle - soft peach
                  Positioned(
                    bottom: size.height * 0.15 + (18 * math.cos(animValue * math.pi * 0.7)),
                    right: -80 + (12 * math.sin(animValue * math.pi * 1.1)),
                    child: _AnimatedBubble(
                      size: size.width * 0.4,
                      color: const Color(0xFFE5D9C9).withValues(alpha: 0.45),
                    ),
                  ),
                  
                  // Small accent bubble - subtle teal
                  Positioned(
                    top: size.height * 0.55 + (15 * math.sin(animValue * math.pi * 1.2)),
                    right: size.width * 0.2 + (8 * math.cos(animValue * math.pi)),
                    child: _AnimatedBubble(
                      size: 80,
                      color: AppColors.primary.withValues(alpha: 0.08),
                    ),
                  ),
                  
                  // Small floating dot decorations
                  ..._buildFloatingDots(size, animValue),
                ],
              );
            },
          ),
          
          // Content
          widget.child,
        ],
      ),
    );
  }
  
  List<Widget> _buildFloatingDots(Size size, double animValue) {
    return [
      // Dot 1
      Positioned(
        top: size.height * 0.15 + (12 * math.sin(animValue * math.pi * 1.5)),
        left: size.width * 0.15,
        child: _FloatingDot(
          size: 8,
          color: AppColors.primary.withValues(alpha: 0.15),
        ),
      ),
      // Dot 2
      Positioned(
        top: size.height * 0.4 + (10 * math.cos(animValue * math.pi * 1.3)),
        right: size.width * 0.1,
        child: _FloatingDot(
          size: 6,
          color: const Color(0xFF5ABFB3).withValues(alpha: 0.2),
        ),
      ),
      // Dot 3
      Positioned(
        bottom: size.height * 0.35 + (8 * math.sin(animValue * math.pi * 0.9)),
        left: size.width * 0.08,
        child: _FloatingDot(
          size: 10,
          color: const Color(0xFFE8C8B8).withValues(alpha: 0.4),
        ),
      ),
      // Dot 4
      Positioned(
        top: size.height * 0.7 + (14 * math.cos(animValue * math.pi * 1.1)),
        right: size.width * 0.25,
        child: _FloatingDot(
          size: 7,
          color: AppColors.accent.withValues(alpha: 0.12),
        ),
      ),
    ];
  }
}

// Animated bubble for background
class _AnimatedBubble extends StatelessWidget {
  final double size;
  final Color color;

  const _AnimatedBubble({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color,
            color.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}

// Small floating dot
class _FloatingDot extends StatelessWidget {
  final double size;
  final Color color;

  const _FloatingDot({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

// FollowUP 主题配置
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.backgroundStart,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        foregroundColor: AppColors.textPrimary,
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.cardBg,
        indicatorColor: AppColors.primary.withValues(alpha: 0.1),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.cardBg,
        indicatorColor: AppColors.primary.withValues(alpha: 0.1),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}
