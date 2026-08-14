import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../l10n/app_localizations.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_fonts.dart';

class WebPanelAccessPage extends StatefulWidget {
  final String groupId;

  const WebPanelAccessPage({
    super.key,
    required this.groupId,
  });

  @override
  State<WebPanelAccessPage> createState() =>
      _WebPanelAccessPageState();
}

class _WebPanelAccessPageState
    extends State<WebPanelAccessPage> {

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
	bool _isLoading = false;
	String? _errorText;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
	
	Future<void> _createWebAccess() async {
		final email = _emailController.text.trim();
		final password = _passwordController.text;

		if (email.isEmpty || password.isEmpty) {
			setState(() {
				_errorText = 'Email and password are required.';
			});
			return;
		}

		if (password.length < 6) {
			setState(() {
				_errorText = 'Password must contain at least 6 characters.';
			});
			return;
		}

		setState(() {
			_isLoading = true;
			_errorText = null;
		});

		try {
			final callable = FirebaseFunctions.instance
					.httpsCallable('createFleetManager');

			await callable.call({
				'email': email,
				'password': password,
				'groupId': widget.groupId,
			});

			if (!mounted) return;

			ScaffoldMessenger.of(context).showSnackBar(
				const SnackBar(
					content: Text(
						'Web panel access created successfully.',
					),
				),
			);

			Navigator.pop(context, true);
		} on FirebaseFunctionsException catch (e) {
			if (!mounted) return;

			setState(() {
				_errorText = switch (e.code) {
					'already-exists' =>
						'This email address is already registered.',
					'permission-denied' =>
						'You are not authorized to create web access.',
					'unauthenticated' =>
						'Authentication required.',
					'invalid-argument' =>
						e.message ?? 'Invalid information.',
					_ =>
						e.message ?? 'Could not create web access.',
				};
			});
		} catch (e) {
			if (!mounted) return;

			setState(() {
				_errorText = 'Could not create web access.';
			});
		} finally {
			if (!mounted) return;

			setState(() {
				_isLoading = false;
			});
		}
	}

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.webPanelAccess,
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 460,
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.border,
                  ),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.language_rounded,
                      size: 42,
                      color: AppColors.primary,
                    ),

                    const SizedBox(height: 16),

                    Text(
                      l10n.webPanelAccess,
                      textAlign: TextAlign.center,
                      style: AppFonts.title.copyWith(
                        fontSize: 20,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      l10n.webPanelAccessDescription,
                      textAlign: TextAlign.center,
                      style: AppFonts.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 24),

                    TextField(
                      controller: _emailController,
                      keyboardType:
                          TextInputType.emailAddress,
                      autofillHints: const [
                        AutofillHints.email,
                      ],
											style: AppFonts.body.copyWith(
												color: AppColors.textSecondary,
											),
                      decoration: InputDecoration(
                        labelText: l10n.email,
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                        ),
                        border:
                            const OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      autofillHints: const [
                        AutofillHints.newPassword,
                      ],
											style: AppFonts.body.copyWith(
												color: AppColors.textSecondary,
											),
                      decoration: InputDecoration(
                        labelText: l10n.password,
                        prefixIcon: const Icon(
                          Icons.lock_outline_rounded,
                        ),
                        border:
                            const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword =
                                  !_obscurePassword;
                            });
                          },
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons
                                    .visibility_off_outlined,
                          ),
                        ),
                      ),
                    ),
										
										if (_errorText != null) ...[
											const SizedBox(height: 12),
											Text(
												_errorText!,
												style: TextStyle(
													color: Theme.of(context).colorScheme.error,
													fontSize: 13,
												),
											),
										],

                    const SizedBox(height: 24),

                    FilledButton.icon(
											onPressed: _isLoading
													? null
													: _createWebAccess,
											icon: _isLoading
													? const SizedBox(
															width: 18,
															height: 18,
															child: CircularProgressIndicator(
																strokeWidth: 2,
															),
														)
													: const Icon(
															Icons.add_moderator_outlined,
														),
											label: Text(
												l10n.createWebAccess,
											),
										),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}