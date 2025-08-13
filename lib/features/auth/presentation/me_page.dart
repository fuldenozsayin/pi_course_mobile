import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';

class MePage extends ConsumerStatefulWidget {
  const MePage({super.key});
  @override
  ConsumerState<MePage> createState() => _MePageState();
}

class _MePageState extends ConsumerState<MePage> {
  final _form = GlobalKey<FormState>();

  final _email = TextEditingController();
  final _username = TextEditingController();
  final _grade = TextEditingController();
  final _bio = TextEditingController();

  Map<String, dynamic>? _me;
  String _role = '';

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _email.dispose();
    _username.dispose();
    _grade.dispose();
    _bio.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final me = await ref.read(authRepositoryProvider).meRaw();
      _me = me;
      _role = (me['role'] ?? '') as String;

      _email.text = (me['email'] ?? '') as String;
      _username.text = (me['username'] ?? '') as String;
      _grade.text = (me['grade_level'] ?? '') as String;
      _bio.text = (me['bio'] ?? '') as String;
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;

    final isStudent = _role == 'student';
    final isTutor = _role == 'tutor';

    final payload = <String, dynamic>{};

    // Sadece role'e açık alanları gönder
    if (isStudent) {
      payload['email'] = _email.text.trim();
      payload['username'] = _username.text.trim();
      payload['grade_level'] =
      _grade.text.trim().isEmpty ? null : _grade.text.trim();
    }
    if (isTutor) {
      payload['bio'] = _bio.text.trim();
    }

    if (payload.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Güncellenecek alan yok')),
      );
      return;
    }

    try {
      await ref.read(authRepositoryProvider).updateMe(payload);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Güncellendi')),
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profilim')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Hata: $_error'),
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

    final isStudent = _role == 'student';
    final isTutor = _role == 'tutor';

    return Scaffold(
      appBar: AppBar(title: const Text('Profilim')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Sabit bilgiler (okunur)
              Text('Rol: $_role'),
              const SizedBox(height: 16),

              // STUDENT → email & username düzenlenir; TUTOR’da sadece göster
              if (isStudent) ...[
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (v) =>
                  (v == null || v.isEmpty) ? 'Email zorunlu' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _username,
                  decoration: const InputDecoration(labelText: 'Kullanıcı adı'),
                  validator: (v) =>
                  (v == null || v.isEmpty) ? 'Kullanıcı adı zorunlu' : null,
                ),
                const SizedBox(height: 8),
              ] else ...[
                Text('Email: ${_email.text}'),
                Text('Kullanıcı adı: ${_username.text}'),
                const SizedBox(height: 8),
              ],

              // TUTOR → sadece bio düzenlenir; STUDENT’ta gizli
              if (isTutor) ...[
                TextFormField(
                  controller: _bio,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Bio (eğitmen)'),
                ),
                const SizedBox(height: 8),
              ],

              // STUDENT → grade düzenlenir; TUTOR’da gizli
              if (isStudent) ...[
                TextFormField(
                  controller: _grade,
                  decoration:
                  const InputDecoration(labelText: 'Sınıf (öğrenci için)'),
                ),
                const SizedBox(height: 16),
              ],

              // Kaydet
              FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text('Kaydet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
