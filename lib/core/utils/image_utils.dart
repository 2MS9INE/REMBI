import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart' show getTemporaryDirectory;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;

/// Compresses [originalFile] to max 800px on the longest side at JPEG quality 80.
/// Returns a new [File] with the compressed image.
Future<File> compressImage(File originalFile) async {
  final tmpDir = await getTemporaryDirectory();
  final outPath = p.join(
    tmpDir.path,
    '${DateTime.now().millisecondsSinceEpoch}_compressed.jpg',
  );

  final Uint8List? result = await FlutterImageCompress.compressWithFile(
    originalFile.absolute.path,
    minWidth: 800,
    minHeight: 800,
    quality: 80,
    format: CompressFormat.jpeg,
    keepExif: false,
  );

  if (result == null) return originalFile;
  final outFile = File(outPath);
  await outFile.writeAsBytes(result);
  return outFile;
}

/// Compresses and uploads a listing photo to Supabase Storage.
/// Returns the public URL of the uploaded photo.
Future<String> uploadListingPhoto(
  File file,
  String farmerId,
  String listingId,
) async {
  final compressed = await compressImage(file);
  final filename = '${DateTime.now().millisecondsSinceEpoch}.jpg';
  final storagePath = 'listings/$farmerId/$listingId/$filename';

  await Supabase.instance.client.storage
      .from('listings')
      .upload(storagePath, compressed);

  return Supabase.instance.client.storage
      .from('listings')
      .getPublicUrl(storagePath);
}

/// Uploads an avatar image to the 'avatars' bucket, returns public URL.
Future<String> uploadAvatarPhoto(File file, String userId) async {
  final compressed = await compressImage(file);
  final filename = '${DateTime.now().millisecondsSinceEpoch}.jpg';
  final storagePath = 'avatars/$userId/$filename';

  await Supabase.instance.client.storage
      .from('avatars')
      .upload(storagePath, compressed);

  return Supabase.instance.client.storage
      .from('avatars')
      .getPublicUrl(storagePath);
}
