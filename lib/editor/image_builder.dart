import 'dart:io';
import 'dart:typed_data';

import 'package:onyx/cubit/page_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class _ErrorBuilder extends StatelessWidget {
  final String name;
  const _ErrorBuilder({required this.name});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(
        Icons.error_outline,
        color: Colors.red,
      ),
      title: const Text('Image URL unparseable'),
      subtitle: Text(name),
    );
  }
}

class _LoadingBuilder extends StatelessWidget {
  final String name;
  const _LoadingBuilder({required this.name});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircularProgressIndicator(),
      title: const Text('Image is loading'),
      subtitle: Text(name),
    );
  }
}

class ImageBuilder extends StatelessWidget {
  final Uri uri;
  final String? title;
  final String? alt;

  const ImageBuilder({
    super.key,
    required this.uri,
    required this.title,
    required this.alt,
  });

  @override
  Widget build(BuildContext context) {
    final name = uri.toString();
    final cubit = context.read<PageCubit>();
    return FutureBuilder<Uint8List>(
        future: cubit.getImage(name).then((image) {
          if (image == null) throw PathNotFoundException(name, const OSError());
          return image.bytes;
        }),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.done && snap.hasData) {
            return ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 750),
                child: Image.memory(snap.data!));
          } else if (snap.hasError && snap.error is PathNotFoundException) {
            if (Uri.tryParse(name) != null) {
              return ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 750),
                child: Image.network(
                  name,
                  errorBuilder: (context, error, stackTrace) => _ErrorBuilder(
                    name: error.toString(),
                  ),
                ),
              );
            } else {
              return _ErrorBuilder(name: name);
            }
          } else if (snap.connectionState != ConnectionState.done) {
            return _LoadingBuilder(name: name);
          } else {
            return _ErrorBuilder(name: name);
          }
        });
  }
}
