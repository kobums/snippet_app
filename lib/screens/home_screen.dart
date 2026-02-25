import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/swipe_card.dart';
import '../providers/snippet_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(snippetProvider.notifier).fetchSnippets());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(snippetProvider);

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
            child: Center(
              child: Text(
                'SNIPPET',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 5.0,
                  color: Colors.black.withOpacity(0.55),
                ),
              ),
            ),
          ),
          Expanded(
            child: state.isLoading && state.snippets.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : state.snippets.isEmpty
                ? Center(
                    child: Text(
                      "더 이상 카드가 없습니다.\n보관함이나 위젯을 확인해보세요!",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black.withOpacity(0.55)),
                    ),
                  )
                : Stack(
                    alignment: Alignment.center,
                    children: state.snippets
                        .asMap()
                        .entries
                        .map((entry) {
                          final snippet = entry.value;
                          return Dismissible(
                            key: ValueKey(snippet.id),
                            direction: DismissDirection.horizontal,
                            onDismissed: (direction) {
                              final isLike =
                                  direction == DismissDirection.startToEnd;
                              ref
                                  .read(snippetProvider.notifier)
                                  .handleSwipe(snippet.id, isLike);
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 24,
                                right: 24,
                                bottom: 48,
                              ),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 400,
                                ),
                                child: SwipeCard(snippet: snippet),
                              ),
                            ),
                          );
                        })
                        .toList()
                        .reversed
                        .toList(),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 100.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '← Pass',
                  style: TextStyle(color: Colors.black.withOpacity(0.35)),
                ),
                const SizedBox(width: 48),
                Text(
                  'Like →',
                  style: TextStyle(color: Colors.black.withOpacity(0.35)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
