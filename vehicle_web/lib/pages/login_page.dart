import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../extensions/context_extensions.dart';

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

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorText = 'Email and password are required.';
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
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() {// ?*? l10n
        _errorText = switch (e.code) {
          'invalid-credential' => 'Invalid email or password.',
          'user-disabled' => 'This account has been disabled.',
          'too-many-requests' => 'Too many attempts. Please try again later.',
          _ => e.message ?? 'Login failed.',
        };
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorText = 'Login failed.';
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
    super.dispose();
  }
	
	Future<void> _resetPassword() async {
		final email = _emailController.text.trim();

		if (email.isEmpty) {
			ScaffoldMessenger.of(context).showSnackBar(
				const SnackBar(
					content: Text('Please enter your email address first.'),
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
				const SnackBar(
					content: Text('Password reset email sent.'),
				),
			);
		} on FirebaseAuthException catch (e) {
				if (!mounted) return;

				debugPrint(
					'PASSWORD RESET ERROR => code=${e.code} message=${e.message}',
				);

				ScaffoldMessenger.of(context).showSnackBar(
					SnackBar(
						content: Text(
							'Password reset failed: ${e.code}',
						),
					),
				);
			}		
	}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 380,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.local_shipping_rounded,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'LynraFleet',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Sign in to your fleet dashboard'),
                  const SizedBox(height: 28),

                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [
                      AutofillHints.email,
                    ],
                    decoration: InputDecoration(
                      labelText: context.l10n.email,
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
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
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(),
                    ),
                  ),
									
									Align(
										alignment: Alignment.centerRight,
										child: TextButton(
											onPressed: _resetPassword,
											child: const Text('Forgot password?'),
										),
									),

                  if (_errorText != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _errorText!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: _isLoading ? null : _login,
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Sign In'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}