import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});
  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  String _role = 'student';

  @override
  void dispose() {
    _email.dispose();
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Kayıt')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _form,
          child: ListView(
            children: [
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) => (v == null || v.isEmpty) ? 'Email zorunlu' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _username,
                decoration: const InputDecoration(labelText: 'Kullanıcı adı'),
                validator: (v) => (v == null || v.isEmpty) ? 'Kullanıcı adı zorunlu' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _password,
                decoration: const InputDecoration(labelText: 'Şifre'),
                obscureText: true,
                validator: (v) => (v == null || v.length < 6) ? 'Min 6 karakter' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _role,
                decoration: const InputDecoration(labelText: 'Rol'),
                items: const [
                  DropdownMenuItem(value: 'student', child: Text('Öğrenci')),
                  DropdownMenuItem(value: 'tutor', child: Text('Eğitmen')),
                ],
                onChanged: (String? v) => setState(() => _role = v ?? 'student'),
              ),
              const SizedBox(height: 16),

              if (auth.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(auth.error!, style: const TextStyle(color: Colors.red)),
                ),

              ElevatedButton(
                onPressed: auth.loading
                    ? null
                    : () async {
                  if (!_form.currentState!.validate()) return;

                  // !!! Buradaki parametre sırasını kendi register(...) imzana göre ayarla
                  await ref.read(authNotifierProvider.notifier).register(
                    _email.text.trim(),
                    _username.text.trim(),
                    _password.text,
                    _role,
                  );

                  if (!mounted) return;
                  if (ref.read(authNotifierProvider).user != null) {
                    Navigator.of(context).pop(); // Login'e geri
                  }
                },
                child: auth.loading
                    ? const SizedBox(
                  width: 18, height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text('Kayıt Ol'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
