import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/cyber_background.dart';
import 'home_screen.dart';
import '../providers/task_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _rememberMe = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'Lütfen tüm bilgileri giriniz');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await context.read<AuthProvider>().login(
          _emailController.text,
          _passwordController.text,
        );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                ChangeNotifierProvider(
              create: (_) => TaskProvider(),
              child: const HomeScreen(),
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      } else {
        setState(() => _errorMessage = 'Geçersiz kimlik veya şifre');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      body: CyberBackground(
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 72),

                    // Logo
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.accentCyan.withOpacity(0.4),
                                  blurRadius: 50,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppTheme.accentCyan.withOpacity(0.3),
                                  AppTheme.accentPurple.withOpacity(0.3),
                                ],
                              ),
                              border: Border.all(
                                color: AppTheme.accentCyan.withOpacity(0.6),
                                width: 1.5,
                              ),
                            ),
                            child: const Center(
                              child: Text('⚡',
                                  style: TextStyle(fontSize: 48)),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    ShaderMask(
                      shaderCallback: (bounds) =>
                          AppTheme.primaryGradient.createShader(bounds),
                      child: const Text(
                        'GAMEFORGE',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Orbitron',
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'GÖREV KOMUTA ERİŞİMİ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Rajdhani',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 5,
                        color: AppTheme.accentCyan,
                      ),
                    ),

                    const SizedBox(height: 52),

                    // Divider with label
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                              height: 1,
                              color: AppTheme.borderGlow),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'KİMLİK DOĞRULAMA',
                            style: TextStyle(
                              fontFamily: 'Orbitron',
                              fontSize: 9,
                              letterSpacing: 2,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                              height: 1,
                              color: AppTheme.borderGlow),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Email field
                    _buildField(
                      controller: _emailController,
                      hint: 'Komutan Kimliği',
                      icon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 14),

                    // Password field
                    _buildField(
                      controller: _passwordController,
                      hint: 'Erişim Şifresi',
                      icon: Icons.lock_outline_rounded,
                      obscure: _obscurePassword,
                      suffix: GestureDetector(
                        onTap: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                        child: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppTheme.textSecondary,
                          size: 18,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Remember me
                    Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: Checkbox(
                            value: _rememberMe,
                            onChanged: (v) =>
                                setState(() => _rememberMe = v ?? false),
                            activeColor: AppTheme.accentCyan,
                            checkColor: AppTheme.bgDeep,
                            side: const BorderSide(
                                color: AppTheme.borderGlow, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Beni hatırla',
                          style: TextStyle(
                            fontFamily: 'Rajdhani',
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),

                    if (_errorMessage != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppTheme.accentPink.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: AppTheme.accentPink.withOpacity(0.4)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded,
                                color: AppTheme.accentPink, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              _errorMessage!,
                              style: const TextStyle(
                                  color: AppTheme.accentPink,
                                  fontSize: 13,
                                  fontFamily: 'Rajdhani'),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),

                    // Login button
                    GestureDetector(
                      onTap: _isLoading ? null : _handleLogin,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        height: 54,
                        decoration: BoxDecoration(
                          gradient: _isLoading
                              ? null
                              : AppTheme.primaryGradient,
                          color: _isLoading
                              ? AppTheme.bgElevated
                              : null,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: _isLoading
                              ? null
                              : [
                                  BoxShadow(
                                    color: AppTheme.accentCyan.withOpacity(0.35),
                                    blurRadius: 20,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                        ),
                        child: Center(
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        AppTheme.accentCyan),
                                  ),
                                )
                              : const Text(
                                  '⚡  OTURUMU BAŞLAT',
                                  style: TextStyle(
                                    fontFamily: 'Orbitron',
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 2,
                                  ),
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'ERİŞİM ŞİFRESİNİ Mİ UNUTTUN?',
                        style: TextStyle(
                          fontFamily: 'Rajdhani',
                          color: AppTheme.textSecondary,
                          fontSize: 11,
                          letterSpacing: 2,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgElevated.withOpacity(0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderGlow, width: 1),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(
          fontFamily: 'Rajdhani',
          color: AppTheme.textPrimary,
          fontSize: 15,
        ),
        onSubmitted: (_) => _handleLogin(),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
              color: AppTheme.textSecondary, fontFamily: 'Rajdhani'),
          prefixIcon: Icon(icon, color: AppTheme.accentCyan, size: 20),
          suffixIcon: suffix != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: suffix)
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }
}
