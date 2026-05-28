import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class _CurrentPageNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setPage(int index) {
    state = index;
  }
}

final _currentPageProvider = NotifierProvider<_CurrentPageNotifier, int>(
  _CurrentPageNotifier.new,
);

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPage = ref.watch(_currentPageProvider);
    final pageController = PageController();

    final titles = [
      "تصفح آلاف الإعلانات الفلاحية",
      "تواصل مع الفلاحين مباشرة",
      "أنت فلاح؟ انشر إعلانك في دقائق"
    ];
    
    final subtitles = [
      "Browse thousands of agricultural listings",
      "Contact farmers directly by phone or WhatsApp",
      "Are you a farmer? Post your listing in minutes"
    ];

    void onSkip() => context.go('/');
    
    void onNext() {
      if (currentPage == 2) {
        onSkip();
      } else {
        pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      }
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: AlignmentDirectional.topEnd,
              child: TextButton(
                onPressed: onSkip,
                child: const Text('Skip', style: TextStyle(color: AppTheme.primary, fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: pageController,
                onPageChanged: (index) => ref.read(_currentPageProvider.notifier).setPage(index),
                itemCount: 3,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Ram motif representation
                        const Icon(Icons.pets, size: 100, color: AppTheme.accent),
                        const SizedBox(height: 40),
                        Text(
                          titles[index],
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primary, fontFamily: 'Cairo'),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          subtitles[index],
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16, color: Colors.black54, fontFamily: 'Cairo'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      3,
                      (index) => Container(
                        margin: const EdgeInsetsDirectional.only(end: 8),
                        width: currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: currentPage == index ? AppTheme.primary : AppTheme.secondary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: AppTheme.secondary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      minimumSize: const Size(100, 48),
                    ),
                    child: Text(currentPage == 2 ? 'Start' : 'Next'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
