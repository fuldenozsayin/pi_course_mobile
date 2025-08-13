import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import 'register_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});
  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Giriş')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _form,
          child: Column(
            children: [
              TextFormField(
                controller: _email,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) => (v == null || v.isEmpty) ? 'Email zorunlu' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _password,
                decoration: const InputDecoration(labelText: 'Şifre'),
                obscureText: true,
                validator: (v) => (v == null || v.length < 6) ? 'Min 6 karakter' : null,
              ),
              const SizedBox(height: 16),
              if (auth.loading) const CircularProgressIndicator(),
              if (auth.error != null)
                Text(auth.error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: auth.loading
                    ? null
                    : () async {
                  if (!_form.currentState!.validate()) return;
                  await ref
                      .read(authNotifierProvider.notifier)
                      .login(_email.text.trim(), _password.text);

                  final u = ref.read(authNotifierProvider).user;
                  if (u != null && context.mounted) {
                    // >>> BURASI DEĞİŞTİ: named route ile /tutors
                    Navigator.of(context)
                        .pushReplacementNamed('/tutors');
                  }
                },
                child: const Text('Giriş Yap'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RegisterPage()),
                ),
                child: const Text('Hesabın yok mu? Kayıt ol'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
