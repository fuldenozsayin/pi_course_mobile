import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../subjects/providers.dart';
import '../../subjects/data/models/subject.dart';

import '../providers.dart';
import '../data/models/tutor.dart';
import 'tutor_detail_page.dart';

// Menüde role'e göre seçenek göstermek için
import '../../auth/providers.dart';

class TutorListPage extends ConsumerStatefulWidget {
  const TutorListPage({super.key});

  @override
  ConsumerState<TutorListPage> createState() => _TutorListPageState();
}

class _TutorListPageState extends ConsumerState<TutorListPage> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    final state = ref.read(tutorListControllerProvider);
    if (!state.hasMore || state.loadingMore) return;

    final threshold = 0.8 * _scroll.position.maxScrollExtent;
    if (_scroll.position.pixels >= threshold) {
      ref.read(tutorListControllerProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final subjects = ref.watch(subjectsProvider);
    final params = ref.watch(tutorListParamsProvider);
    final listState = ref.watch(tutorListControllerProvider);

    // YENİ: rol
    final auth = ref.watch(authNotifierProvider);
    final role = auth.user?.role; // 'student' | 'tutor'

    return Scaffold(
      appBar: AppBar(
        title: const Text('Eğitmenler'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) async {
              switch (v) {
                case 'me':
                  Navigator.of(context).pushNamed('/me');
                  break;
                case 'my_requests':
                  Navigator.of(context).pushNamed('/my_requests');
                  break;
                case 'incoming':
                  Navigator.of(context).pushNamed('/incoming_requests');
                  break;
                case 'logout':
                  await ref.read(authNotifierProvider.notifier).logout();
                  if (context.mounted) {
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil('/', (r) => false);
                  }
                  break;
              }
            },
            itemBuilder: (ctx) => <PopupMenuEntry<String>>[
              const PopupMenuItem(value: 'me', child: Text('Profilim')),
              if (role == 'student')
                const PopupMenuItem(
                    value: 'my_requests', child: Text('Taleplerim')),
              if (role == 'tutor')
                const PopupMenuItem(
                    value: 'incoming', child: Text('Gelen Talepler')),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'logout', child: Text('Çıkış yap')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _Filters(subjects: subjects, params: params),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await ref
                    .read(tutorListControllerProvider.notifier)
                    .refreshWith({...params});
              },
              child: Builder(
                builder: (_) {
                  if (listState.loading && listState.items.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (listState.error != null && listState.items.isEmpty) {
                    return _ErrorView(
                      message: listState.error!,
                      onRetry: () => ref
                          .read(tutorListControllerProvider.notifier)
                          .refreshWith({...params}),
                    );
                  }
                  if (listState.items.isEmpty) {
                    return const _EmptyView();
                  }
                  return ListView.separated(
                    controller: _scroll,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: listState.items.length + 1, // +1 => loader alanı
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      if (i == listState.items.length) {
                        // alt yükleme göstergesi
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child: listState.loadingMore
                                ? const CircularProgressIndicator()
                                : listState.hasMore
                                ? const Text('Daha fazlası için aşağı kaydırın…')
                                : const Text('Hepsi yüklendi'),
                          ),
                        );
                      }
                      final t = listState.items[i];
                      return _TutorTile(tutor: t);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TutorTile extends StatelessWidget {
  final Tutor tutor;
  const _TutorTile({required this.tutor});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(tutor.name),
      subtitle: Text(
        '${tutor.subjects.map((e) => e.name).join(', ')}\n${tutor.bio}',
      ),
      isThreeLine: true,
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('${tutor.hourly_rate}₺/saat'),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 16),
              const SizedBox(width: 4),
              Text(tutor.rating.toStringAsFixed(1)),
            ],
          ),
        ],
      ),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => TutorDetailPage(tutorId: tutor.id)),
      ),
    );
  }
}

class _Filters extends ConsumerWidget {
  final AsyncValue<List<Subject>> subjects;
  final Map<String, dynamic> params;
  const _Filters({required this.subjects, required this.params});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Ara (ad/bio)',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onSubmitted: (v) {
                    final next = {...params, 'search': v};
                    ref.read(tutorListControllerProvider.notifier).refreshWith(next);
                  },
                ),
              ),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: params['ordering'] as String,
                items: const [
                  DropdownMenuItem(value: '-rating', child: Text('Puana göre (↓)')),
                  DropdownMenuItem(value: 'rating', child: Text('Puana göre (↑)')),
                ],
                onChanged: (v) {
                  final next = {...params, 'ordering': v!};
                  ref.read(tutorListControllerProvider.notifier).refreshWith(next);
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          subjects.when(
            data: (list) {
              final int? selected = params['subjectId'] as int?;
              return DropdownButton<int?>(
                isExpanded: true,
                value: selected,
                items: [
                  const DropdownMenuItem(value: null, child: Text('Tüm dersler')),
                  ...list.map((s) =>
                      DropdownMenuItem(value: s.id, child: Text(s.name))),
                ],
                onChanged: (v) {
                  final next = {...params, 'subjectId': v};
                  ref.read(tutorListControllerProvider.notifier).refreshWith(next);
                },
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Subject hata: $e'),
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Text('Sonuç bulunamadı'),
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
            Text('Bir şeyler ters gitti.\n$message',
                textAlign: TextAlign.center),
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
