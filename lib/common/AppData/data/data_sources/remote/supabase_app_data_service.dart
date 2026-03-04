import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:endimata/common/AppData/data/data_sources/remote/app_data_api_service.dart';
import 'package:endimata/common/AppData/data/models/deleted_photo_model.dart';
import 'package:endimata/common/AppData/data/models/photo_model.dart';

class SupabaseAppDataService implements AppDataApiService {
  final SupabaseClient _client = Supabase.instance.client;
  final String _userId;

  final Box<String> _humanPhotosBox;
  final Box<PhotoModel> _wardrobeItemsBox;
  final Box<DeletedPhotoModel> _deletedPhotosBox;

  SupabaseAppDataService(
    this._userId, {
    required Box<String> humanPhotosBox,
    required Box<PhotoModel> wardrobeItemsBox,
    required Box<DeletedPhotoModel> deletedPhotosBox,
  }) : _humanPhotosBox = humanPhotosBox,
       _wardrobeItemsBox = wardrobeItemsBox,
       _deletedPhotosBox = deletedPhotosBox;

  // ──────────────── STORAGE ────────────────

  Future<String> _uploadToStorage(String base64Image, String path) async {
    final cleanBase64 =
        base64Image.contains(',') ? base64Image.split(',').last : base64Image;
    final Uint8List bytes = base64Decode(cleanBase64);

    await _client.storage
        .from('photos')
        .uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: true,
          ),
        );

    return path; // возвращаем путь, скачиваем отдельно
  }

  Future<String> _downloadAsBase64(String storagePath) async {
    final Uint8List bytes = await _client.storage
        .from('photos')
        .download(storagePath);
    return base64Encode(bytes);
  }

  // ──────────────── HUMAN PHOTOS ────────────────

  @override
  Future<List<String>> getHumanPhotos() async {
    // Сначала кэш
    final cached = _humanPhotosBox.values.toList();
    if (cached.isNotEmpty) return cached;

    return await _syncHumanPhotosFromSupabase();
  }

  Future<List<String>> _syncHumanPhotosFromSupabase() async {
    final rows = await _client
        .from('human_photos')
        .select()
        .eq('user_id', _userId)
        .order('created_at');

    await _humanPhotosBox.clear();

    for (final row in rows) {
      final base64 = await _downloadAsBase64(row['storage_path'] as String);
      await _humanPhotosBox.put(row['id'] as String, base64);
    }

    return _humanPhotosBox.values.toList();
  }

  @override
  Future<void> addHumanPhoto(String fileBase64, String userName) async {
    final id = const Uuid().v4();
    final path = '$_userId/human_photos/$id.jpg';

    // 1. Загружаем в Storage
    await _uploadToStorage(fileBase64, path);

    // 2. Сохраняем метаданные в БД
    await _client.from('human_photos').insert({
      'id': id,
      'user_id': _userId,
      'storage_path': path,
      'user_name': userName,
    });

    // 3. Кэшируем в Hive
    await _humanPhotosBox.put(id, fileBase64);
  }

  // ──────────────── WARDROBE ITEMS ────────────────

  @override
  Future<List<PhotoModel>> getWardrobeItems() async {
    final cached = _wardrobeItemsBox.values.toList();
    if (cached.isNotEmpty) return cached;

    return await _syncWardrobeFromSupabase();
  }

  Future<List<PhotoModel>> _syncWardrobeFromSupabase() async {
    final rows = await _client
        .from('wardrobe_items')
        .select()
        .eq('user_id', _userId)
        .order('category');

    await _wardrobeItemsBox.clear();

    for (final row in rows) {
      final base64 = await _downloadAsBase64(row['storage_path'] as String);
      final model = PhotoModel(
        user_name: row['user_name'] ?? '',
        image: base64,
        category: row['category'] ?? '',
        subcategory: row['subcategory'] ?? '',
        sub_subcategory: row['sub_subcategory'] ?? '',
      );
      await _wardrobeItemsBox.put(row['id'] as String, model);
    }

    final items = _wardrobeItemsBox.values.toList();
    items.sort((a, b) {
      final c = a.category.compareTo(b.category);
      return c != 0 ? c : a.subcategory.compareTo(b.subcategory);
    });
    return items;
  }

  @override
  Future<void> addClothingItem(
    String fileBase64,
    String userName,
    String category,
    String subcategory,
    String subSubcategory,
  ) async {
    final id = const Uuid().v4();
    final path = '$_userId/wardrobe/$id.jpg';

    await _uploadToStorage(fileBase64, path);

    await _client.from('wardrobe_items').insert({
      'id': id,
      'user_id': _userId,
      'storage_path': path,
      'user_name': userName,
      'category': category,
      'subcategory': subcategory,
      'sub_subcategory': subSubcategory,
    });

    final model = PhotoModel(
      user_name: userName,
      image: fileBase64,
      category: category,
      subcategory: subcategory,
      sub_subcategory: subSubcategory,
    );
    await _wardrobeItemsBox.put(id, model);
  }

  // ──────────────── DELETE ────────────────

  @override
  Future<void> deletePhoto(String id, String type) async {
    if (type == 'human') {
      final entries = _humanPhotosBox.toMap();
      for (final entry in entries.entries) {
        if (entry.value.hashCode.toString() == id) {
          final base64 = entry.value;
          final docId = entry.key.toString();
          final path = '$_userId/human_photos/$docId.jpg';

          // Удаляем запись из БД
          await _client
              .from('human_photos')
              .delete()
              .eq('id', docId)
              .eq('user_id', _userId);

          // Добавляем в удалённые
          final deletedId = const Uuid().v4();
          await _client.from('deleted_photos').insert({
            'id': deletedId,
            'user_id': _userId,
            'storage_path': path,
            'type': 'human',
            'user_name': 'user',
          });

          // Обновляем Hive
          await _humanPhotosBox.delete(entry.key);
          final deletedModel = DeletedPhotoModel.fromHumanPhoto(
            base64,
            'user',
            docId,
          );
          await _deletedPhotosBox.put(docId, deletedModel);
          break;
        }
      }
    } else if (type == 'wardrobe') {
      final entries = _wardrobeItemsBox.toMap();
      for (final entry in entries.entries) {
        if (entry.value.hashCode.toString() == id) {
          final photo = entry.value;
          final docId = entry.key.toString();
          final path = '$_userId/wardrobe/$docId.jpg';

          await _client
              .from('wardrobe_items')
              .delete()
              .eq('id', docId)
              .eq('user_id', _userId);

          final deletedId = const Uuid().v4();
          await _client.from('deleted_photos').insert({
            'id': deletedId,
            'user_id': _userId,
            'storage_path': path,
            'type': 'wardrobe',
            'user_name': photo.user_name,
            'category': photo.category,
            'subcategory': photo.subcategory,
            'sub_subcategory': photo.sub_subcategory,
          });

          await _wardrobeItemsBox.delete(entry.key);
          final deletedModel = DeletedPhotoModel.fromWardrobeItem(photo, docId);
          await _deletedPhotosBox.put(docId, deletedModel);
          break;
        }
      }
    }
  }

  // ──────────────── DELETED PHOTOS ────────────────

  Future<List<DeletedPhotoModel>> getDeletedPhotos() async {
    return _deletedPhotosBox.values.toList();
  }

  Future<void> permanentlyDeletePhoto(String imageBase64) async {
    final entries = _deletedPhotosBox.toMap();
    for (final entry in entries.entries) {
      if (entry.value.imageBase64 == imageBase64) {
        final docId = entry.key.toString();
        final type = entry.value.type;
        final path =
            type == 'human'
                ? '$_userId/human_photos/$docId.jpg'
                : '$_userId/wardrobe/$docId.jpg';

        // Удаляем файл из Storage
        try {
          await _client.storage.from('photos').remove([path]);
        } catch (_) {}

        await _client.from('deleted_photos').delete().eq('user_id', _userId);

        await _deletedPhotosBox.delete(entry.key);
        break;
      }
    }
  }

  @override
  Future<void> clearData() async {
    await _humanPhotosBox.clear();
    await _wardrobeItemsBox.clear();
    await _deletedPhotosBox.clear();

    await _client.from('human_photos').delete().eq('user_id', _userId);
    await _client.from('wardrobe_items').delete().eq('user_id', _userId);
    await _client.from('deleted_photos').delete().eq('user_id', _userId);
  }

  // ──────────────── SYNC ────────────────

  Future<void> syncFromSupabase() async {
    await _humanPhotosBox.clear();
    await _wardrobeItemsBox.clear();
    await _deletedPhotosBox.clear();
    await _syncHumanPhotosFromSupabase();
    await _syncWardrobeFromSupabase();
  }

  @override
  Future<List<PhotoModel>> getCatalogItems() async => [];

  Future<bool> hasUpdates() async => false;
}
