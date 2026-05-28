import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Domain model for a single field definition from category_schemas.
class FieldDefinition {
  final String key;
  final String labelAr;
  final String labelFr;
  final String labelEn;
  final String labelKab;
  final String type; // text, number, select, boolean, date, textarea
  final bool required;
  final List<String>? options;

  const FieldDefinition({
    required this.key,
    required this.labelAr,
    required this.labelFr,
    required this.labelEn,
    required this.labelKab,
    required this.type,
    required this.required,
    this.options,
  });

  factory FieldDefinition.fromJson(Map<String, dynamic> json) {
    return FieldDefinition(
      key: json['key'] as String,
      labelAr: json['label_ar'] as String? ?? json['key'],
      labelFr: json['label_fr'] as String? ?? json['key'],
      labelEn: json['label_en'] as String? ?? json['key'],
      labelKab: json['label_kab'] as String? ?? json['key'],
      type: json['type'] as String? ?? 'text',
      required: json['required'] as bool? ?? false,
      options: (json['options'] as List?)?.cast<String>(),
    );
  }

  String labelFor(String locale) {
    switch (locale) {
      case 'ar': return labelAr;
      case 'fr': return labelFr;
      case 'kab': return labelKab;
      default: return labelEn;
    }
  }
}

/// Result containing required and optional field definitions parsed from a schema row.
class CategorySchema {
  final List<FieldDefinition> requiredFields;
  final List<FieldDefinition> optionalFields;

  const CategorySchema({
    required this.requiredFields,
    required this.optionalFields,
  });
}

