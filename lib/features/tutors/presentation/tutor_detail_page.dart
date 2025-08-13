import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart'; // tutorRepositoryProvider
import '../data/models/tutor.dart';
import '../../auth/providers.dart'; // role kontrolü için
import '../../lessons/presentation/lesson_request_page.dart';

/// Eğitmen Detayı sayfası
class TutorDetailPage extends ConsumerWidget {
  final int tutorId;
  const TutorDetailPage({super.key, required this.tutorId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(_tutorDetailProvider(tutorId));
    final role = ref.watch(authNotifierProvider).user?.role; // 'student' | 'tutor' | null

    return Scaffold(
      appBar: AppBar(title: const Text('Eğitmen Detayı')),
      body: detail.when(
        data: (t) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(_tutorDetailProvider(tutorId));
            await Future<void>.delayed(const Duration(milliseconds: 200));
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Başlık
              Text(t.name, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),

              // Ücret ve Puan
              Row(
                children: [
                  _InfoPill(icon: Icons.schedule, text: '${t.hourly_rate}₺/saat'),
                  const SizedBox(width: 8),
                  _InfoPill(icon: Icons.star, text: t.rating.toStringAsFixed(1)),
                ],
              ),

              const SizedBox(height: 12),

              // Ders etiketleri (subjects)
              if (t.subjects.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: -6,
                  children: t.subjects
                      .map((s) => Chip(
                    label: Text(s.name),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ))
                      .toList(),
                ),
                const SizedBox(height: 12),
              ],

              // Bio
              Text(
                t.bio,
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              const SizedBox(height: 24),

              // Ders Talep Et butonu (sadece öğrenci için aktif)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.send),
                  label: const Text('Ders Talep Et'),
                  onPressed: role == 'student'
                      ? () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => LessonRequestPage(tutorId: t.id),
                      ),
                    );
                  }
                      : null, // tutor veya anonim ise disabled
                ),
              ),
              if (role != 'student')
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Ders talebi yalnızca öğrenci hesabıyla yapılabilir.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.outline,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Hata: $e'),
          ),
        ),
      ),
    );
  }
}

// Detay provider: autoDispose + family
final _tutorDetailProvider =
FutureProvider.autoDispose.family<Tutor, int>((ref, id) async {
  final repo = ref.read(tutorRepositoryProvider);
  return repo.detail(id);
});

/// Küçük bilgi rozeti
class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoPill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: icon == Icons.star ? Colors.amber : cs.primary,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: cs.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
