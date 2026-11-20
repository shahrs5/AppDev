import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_providers.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _signUp = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    final controller = ref.read(authControllerProvider.notifier);
    if (_signUp) {
      controller.signUp(_name.text, _email.text, _password.text);
    } else {
      controller.signIn(_email.text, _password.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authControllerProvider, (prev, next) {
      if (next.hasError) {
        final msg = next.error.toString().replaceFirst('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    });
    final loading = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: Text(_signUp ? 'Sign Up' : 'Login')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('IBA RoomBook', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (_signUp)
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'IBA email'),
          ),
          TextField(
            controller: _password,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Password'),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: loading ? null : _submit,
            child: Text(loading ? 'Please wait...' : (_signUp ? 'Create account' : 'Login')),
          ),
          TextButton(
            onPressed: () => setState(() => _signUp = !_signUp),
            child: Text(_signUp ? 'Have an account? Login' : 'New here? Sign up'),
          ),
        ],
      ),
    );
  }
}
