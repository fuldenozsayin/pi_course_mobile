import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/models/lesson_request.dart';
import '../providers.dart' as lessons;
import '../../subjects/providers.dart';

class MyRequestsPage extends ConsumerStatefulWidget {
  const MyRequestsPage({super.key});
  @override
  ConsumerState<MyRequestsPage> createState() => _MyRequestsPageState();
}

class _MyRequestsPageState extends ConsumerState<MyRequestsPage> {
  String? _status;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(lessons.myRequestsFilterProvider.notifier)
          .state = {'role': 'student', 'status': _status};
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
    final subjects = ref.watch(subjectsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Taleplerim (Öğrenci)')),
      body: Column(
        children: [
          _StatusChips(
            selected: _status,
            onChanged: (s) {
              setState(() => _status = s);
              ref.read(lessons.myRequestsFilterProvider.notifier)
                  .state = {'role': 'student', 'status': s};
              ref.invalidate(lessons.myRequestsProvider);
            },
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: reqs.when(
                data: (list) {
                  if (list.isEmpty) return const _EmptyView(message: 'Talebiniz bulunmuyor');
                  return subjects.when(
                    data: (subs) {
                      final byId = {for (final s in subs) s.id: s.name};
                      return ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: list.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, i) =>
                            _StudentRequestTile(item: list[i], subjectById: byId),
                      );
                    },
                    loading: () => const _LoadingView(),
                    error: (e, _) =>
                        _ErrorView(message: 'Dersler yüklenemedi: $e', onRetry: _refresh),
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

class _StudentRequestTile extends StatelessWidget {
  final LessonRequest item;
  final Map<int, String> subjectById;
  const _StudentRequestTile({required this.item, required this.subjectById});

  String _pretty(String iso, int minutes) {
    if (iso.isEmpty) return '-';
    try {
      final dt = DateTime.parse(iso).toLocal();
      final d = DateFormat('EEE, d MMM HH:mm', 'tr_TR').format(dt);
      return '$d • $minutes dk';
    } catch (_) {
      return '$iso • $minutes dk';
    }
  }

  @override
  Widget build(BuildContext context) {
    final subjectLabel =
        item.subject_name ??
            subjectById[item.subjectId] ??
            (item.subjectId > 0 ? 'Ders #${item.subjectId}' : 'Ders');

    final info = _pretty(item.startTime, item.durationMinutes);

    return ListTile(
      title: Text(subjectLabel),
      subtitle: Text('$info\nDurum: ${item.status}'),
      isThreeLine: true,
      trailing: _StatusBadge(status: item.status),
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
      null: 'Hepsi',
      'pending': 'Bekleyen',
      'approved': 'Onaylı',
      'rejected': 'Reddedilen',
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

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});
  Color _bg() {
    switch (status) {
      case 'approved':
        return Colors.green.shade100;
      case 'rejected':
        return Colors.red.shade100;
      default:
        return Colors.amber.shade100;
    }
  }
  Color _fg() {
    switch (status) {
      case 'approved':
        return Colors.green.shade800;
      case 'rejected':
        return Colors.red.shade800;
      default:
        return Colors.amber.shade800;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: _bg(), borderRadius: BorderRadius.circular(12)),
      child: Text(status, style: TextStyle(fontWeight: FontWeight.w600, color: _fg())),
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
