import 'dart:io';

import 'package:onyx/cubit/origin/origin_cubit.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:onyx/service/directory_service.dart';

class DirectoryCredentials {
  final String path;

  DirectoryCredentials({
    required this.path,
  });
}

class DirectoryCubit extends OriginCubit<DirectoryCredentials> {
  @override
  Future<OriginState> init(
    FlutterSecureStorage storage,
  ) async {
    final path = await storage.read(key: 'path');

    if (path != null) {
      var dir = Directory(path);
      if (!(await dir.exists())) {
        dir = await dir.create();
      }
      return OriginSuccess<DirectoryCredentials, DirectoryService>(
        credentials: DirectoryCredentials(
          path: path,
        ),
        service: DirectoryService(dir, this),
      );
    } else {
      return OriginPrompt();
    }
  }

  @override
  Future<OriginSuccess> reInit(
    FlutterSecureStorage storage,
    DirectoryCredentials credentials,
  ) async {
    await storage.write(key: 'path', value: credentials.path);
    var dir = Directory(credentials.path);
    if (!(await dir.exists())) {
      dir = await dir.create();
    }
    return OriginSuccess(
      credentials: DirectoryCredentials(
        path: credentials.path,
      ),
      service: DirectoryService(dir, this),
    );
  }
}
