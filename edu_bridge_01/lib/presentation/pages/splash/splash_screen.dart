import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:math' as math;
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/animated_next_button.dart';
import '../../bloc/splash/splash_bloc.dart';
import '../../bloc/splash/splash_event.dart';
import '../../bloc/splash/splash_state.dart';
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
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    AppColors.primary.withOpacity(0.1),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
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
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    AppColors.secondary.withOpacity(0.1),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(-15, 15),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/images/image_2.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
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
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(35),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.9),
                    Colors.white.withOpacity(0.7),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.4),
                    blurRadius: 50,
                    offset: const Offset(0, 25),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Image.asset(
                    'assets/images/image_3.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
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