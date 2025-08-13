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
  final _email = TextEditingController();
  final _username = TextEditingController();

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
    _email.text = (me?['email'] ?? '') as String;
    _username.text = (me?['username'] ?? '') as String;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (me == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final role = (me!['role'] ?? '') as String;
    final isStudent = role == 'student';
    final isTutor = role == 'tutor';

    return Scaffold(
      appBar: AppBar(title: const Text('Profilim')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // Başlık bilgiler
            Text('Rol: $role'),
            const SizedBox(height: 16),

            // Öğrenciye: email & username düzenlenebilir
            if (isStudent) ...[
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _username,
                decoration: const InputDecoration(labelText: 'Kullanıcı adı'),
              ),
              const SizedBox(height: 8),
            ] else ...[
              Text('Email: ${me!['email']}'),
              Text('Kullanıcı adı: ${me!['username']}'),
              const SizedBox(height: 8),
            ],

            // Eğitmene: Bio düzenlenebilir
            if (isTutor) ...[
              TextField(
                controller: _bio,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Bio'),
              ),
              const SizedBox(height: 8),
            ] else ...[
              // Öğrencide bio gösterilebilir (opsiyonel)
              if ((_bio.text).isNotEmpty) ...[
                const Text('Bio'),
                const SizedBox(height: 4),
                Text(_bio.text),
                const SizedBox(height: 8),
              ],
            ],

            // Öğrenciye: Sınıf alanı düzenlenebilir
            if (isStudent) ...[
              TextField(
                controller: _grade,
                decoration: const InputDecoration(labelText: 'Sınıf (öğrenci için)'),
              ),
              const SizedBox(height: 16),
            ] else ...[
              if (_grade.text.isNotEmpty) Text('Sınıf: ${_grade.text}'),
              const SizedBox(height: 16),
            ],

            // Kaydet
            ElevatedButton(
              onPressed: () async {
                final payload = <String, dynamic>{};

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

                await ref.read(authRepositoryProvider).updateMe(payload);
                if (!mounted) return;
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('Güncellendi')));
              },
              child: const Text('Kaydet'),
            ),

            // Eğitmene: Verdiğim Dersler kısayolu (sayfan hazırsa açılır)
            if (isTutor) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.menu_book),
                label: const Text('Verdiğim Dersler'),
                onPressed: () {
                  // Eğer route tanımladıysan:
                  // Navigator.of(context).pushNamed('/tutor/subjects');
                  // veya sayfayı doğrudan import edip:
                  // Navigator.of(context).push(MaterialPageRoute(
                  //   builder: (_) => const TutorSubjectsPage(),
                  // ));
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
