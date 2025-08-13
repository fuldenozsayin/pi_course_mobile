import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/models/lesson_request.dart';
import '../data/lesson_repository.dart' as data_repo hide lessonRepositoryProvider;
import '../providers.dart' as lessons;

class IncomingRequestsPage extends ConsumerStatefulWidget {
  const IncomingRequestsPage({super.key});
  @override
  ConsumerState<IncomingRequestsPage> createState() => _IncomingRequestsPageState();
}

class _IncomingRequestsPageState extends ConsumerState<IncomingRequestsPage> {
  String? _status = 'pending'; // bekleyen varsayılan

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(lessons.myRequestsFilterProvider.notifier)
          .state = {'role': 'tutor', 'status': _status};
      ref.invalidate(lessons.myRequestsProvider);
    });
  }

  Future<void> _refresh() async {
    ref.invalidate(lessons.myRequestsProvider);
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }

  @override
  Widget build(BuildContext context) {
    final reqs = ref.watch(lessons.myRequestsProvider);
    final repo = ref.read(lessons.lessonRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Gelen Talepler (Eğitmen)')),
      body: Column(
        children: [
          _StatusChips(
            selected: _status,
            onChanged: (s) {
              setState(() => _status = s);
              ref.read(lessons.myRequestsFilterProvider.notifier)
                  .state = {'role': 'tutor', 'status': s};
              ref.invalidate(lessons.myRequestsProvider);
            },
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: reqs.when(
                data: (list) {
                  if (list.isEmpty) {
                    return const _EmptyView(message: 'Gelen talep bulunmadı');
                  }
                  return ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) => _TutorRequestTile(
                      item: list[i],
                      repo: repo,
                      refresh: _refresh,
                    ),
                  );
                },
                loading: () => const _LoadingView(),
                error: (e, _) => _ErrorView(message: e.toString(), onRetry: _refresh),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TutorRequestTile extends StatelessWidget {
  final LessonRequest item;
  final data_repo.LessonRepository repo;
  final Future<void> Function() refresh;
  const _TutorRequestTile({
    required this.item,
    required this.repo,
    required this.refresh,
  });

  // —— kullanıcı dostu zaman metni ——
  String _pretty(String iso, int minutes) {
    if (iso.isEmpty) return '-';
    try {
      final dt = DateTime.parse(iso).toLocal();
      // Örn: Per, 22 Ağu 15:49 • 60 dk   (hafta günü kısaltmalı)
      final d = DateFormat('EEE, d MMM HH:mm', 'tr_TR').format(dt);
      return '$d • $minutes dk';
    } catch (_) {
      return '$iso • $minutes dk';
    }
  }

  @override
  Widget build(BuildContext context) {
    final subjectLabel =
        item.subject_name ?? (item.subjectId > 0 ? 'Ders #${item.subjectId}' : 'Ders');

    final info = _pretty(item.startTime, item.durationMinutes);

    return ListTile(
      title: Text(subjectLabel),
      subtitle: Text('$info\nDurum: ${item.status}'),
      isThreeLine: true,
      trailing: Wrap(
        spacing: 8,
        children: [
          OutlinedButton(
            onPressed: item.status == 'pending'
                ? () async {
              try {
                await repo.changeStatus(id: item.id, status: 'rejected');
                await refresh();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Reddedildi')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Hata: $e')),
                  );
                }
              }
            }
                : null,
            child: const Text('Reddet'),
          ),
          ElevatedButton(
            onPressed: item.status == 'pending'
                ? () async {
              try {
                await repo.changeStatus(id: item.id, status: 'approved');
                await refresh();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Onaylandı')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Hata: $e')),
                  );
                }
              }
            }
                : null,
            child: const Text('Onayla'),
          ),
        ],
      ),
    );
  }
}

class _StatusChips extends StatelessWidget {
  final String? selected;
  final void Function(String?) onChanged;
  const _StatusChips({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final items = <String?, String>{
      'pending': 'Bekleyen',
      'approved': 'Onaylı',
      'rejected': 'Reddedilen',
      null: 'Hepsi',
    };
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(8),
      child: Row(
        children: items.entries.map((e) {
          final sel = selected == e.key;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(e.value),
              selected: sel,
              onSelected: (_) => onChanged(e.key),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();
  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}

class _ErrorView extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;
  const _ErrorView({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text('Bir şeyler ters gitti.\n$message', textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Tekrar dene'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyView extends StatelessWidget {
  final String message;
  const _EmptyView({required this.message});
  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.all(32),
          child: Center(child: Text(message)),
        ),
      ],
    );
  }
}
