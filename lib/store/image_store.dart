import 'dart:async';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:nanoid/nanoid.dart';
import 'package:onyx/store/pocketbase.dart';

class ImageModel {
  Future<Uint8List> bytes;
  String title;
  String uid;

  ImageModel({
    required this.bytes,
    required this.title,
    required this.uid,
  });
}

class ImageStore {
  PocketBaseService? _pbService;
  final List<ImageModel> images;

  ImageStore(this.images, {PocketBaseService? pbService})
      : _pbService = pbService;

  set pbService(PocketBaseService pbService) {
    _pbService = pbService;
  }

  Future<void> init() async {
    final dbImages = await _pbService?.getImages();
    images.addAll([
      ...?dbImages,
    ]);
  }

  Future<int> addImage(Uint8List bytes, String title) async {
    final model = ImageModel(
      bytes: Future.value(bytes),
      title: title,
      uid: nanoid(15),
    );
    images.add(model);
    _pbService?.createImage(model);
    return images.length - 1;
  }

  Future<void> removeImage(String uid) async {
    images.removeWhere((e) => e.uid == uid);
    _pbService?.deleteImage(uid);
  }

  Future<ImageModel?> getImageById(String uid) async =>
      images.singleWhereOrNull((e) => e.uid == uid);

  Future<ImageModel?> getImageByTitle(String title) async =>
      images.singleWhereOrNull((e) => e.title == title);
}
