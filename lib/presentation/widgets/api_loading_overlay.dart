import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:prod_kagitoban_app/core/api_loading_controller.dart';

class ApiLoadingOverlay extends StatelessWidget {
  final Widget child;

  const ApiLoadingOverlay({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ApiLoadingController.instance,
      builder: (context, _) {
        return Stack(
          children: [
            child,
            if (ApiLoadingController.instance.isLoading)
              const Positioned.fill(
                child: AbsorbPointer(child: _LoadingView()),
              ),
          ],
        );
      },
    );
  }
}

class ApiLoadingScreen extends StatelessWidget {
  const ApiLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: _LoadingView());
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.primary,
      child: Center(
        child: LoadingAnimationWidget.fourRotatingDots(
          color: Colors.white,
          size: 100,
        ),
      ),
    );
  }
}
