import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:math' as math;
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/animated_next_button.dart';
import '../../bloc/splash/splash_bloc.dart';
import '../../bloc/splash/splash_event.dart';
import '../../bloc/splash/splash_state.dart';
// import '../auth/login_screen.dart';
import '../auth/signup_screen.dart';
import 'animated_skip_button.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    context.read<SplashBloc>().add(SplashStarted());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<SplashBloc, SplashState>(
        listener: (context, state) {
          if (state is SplashPageChanged) {
            _pageController.animateToPage(
              state.currentPage,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          } else if (state is SplashNavigateToAuth) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const SignUpPage()),
            );
          }
        },
        child: BlocBuilder<SplashBloc, SplashState>(
          builder: (context, state) {
            final currentPage = state is SplashPageChanged ? state.currentPage : 0;
            
            return Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: const [
                          _SplashPage1(),
                          _SplashPage2(),
                          _SplashPage3(),
                        ],
                      ),
                    ),
                    _buildBottomSection(state),
                  ],
                ),
                
                // Skip button at top right with hover effects
                if (currentPage < 2)
                  Positioned(
                    top: 20,
                    right: 24,
                    child: SafeArea(
                      child: AnimatedSkipButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const SignUpPage()),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBottomSection(SplashState state) {
    final currentPage = state is SplashPageChanged ? state.currentPage : 0;
    
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      child: Column(
        children: [
          // Page Indicators
          FadeInUp(
            duration: const Duration(milliseconds: 600),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: currentPage == index 
                        ? AppColors.primary 
                        : AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: AppDimensions.paddingLarge),
          
          // Next/Get Started Button - Centered & Reduced Width
          FadeInUp(
            duration: const Duration(milliseconds: 600),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 80),
              child: AnimatedNextButton(
                text: currentPage == 2 ? AppStrings.getStarted : AppStrings.next,
                onPressed: () {
                  context.read<SplashBloc>().add(SplashNextPressed());
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashPage1 extends StatelessWidget {
  const _SplashPage1();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeInDown(
            duration: const Duration(milliseconds: 800),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1500),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.7 + (0.3 * value),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer glow ring
                      Container(
                        width: 320,
                        height: 320,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.primary.withValues(alpha: 0.1 * value),
                              AppColors.secondary.withValues(alpha: 0.05 * value),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      // Middle ring with animation
                      Transform.rotate(
                        angle: value * 2 * 3.14159,
                        child: Container(
                          width: 300,
                          height: 300,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.3 * value),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      // Main image container
                      Container(
                        width: 260,
                        height: 260,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white,
                              AppColors.primary.withValues(alpha: 0.1),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.4 * value),
                              blurRadius: 40 * value,
                              offset: Offset(0, 20 * value),
                            ),
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.8),
                              blurRadius: 10,
                              offset: const Offset(-5, -5),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(120),
                            child: Image.asset(
                              'assets/images/image_1.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      // Floating particles effect
                      ...List.generate(6, (index) {
                        final angle = (index * 60.0) * (3.14159 / 180);
                        final radius = 150.0;
                        return Transform.translate(
                          offset: Offset(
                            radius * math.cos(angle + value * 2 * 3.14159),
                            radius * math.sin(angle + value * 2 * 3.14159),
                          ),
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.accent.withValues(alpha: 0.6 * value),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 60),
          
          FadeInUp(
            duration: const Duration(milliseconds: 800),
            delay: const Duration(milliseconds: 200),
            child: Text(
              AppStrings.appName,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 16),
          
          FadeInUp(
            duration: const Duration(milliseconds: 800),
            delay: const Duration(milliseconds: 400),
            child: Text(
              AppStrings.tagline,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashPage2 extends StatelessWidget {
  const _SplashPage2();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SlideInLeft(
            duration: const Duration(milliseconds: 1000),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1800),
              builder: (context, value, child) {
                return Transform.rotate(
                  angle: (1 - value) * 0.1,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background geometric shapes
                      Transform.rotate(
                        angle: value * 0.5,
                        child: Container(
                          width: 350,
                          height: 350,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.secondary.withValues(alpha: 0.1 * value),
                                AppColors.primary.withValues(alpha: 0.05 * value),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Main card container
                      Container(
                        width: 320,
                        height: 320,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white,
                              AppColors.secondary.withValues(alpha: 0.1),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.secondary.withValues(alpha: 0.3 * value),
                              blurRadius: 30 * value,
                              offset: Offset(-15 * value, 15 * value),
                            ),
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.2 * value),
                              blurRadius: 20 * value,
                              offset: Offset(10 * value, -10 * value),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Stack(
                              children: [
                                Image.asset(
                                  'assets/images/image_2.png',
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                                // Overlay gradient for professional look
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        AppColors.primary.withValues(alpha: 0.1 * value),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Corner accent elements
                      Positioned(
                        top: 20,
                        right: 20,
                        child: Transform.scale(
                          scale: value,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppColors.accent,
                                  AppColors.accent.withValues(alpha: 0.3),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        left: 20,
                        child: Transform.scale(
                          scale: value,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: AppColors.secondary.withValues(alpha: 0.8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 60),
          
          FadeInUp(
            duration: const Duration(milliseconds: 800),
            delay: const Duration(milliseconds: 200),
            child: Text(
              AppStrings.splash2Title,
              style: Theme.of(context).textTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 16),
          
          FadeInUp(
            duration: const Duration(milliseconds: 800),
            delay: const Duration(milliseconds: 400),
            child: Text(
              AppStrings.splash2Subtitle,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashPage3 extends StatelessWidget {
  const _SplashPage3();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ZoomIn(
            duration: const Duration(milliseconds: 1000),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 2000),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.6 + (0.4 * value),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Animated background waves
                      ...List.generate(3, (index) {
                        final delay = index * 0.3;
                        final animValue = ((value - delay).clamp(0.0, 1.0));
                        return Transform.scale(
                          scale: 1 + (animValue * 0.5),
                          child: Container(
                            width: 300 + (index * 40.0),
                            height: 300 + (index * 40.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.accent.withValues(
                                  alpha: (0.3 - index * 0.1) * animValue,
                                ),
                                width: 2,
                              ),
                            ),
                          ),
                        );
                      }),
                      // Main hexagonal container
                      Transform.rotate(
                        angle: value * 0.2,
                        child: Container(
                          width: 340,
                          height: 340,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(40),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.primary.withValues(alpha: 0.15 * value),
                                AppColors.accent.withValues(alpha: 0.1 * value),
                                AppColors.secondary.withValues(alpha: 0.05 * value),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Image container with glass effect
                      Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(35),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withValues(alpha: 0.9),
                              Colors.white.withValues(alpha: 0.7),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accent.withValues(alpha: 0.4 * value),
                              blurRadius: 50 * value,
                              offset: Offset(0, 25 * value),
                            ),
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.2 * value),
                              blurRadius: 30 * value,
                              offset: Offset(-15 * value, -15 * value),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(25),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: Stack(
                              children: [
                                Image.asset(
                                  'assets/images/image_3.png',
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                                // Glass overlay effect
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.white.withValues(alpha: 0.2 * value),
                                        Colors.transparent,
                                        AppColors.primary.withValues(alpha: 0.1 * value),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Floating elements
                      ...List.generate(4, (index) {
                        final positions = [
                          const Offset(-120, -120),
                          const Offset(120, -120),
                          const Offset(-120, 120),
                          const Offset(120, 120),
                        ];
                        return Transform.translate(
                          offset: positions[index] * value,
                          child: Transform.rotate(
                            angle: value * 2 * 3.14159,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.accent,
                                    AppColors.secondary,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 60),
          
          FadeInUp(
            duration: const Duration(milliseconds: 800),
            delay: const Duration(milliseconds: 200),
            child: Text(
              AppStrings.splash3Title,
              style: Theme.of(context).textTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 16),
          
          FadeInUp(
            duration: const Duration(milliseconds: 800),
            delay: const Duration(milliseconds: 400),
            child: Text(
              AppStrings.splash3Subtitle,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}