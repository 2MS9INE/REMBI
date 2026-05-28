// ignore_for_file: deprecated_member_use
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/wilayas.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/data/auth_repository.dart';

final _packageInfoProvider = FutureProvider<PackageInfo>(
  (_) => PackageInfo.fromPlatform(),
);

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _fullName;
  String? _whatsapp;
  String? _wilaya;
  File? _newPhoto;
  bool _isSaving = false;
  final _picker = ImagePicker();

  Future<void> _pickPhoto() async {
    final x = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (x != null) setState(() => _newPhoto = File(x.path));
  }

  Future<void> _save(Map<String, dynamic> profile) async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _isSaving = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .updateProfile(
            fullName: _fullName ?? profile['full_name'],
            whatsapp: _whatsapp ?? profile['whatsapp'],
            wilaya: _wilaya ?? profile['wilaya'],
            profilePhotoFile: _newPhoto,
          );
      ref.invalidate(currentUserProfileProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.changesSaved)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _logout() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l10n.logout),
        content: Text(l10n.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(c, true),
            child: Text(l10n.logout),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(authRepositoryProvider).logoutFarmer();
      if (mounted) context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final profileAsync = ref.watch(currentUserProfileProvider);
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => _buildBody(null, l10n, theme, currentLocale),
        data: (profile) => _buildBody(profile, l10n, theme, currentLocale),
      ),
    );
  }

  Widget _buildBody(
    Map<String, dynamic>? profile,
    AppLocalizations l10n,
    ThemeData theme,
    Locale currentLocale,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Section 1: Profile ─────────────────────────────────────────
            if (profile != null) ...[
              _SectionHeader(label: l10n.profile),
              const SizedBox(height: 12),

              // Avatar
              Center(
                child: GestureDetector(
                  onTap: _pickPhoto,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundImage: _newPhoto != null
                            ? FileImage(_newPhoto!) as ImageProvider
                            : (profile['profile_photo_url'] != null
                                  ? NetworkImage(
                                      profile['profile_photo_url'] as String,
                                    )
                                  : null),
                        child:
                            (_newPhoto == null &&
                                profile['profile_photo_url'] == null)
                            ? const Icon(Icons.person, size: 40)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: theme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Full Name
              TextFormField(
                initialValue: profile['full_name'] as String? ?? '',
                decoration: InputDecoration(
                  labelText: l10n.fullName,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.person),
                ),
                onSaved: (v) => _fullName = v?.trim(),
              ),
              const SizedBox(height: 12),

              // Phone (read-only)
              TextFormField(
                initialValue: _maskPhone(profile['phone'] as String? ?? ''),
                readOnly: true,
                decoration: InputDecoration(
                  labelText: l10n.phone,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.phone),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest,
                ),
              ),
              const SizedBox(height: 12),

              // WhatsApp
              TextFormField(
                initialValue: profile['whatsapp'] as String? ?? '',
                decoration: InputDecoration(
                  labelText: l10n.whatsappNumber,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.chat),
                ),
                onSaved: (v) => _whatsapp = v?.trim(),
              ),
              const SizedBox(height: 12),

              // Wilaya
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: l10n.wilaya,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.location_on),
                ),
                initialValue: () {
                  final v = _wilaya ?? (profile['wilaya'] as String?);
                  return wilayas.contains(v) ? v : null;
                }(),
                items: wilayas
                    .map((w) => DropdownMenuItem(value: w, child: Text(w)))
                    .toList(),
                onChanged: (v) => setState(() => _wilaya = v),
              ),
              const SizedBox(height: 16),

              FilledButton.icon(
                onPressed: _isSaving ? null : () => _save(profile),
                icon: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(l10n.saveChanges),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),

              const SizedBox(height: 24),
              const Divider(),

              // ── Section 2: Account ───────────────────────────────────────
              _SectionHeader(label: l10n.account),
              const SizedBox(height: 12),

              if (profile['is_verified'] != true &&
                  profile['verification_requested'] != true)
                OutlinedButton.icon(
                  icon: const Icon(Icons.verified_user),
                  label: Text(l10n.requestVerification),
                  onPressed: () async {
                    await ref
                        .read(authRepositoryProvider)
                        .requestVerificationBadge();
                    ref.invalidate(currentUserProfileProvider);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.verificationRequestSent)),
                      );
                    }
                  },
                ),

              const SizedBox(height: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.logout, color: Colors.red),
                label: Text(
                  l10n.logout,
                  style: const TextStyle(color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                ),
                onPressed: _logout,
              ),
              // After the logout OutlinedButton...
              if (profile['role'] == 'admin') ...[
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.admin_panel_settings),
                  label: const Text('Admin Panel'),
                  onPressed: () => context.push('/admin'),
                ),
              ],

              const SizedBox(height: 24),
              const Divider(),
            ],

            // ── Section 3: Language ────────────────────────────────────────
            _SectionHeader(label: l10n.language),
            const SizedBox(height: 8),
            ..._languages(l10n).map(
              (lang) => RadioListTile<String>(
                title: Text(lang.label),
                value: lang.code,
                groupValue: currentLocale.languageCode,
                onChanged: (code) {
                  if (code != null) {
                    final localeCode = code == 'kab' ? 'ar' : code;
                    ref
                        .read(localeProvider.notifier)
                        .setLocale(Locale(localeCode));
                  }
                },
                contentPadding: EdgeInsets.zero,
              ),
            ),

            const SizedBox(height: 24),
            const Divider(),

            // ── Section 4: About ───────────────────────────────────────────
            _SectionHeader(label: l10n.about),
            const SizedBox(height: 8),
            Consumer(
              builder: (ctx, ref, _) {
                final infoAsync = ref.watch(_packageInfoProvider);
                return infoAsync.maybeWhen(
                  data: (info) => ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: Text(
                      '${l10n.appName} v${info.version}+${info.buildNumber}',
                    ),
                    subtitle: Text(l10n.aboutDescription),
                    contentPadding: EdgeInsets.zero,
                  ),
                  orElse: () => const SizedBox.shrink(),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.email_outlined),
              title: Text(l10n.contactUs),
              contentPadding: EdgeInsets.zero,
              onTap: () => launchUrl(Uri.parse('mailto:support@rembi.dz')),
            ),
          ],
        ),
      ),
    );
  }

  String _maskPhone(String phone) {
    if (phone.length < 6) return phone;
    return '${phone.substring(0, 3)}****${phone.substring(phone.length - 2)}';
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).primaryColor,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _LanguageOption {
  final String code;
  final String label;
  const _LanguageOption(this.code, this.label);
}

List<_LanguageOption> _languages(AppLocalizations l10n) => [
  const _LanguageOption('ar', 'العربية'),
  const _LanguageOption('fr', 'Français'),
  const _LanguageOption('en', 'English'),
  const _LanguageOption('kab', 'Tamaziɣt'),
];
