import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class AnimatedNextButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;

  const AnimatedNextButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  State<AnimatedNextButton> createState() => _AnimatedNextButtonState();
}

class _AnimatedNextButtonState extends State<AnimatedNextButton>
    with TickerProviderStateMixin {
  late AnimationController _pressController;
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _arrowSlideAnimation;
  late Animation<double> _arrowOpacityAnimation;
  late Animation<double> _shadowAnimation;
  late Animation<Color?> _colorAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    
    // Press animation controller
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    // Hover animation controller
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // Scale animation for press effect
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(
      parent: _pressController,
      curve: Curves.easeInOut,
    ));
    
    // Arrow slide-in animation from right
    _arrowSlideAnimation = Tween<double>(
      begin: 30.0, // Start from right (off-screen)
      end: 0.0,    // End at normal position
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.elasticOut,
    ));
    
    // Arrow opacity animation
    _arrowOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));
    
    // Shadow depth animation
    _shadowAnimation = Tween<double>(
      begin: 4.0,
      end: 8.0,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));
    
    // Color transition animation
    _colorAnimation = ColorTween(
      begin: AppColors.primary,
      end: AppColors.secondary,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pressController.dispose();
    _hoverController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _pressController.forward();
    // Trigger hover animation on touch for mobile
    if (!_isHovered) {
      _onHoverEnter();
    }
  }

  void _onTapUp(TapUpDetails details) {
    _pressController.reverse();
    // Keep hover effect briefly after tap
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && !_isHovered) {
        _onHoverExit();
      }
    });
  }

  void _onTapCancel() {
    _pressController.reverse();
    _onHoverExit();
  }

  void _onHoverEnter() {
    setState(() => _isHovered = true);
    _hoverController.forward();
  }

  void _onHoverExit() {
    setState(() => _isHovered = false);
    _hoverController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.isLoading ? null : widget.onPressed,
      child: MouseRegion(
        onEnter: (_) => _onHoverEnter(),
        onExit: (_) => _onHoverExit(),
        child: AnimatedBuilder(
          animation: Listenable.merge([_pressController, _hoverController]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                height: AppDimensions.buttonHeight,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _colorAnimation.value ?? AppColors.primary,
                      (_colorAnimation.value ?? AppColors.primary).withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  boxShadow: [
                    BoxShadow(
                      color: (_colorAnimation.value ?? AppColors.primary).withValues(alpha: 0.3),
                      blurRadius: 8 + (_shadowAnimation.value),
                      offset: Offset(0, _shadowAnimation.value),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                    onTap: widget.isLoading ? null : widget.onPressed,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingLarge,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.isLoading)
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          else ...[
                            Text(
                              widget.text,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            // Arrow - always visible with enhanced animation on interaction
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              width: 32,
                              child: Transform.translate(
                                offset: Offset(
                                  _isHovered ? _arrowSlideAnimation.value : 0,
                                  0,
                                ),
                                child: AnimatedOpacity(
                                  opacity: _isHovered ? _arrowOpacityAnimation.value : 0.8,
                                  duration: const Duration(milliseconds: 300),
                                  child: Container(
                                    margin: const EdgeInsets.only(left: 8),
                                    child: AnimatedScale(
                                      scale: _isHovered ? 1.1 : 1.0,
                                      duration: const Duration(milliseconds: 300),
                                      child: const Icon(
                                        Icons.arrow_forward_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}