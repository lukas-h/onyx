import 'dart:async';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:nanoid/nanoid.dart';
import 'package:onyx/service/service.dart';

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
  List<OriginService>? _originServices;
  final List<ImageModel> images;

  ImageStore(this.images, {List<OriginService>? originServices})
      : _originServices = originServices;

  set originServices(List<OriginService> originServices) {
    _originServices = originServices;
  }

  Future<void> init() async {
    final dbImages = await _originServices?.firstOrNull?.getImages();
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
    _originServices?.firstOrNull?.createImage(model);
    return images.length - 1;
  }

  Future<void> removeImage(String uid) async {
    images.removeWhere((e) => e.uid == uid);
    _originServices?.firstOrNull?.deleteImage(uid);
  }

  Future<ImageModel?> getImageById(String uid) async =>
      images.singleWhereOrNull((e) => e.uid == uid);

  Future<ImageModel?> getImageByTitle(String title) async =>
      images.singleWhereOrNull((e) => e.title == title);
}
