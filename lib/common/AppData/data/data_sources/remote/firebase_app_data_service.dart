import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:endimata/common/AppData/data/data_sources/remote/app_data_api_service.dart';
import 'package:endimata/common/AppData/data/models/deleted_photo_model.dart';
import 'package:endimata/common/AppData/data/models/photo_model.dart';

class FirebaseAppDataService implements AppDataApiService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final String _userId;

  // Hive боксы для кэша
  final Box<String> _humanPhotosBox;
  final Box<PhotoModel> _wardrobeItemsBox;
  final Box<DeletedPhotoModel> _deletedPhotosBox;

  FirebaseAppDataService(
    this._userId, {
    required Box<String> humanPhotosBox,
    required Box<PhotoModel> wardrobeItemsBox,
    required Box<DeletedPhotoModel> deletedPhotosBox,
  }) : _humanPhotosBox = humanPhotosBox,
       _wardrobeItemsBox = wardrobeItemsBox,
       _deletedPhotosBox = deletedPhotosBox;

  CollectionReference _userCollection(String name) =>
      _firestore.collection('users').doc(_userId).collection(name);

  // ──────────────── ЗАГРУЗКА В STORAGE ────────────────

  Future<String> _uploadToStorage(String base64Image, String path) async {
    final cleanBase64 =
        base64Image.contains(',') ? base64Image.split(',').last : base64Image;
    final Uint8List bytes = base64Decode(cleanBase64);
    final ref = _storage.ref().child('users/$_userId/$path');
    await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
    return await ref.getDownloadURL();
  }

  Future<String> _downloadAsBase64(String url) async {
    final ref = _storage.refFromURL(url);
    final Uint8List? bytes = await ref.getData();
    if (bytes == null) throw Exception('Не удалось скачать фото');
    return base64Encode(bytes);
  }

  // ──────────────── HUMAN PHOTOS ────────────────

  @override
  Future<List<String>> getHumanPhotos() async {
    final cached = _humanPhotosBox.values.toList();
    if (cached.isNotEmpty) return cached;

    return await _syncHumanPhotosFromFirebase();
  }

  Future<List<String>> _syncHumanPhotosFromFirebase() async {
    final snapshot =
        await _userCollection('human_photos').orderBy('createdAt').get();

    await _humanPhotosBox.clear();

    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final url = data['storageUrl'] as String;
      final base64 = await _downloadAsBase64(url);
      await _humanPhotosBox.put(doc.id, base64);
    }

    return _humanPhotosBox.values.toList();
  }

  @override
  Future<void> addHumanPhoto(String fileBase64, String userName) async {
    final id = const Uuid().v4();

    final url = await _uploadToStorage(fileBase64, 'human_photos/$id.jpg');

    await _userCollection('human_photos').doc(id).set({
      'storageUrl': url,
      'userName': userName,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _humanPhotosBox.put(id, fileBase64);
  }

  // ──────────────── WARDROBE ITEMS ────────────────

  @override
  Future<List<PhotoModel>> getWardrobeItems() async {
    final cached = _wardrobeItemsBox.values.toList();
    if (cached.isNotEmpty) return cached;

    return await _syncWardrobeFromFirebase();
  }

  Future<List<PhotoModel>> _syncWardrobeFromFirebase() async {
    final snapshot =
        await _userCollection('wardrobe_items').orderBy('category').get();

    await _wardrobeItemsBox.clear();

    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final url = data['storageUrl'] as String;
      final base64 = await _downloadAsBase64(url);

      final model = PhotoModel(
        user_name: data['userName'] ?? '',
        image: base64,
        category: data['category'] ?? '',
        subcategory: data['subcategory'] ?? '',
        sub_subcategory: data['subSubcategory'] ?? '',
      );
      await _wardrobeItemsBox.put(doc.id, model);
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

    final url = await _uploadToStorage(fileBase64, 'wardrobe/$id.jpg');

    await _userCollection('wardrobe_items').doc(id).set({
      'storageUrl': url,
      'userName': userName,
      'category': category,
      'subcategory': subcategory,
      'subSubcategory': subSubcategory,
      'createdAt': FieldValue.serverTimestamp(),
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

  // ──────────────── DELETE / RESTORE ────────────────

  @override
  Future<void> deletePhoto(String id, String type) async {
    if (type == 'human') {
      final entries = _humanPhotosBox.toMap();
      for (final entry in entries.entries) {
        if (entry.value.hashCode.toString() == id) {
          final base64 = entry.value;
          final docId = entry.key.toString();

          await _userCollection('human_photos').doc(docId).delete();

          await _userCollection('deleted_photos').doc(docId).set({
            'imageBase64_ref': docId,
            'type': 'human',
            'userName': 'user',
            'deletedAt': FieldValue.serverTimestamp(),
          });

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
    }
  }

  @override
  Future<void> clearData() async {
    await _humanPhotosBox.clear();
    await _wardrobeItemsBox.clear();
    await _deletedPhotosBox.clear();

    final batch = _firestore.batch();
    for (final col in ['human_photos', 'wardrobe_items', 'deleted_photos']) {
      final snap = await _userCollection(col).get();
      for (final doc in snap.docs) {
        batch.delete(doc.reference);
      }
    }
    await batch.commit();
  }

  // ──────────────── DELETED PHOTOS ────────────────

  Future<List<DeletedPhotoModel>> getDeletedPhotos() async {
    return _deletedPhotosBox.values.toList();
  }

  Future<void> permanentlyDeletePhoto(String imageBase64) async {
    final entries = _deletedPhotosBox.toMap();
    for (final entry in entries.entries) {
      if (entry.value.imageBase64 == imageBase64) {
        try {
          final ref = _storage.ref().child(
            'users/$_userId/human_photos/${entry.key}.jpg',
          );
          await ref.delete();
        } catch (_) {}

        await _userCollection(
          'deleted_photos',
        ).doc(entry.key.toString()).delete();
        await _deletedPhotosBox.delete(entry.key);
        break;
      }
    }
  }

  Future<bool> hasUpdates() async => false;

  // ──────────────── SYNC (вызывать при входе) ────────────────

  Future<void> syncFromFirebase() async {
    await _humanPhotosBox.clear();
    await _wardrobeItemsBox.clear();
    await _deletedPhotosBox.clear();
    await _syncHumanPhotosFromFirebase();
    await _syncWardrobeFromFirebase();
  }

  @override
  Future<List<PhotoModel>> getCatalogItems() async => [];
}
