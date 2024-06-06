import 'package:onyx/cubit/page_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class _ErrorBuilder extends StatelessWidget {
  final String name;
  const _ErrorBuilder({super.key, required this.name});

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
    final image = context.read<PageCubit>().getImage(name);
    if (image != null) {
      return Image.memory(image.bytes);
    } else if (Uri.tryParse(name) != null) {
      return Image.network(
        name,
        errorBuilder: (context, error, stackTrace) => _ErrorBuilder(
          name: error.toString(),
        ),
      );
    } else {
      return _ErrorBuilder(name: name);
    }
  }
}
