import 'package:flutter/material.dart';

import 'login_page.dart';
import 'signup_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});
	static const Color lynraBlue = Color(0xFF43bff3);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 700;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 1100,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 24 : 48,
                  vertical: isMobile ? 40 : 70,
                ),
                child: Column(
                  children: [
                    // ================= HEADER =================

                    Row(
											mainAxisAlignment: MainAxisAlignment.center,
											children: [
												Image.asset(
													'assets/images/fleet_icon.png',
													width: 46,
													height: 46,
													fit: BoxFit.contain,
												),
												const SizedBox(width: 12),
												const Text(
													'LynraFleet',
													style: TextStyle(
														fontSize: 26,
														fontWeight: FontWeight.w800,
														color: lynraBlue,
													),
												),
											],
										),

                    SizedBox(
                      height: isMobile ? 65 : 100,
                    ),

                    // ================= HERO =================

                    const Text(
                      'Turn your driver\'s Android phone\n'
                      'into a vehicle tracker.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 42,
                        height: 1.15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'Track your vehicles from anywhere using the web panel '
											'or the LynraFleet mobile app.\n'
											'No additional GPS tracking device required.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        height: 1.6,
                        color: Colors.white70,
                      ),
                    ),

                    const SizedBox(height: 35),

                    // ================= FREE CARD =================

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.greenAccent.withValues(alpha: 0.5),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.greenAccent,
                          ),
                          SizedBox(width: 12),
                          Text(
                            '1 VEHICLE FREE — FOREVER',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.greenAccent,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(
                      height: isMobile ? 55 : 75,
                    ),

                    // ================= STEPS =================

                    Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      alignment: WrapAlignment.center,
                      children: const [
                        _StepCard(
                          number: '1',
                          icon: Icons.person_add_alt_1,
                          title: 'Create your account',
                          text:
                              'Create your free LynraFleet account.',
                        ),
                        _StepCard(
                          number: '2',
                          icon: Icons.business_outlined,
                          title: 'Create your fleet',
                          text:
                              'Create a new fleet or join an existing one.',
                        ),
                        _StepCard(
                          number: '3',
                          icon: Icons.directions_car,
                          title: 'Add your vehicle',
                          text:
                              'Connect the driver phone and start tracking.',
                        ),
                      ],
                    ),

                    const SizedBox(height: 55),

                    // ================= GET STARTED =================

                    SizedBox(
                      width: 260,
                      height: 54,
                      child: FilledButton(
                        onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SignUpPage(),
                              ),
                            );
                          },
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Get Started — Free',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account?',
                          style: TextStyle(
                            color: Colors.white60,
                          ),
                        ),
                        const SizedBox(width: 6),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginPage(),
                              ),
                            );
                          },
                          child: const Text('Sign In'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 65),

                    const Divider(
                      color: Colors.white12,
                    ),

                    const SizedBox(height: 25),

                    const Text(
                      'You can also manage and monitor your fleet '
                      'using the LynraFleet Android app.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
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

class _StepCard extends StatelessWidget {
  final String number;
  final IconData icon;
  final String title;
  final String text;

  const _StepCard({
    required this.number,
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 290,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: const Color(0xFF172033),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white10,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.blueAccent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.blueAccent,
              ),
            ),
          ),

          const SizedBox(height: 18),

          Icon(
            icon,
            size: 34,
            color: Colors.white,
          ),

          const SizedBox(height: 15),

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.white60,
            ),
          ),
        ],
      ),
    );
  }
}