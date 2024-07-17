import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppBackButton extends StatelessWidget {
  const AppBackButton({
    super.key,
    this.onPressed,
  });

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      style: IconButton.styleFrom(
        backgroundColor: Colors.transparent,
        padding: EdgeInsets.zero,
      ),
      icon: const Icon(Icons.arrow_back_rounded),
      onPressed: () {
        if (onPressed != null) {
          return onPressed!.call();
        }

        context.pop();
      },
    );
  }
}
