import 'package:flutter/material.dart';

import '../../core/api_client.dart';
import '../../shared/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    required this.api,
    required this.user,
    required this.onLogout,
    super.key,
  });

  final ApiClient api;
  final Map<String, dynamic> user;
  final Future<void> Function() onLogout;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _profileForm = GlobalKey<FormState>();
  final _passwordForm = GlobalKey<FormState>();
  late final TextEditingController _nom;
  late final TextEditingController _prenom;
  late final TextEditingController _email;
  late final TextEditingController _telephone;
  final _currentPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmation = TextEditingController();
  bool _savingProfile = false;
  bool _savingPassword = false;
  bool _loggingOut = false;
  bool _hidePasswords = true;

  @override
  void initState() {
    super.initState();
    _nom = TextEditingController(text: widget.user['nom']?.toString() ?? '');
    _prenom = TextEditingController(
      text: widget.user['prenom']?.toString() ?? '',
    );
    _email = TextEditingController(
      text: widget.user['email']?.toString() ?? '',
    );
    _telephone = TextEditingController(
      text: widget.user['telephone']?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    for (final controller in [
      _nom,
      _prenom,
      _email,
      _telephone,
      _currentPassword,
      _newPassword,
      _confirmation,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = '${_prenom.text} ${_nom.text}'.trim();
    return Scaffold(
      appBar: AppBar(title: const Text('Mon profil')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 35,
                  backgroundColor: AppColors.forest,
                  child: Icon(Icons.person, color: AppColors.lime, size: 34),
                ),
                const SizedBox(height: 12),
                Text(
                  name.isEmpty ? 'Utilisateur' : name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF17251F),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _roleLabel(widget.user['role']?.toString() ?? ''),
                  style: const TextStyle(color: AppColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Informations personnelles',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
          ),
          const SizedBox(height: 10),
          Form(
            key: _profileForm,
            child: Column(
              children: [
                _profileField(_prenom, 'Prénom', required: true),
                _profileField(_nom, 'Nom', required: true),
                _profileField(
                  _email,
                  'Adresse e-mail',
                  required: true,
                  keyboardType: TextInputType.emailAddress,
                ),
                _profileField(
                  _telephone,
                  'Téléphone',
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _savingProfile ? null : _saveProfile,
                    child: Text(
                      _savingProfile
                          ? 'Enregistrement…'
                          : 'Enregistrer le profil',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Sécurité',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
          ),
          const SizedBox(height: 10),
          Form(
            key: _passwordForm,
            child: Column(
              children: [
                _passwordField(_currentPassword, 'Mot de passe actuel'),
                _passwordField(_newPassword, 'Nouveau mot de passe'),
                _passwordField(
                  _confirmation,
                  'Confirmer le nouveau mot de passe',
                ),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _savingPassword ? null : _changePassword,
                    child: Text(
                      _savingPassword
                          ? 'Modification…'
                          : 'Changer le mot de passe',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _loggingOut ? null : _confirmLogout,
            icon: _loggingOut
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.logout),
            label: Text(_loggingOut ? 'Déconnexion…' : 'Se déconnecter'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF9C422B),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileField(
    TextEditingController controller,
    String label, {
    bool required = false,
    TextInputType keyboardType = TextInputType.text,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(labelText: label),
      validator: required
          ? (value) => value == null || value.trim().isEmpty
                ? 'Champ obligatoire.'
                : null
          : null,
    ),
  );

  Widget _passwordField(TextEditingController controller, String label) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextFormField(
          controller: controller,
          obscureText: _hidePasswords,
          decoration: InputDecoration(
            labelText: label,
            suffixIcon: IconButton(
              tooltip: _hidePasswords
                  ? 'Afficher les mots de passe'
                  : 'Masquer les mots de passe',
              onPressed: () => setState(() => _hidePasswords = !_hidePasswords),
              icon: Icon(
                _hidePasswords
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
            ),
          ),
          validator: (value) =>
              value == null || value.isEmpty ? 'Champ obligatoire.' : null,
        ),
      );

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Se déconnecter'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _loggingOut = true);
    try {
      await widget.onLogout();
    } finally {
      if (mounted) setState(() => _loggingOut = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_profileForm.currentState!.validate()) return;
    setState(() => _savingProfile = true);
    try {
      await widget.api.put('auth/me', {
        'nom': _nom.text.trim(),
        'prenom': _prenom.text.trim(),
        'email': _email.text.trim(),
        'telephone': _telephone.text.trim(),
      });
      if (mounted) setState(() {});
      _message('Profil enregistré.');
    } catch (error) {
      _message(error.toString());
    } finally {
      if (mounted) setState(() => _savingProfile = false);
    }
  }

  Future<void> _changePassword() async {
    if (!_passwordForm.currentState!.validate()) return;
    if (_newPassword.text.length < 8) {
      _message('Le nouveau mot de passe doit contenir au moins 8 caractères.');
      return;
    }
    if (_newPassword.text != _confirmation.text) {
      _message('Les deux nouveaux mots de passe sont différents.');
      return;
    }
    setState(() => _savingPassword = true);
    try {
      await widget.api.post('auth/mot-de-passe', {
        'mot_de_passe_actuel': _currentPassword.text,
        'nouveau_mot_de_passe': _newPassword.text,
        'nouveau_mot_de_passe_confirmation': _confirmation.text,
      });
      await widget.onLogout();
    } catch (error) {
      _message(error.toString());
    } finally {
      if (mounted) setState(() => _savingPassword = false);
    }
  }

  void _message(String value) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(value)));
    }
  }
}

String _roleLabel(String role) => switch (role) {
  'directeur' => 'Directeur',
  'chef_chantier' => 'Chef de chantier',
  'comptable' => 'Comptable',
  'magasinier' => 'Magasinier',
  _ => role,
};
