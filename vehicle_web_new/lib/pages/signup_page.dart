import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import 'login_page.dart';
import '../services/code_service.dart';
import 'dashboard_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  String? _errorText;

  bool get _isTr =>
      Uri.base.queryParameters['lang'] == 'tr';

  Future<void> _signUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      setState(() {
        _errorText = _isTr ? 'Lütfen tüm alanları doldurun.' : 'Please complete all fields.';
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _errorText = _isTr ? 'Şifreler eşleşmiyor.' : 'Passwords do not match.';
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        _errorText = _isTr ? 'Şifre en az 6 karakter olmalıdır.' : 'Password must be at least 6 characters.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
			await _createRequesterIdentity();
			if (!mounted) return;

			Navigator.of(context).pushAndRemoveUntil(
				MaterialPageRoute(
					builder: (_) => DashboardPage(),
				),
				(route) => false,
			);


      // AuthGate authStateChanges() üzerinden kullanıcıyı
      // otomatik olarak yakalayacak.
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() {
        _errorText = switch (e.code) {
          'email-already-in-use' =>
            _isTr ? 'Bu e-posta adresiyle zaten bir hesap var.' : 'An account already exists with this email.',
          'invalid-email' =>
            _isTr ? 'Lütfen geçerli bir e-posta adresi girin.' : 'Please enter a valid email address.',
          'weak-password' =>
            _isTr ? 'Lütfen daha güçlü bir şifre seçin.' : 'Please choose a stronger password.',
          _ =>
							e.message ??
							(_isTr
									? 'Hesap oluşturulamadı.'
									: 'Account creation failed.'),
        };
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorText = _isTr ? 'Hesap oluşturulamadı.' : 'Account creation failed.';
      });
    } finally {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
	
	Future<void> _createRequesterIdentity() async {
		final user = FirebaseAuth.instance.currentUser;

		if (user == null) {
			throw Exception('Authenticated user not found.');
		}

		final requesterId = const Uuid().v4();

		final requesterCode =
				CodeService.shortCodeFromId(requesterId);

		final now = FieldValue.serverTimestamp();

		await FirebaseFirestore.instance
				.collection('requesters')
				.doc(requesterId)
				.set({
			'active': true,
			'authUid': user.uid,
			'requesterId': requesterId,
			'requesterCode': requesterCode,
			'platform': 'web',
			'createdAt': now,
			'updatedAt': now,
		});

		debugPrint(
			'WEB REQUESTER CREATED => '
			'requesterId=$requesterId '
			'requesterCode=$requesterCode '
			'authUid=${user.uid}',
		);
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
                        mainAxisAlignment: MainAxisAlignment.center,
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
                        isTr ? 'Ücretsiz hesabınızı oluşturun' : 'Create your free account',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        isTr ? 'İlk aracınız ömür boyu ücretsiz.' : 'Your first vehicle is free forever.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.greenAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 30),

                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [
                          AutofillHints.email,
                        ],
                        decoration: InputDecoration(
                          labelText: isTr ? 'E-posta' : 'Email',
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: const OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        autofillHints: const [
                          AutofillHints.newPassword,
                        ],
                        decoration: InputDecoration(
                          labelText: isTr ? 'Şifre' : 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: const OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        onSubmitted: (_) {
                          if (!_isLoading) {
                            _signUp();
                          }
                        },
                        decoration: InputDecoration(
                          labelText: isTr ? 'Şifreyi Onayla' : 'Confirm Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: const OutlineInputBorder(),
                        ),
                      ),

                      if (_errorText != null) ...[
                        const SizedBox(height: 18),
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

                      const SizedBox(height: 26),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: FilledButton(
                          onPressed:
                              _isLoading ? null : _signUp,
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
                                  isTr ? 'Hesap Oluştur' : 'Create Account',
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
                            isTr ? 'Zaten bir hesabınız var mı?' : 'Already have an account?',
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
                                      const LoginPage(),
                                ),
                              );
                            },
                            child: Text(
                              isTr ? 'Giriş Yap' : 'Sign In',
                              style: TextStyle(
                                color: Color(0xFF43BFF3),
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