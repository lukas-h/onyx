import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import '../states/file_state.dart';

class FileCubit extends Cubit<FileState> {
  FileCubit() : super(FileInitial());

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> getLocalFile(String filename) async {
    final path = await _localPath;
    return File('$path/$filename');
  }

  Future<void> checkAndWriteFile(String filename, String newContent) async {
    emit(FileLoading());
    try {
      final file = await getLocalFile(filename);
      if (await file.exists()) {
        String existingContent = await readFromFile(file);
        existingContent = existingContent + '\n' + newContent;
        await writeToFile(existingContent, file);
        emit(FileLoaded(existingContent));
      } else {
        await writeToFile(newContent, file);
        emit(FileLoaded(newContent));
      }
    } catch (e) {
      debugPrint("shreyash_exception ${e.toString()}");
      emit(FileError(e.toString()));
    }
  }

  Future<String> readFromFile(File file) async {
    try {
      String contents = await file.readAsString();
      return contents;
    } catch (e) {
      throw Exception('Error reading file: $e');
    }
  }

  Future<void> writeToFile(String content, File file) async {
    try {
      await file.writeAsString(content);
    } catch (e) {
      throw Exception('Error writing to file: $e');
    }
  }
}
