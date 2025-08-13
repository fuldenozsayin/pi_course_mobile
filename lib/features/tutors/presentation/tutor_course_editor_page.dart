import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart'; // tutorRepositoryProvider
import '../../auth/providers.dart';

class TutorCourseEditorPage extends ConsumerStatefulWidget {
  const TutorCourseEditorPage({super.key});

  @override
  ConsumerState<TutorCourseEditorPage> createState() => _TutorCourseEditorPageState();
}

class _TutorCourseEditorPageState extends ConsumerState<TutorCourseEditorPage> {
  bool loading = true;
  String? loadError;

  final hourlyCtrl = TextEditingController();
  final ratingCtrl = TextEditingController();

  List<Map<String, dynamic>> allSubjects = [];
  final Set<int> selectedSubjectIds = <int>{};

  @override
  void initState() {
    super.initState();
    _guardAndLoad();
  }

  @override
  void dispose() {
    hourlyCtrl.dispose();
    ratingCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardAndLoad() async {
    final role = ref.read(authNotifierProvider).user?.role;
    if (role != 'tutor') {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bu sayfa yalnızca eğitmenler içindir.')),
      );
      Navigator.of(context).maybePop();
      return;
    }
    await _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      loadError = null;
    });
    try {
      final repo = ref.read(tutorRepositoryProvider);
      final me = await repo.meTutor();     // {subjects:[{id,name}], hourly_rate, rating}
      final subs = await repo.subjects();  // [{id,name}, ...]

      allSubjects = subs;
      selectedSubjectIds
        ..clear()
        ..addAll(((me['subjects'] ?? []) as List).map((e) => e['id'] as int));

      hourlyCtrl.text = me['hourly_rate']?.toString() ?? '';
      ratingCtrl.text = me['rating']?.toString() ?? '';
    } catch (e) {
      loadError = '$e';
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _save() async {
    final hr = int.tryParse(hourlyCtrl.text.trim());
    if (hr == null || hr < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saatlik ücret geçersiz.')),
      );
      return;
    }

    double r = double.tryParse(ratingCtrl.text.trim()) ?? 0.0;
    if (r < 0) r = 0;
    if (r > 5) r = 5;

    try {
      await ref.read(tutorRepositoryProvider).updateTutor(
        subjectIds: selectedSubjectIds.toList(),
        hourlyRate: hr,
        rating: r,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kaydedildi')),
      );
      Navigator.of(context).pop(true); // başarı → önceki sayfa refresh
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kaydedilemedi: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (loadError != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Ders Ayarları')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Yüklenemedi: $loadError', textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _load,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tekrar dene'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Ders Ayarları')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Ders(ler)', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),

            if (allSubjects.isEmpty)
              const Text('Sistem ders listesi boş.')
            else
              ...allSubjects.map((s) {
                final id = s['id'] as int;
                final name = s['name'] as String;
                final selected = selectedSubjectIds.contains(id);
                return CheckboxListTile(
                  value: selected,
                  onChanged: (v) {
                    setState(() {
                      if (v == true) {
                        selectedSubjectIds.add(id);
                      } else {
                        selectedSubjectIds.remove(id);
                      }
                    });
                  },
                  title: Text(name),
                  dense: true,
                  controlAffinity: ListTileControlAffinity.leading,
                );
              }),

            const Divider(height: 32),

            TextField(
              controller: hourlyCtrl,
              decoration: const InputDecoration(
                labelText: 'Saatlik Ücret (₺)',
                hintText: 'örn. 500',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 12),

            TextField(
              controller: ratingCtrl,
              decoration: const InputDecoration(
                labelText: 'Rating (0–5)',
                hintText: 'örn. 4.5',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
            ),
            const SizedBox(height: 16),

            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }
}
