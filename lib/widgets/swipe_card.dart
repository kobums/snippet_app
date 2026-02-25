import 'package:flutter/material.dart';
import 'glass_container.dart';
import '../models/snippet.dart';

class SwipeCard extends StatelessWidget {
  final Snippet snippet;

  const SwipeCard({super.key, required this.snippet});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.35),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: Colors.white.withOpacity(0.4)),
              ),
              child: Text(
                snippet.tag,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.black.withOpacity(0.55),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Container(
                constraints: const BoxConstraints(minHeight: 180),
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '“${snippet.text}”',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        height: 1.6,
                        fontWeight: FontWeight.w300,
                        color: Colors.black.withOpacity(0.85),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (snippet.bookTitle != null) ...[
                      const SizedBox(height: 20),
                      Text(
                        snippet.bookTitle!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.black.withOpacity(0.45),
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: 48,
            height: 2,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}
