import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sfmc_flutter/core/utils/validators.dart';
import 'package:sfmc_flutter/core/widgets/custom_button.dart';
import 'package:sfmc_flutter/core/widgets/custom_text_field.dart';
import 'package:sfmc_flutter/features/users/models/user_profile_model.dart';
import 'package:sfmc_flutter/features/users/providers/user_provider.dart';

class UserFormScreen extends StatefulWidget {
  final UserProfile? user;

  const UserFormScreen({super.key, this.user});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _adresseController = TextEditingController();
  String _role = 'client';
  bool _actif = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _nomController.text = widget.user!.nom;
      _prenomController.text = widget.user!.prenom;
      _emailController.text = widget.user!.email;
      _telephoneController.text = widget.user!.telephone ?? '';
      _adresseController.text = widget.user!.adresse ?? '';
      _role = widget.user!.role;
      _actif = widget.user!.actif;
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _adresseController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final user = UserProfile(
        id: widget.user?.id,
        nom: _nomController.text.trim(),
        prenom: _prenomController.text.trim(),
        email: _emailController.text.trim(),
        telephone: _telephoneController.text.trim().isNotEmpty
            ? _telephoneController.text.trim()
            : null,
        role: _role,
        adresse: _adresseController.text.trim().isNotEmpty
            ? _adresseController.text.trim()
            : null,
        actif: _actif,
      );

      final provider = context.read<UserProvider>();
      final success = widget.user == null
          ? await provider.createUser(user)
          : await provider.updateUser(widget.user!.id!, user);

      setState(() => _isLoading = false);

      if (success && mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.user == null ? 'Nouvel utilisateur' : 'Modifier utilisateur',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                label: 'Nom',
                controller: _nomController,
                validator: (v) => Validators.validateRequired(v, 'Nom'),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Prénom',
                controller: _prenomController,
                validator: (v) => Validators.validateRequired(v, 'Prénom'),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.validateEmail,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Téléphone',
                controller: _telephoneController,
                keyboardType: TextInputType.phone,
                validator: Validators.validatePhone,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Adresse',
                controller: _adresseController,
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _role,
                decoration: const InputDecoration(labelText: 'Rôle'),
                items: const [
                  DropdownMenuItem(
                    value: 'admin',
                    child: Text('Administrateur'),
                  ),
                  DropdownMenuItem(
                    value: 'operateur',
                    child: Text('Opérateur'),
                  ),
                  DropdownMenuItem(value: 'client', child: Text('Client')),
                ],
                onChanged: (value) => setState(() => _role = value!),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Compte actif'),
                value: _actif,
                onChanged: (value) => setState(() => _actif = value),
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: widget.user == null ? 'Créer' : 'Mettre à jour',
                onPressed: _save,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
