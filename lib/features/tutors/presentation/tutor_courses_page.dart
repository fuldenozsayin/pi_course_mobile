import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/tutor_repository.dart';
import '../providers.dart';
import 'tutor_course_editor_page.dart';

class TutorCoursesPage extends ConsumerWidget {
  const TutorCoursesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(tutorRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Verdiğim Dersler')),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Yeni / Düzenle'),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const TutorCourseEditorPage()),
          );
        },
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: repo.meTutor(),
        builder: (ctx, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return _ErrorView(
              message: snap.error.toString(),
              onRetry: () => ref.refresh(tutorRepositoryProvider),
            );
          }

          final me = snap.data!;
          // Bazı backend’lerde subjects int listesi, bazılarında obje listesi olabilir.
          List<int> subjectIds = [];
          final raw = me['subjects'];
          if (raw is List) {
            for (final x in raw) {
              if (x is int) subjectIds.add(x);
              if (x is Map && x['id'] is int) subjectIds.add(x['id'] as int);
            }
          }

          final hourly = me['hourly_rate'];
          final rating = me['rating'];

          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                Text('Özet', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text('Saatlik Ücret: ${hourly ?? '-'} ₺'),
                Text('Puan: ${rating ?? '-'}'),
                const Divider(height: 32),
                Text('Derslerim', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                if (subjectIds.isEmpty)
                  const Text('Henüz ders eklemediniz.')
                else
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: repo.subjects(),
                    builder: (ctx, s2) {
                      if (s2.connectionState != ConnectionState.done) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 12),
                          child: LinearProgressIndicator(),
                        );
                      }
                      if (s2.hasError) {
                        return Text('Dersler yüklenemedi: ${s2.error}');
                      }
                      final all = s2.data!;
                      final names = all
                          .where((e) => subjectIds.contains(e['id'] as int))
                          .map((e) => e['name'] as String)
                          .toList();
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: names.map((n) => Chip(label: Text(n))).toList(),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Hata: $message', textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Tekrar dene'),
            ),
          ],
        ),
      ),
    );
  }
}
