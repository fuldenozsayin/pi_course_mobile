import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';

class MePage extends ConsumerStatefulWidget {
  const MePage({super.key});
  @override
  ConsumerState<MePage> createState() => _MePageState();
}

class _MePageState extends ConsumerState<MePage> {
  final _bio = TextEditingController();
  final _grade = TextEditingController();

  Map<String, dynamic>? me;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    me = await ref.read(authRepositoryProvider).meRaw();
    _bio.text = (me?['bio'] ?? '') as String;
    _grade.text = (me?['grade_level'] ?? '') as String;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (me == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Profilim')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text('Email: ${me!['email']}'),
            Text('Kullanıcı adı: ${me!['username']}'),
            Text('Rol: ${me!['role']}'),
            const SizedBox(height: 16),
            TextField(controller: _bio, maxLines: 3, decoration: const InputDecoration(labelText: 'Bio')),
            const SizedBox(height: 8),
            TextField(controller: _grade, decoration: const InputDecoration(labelText: 'Sınıf (öğrenci için)')),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await ref.read(authRepositoryProvider).updateMe({
                  'bio': _bio.text,
                  'grade_level': _grade.text.isEmpty ? null : _grade.text,
                });
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Güncellendi')));
              },
              child: const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }
}
