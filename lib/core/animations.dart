import 'package:flutter/material.dart';
import 'design_tokens.dart';

/// App Animations - Fintech Style
/// 부드럽고 세련된 애니메이션 헬퍼
class AppAnimations {
  AppAnimations._();

  /// Fade In Transition
  static Widget fadeIn({
    required Widget child,
    Duration duration = DesignTokens.durationNormal,
    Curve curve = DesignTokens.curveEaseOut,
    double begin = 0.0,
    double end = 1.0,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: begin, end: end),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      child: child,
    );
  }

  /// Slide In Transition
  static Widget slideIn({
    required Widget child,
    Duration duration = DesignTokens.durationNormal,
    Curve curve = DesignTokens.curveEaseOut,
    Offset begin = const Offset(0, 0.1),
    Offset end = Offset.zero,
  }) {
    return TweenAnimationBuilder<Offset>(
      tween: Tween(begin: begin, end: end),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(
            value.dx * MediaQuery.of(context).size.width,
            value.dy * MediaQuery.of(context).size.height,
          ),
          child: child,
        );
      },
      child: child,
    );
  }

  /// Scale In Transition
  static Widget scaleIn({
    required Widget child,
    Duration duration = DesignTokens.durationNormal,
    Curve curve = DesignTokens.curveSpring,
    double begin = 0.8,
    double end = 1.0,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: begin, end: end),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  }

  /// Fade & Slide Combination
  static Widget fadeSlideIn({
    required Widget child,
    Duration duration = DesignTokens.durationNormal,
    Curve curve = DesignTokens.curveEaseOut,
    Offset slideOffset = const Offset(0, 0.05),
  }) {
    return slideIn(
      duration: duration,
      curve: curve,
      begin: slideOffset,
      child: fadeIn(
        duration: duration,
        curve: curve,
        child: child,
      ),
    );
  }
}

/// Page Route Transitions
class AppPageRoute {
  AppPageRoute._();

  /// Fade Route
  static Route<T> fade<T>({
    required WidgetBuilder builder,
    RouteSettings? settings,
    Duration duration = DesignTokens.durationNormal,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => builder(context),
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  /// Slide Route (from right)
  static Route<T> slide<T>({
    required WidgetBuilder builder,
    RouteSettings? settings,
    Duration duration = DesignTokens.durationNormal,
    Offset begin = const Offset(1.0, 0.0),
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => builder(context),
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween(begin: begin, end: Offset.zero)
            .chain(CurveTween(curve: DesignTokens.curveEaseOut));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  /// Scale & Fade Route
  static Route<T> scaleFade<T>({
    required WidgetBuilder builder,
    RouteSettings? settings,
    Duration duration = DesignTokens.durationNormal,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => builder(context),
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final scaleTween = Tween(begin: 0.9, end: 1.0)
            .chain(CurveTween(curve: DesignTokens.curveSpring));
        final fadeTween =
            Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeIn));

        return FadeTransition(
          opacity: animation.drive(fadeTween),
          child: ScaleTransition(
            scale: animation.drive(scaleTween),
            child: child,
          ),
        );
      },
    );
  }

  /// Shared Axis Route (Material Design)
  static Route<T> sharedAxis<T>({
    required WidgetBuilder builder,
    RouteSettings? settings,
    Duration duration = DesignTokens.durationSlow,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => builder(context),
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Forward transition
        final enterTween = Tween(begin: const Offset(0.05, 0.0), end: Offset.zero)
            .chain(CurveTween(curve: DesignTokens.curveEaseOut));
        final enterFadeTween =
            Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeIn));

        // Backward transition
        final exitTween =
            Tween(begin: Offset.zero, end: const Offset(-0.05, 0.0))
                .chain(CurveTween(curve: DesignTokens.curveEaseOut));
        final exitFadeTween =
            Tween(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.easeOut));

        return Stack(
          children: [
            // Exiting page
            SlideTransition(
              position: secondaryAnimation.drive(exitTween),
              child: FadeTransition(
                opacity: secondaryAnimation.drive(exitFadeTween),
                child: child,
              ),
            ),
            // Entering page
            SlideTransition(
              position: animation.drive(enterTween),
              child: FadeTransition(
                opacity: animation.drive(enterFadeTween),
                child: child,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Stagger Animation Helper
class StaggeredAnimation extends StatelessWidget {
  final List<Widget> children;
  final Duration interval;
  final Duration initialDelay;
  final Axis direction;

  const StaggeredAnimation({
    super.key,
    required this.children,
    this.interval = const Duration(milliseconds: 80),
    this.initialDelay = Duration.zero,
    this.direction = Axis.vertical,
  });

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: direction,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        children.length,
        (index) {
          final delay = initialDelay + (interval * index);
          return _DelayedAnimation(
            delay: delay,
            child: children[index],
          );
        },
      ),
    );
  }
}

class _DelayedAnimation extends StatefulWidget {
  final Duration delay;
  final Widget child;

  const _DelayedAnimation({
    required this.delay,
    required this.child,
  });

  @override
  State<_DelayedAnimation> createState() => _DelayedAnimationState();
}

class _DelayedAnimationState extends State<_DelayedAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: DesignTokens.durationNormal,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: DesignTokens.curveEaseOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: DesignTokens.curveEaseOut,
      ),
    );

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}
