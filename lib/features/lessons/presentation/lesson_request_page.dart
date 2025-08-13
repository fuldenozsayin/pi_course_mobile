import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../subjects/providers.dart';
import '../providers.dart';

class LessonRequestPage extends ConsumerStatefulWidget {
  final int tutorId;
  const LessonRequestPage({super.key, required this.tutorId});

  @override
  ConsumerState<LessonRequestPage> createState() => _LessonRequestPageState();
}

class _LessonRequestPageState extends ConsumerState<LessonRequestPage> {
  final _form = GlobalKey<FormState>();

  int? _subjectId;
  DateTime? _pickedDate;
  TimeOfDay? _pickedTime;

  final _duration = TextEditingController(text: '60');
  final _note = TextEditingController();

  // Görünen metinler
  String get _dateLabel {
    if (_pickedDate == null) return '';
    // Örn: Per, 22 Ağu 2025
    return DateFormat('EEE, d MMM yyyy', 'tr_TR').format(_pickedDate!);
  }

  String get _timeLabel {
    if (_pickedTime == null) return '';
    final h = _pickedTime!.hour.toString().padLeft(2, '0');
    final m = _pickedTime!.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  // Sunucuya gidecek ISO (UTC, Z)
  String _buildUtcIso() {
    final d = _pickedDate!;
    final t = _pickedTime!;
    final local = DateTime(d.year, d.month, d.day, t.hour, t.minute);
    return DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(local.toUtc());
  }

  @override
  Widget build(BuildContext context) {
    final subjects = ref.watch(subjectsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ders Talebi')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: subjects.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Hata: $e')),
          data: (list) => Form(
            key: _form,
            child: ListView(
              children: [
                // Ders seçimi
                DropdownButtonFormField<int>(
                  value: _subjectId,
                  items: list
                      .map((s) => DropdownMenuItem(
                    value: s.id,
                    child: Text(s.name),
                  ))
                      .toList(),
                  onChanged: (v) => setState(() => _subjectId = v),
                  decoration: const InputDecoration(labelText: 'Ders'),
                  validator: (v) => v == null ? 'Ders seçin' : null,
                ),
                const SizedBox(height: 12),

                // Tarih
                TextFormField(
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Tarih',
                    hintText: 'Gün seçin',
                    suffixIcon: const Icon(Icons.event),
                  ),
                  controller: TextEditingController(text: _dateLabel),
                  onTap: () async {
                    final now = DateTime.now();
                    final d = await showDatePicker(
                      context: context,
                      firstDate: now,
                      lastDate: now.add(const Duration(days: 365)),
                      initialDate: _pickedDate ?? now,
                      locale: const Locale('tr', 'TR'),
                    );
                    if (d != null) setState(() => _pickedDate = d);
                  },
                  validator: (_) => _pickedDate == null ? 'Tarih seçin' : null,
                ),
                const SizedBox(height: 12),

                // Saat
                TextFormField(
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Saat',
                    hintText: 'Saat seçin',
                    suffixIcon: Icon(Icons.schedule),
                  ),
                  controller: TextEditingController(text: _timeLabel),
                  onTap: () async {
                    final t = await showTimePicker(
                      context: context,
                      initialTime: _pickedTime ?? TimeOfDay.now(),
                      builder: (context, child) => MediaQuery(
                        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                        child: child ?? const SizedBox.shrink(),
                      ),
                    );
                    if (t != null) setState(() => _pickedTime = t);
                  },
                  validator: (_) => _pickedTime == null ? 'Saat seçin' : null,
                ),
                const SizedBox(height: 12),

                // Süre
                TextFormField(
                  controller: _duration,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Süre (dakika)'),
                  validator: (v) =>
                  (v == null || int.tryParse(v) == null) ? 'Sayı girin' : null,
                ),
                const SizedBox(height: 12),

                // Not
                TextFormField(
                  controller: _note,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Not (opsiyonel)',
                  ),
                ),

                // Özet satırı
                if (_pickedDate != null && _pickedTime != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Seçilen: ${DateFormat('EEE, d MMM yyyy', 'tr_TR').format(_pickedDate!)} • $_timeLabel • ${_duration.text} dk',
                    style: TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                ],

                const SizedBox(height: 20),

                // Gönder
                FilledButton(
                  onPressed: () async {
                    if (!_form.currentState!.validate()) return;

                    try {
                      final utcIso = _buildUtcIso();
                      await ref.read(lessonRepositoryProvider).create(
                        tutorId: widget.tutorId,
                        subjectId: _subjectId!,
                        startTime: utcIso, // backend’e UTC ISO gönderiyoruz
                        durationMinutes: int.parse(_duration.text),
                        note: _note.text.trim().isEmpty ? null : _note.text.trim(),
                      );
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Talep oluşturuldu')),
                      );
                      Navigator.of(context).pop();
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Talep başarısız: $e')),
                      );
                    }
                  },
                  child: const Text('Gönder'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
