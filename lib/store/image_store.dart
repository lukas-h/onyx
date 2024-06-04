import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:nanoid/nanoid.dart';

class ImageModel {
  Uint8List bytes;
  String title;
  String uid;

  ImageModel({
    required this.bytes,
    required this.title,
    required this.uid,
  });
}

class ImageStore {
  final List<ImageModel> images;

  ImageStore(this.images);

  Future<void> init() async {
    images.addAll([]);
  }

  Future<int> addImage(Uint8List bytes, String title) async {
    images.add(
      ImageModel(
        bytes: bytes,
        title: title,
        uid: nanoid(),
      ),
    );
    return images.length - 1;
  }

  void removeImage(String uid) {
    images.removeWhere((e) => e.uid == uid);
  }

  ImageModel? getImageById(String uid) {
    return images.singleWhereOrNull((e) => e.uid == uid);
  }

  ImageModel? getImageByName(String name) {
    return images.singleWhereOrNull((e) => e.title == name);
  }
}
