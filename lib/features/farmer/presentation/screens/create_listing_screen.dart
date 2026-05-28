import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/wilayas.dart';
import '../../../../core/utils/image_utils.dart';
import '../../../auth/data/auth_repository.dart';
import '../../data/farmer_repository.dart';
import '../providers/category_schema_provider.dart';

// ── Local ephemeral state using ConsumerStatefulWidget ───────────────────────
// Note: all state below lives in a ConsumerStatefulWidget member.

const _kMaxPhotos = 5;

/// Category → display label (AR)
// Replace _categoryLabels with this function:
Map<String, String> getCategoryLabels(String langCode) {
  switch (langCode) {
    case 'fr':
      return {
        'LIVESTOCK': 'Bétail',
        'CROPS': 'Cultures',
        'ARTISAN PRODUCTS': 'Produits artisanaux',
        'AGRICULTURAL SERVICES': 'Services agricoles',
      };
    case 'en':
      return {
        'LIVESTOCK': 'Livestock',
        'CROPS': 'Crops',
        'ARTISAN PRODUCTS': 'Artisan Products',
        'AGRICULTURAL SERVICES': 'Agricultural Services',
      };
    default: // ar
      return {
        'LIVESTOCK': 'مواشي',
        'CROPS': 'المحاصيل',
        'ARTISAN PRODUCTS': 'المنتجات الحرفية',
        'AGRICULTURAL SERVICES': 'الخدمات الفلاحية',
      };
  }
}

Map<String, List<String>> getSubcategories(String langCode) {
  switch (langCode) {
    case 'fr':
      return {
        'LIVESTOCK': [
          'Bovins',
          'Ovins',
          'Caprins',
          'Volailles',
          'Chameaux',
          'Autre',
        ],
        'CROPS': [
          'Céréales',
          'Légumes',
          'Fruits',
          'Légumineuses',
          'Herbes',
          'Autre',
        ],
        'ARTISAN PRODUCTS': [
          'Miel',
          'Fromage & Lait',
          'Laine & Cuir',
          'Herbes séchées',
          'Huile d\'olive',
          'Autre',
        ],
        'AGRICULTURAL SERVICES': [
          'Labour',
          'Récolte',
          'Irrigation',
          'Transport',
          'Vétérinaire',
          'Traitement',
          'Autre',
        ],
      };
    case 'en':
      return {
        'LIVESTOCK': ['Cattle', 'Sheep', 'Goats', 'Poultry', 'Camels', 'Other'],
        'CROPS': [
          'Cereals',
          'Vegetables',
          'Fruits',
          'Legumes',
          'Herbs',
          'Other',
        ],
        'ARTISAN PRODUCTS': [
          'Honey',
          'Cheese & Dairy',
          'Wool & Leather',
          'Dried herbs',
          'Olive oil',
          'Other',
        ],
        'AGRICULTURAL SERVICES': [
          'Plowing',
          'Harvesting',
          'Irrigation',
          'Transport',
          'Veterinary',
          'Pest control',
          'Other',
        ],
      };
    default: // ar
      return {
        'LIVESTOCK': ['أبقار', 'أغنام', 'ماعز', 'دواجن', 'إبل', 'أخرى'],
        'CROPS': ['حبوب', 'خضروات', 'فواكه', 'بقوليات', 'أعشاب', 'أخرى'],
        'ARTISAN PRODUCTS': [
          'عسل',
          'جبن وألبان',
          'صوف وجلود',
          'أعشاب مجففة',
          'زيت زيتون',
          'أخرى',
        ],
        'AGRICULTURAL SERVICES': [
          'حراثة',
          'حصاد',
          'ري',
          'نقل',
          'بيطرة',
          'مكافحة آفات',
          'أخرى',
        ],
      };
  }
}

/// Category → icon
const _categoryIcons = {
  'LIVESTOCK': Icons.pets,
  'CROPS': Icons.grass,
  'ARTISAN PRODUCTS': Icons.local_grocery_store,
  'AGRICULTURAL SERVICES': Icons.handyman,
};

/// Category → subcategories

class CreateListingScreen extends ConsumerStatefulWidget {
  final String? listingId; // null = create, non-null = edit

  const CreateListingScreen({super.key, this.listingId});

  @override
  ConsumerState<CreateListingScreen> createState() =>
      _CreateListingScreenState();
}

class _CreateListingScreenState extends ConsumerState<CreateListingScreen> {
  // Step control
  int _step = 0; // 0=category, 1=dynamic fields, 2=common fields, 3=photos

