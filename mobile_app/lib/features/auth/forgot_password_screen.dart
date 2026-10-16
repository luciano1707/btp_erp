import 'package:flutter/material.dart';

import '../../core/api_client.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({required this.api, super.key});

  final ApiClient api;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _email = TextEditingController();
  final _code = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  bool _codeSent = false;
  bool _busy = false;
  bool _hidePassword = true;

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Réinitialiser le mot de passe')),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      Text(_codeSent ? 'Saisissez le code reçu par e-mail et votre nouveau mot de passe.' : 'Un code temporaire sera envoyé à votre adresse e-mail.'),
      const SizedBox(height: 18),
      TextField(controller: _email, keyboardType: TextInputType.emailAddress, enabled: !_codeSent, decoration: const InputDecoration(labelText: 'Adresse e-mail')),
      if (_codeSent) ...[
        const SizedBox(height: 12),
        TextField(controller: _code, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Code à 6 chiffres')),
        const SizedBox(height: 12),
        TextField(controller: _password, obscureText: _hidePassword, decoration: InputDecoration(labelText: 'Nouveau mot de passe', suffixIcon: IconButton(tooltip: _hidePassword ? 'Afficher' : 'Masquer', onPressed: () => setState(() => _hidePassword = !_hidePassword), icon: Icon(_hidePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined)))),
        const SizedBox(height: 12),
        TextField(controller: _confirmation, obscureText: _hidePassword, decoration: const InputDecoration(labelText: 'Confirmer le mot de passe')),
      ],
      const SizedBox(height: 20),
      FilledButton(onPressed: _busy ? null : (_codeSent ? _reset : _requestCode), child: Text(_busy ? 'Veuillez patienter…' : (_codeSent ? 'Réinitialiser' : 'Envoyer le code'))),
    ]),
  );

  Future<void> _requestCode() async {
    final email = _email.text.trim();
    if (!email.contains('@')) return _message('Saisissez une adresse e-mail valide.');
    setState(() => _busy = true);
    try {
      await widget.api.post('auth/mot-de-passe-oublie', {'email': email});
      if (mounted) setState(() => _codeSent = true);
      _message('Si un compte correspond à cette adresse, un code a été envoyé.');
    } catch (error) {
      _message(error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reset() async {
    if (_code.text.trim().isEmpty || _password.text.length < 8) {
      return _message('Le code est requis et le mot de passe doit contenir au moins 8 caractères.');
    }
    if (_password.text != _confirmation.text) return _message('Les deux mots de passe sont différents.');
    setState(() => _busy = true);
    try {
      await widget.api.post('auth/reinitialiser-mot-de-passe', {
        'email': _email.text.trim(),
        'code': _code.text.trim(),
        'nouveau_mot_de_passe': _password.text,
        'nouveau_mot_de_passe_confirmation': _confirmation.text,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mot de passe réinitialisé. Vous pouvez vous connecter.')));
        Navigator.pop(context);
      }
    } catch (error) {
      _message(error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _message(String message) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}