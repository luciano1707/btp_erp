import 'package:flutter/material.dart';

import '../../shared/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({required this.busy, required this.onLogin, required this.onForgotPassword, super.key});

  final bool busy;
  final Future<void> Function(String, String) onLogin;
  final VoidCallback onForgotPassword;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _hidePassword = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 36, 24, 28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Form(
              key: _formKey,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(width: 54, height: 54, decoration: BoxDecoration(color: AppColors.forest, borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.foundation, color: AppColors.lime, size: 29)),
                const SizedBox(height: 42),
                const Text('DIGITAL CHANTIER', style: TextStyle(color: AppColors.forest, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
                const SizedBox(height: 10),
                const Text('Le terrain,\nà portée de main.', style: TextStyle(fontSize: 34, height: 1.12, fontWeight: FontWeight.w800, color: Color(0xFF17251F))),
                const SizedBox(height: 12),
                const Text('Connectez-vous à votre espace de gestion.', style: TextStyle(color: AppColors.muted, fontSize: 15)),
                const SizedBox(height: 34),
                TextFormField(
                  key: const Key('login-email'),
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.username],
                  decoration: const InputDecoration(labelText: 'Adresse e-mail', prefixIcon: Icon(Icons.mail_outline)),
                  validator: (value) => value == null || !value.contains('@') ? 'Saisissez une adresse e-mail valide.' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  key: const Key('login-password'),
                  controller: _password,
                  obscureText: _hidePassword,
                  autofillHints: const [AutofillHints.password],
                  onFieldSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      tooltip: _hidePassword ? 'Afficher le mot de passe' : 'Masquer le mot de passe',
                      onPressed: () => setState(() => _hidePassword = !_hidePassword),
                      icon: Icon(_hidePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                    ),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Saisissez votre mot de passe.' : null,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton(
                    onPressed: widget.busy ? null : _submit,
                    style: FilledButton.styleFrom(backgroundColor: AppColors.forest, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: widget.busy
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Se connecter', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(onPressed: widget.onForgotPassword, child: const Text('Mot de passe oublié ?')),
                ),
                const SizedBox(height: 24),
                const Center(child: Text('Digital Chantier · Madagascar', style: TextStyle(color: Color(0xFF78837D), fontSize: 12))),
              ]),
            ),
          ),
        ),
      ),
    ),
  );

  void _submit() {
    if (_formKey.currentState!.validate()) widget.onLogin(_email.text, _password.text);
  }
}