import 'package:equatable/equatable.dart';

abstract class FileState extends Equatable {
  const FileState();

  @override
  List<Object> get props => [];
}

class FileInitial extends FileState {}

class FileLoading extends FileState {}

class FileLoaded extends FileState {
  final String content;

  const FileLoaded(this.content);

  @override
  List<Object> get props => [content];
}

class FileError extends FileState {
  final String message;

  const FileError(this.message);

  @override
  List<Object> get props => [message];
}