  // Category selection
  String? _category;
  String? _subcategory;

  // Dynamic field values (key → value)
  final Map<String, dynamic> _dynamicValues = {};

  // Common fields
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  bool _isNegotiable = false;
  String? _wilaya;

  // Photos
  final List<File> _newPhotos = [];
  final List<String> _existingPhotoUrls = [];
  final _imagePicker = ImagePicker();

  // Form keys for each step
  final _dynamicFormKey = GlobalKey<FormState>();
  final _commonFormKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    if (widget.listingId != null) {
      _isEditMode = true;
      _loadExistingListing();
    }
  }

  Future<void> _loadExistingListing() async {
    final data = await ref
        .read(farmerRepositoryProvider)
        .fetchListingById(widget.listingId!);
    final photos =
        (data['listing_photos'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    photos.sort(
      (a, b) =>
          (a['display_order'] as int).compareTo(b['display_order'] as int),
    );

    setState(() {
      _category = data['category'] as String?;
      _subcategory = data['subcategory'] as String?;
      _titleController.text = data['title'] as String? ?? '';
      _descController.text = data['description'] as String? ?? '';
      final price = data['price'];
      _priceController.text = price != null ? price.toString() : '';
      _isNegotiable = data['is_negotiable'] as bool? ?? false;
      _wilaya = data['wilaya'] as String?;
      _existingPhotoUrls.addAll(photos.map((p) => p['photo_url'] as String));
      final df = data['dynamic_fields'] as Map<String, dynamic>? ?? {};
      _dynamicValues.addAll(df);
      _step = 1; // start at dynamic fields in edit mode
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  // ── Photo Picker ────────────────────────────────────────────────────────────
  Future<void> _pickPhoto() async {
    final total = _newPhotos.length + _existingPhotoUrls.length;
    if (total >= _kMaxPhotos) return;

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
    final xFile = await _imagePicker.pickImage(source: source);
    if (xFile != null) {
      setState(() => _newPhotos.add(File(xFile.path)));
    }
  }

  // ── Submit ──────────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;

    // Validate photos
    if (_newPhotos.isEmpty && _existingPhotoUrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.photoRequired),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final farmerId =
          ref.read(authRepositoryProvider).getCurrentUser()?.id ?? '';
      final repo = ref.read(farmerRepositoryProvider);

      if (_isEditMode) {
        await repo.updateListing(
          listingId: widget.listingId!,
          title: _titleController.text.trim(),
          description: _descController.text.trim().isEmpty
              ? null
              : _descController.text.trim(),
          category: _category!,
          subcategory: _subcategory!,
          dynamicFields: _dynamicValues,
          price: double.tryParse(_priceController.text),
          isNegotiable: _isNegotiable,
          wilaya: _wilaya!,
        );
        // Replace photos if new ones added
        if (_newPhotos.isNotEmpty) {
          await repo.deleteListingPhotos(widget.listingId!);
          for (int i = 0; i < _newPhotos.length; i++) {
            final url = await uploadListingPhoto(
              _newPhotos[i],
              farmerId,
              widget.listingId!,
            );
            await repo.addListingPhoto(widget.listingId!, url, i);
          }
        }
      } else {
        final listingId = await repo.createListing(
          title: _titleController.text.trim(),
          description: _descController.text.trim().isEmpty
              ? null
              : _descController.text.trim(),
          category: _category!,
          subcategory: _subcategory!,
          dynamicFields: _dynamicValues,
          price: double.tryParse(_priceController.text),
          isNegotiable: _isNegotiable,
          wilaya: _wilaya!,
        );
        for (int i = 0; i < _newPhotos.length; i++) {
          final url = await uploadListingPhoto(
            _newPhotos[i],
            farmerId,
            listingId,
          );
          await repo.addListingPhoto(listingId, url, i);
        }
      }

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

  // ── Builders ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? l10n.editListing : l10n.createListing),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: switch (_step) {
          0 => _CategoryStep(
            selectedCategory: _category,
            selectedSubcategory: _subcategory,
            onCategorySelected: (c) => setState(() {
              _category = c;
              _subcategory = null;
            }),
            onSubcategorySelected: (s) => setState(() => _subcategory = s),
            onNext: () => setState(() => _step = 1),
          ),
          1 => _DynamicFieldsStep(
            formKey: _dynamicFormKey,
            category: _category!,
            subcategory: _subcategory!,
            values: _dynamicValues,
            onValueChanged: (key, val) =>
                setState(() => _dynamicValues[key] = val),
            onNext: () {
              if (_dynamicFormKey.currentState!.validate()) {
                _dynamicFormKey.currentState!.save();
                setState(() => _step = 2);
              }
            },
            onBack: () => setState(() => _step = 0),
          ),
          2 => _CommonFieldsStep(
            formKey: _commonFormKey,
            titleController: _titleController,
            descController: _descController,
            priceController: _priceController,
            isNegotiable: _isNegotiable,
            wilaya: _wilaya,
            onNegotiableChanged: (v) => setState(() => _isNegotiable = v),
            onWilayaChanged: (v) => setState(() => _wilaya = v),
            onNext: () {
              if (_commonFormKey.currentState!.validate()) {
                _commonFormKey.currentState!.save();
                setState(() => _step = 3);
              }
            },
            onBack: () => setState(() => _step = 1),
          ),
          _ => _PhotosStep(
            newPhotos: _newPhotos,
            existingUrls: _existingPhotoUrls,
            onAdd: _pickPhoto,
            onRemoveNew: (i) => setState(() => _newPhotos.removeAt(i)),
            onRemoveExisting: (i) =>
                setState(() => _existingPhotoUrls.removeAt(i)),
            onBack: () => setState(() => _step = 2),
            onSubmit: _submit,
            isLoading: _isLoading,
            isEditMode: _isEditMode,
          ),
        },
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// STEP 1: Category Selection
// ────────────────────────────────────────────────────────────────────────────
class _CategoryStep extends StatelessWidget {
  final String? selectedCategory;
  final String? selectedSubcategory;
  final ValueChanged<String> onCategorySelected;
  final ValueChanged<String> onSubcategorySelected;
  final VoidCallback onNext;

  const _CategoryStep({
    required this.selectedCategory,
    required this.selectedSubcategory,
    required this.onCategorySelected,
    required this.onSubcategorySelected,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final langCode = Localizations.localeOf(context).languageCode;
    final categoryLabels = getCategoryLabels(langCode);
    final subcategories = getSubcategories(langCode);
    final englishSubs = getSubcategories('en');

    final subs = selectedCategory != null
        ? subcategories[selectedCategory!] ?? []
        : <String>[];
    final engSubs = selectedCategory != null
        ? englishSubs[selectedCategory!] ?? []
        : <String>[];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.categorySelect,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Category cards (2x2 grid)
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: categoryLabels.entries.map((entry) {
              final isSelected = selectedCategory == entry.key;
              return GestureDetector(
                onTap: () => onCategorySelected(entry.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: isSelected
                        ? theme.primaryColor
                        : theme.colorScheme.surfaceContainerHighest,
                    border: Border.all(
                      color: isSelected
                          ? theme.primaryColor
                          : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: theme.primaryColor.withAlpha(80),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _categoryIcons[entry.key],
                        size: 36,
                        color: isSelected ? Colors.white : theme.primaryColor,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        categoryLabels[entry.key] ?? entry.key,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : null,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          // Subcategory chips
          if (selectedCategory != null) ...[
            const SizedBox(height: 24),
            Text(
              l10n.subcategorySelect,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: subs.asMap().entries.map((entry) {
                final englishKey = engSubs[entry.key]; // e.g. "Sheep"
                final isSelected = selectedSubcategory == englishKey;
                return FilterChip(
                  label: Text(entry.value), // shows "Ovins" in French
                  selected: isSelected,
                  onSelected: (_) =>
                      onSubcategorySelected(englishKey), // stores "Sheep"
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed:
                  (selectedCategory != null && selectedSubcategory != null)
                  ? onNext
                  : null,
              child: Text(l10n.next),
            ),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// STEP 2: Dynamic Fields
// ────────────────────────────────────────────────────────────────────────────
class _DynamicFieldsStep extends ConsumerWidget {
  final GlobalKey<FormState> formKey;
  final String category;
  final String subcategory;
  final Map<String, dynamic> values;
  final void Function(String key, dynamic val) onValueChanged;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const _DynamicFieldsStep({
    required this.formKey,
    required this.category,
    required this.subcategory,
    required this.values,
    required this.onValueChanged,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final schemaAsync = ref.watch(
      categorySchemaProvider((category: category, subcategory: subcategory)),
    );

    return schemaAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(e.toString())),
      data: (schema) {
        if (schema.requiredFields.isEmpty && schema.optionalFields.isEmpty) {
          return _emptyStepBody(context, l10n);
        }

        return Form(
          key: formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Required fields
                if (schema.requiredFields.isNotEmpty) ...[
                  _sectionHeader(l10n.requiredFields, context),
                  const SizedBox(height: 8),
                  ...schema.requiredFields.map(
                    (f) => _DynamicField(
                      field: f,
                      locale: locale,
                      value: values[f.key],
                      onChanged: (v) => onValueChanged(f.key, v),
                    ),
                  ),
                ],

                // Optional fields
                if (schema.optionalFields.isNotEmpty) ...[
                  const Divider(height: 32),
                  _sectionHeader(l10n.optionalFields, context),
                  const SizedBox(height: 8),
                  ...schema.optionalFields.map(
                    (f) => _DynamicField(
                      field: f,
                      locale: locale,
                      value: values[f.key],
                      onChanged: (v) => onValueChanged(f.key, v),
                    ),
                  ),
                ],

                const SizedBox(height: 24),
                Row(
                  children: [
                    OutlinedButton(onPressed: onBack, child: Text(l10n.back)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: onNext,
                        child: Text(l10n.next),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sectionHeader(String title, BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  Widget _emptyStepBody(BuildContext ctx, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text('No additional fields for this category.'),
          const SizedBox(height: 24),
          Row(
            children: [
              OutlinedButton(onPressed: onBack, child: Text(l10n.back)),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(onPressed: onNext, child: Text(l10n.next)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Dynamic Field Widget
// ────────────────────────────────────────────────────────────────────────────
class _DynamicField extends StatelessWidget {
  final FieldDefinition field;
  final String locale;
  final dynamic value;
  final ValueChanged<dynamic> onChanged;

  const _DynamicField({
    required this.field,
    required this.locale,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final label = field.labelFor(locale);
    final asterisk = field.required ? ' *' : '';
    final fullLabel = '$label$asterisk';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: switch (field.type) {
        'boolean' => SwitchListTile(
          title: Text(fullLabel),
          value: value == true,
          onChanged: (v) => onChanged(v),
          contentPadding: EdgeInsets.zero,
        ),
        'select' => DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: fullLabel,
            border: const OutlineInputBorder(),
          ),
          initialValue: value as String?,
          items: (field.options ?? [])
              .map((o) => DropdownMenuItem(value: o, child: Text(o)))
              .toList(),
          onChanged: onChanged,
          validator: field.required
              ? (v) => v == null ? 'Required' : null
              : null,
        ),
        'date' => _DateField(
          label: fullLabel,
          value: value as String?,
          onChanged: onChanged,
          required: field.required,
        ),
        'number' => TextFormField(
          decoration: InputDecoration(
            labelText: fullLabel,
            border: const OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          initialValue: value?.toString(),
          validator: field.required
              ? (v) => (v == null || v.isEmpty) ? 'Required' : null
              : null,
          onChanged: onChanged,
        ),
        'textarea' => TextFormField(
          decoration: InputDecoration(
            labelText: fullLabel,
            border: const OutlineInputBorder(),
          ),
          maxLines: 3,
          maxLength: 500,
          initialValue: value?.toString(),
          validator: field.required
              ? (v) => (v == null || v.isEmpty) ? 'Required' : null
              : null,
          onChanged: onChanged,
        ),
        _ => TextFormField(
          decoration: InputDecoration(
            labelText: fullLabel,
            border: const OutlineInputBorder(),
          ),
          initialValue: value?.toString(),
          validator: field.required
              ? (v) => (v == null || v.isEmpty) ? 'Required' : null
              : null,
          onChanged: onChanged,
        ),
      },
    );
  }
}

class _DateField extends StatefulWidget {
  final String label;
  final String? value;
  final ValueChanged<String> onChanged;
  final bool required;

  const _DateField({
    required this.label,
    this.value,
    required this.onChanged,
    required this.required,
  });

  @override
  State<_DateField> createState() => _DateFieldState();
}

class _DateFieldState extends State<_DateField> {
  String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
        );
        if (picked != null) {
          final formatted = picked.toIso8601String().substring(0, 10);
          setState(() => _selected = formatted);
          widget.onChanged(formatted);
        }
      },
      child: FormField<String>(
        initialValue: _selected,
        validator: widget.required
            ? (v) => (_selected == null ? 'Required' : null)
            : null,
        builder: (state) => InputDecorator(
          decoration: InputDecoration(
            labelText: widget.label,
            border: const OutlineInputBorder(),
            suffixIcon: const Icon(Icons.calendar_today),
            errorText: state.errorText,
          ),
          child: Text(_selected ?? ''),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// STEP 3: Common Fields
// ────────────────────────────────────────────────────────────────────────────
class _CommonFieldsStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final TextEditingController descController;
  final TextEditingController priceController;
  final bool isNegotiable;
  final String? wilaya;
  final ValueChanged<bool> onNegotiableChanged;
  final ValueChanged<String?> onWilayaChanged;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const _CommonFieldsStep({
    required this.formKey,
    required this.titleController,
    required this.descController,
    required this.priceController,
    required this.isNegotiable,
    required this.wilaya,
    required this.onNegotiableChanged,
    required this.onWilayaChanged,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Form(
      key: formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            TextFormField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: '${l10n.listingTitle} *',
                hintText: l10n.listingTitleHint,
                border: const OutlineInputBorder(),
              ),
              maxLength: 100,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l10n.fieldRequired : null,
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: descController,
              decoration: InputDecoration(
                labelText: l10n.listingDescription,
                hintText: l10n.listingDescriptionHint,
                border: const OutlineInputBorder(),
              ),
              maxLines: 4,
              maxLength: 500,
            ),
            const SizedBox(height: 16),

            // Price
            TextFormField(
              controller: priceController,
              decoration: InputDecoration(
                labelText: l10n.listingPrice,
                border: const OutlineInputBorder(),
                prefixText: 'DZD ',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),

            // Negotiable toggle
            SwitchListTile(
              title: Text(l10n.negotiableToggle),
              value: isNegotiable,
              onChanged: onNegotiableChanged,
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),

            // Wilaya
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: '${l10n.wilaya} *',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.location_on),
              ),
              hint: Text(l10n.selectWilaya),
              initialValue: wilaya,
              items: wilayas
                  .map((w) => DropdownMenuItem(value: w, child: Text(w)))
                  .toList(),
              onChanged: onWilayaChanged,
              validator: (v) => v == null ? l10n.fieldRequired : null,
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                OutlinedButton(onPressed: onBack, child: Text(l10n.back)),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: onNext,
                    child: Text(l10n.next),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// STEP 4: Photo Upload
// ────────────────────────────────────────────────────────────────────────────
class _PhotosStep extends StatelessWidget {
  final List<File> newPhotos;
  final List<String> existingUrls;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemoveNew;
  final ValueChanged<int> onRemoveExisting;
  final VoidCallback onBack;
  final Future<void> Function() onSubmit;
  final bool isLoading;
  final bool isEditMode;

  const _PhotosStep({
    required this.newPhotos,
    required this.existingUrls,
    required this.onAdd,
    required this.onRemoveNew,
    required this.onRemoveExisting,
    required this.onBack,
    required this.onSubmit,
    required this.isLoading,
    required this.isEditMode,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final total = newPhotos.length + existingUrls.length;
    final remaining = _kMaxPhotos - total;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.photos,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '$total / $_kMaxPhotos',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),

          // Photo slots row
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                // Existing photos
                ...existingUrls.asMap().entries.map((entry) {
                  return _PhotoSlot(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: entry.value,
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          top: 2,
                          right: 2,
                          child: GestureDetector(
                            onTap: () => onRemoveExisting(entry.key),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                // New photos
                ...newPhotos.asMap().entries.map((entry) {
                  return _PhotoSlot(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(entry.value, fit: BoxFit.cover),
                        Positioned(
                          top: 2,
                          right: 2,
                          child: GestureDetector(
                            onTap: () => onRemoveNew(entry.key),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                // Add slot
                if (remaining > 0)
                  _PhotoSlot(
                    onTap: onAdd,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.add_a_photo_outlined,
                          size: 28,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.addPhotoSlot,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const Spacer(),
          Row(
            children: [
              OutlinedButton(
                onPressed: isLoading ? null : onBack,
                child: Text(l10n.back),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: isLoading ? null : onSubmit,
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          isEditMode ? l10n.saveChanges : l10n.publishListing,
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PhotoSlot extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _PhotoSlot({required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.grey.withAlpha(100),
            width: 1.5,
            style: BorderStyle.solid,
          ),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        clipBehavior: Clip.antiAlias,
        child: child,
      ),
    );
  }
}