// Hardcoded field definitions keyed by field key, since the DB stores only keys in arrays.
// Matches the seed data in supabase_schema.sql.
const _fieldDefinitions = <String, Map<String, dynamic>>{
  // Livestock
  'species': {'key': 'species', 'label_ar': 'النوع', 'label_fr': 'Espèce', 'label_en': 'Species', 'label_kab': 'Taneggart', 'type': 'text', 'required': true},
  'age_months': {'key': 'age_months', 'label_ar': 'العمر (أشهر)', 'label_fr': 'Âge (mois)', 'label_en': 'Age (months)', 'label_kab': 'Amadu (wagguren)', 'type': 'number', 'required': true},
  'weight_kg': {'key': 'weight_kg', 'label_ar': 'الوزن (كغ)', 'label_fr': 'Poids (kg)', 'label_en': 'Weight (kg)', 'label_kab': 'Azal (kg)', 'type': 'number', 'required': true},
  'sex': {'key': 'sex', 'label_ar': 'الجنس', 'label_fr': 'Sexe', 'label_en': 'Sex', 'label_kab': 'Turgit', 'type': 'select', 'required': true, 'options': ['ذكر', 'أنثى']},
  'health_status': {'key': 'health_status', 'label_ar': 'الحالة الصحية', 'label_fr': 'État de santé', 'label_en': 'Health status', 'label_kab': 'Taɣult n tafat', 'type': 'select', 'required': true, 'options': ['سليم', 'تحت العلاج', 'محجور صحياً']},
  'breed': {'key': 'breed', 'label_ar': 'السلالة', 'label_fr': 'Race', 'label_en': 'Breed', 'label_kab': 'Abrid', 'type': 'text', 'required': false},
  'vaccinated': {'key': 'vaccinated', 'label_ar': 'تم التطعيم', 'label_fr': 'Vacciné', 'label_en': 'Vaccinated', 'label_kab': 'Yettwaseqqa', 'type': 'boolean', 'required': false},
  'color': {'key': 'color', 'label_ar': 'اللون', 'label_fr': 'Couleur', 'label_en': 'Color', 'label_kab': 'Amensay', 'type': 'text', 'required': false},
  'quantity': {'key': 'quantity', 'label_ar': 'الكمية', 'label_fr': 'Quantité', 'label_en': 'Quantity', 'label_kab': 'Tuddart', 'type': 'number', 'required': false},
  'notes': {'key': 'notes', 'label_ar': 'ملاحظات', 'label_fr': 'Notes', 'label_en': 'Notes', 'label_kab': 'Tifraz', 'type': 'textarea', 'required': false},
  // Crops
  'crop_type': {'key': 'crop_type', 'label_ar': 'نوع المحصول', 'label_fr': 'Type de culture', 'label_en': 'Crop type', 'label_kab': 'Anaw n tfellaḥt', 'type': 'text', 'required': true},
  'unit': {'key': 'unit', 'label_ar': 'الوحدة', 'label_fr': 'Unité', 'label_en': 'Unit', 'label_kab': 'Asdaw', 'type': 'select', 'required': true, 'options': ['كغ', 'طن', 'قنطال', 'عدد']},
  'harvest_date': {'key': 'harvest_date', 'label_ar': 'تاريخ الحصاد', 'label_fr': 'Date de récolte', 'label_en': 'Harvest date', 'label_kab': 'Azemz n tuɣmawin', 'type': 'date', 'required': true},
  'price_per_unit': {'key': 'price_per_unit', 'label_ar': 'السعر لكل وحدة', 'label_fr': 'Prix par unité', 'label_en': 'Price per unit', 'label_kab': 'Aqar di kul asdaw', 'type': 'number', 'required': true},
  'organic': {'key': 'organic', 'label_ar': 'عضوي', 'label_fr': 'Biologique', 'label_en': 'Organic', 'label_kab': 'Aɣerfan', 'type': 'boolean', 'required': false},
  'irrigation_method': {'key': 'irrigation_method', 'label_ar': 'طريقة الري', 'label_fr': 'Mode d\'irrigation', 'label_en': 'Irrigation method', 'label_kab': 'Tarrayt n usqsi', 'type': 'text', 'required': false},
  'storage_conditions': {'key': 'storage_conditions', 'label_ar': 'ظروف التخزين', 'label_fr': 'Conditions de stockage', 'label_en': 'Storage conditions', 'label_kab': 'Aḍris n asekles', 'type': 'textarea', 'required': false},
  // Artisan
  'product_type': {'key': 'product_type', 'label_ar': 'نوع المنتج', 'label_fr': 'Type de produit', 'label_en': 'Product type', 'label_kab': 'Anaw n asali', 'type': 'text', 'required': true},
  'ingredients': {'key': 'ingredients', 'label_ar': 'المكونات', 'label_fr': 'Ingrédients', 'label_en': 'Ingredients', 'label_kab': 'Timahlin', 'type': 'textarea', 'required': false},
  'origin_region': {'key': 'origin_region', 'label_ar': 'منطقة المنشأ', 'label_fr': 'Région d\'origine', 'label_en': 'Origin region', 'label_kab': 'Tamurt n tazwara', 'type': 'text', 'required': false},
  'shelf_life': {'key': 'shelf_life', 'label_ar': 'مدة الصلاحية', 'label_fr': 'Durée de conservation', 'label_en': 'Shelf life', 'label_kab': 'Talast n tadukli', 'type': 'text', 'required': false},
  'certifications': {'key': 'certifications', 'label_ar': 'الشهادات', 'label_fr': 'Certifications', 'label_en': 'Certifications', 'label_kab': 'Tisiggelt', 'type': 'text', 'required': false},
  // Services
  'service_type': {'key': 'service_type', 'label_ar': 'نوع الخدمة', 'label_fr': 'Type de service', 'label_en': 'Service type', 'label_kab': 'Anaw n tmekkiḍt', 'type': 'text', 'required': true},
  'wilaya_coverage': {'key': 'wilaya_coverage', 'label_ar': 'ولايات التغطية', 'label_fr': 'Wilayas couvertes', 'label_en': 'Coverage wilayas', 'label_kab': 'Tilalen yettwattwalen', 'type': 'text', 'required': true},
  'availability': {'key': 'availability', 'label_ar': 'التوفر', 'label_fr': 'Disponibilité', 'label_en': 'Availability', 'label_kab': 'Aɣref', 'type': 'text', 'required': true},
  'contact_preference': {'key': 'contact_preference', 'label_ar': 'طريقة التواصل المفضلة', 'label_fr': 'Mode de contact préféré', 'label_en': 'Contact preference', 'label_kab': 'Aɣewwaḍ n tutlayt', 'type': 'select', 'required': true, 'options': ['هاتف', 'واتساب', 'كليهما']},
  'equipment_used': {'key': 'equipment_used', 'label_ar': 'المعدات المستخدمة', 'label_fr': 'Équipements utilisés', 'label_en': 'Equipment used', 'label_kab': 'Iferdisen yettwaseqdacen', 'type': 'textarea', 'required': false},
  'experience_years': {'key': 'experience_years', 'label_ar': 'سنوات الخبرة', 'label_fr': 'Années d\'expérience', 'label_en': 'Experience years', 'label_kab': 'Iseggasen n tmusni', 'type': 'number', 'required': false},
  'service_radius_km': {'key': 'service_radius_km', 'label_ar': 'نطاق الخدمة (كم)', 'label_fr': 'Rayon de service (km)', 'label_en': 'Service radius (km)', 'label_kab': 'Azwaw n tmekkiḍt (km)', 'type': 'number', 'required': false},
};

final categorySchemaProvider = FutureProvider.family<CategorySchema, ({String category, String subcategory})>((ref, args) async {
  final supabase = Supabase.instance.client;

  final data = await supabase
      .from('category_schemas')
      .select('fields_schema')
      .eq('category', args.category)
      .eq('subcategory', args.subcategory)
      .maybeSingle();

  if (data == null) return const CategorySchema(requiredFields: [], optionalFields: []);

  final schema = data['fields_schema'] as Map<String, dynamic>;
  final criticalKeys = (schema['critical'] as List?)?.cast<String>() ?? [];
  final optionalKeys = (schema['optional'] as List?)?.cast<String>() ?? [];

  FieldDefinition? resolve(String key) {
    final def = _fieldDefinitions[key];
    if (def == null) return null;
    return FieldDefinition.fromJson(def);
  }

  final requiredFields = criticalKeys
      .where((k) => !['price', 'wilaya', 'photos'].contains(k)) // common fields handled separately
      .map(resolve)
      .whereType<FieldDefinition>()
      .toList();

  final optionalFields = optionalKeys
      .map(resolve)
      .whereType<FieldDefinition>()
      .toList();

  return CategorySchema(requiredFields: requiredFields, optionalFields: optionalFields);
});
