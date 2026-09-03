import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../extensions/context_extensions.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorText;

  bool get _isTr =>
      Uri.base.queryParameters['lang'] == 'tr';
			
  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorText = _isTr ? 'E-posta ve şifre gereklidir.' : 'Email and password are required.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
			if (!mounted) return;

			Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() {
        _errorText = switch (e.code) {
          'invalid-credential' => _isTr ? 'E-posta veya şifre hatalı.' : 'Invalid email or password.',
          'user-disabled' => _isTr ? 'Bu hesap devre dışı bırakılmış.' : 'This account has been disabled.',
          'too-many-requests' =>
            _isTr ? 'Çok fazla deneme yapıldı. Lütfen daha sonra tekrar deneyin.' : 'Too many attempts. Please try again later.',
          _ => e.message ?? (_isTr ? 'Giriş başarısız.' : _isTr ? 'Giriş başarısız.' : 'Login failed.'),
        };
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorText = _isTr ? 'Giriş başarısız.' : 'Login failed.';
      });
    } finally {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isTr
                ? 'Lütfen önce e-posta adresinizi girin.'
                : 'Please enter your email address first.',
          ),
        ),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isTr
                ? 'Şifre sıfırlama e-postası gönderildi.'
                : 'Password reset email sent.',
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      debugPrint(
        'PASSWORD RESET ERROR => '
        'code=${e.code} message=${e.message}',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isTr
                ? 'Şifre sıfırlama başarısız: ${e.code}'
                : 'Password reset failed: ${e.code}',
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTr = Uri.base.queryParameters['lang'] == 'tr';

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: 420,
              child: Card(
                color: const Color(0xFF172033),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/fleet_icon.png',
                            width: 52,
                            height: 52,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 14),
                          const Text(
                            'LynraFleet',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF43BFF3),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      Text(
                        isTr ? 'Hesabınıza giriş yapın' : 'Sign in to your account',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        isTr
                            ? 'Filonuzu her yerden yönetin ve takip edin.'
                            : 'Manage and track your fleet from anywhere.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white60,
                        ),
                      ),

                      const SizedBox(height: 30),

                      TextField(
                        controller: _emailController,
                        keyboardType:
                            TextInputType.emailAddress,
                        autofillHints: const [
                          AutofillHints.email,
                        ],
                        decoration: InputDecoration(
                          labelText: context.l10n.email,
                          prefixIcon:
                              const Icon(Icons.email_outlined),
                          border:
                              const OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        autofillHints: const [
                          AutofillHints.password,
                        ],
                        onSubmitted: (_) {
                          if (!_isLoading) {
                            _login();
                          }
                        },
                        decoration: InputDecoration(
                          labelText: isTr ? 'Şifre' : 'Password',
                          prefixIcon:
                              const Icon(Icons.lock_outline),
                          border: const OutlineInputBorder(),
                        ),
                      ),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _resetPassword,
                          child: Text(
                            isTr ? 'Şifremi unuttum' : 'Forgot password?',
                            style: TextStyle(
                              color: Color(0xFF43BFF3),
                            ),
                          ),
                        ),
                      ),

                      if (_errorText != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _errorText!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .error,
                          ),
                        ),
                      ],

                      const SizedBox(height: 22),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: FilledButton(
                          onPressed:
                              _isLoading ? null : _login,
                          style: FilledButton.styleFrom(
                            backgroundColor:
                                const Color(0xFF43BFF3),
                            foregroundColor:
                                const Color(0xFF0F172A),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  isTr ? 'Giriş Yap' : 'Sign In',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight:
                                        FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Text(
                            isTr ? 'Hesabınız yok mu?' : "Don't have an account?",
                            style: TextStyle(
                              color: Colors.white60,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const SignUpPage(),
                                ),
                              );
                            },
                            child: Text(
                              isTr ? 'Hesap Oluştur' : 'Create Account',
                              style: TextStyle(
                                color:
                                    Color(0xFF43BFF3),
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}