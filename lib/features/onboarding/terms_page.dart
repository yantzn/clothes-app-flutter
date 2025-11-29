import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/router.dart';
import 'presentation/onboarding_providers.dart';

class TermsPage extends ConsumerWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(onboardingProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7FAFD),
        elevation: 0,
        title: const Text(
          "利用規約",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ---- 白カード ----
            Expanded(
              child: Card(
                elevation: 0,
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: const BorderSide(color: Color(0xFFE7EDF3)),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: Text(
                      _dummyTerms,
                      style: TextStyle(fontSize: 14, height: 1.6),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ---- ボタン ----
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("同意しない"),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  controller.setAgreedTerms(true);
                  Navigator.pushReplacementNamed(
                    context,
                    AppRouter.registerUserInfo,
                  );
                },
                child: const Text("同意する"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const _dummyTerms = """
【利用規約（ダミー）】

ここにあなたの利用規約の文章が入ります。
内容は長文でも自動でスクロールされます。

""";
