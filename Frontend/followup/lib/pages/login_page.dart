import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../utils/validators.dart';
import '../widgets/loading_overlay.dart';
import '../theme/app_theme.dart';

/// Login Page matching the FollowUP design mockup
/// Features organic flowing shapes, glassmorphism card, and decorative calendar icons
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String _version = '';

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _floatController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _loadVersion();
    _initAnimations();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _floatController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    _fadeController.forward();
    _slideController.forward();
  }

  Future<void> _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = packageInfo.version;
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      _usernameController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/chat');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 600;

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return LoadingOverlay(
          isLoading: authProvider.isLoading,
          message: l10n.loggingIn,
          child: Scaffold(
            body: Stack(
              children: [
                // Background with organic shapes
                _OrganicBackground(floatController: _floatController),

                // Decorative calendar icons
                _DecorativeCalendarIcons(floatController: _floatController),

                // Content
                SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: isWide ? 48 : 24,
                        vertical: 24,
                      ),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: _buildLoginContent(
                            context,
                            authProvider,
                            l10n,
                            isWide,
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
      },
    );
  }

  Widget _buildLoginContent(
    BuildContext context,
    AuthProvider authProvider,
    AppLocalizations l10n,
    bool isWide,
  ) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: isWide ? 380 : double.infinity,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // App Title - Styled to match logo
          const _FollowUpLogo(),
          const SizedBox(height: 8),
          // Tagline - Matching logo text
          Text(
            'Your smart path from input to action.',
            style: TextStyle(
              fontSize: 16,
              color: FollowUpColors.taglineColor,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 48),

          // Login Card
          _buildLoginCard(authProvider, l10n),

          const SizedBox(height: 32),

          // Version and Copyright
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        // Version
        if (_version.isNotEmpty)
          Text(
            'v$_version',
            style: TextStyle(
              fontSize: 13,
              color: FollowUpColors.titleColor.withValues(alpha: 0.5),
            ),
          ),
        const SizedBox(height: 8),
        // Copyright
        Text(
          '© 2026 FollowUP. All rights reserved.',
          style: TextStyle(
            fontSize: 12,
            color: FollowUpColors.titleColor.withValues(alpha: 0.4),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard(AuthProvider authProvider, AppLocalizations l10n) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.6),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 30,
                spreadRadius: 0,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Error message
                if (authProvider.error != null) ...[
                  _buildErrorMessage(authProvider.error!),
                  const SizedBox(height: 20),
                ],

                // Username input
                _buildInputField(
                  controller: _usernameController,
                  hint: 'Username',
                  icon: Icons.person_outline_rounded,
                  validator: Validators.validateUsername,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Password input
                _buildInputField(
                  controller: _passwordController,
                  hint: 'Password',
                  icon: Icons.lock_outline_rounded,
                  validator: Validators.validatePassword,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _login(),
                ),
                const SizedBox(height: 24),

                // Login button
                _buildLoginButton(l10n),
                const SizedBox(height: 16),

                // Forgot password link
                Center(
                  child: TextButton(
                    onPressed: () {
                      // TODO: Implement forgot password
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: FollowUpColors.titleColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                        decorationColor:
                            FollowUpColors.titleColor.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    bool obscureText = false,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    void Function(String)? onFieldSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      style: const TextStyle(
        fontSize: 16,
        color: FollowUpColors.textColor,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: FollowUpColors.textColor.withValues(alpha: 0.5),
          fontSize: 16,
        ),
        prefixIcon: Container(
          padding: const EdgeInsets.all(12),
          child: Icon(
            icon,
            color: FollowUpColors.sageGreen.withValues(alpha: 0.7),
            size: 24,
          ),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: BorderSide(
            color: FollowUpColors.sageGreen.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: BorderSide(
            color: FollowUpColors.sageGreen.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: const BorderSide(
            color: FollowUpColors.sageGreen,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(AppLocalizations l10n) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: FollowUpColors.sageGreen,
        boxShadow: [
          BoxShadow(
            color: FollowUpColors.sageGreen.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _login,
          borderRadius: BorderRadius.circular(32),
          child: Center(
            child: Text(
              'Log In',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorMessage(String error) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: AppColors.error,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              error,
              style: TextStyle(
                color: AppColors.error,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Design colors matching the mockup
class FollowUpColors {
  // Main colors from the design
  static const Color sageGreen = Color(0xFF5A7A6B);
  static const Color lightTeal = Color(0xFFAAD4CC);
  static const Color peach = Color(0xFFE8C8B8);
  static const Color cream = Color(0xFFFDF5ED);
  static const Color warmBeige = Color(0xFFF5E6D8);

  // Logo colors - matching the brand logo
  static const Color logoDarkTeal = Color(0xFF2F4858); // "Follow" text
  static const Color logoTurquoise = Color(0xFF5ABFB3); // "UP" text with arrow
  static const Color taglineColor = Color(0xFF5A6B6B); // Tagline gray

  // Text colors
  static const Color titleColor = Color(0xFF3D5A4C);
  static const Color textColor = Color(0xFF4A5D52);
}

/// FollowUP Logo Widget - Styled to match the brand logo
/// "Follow" in dark teal, "UP" in turquoise with animated arrow effect
class _FollowUpLogo extends StatefulWidget {
  const _FollowUpLogo();

  @override
  State<_FollowUpLogo> createState() => _FollowUpLogoState();
}

class _FollowUpLogoState extends State<_FollowUpLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    // Subtle floating/bounce animation for "UP"
    _floatAnimation = Tween<double>(begin: 0, end: -4).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // "Follow" text - static
        const Text(
          'Follow',
          style: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.w700,
            color: FollowUpColors.logoDarkTeal,
            letterSpacing: -0.5,
            height: 1.0,
          ),
        ),
        // "UP" with gentle bounce animation
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _floatAnimation.value),
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    FollowUpColors.logoTurquoise,
                    Color(0xFF7CD4C8), // Lighter shade at top
                  ],
                ).createShader(bounds),
                child: const Text(
                  'UP',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.5,
                    height: 1.0,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Organic flowing background shapes
class _OrganicBackground extends StatelessWidget {
  final AnimationController floatController;

  const _OrganicBackground({required this.floatController});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      width: size.width,
      height: size.height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            FollowUpColors.cream,
            FollowUpColors.warmBeige,
            Color(0xFFF8EEE4),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: AnimatedBuilder(
        animation: floatController,
        builder: (context, child) {
          final animValue = floatController.value;

          return Stack(
            children: [
              // Top-right sage green organic shape
              Positioned(
                top: -50 + (15 * math.sin(animValue * math.pi)),
                right: -100 + (10 * math.cos(animValue * math.pi)),
                child: _OrganicShape(
                  width: size.width * 0.8,
                  height: size.height * 0.35,
                  color: FollowUpColors.sageGreen.withValues(alpha: 0.4),
                  shapeType: ShapeType.topRight,
                ),
              ),

              // Left teal organic shape
              Positioned(
                top: size.height * 0.15 + (20 * math.sin(animValue * math.pi)),
                left: -size.width * 0.3,
                child: _OrganicShape(
                  width: size.width * 0.7,
                  height: size.height * 0.4,
                  color: FollowUpColors.lightTeal.withValues(alpha: 0.5),
                  shapeType: ShapeType.left,
                ),
              ),

              // Bottom-right peach organic shape
              Positioned(
                bottom: -size.height * 0.1 +
                    (15 * math.cos(animValue * math.pi * 0.8)),
                right: -size.width * 0.2,
                child: _OrganicShape(
                  width: size.width * 0.9,
                  height: size.height * 0.45,
                  color: FollowUpColors.peach.withValues(alpha: 0.6),
                  shapeType: ShapeType.bottomRight,
                ),
              ),

              // Bottom-left small sage accent
              Positioned(
                bottom: size.height * 0.15 +
                    (10 * math.sin(animValue * math.pi * 1.2)),
                left: -size.width * 0.15,
                child: _OrganicShape(
                  width: size.width * 0.5,
                  height: size.height * 0.25,
                  color: FollowUpColors.sageGreen.withValues(alpha: 0.25),
                  shapeType: ShapeType.bottomLeft,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

enum ShapeType { topRight, left, bottomRight, bottomLeft }

/// Custom organic shape painter
class _OrganicShape extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final ShapeType shapeType;

  const _OrganicShape({
    required this.width,
    required this.height,
    required this.color,
    required this.shapeType,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _OrganicShapePainter(color: color, shapeType: shapeType),
    );
  }
}

class _OrganicShapePainter extends CustomPainter {
  final Color color;
  final ShapeType shapeType;

  _OrganicShapePainter({required this.color, required this.shapeType});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    switch (shapeType) {
      case ShapeType.topRight:
        path.moveTo(size.width * 0.3, 0);
        path.quadraticBezierTo(
          size.width * 0.8,
          size.height * 0.1,
          size.width,
          size.height * 0.4,
        );
        path.quadraticBezierTo(
          size.width * 0.95,
          size.height * 0.8,
          size.width * 0.5,
          size.height,
        );
        path.quadraticBezierTo(
          size.width * 0.1,
          size.height * 0.7,
          size.width * 0.2,
          size.height * 0.3,
        );
        path.quadraticBezierTo(
          size.width * 0.25,
          size.height * 0.1,
          size.width * 0.3,
          0,
        );
        break;

      case ShapeType.left:
        path.moveTo(0, size.height * 0.2);
        path.quadraticBezierTo(
          size.width * 0.3,
          0,
          size.width * 0.7,
          size.height * 0.2,
        );
        path.quadraticBezierTo(
          size.width,
          size.height * 0.5,
          size.width * 0.8,
          size.height * 0.8,
        );
        path.quadraticBezierTo(
          size.width * 0.4,
          size.height,
          0,
          size.height * 0.7,
        );
        path.close();
        break;

      case ShapeType.bottomRight:
        path.moveTo(size.width * 0.1, size.height);
        path.quadraticBezierTo(
          0,
          size.height * 0.5,
          size.width * 0.3,
          size.height * 0.2,
        );
        path.quadraticBezierTo(
          size.width * 0.6,
          0,
          size.width * 0.9,
          size.height * 0.3,
        );
        path.quadraticBezierTo(
          size.width,
          size.height * 0.7,
          size.width * 0.7,
          size.height,
        );
        path.close();
        break;

      case ShapeType.bottomLeft:
        path.moveTo(0, size.height * 0.5);
        path.quadraticBezierTo(
          size.width * 0.2,
          0,
          size.width * 0.6,
          size.height * 0.3,
        );
        path.quadraticBezierTo(
          size.width,
          size.height * 0.6,
          size.width * 0.7,
          size.height,
        );
        path.quadraticBezierTo(
          size.width * 0.2,
          size.height * 0.9,
          0,
          size.height * 0.5,
        );
        break;
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Decorative floating calendar icons with checkmarks
class _DecorativeCalendarIcons extends StatelessWidget {
  final AnimationController floatController;

  const _DecorativeCalendarIcons({required this.floatController});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: floatController,
      builder: (context, child) {
        final animValue = floatController.value;

        return Stack(
          children: [
            // Top-right calendar
            Positioned(
              top: size.height * 0.22 + (8 * math.sin(animValue * math.pi)),
              right: size.width * 0.08,
              child: Transform.rotate(
                angle: 0.15 + (0.05 * math.sin(animValue * math.pi)),
                child: const _CalendarIcon(size: 48),
              ),
            ),

            // Left-side calendar
            Positioned(
              top: size.height * 0.55 + (10 * math.cos(animValue * math.pi)),
              left: size.width * 0.05,
              child: Transform.rotate(
                angle: -0.2 + (0.08 * math.cos(animValue * math.pi)),
                child: const _CalendarIcon(size: 44),
              ),
            ),

            // Bottom calendar
            Positioned(
              bottom: size.height * 0.08 +
                  (12 * math.sin(animValue * math.pi * 0.7)),
              left: size.width * 0.35,
              child: Transform.rotate(
                angle: 0.1 + (0.06 * math.sin(animValue * math.pi * 0.8)),
                child: const _CalendarIcon(size: 40),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Calendar icon widget with checkmark
class _CalendarIcon extends StatelessWidget {
  final double size;

  const _CalendarIcon({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: FollowUpColors.lightTeal.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Calendar top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: size * 0.25,
              decoration: BoxDecoration(
                color: FollowUpColors.sageGreen.withValues(alpha: 0.5),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
              ),
            ),
          ),

          // Calendar rings
          Positioned(
            top: size * 0.08,
            left: size * 0.25,
            child: Container(
              width: size * 0.08,
              height: size * 0.18,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Positioned(
            top: size * 0.08,
            right: size * 0.25,
            child: Container(
              width: size * 0.08,
              height: size * 0.18,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Checkmark
          Positioned(
            bottom: size * 0.15,
            left: 0,
            right: 0,
            child: Icon(
              Icons.check_rounded,
              size: size * 0.45,
              color: FollowUpColors.sageGreen,
            ),
          ),
        ],
      ),
    );
  }
}
