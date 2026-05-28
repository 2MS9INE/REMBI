import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/wilayas.dart';
import '../../data/auth_repository.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _fullName = '';
  String _phone = '';
  String _whatsapp = '';
  String? _wilaya;
  File? _profilePhoto;
  bool _isLoading = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  final _imagePicker = ImagePicker();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isValidPhone(String phone) =>
      RegExp(r'^0[567]\d{8}$').hasMatch(phone.trim());

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final xFile = await _imagePicker.pickImage(
      source: source,
      imageQuality: 85,
    );
    if (xFile != null) setState(() => _profilePhoto = File(xFile.path));
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    if (_wilaya == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.fieldRequired)));
      return;
    }
    _formKey.currentState!.save();
    setState(() => _isLoading = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .registerFarmer(
            fullName: _fullName,
            phone: _phone,
            whatsapp: _whatsapp.isEmpty ? null : _whatsapp,
            wilaya: _wilaya!,
            password: _passwordController.text.trim(),
            profilePhotoFile: _profilePhoto,
          );
      if (mounted) context.go('/farmer/dashboard');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.register),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/auth/login'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Avatar picker
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                      backgroundImage: _profilePhoto != null
                          ? FileImage(_profilePhoto!)
                          : null,
                      child: _profilePhoto == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.camera_alt, size: 28),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.addPhoto,
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ],
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Full Name
                TextFormField(
                  decoration: InputDecoration(
                    labelText: l10n.fullName,
                    prefixIcon: const Icon(Icons.person),
                    border: const OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? l10n.fieldRequired
                      : null,
                  onSaved: (v) => _fullName = v!.trim(),
                ),
                const SizedBox(height: 16),

                // Phone
                TextFormField(
                  decoration: InputDecoration(
                    labelText: l10n.phone,
                    hintText: '0XXXXXXXXX',
                    prefixIcon: const Icon(Icons.phone),
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty)
                      return l10n.fieldRequired;
                    if (!_isValidPhone(v)) return l10n.phoneInvalid;
                    return null;
                  },
                  onSaved: (v) => _phone = v!.trim(),
                ),
                const SizedBox(height: 16),

                // WhatsApp (optional)
                TextFormField(
                  decoration: InputDecoration(
                    labelText: l10n.whatsappNumber,
                    hintText: l10n.whatsappHint,
                    prefixIcon: const Icon(Icons.chat),
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (v) {
                    if (v != null && v.trim().isNotEmpty && !_isValidPhone(v)) {
                      return l10n.phoneInvalid;
                    }
                    return null;
                  },
                  onSaved: (v) => _whatsapp = v?.trim() ?? '',
                ),
                const SizedBox(height: 16),

                // Wilaya
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: l10n.wilaya,
                    prefixIcon: const Icon(Icons.location_on),
                    border: const OutlineInputBorder(),
                  ),
                  hint: Text(l10n.selectWilaya),
                  value: _wilaya,
                  items: wilayas
                      .map((w) => DropdownMenuItem(value: w, child: Text(w)))
                      .toList(),
                  onChanged: (v) => setState(() => _wilaya = v),
                  validator: (v) => v == null ? l10n.fieldRequired : null,
                ),
                const SizedBox(height: 16),

                // Password
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: l10n.password,
                    prefixIcon: const Icon(Icons.lock),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showPassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () =>
                          setState(() => _showPassword = !_showPassword),
                    ),
                  ),
                  obscureText: !_showPassword,
                  validator: (v) {
                    if (v == null || v.isEmpty) return l10n.fieldRequired;
                    if (v.length < 6) return l10n.passwordTooShort;
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Confirm Password
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: l10n.confirmPassword,
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () => setState(
                        () => _showConfirmPassword = !_showConfirmPassword,
                      ),
                    ),
                  ),
                  obscureText: !_showConfirmPassword,
                  validator: (v) {
                    if (v == null || v.isEmpty) return l10n.fieldRequired;
                    if (v != _passwordController.text)
                      return l10n.passwordMismatch;
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Register button
                FilledButton(
                  onPressed: _isLoading ? null : _submit,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(l10n.register),
                ),
                const SizedBox(height: 16),

                TextButton(
                  onPressed: () => context.go('/auth/login'),
                  child: Text(l10n.haveAccount),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
