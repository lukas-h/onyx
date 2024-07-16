import 'package:onyx/cubit/pb_cubit.dart';
import 'package:onyx/extensions/extensions_registry.dart';
import 'package:onyx/widgets/button.dart';
import 'package:onyx/widgets/narrow_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class _SettingsCard extends StatelessWidget {
  final Widget child;
  const _SettingsCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 0.5, color: Colors.grey[300]!),
        ),
      ),
      child: child,
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: ListTile(
            title: Text(
              'Settings',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
          ),
        ),
        Expanded(
          child: NarrowBody(
            child: ListView(
              children: [
                const _PocketBaseSettings(),
                for (final ext in context
                    .read<ExtensionsRegistry>()
                    .settingsExtensions) ...[
                  const SizedBox(height: 32),
                  _SettingsCard(
                    child: ListTile(
                      leading: ext.icon,
                      title: Text(ext.title),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ext.buildBody(context),
                  ),
                ]
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PocketBaseSettings extends StatelessWidget {
  const _PocketBaseSettings({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PocketBaseCubit, PocketBaseState>(
      builder: (context, state) {
        if (state is PocketBaseSuccess) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SettingsCard(
                child: ListTile(
                  leading: const Icon(
                    Icons.done_all,
                    color: Colors.green,
                  ),
                  title: const Text('Pocketbase connection active'),
                  subtitle: Text(state.url),
                ),
              ),
              _PocketBaseForm(
                initialUrl: state.url,
                initialEmail: state.email,
                initialPassword: state.password,
                saveButtonText: 'Update credentials',
              ),
            ],
          );
        } else if (state is PocketBaseError) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SettingsCard(
                child: ListTile(
                  leading: const Icon(
                    Icons.warning_amber_outlined,
                    color: Colors.red,
                  ),
                  title: const Text('Pocketbase connection error'),
                  subtitle: Text(state.message),
                ),
              ),
              _PocketBaseForm(
                initialUrl: state.url,
                initialEmail: state.email,
                initialPassword: state.password,
                saveButtonText: 'Fix credentials',
              ),
            ],
          );
        } else if (state is PocketBasePrompt) {
          return const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SettingsCard(
                child: ListTile(
                  leading: Icon(
                    Icons.info_outline,
                    color: Colors.yellow,
                  ),
                  title: Text('Pocketbase configuration'),
                  subtitle: Text('Please provide your credentials'),
                ),
              ),
              _PocketBaseForm(
                initialUrl: '',
                initialEmail: '',
                initialPassword: '',
                saveButtonText: 'Set credentials',
              ),
            ],
          );
        } else {
          return const _SettingsCard(
            child: ListTile(
              leading: CircularProgressIndicator(),
              title: Text('Pocketbase connection loading'),
              subtitle: Text('Trying to connect to service'),
            ),
          );
        }
      },
    );
  }
}

class _PocketBaseForm extends StatefulWidget {
  final String initialUrl;
  final String initialEmail;
  final String initialPassword;
  final String saveButtonText;

  const _PocketBaseForm({
    required this.initialUrl,
    required this.initialEmail,
    required this.initialPassword,
    required this.saveButtonText,
  });

  @override
  State<_PocketBaseForm> createState() => _PocketBaseFormState();
}

class _PocketBaseFormState extends State<_PocketBaseForm> {
  late final TextEditingController _urlController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  bool changed = false;

  @override
  void initState() {
    _urlController = TextEditingController(text: widget.initialUrl);
    _emailController = TextEditingController(text: widget.initialEmail);
    _passwordController = TextEditingController(text: widget.initialPassword);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _urlController,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Pocketbase instance URL...',
            ),
            cursorColor: Colors.black,
            onChanged: (v) {
              setState(() {
                changed = true;
              });
            },
          ),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Admin account email',
            ),
            cursorColor: Colors.black,
            onChanged: (v) {
              setState(() {
                changed = true;
              });
            },
          ),
          TextField(
            controller: _passwordController,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Admin account password',
            ),
            obscureText: true,
            cursorColor: Colors.black,
            onChanged: (v) {
              setState(() {
                changed = true;
              });
            },
          ),
          Button(
            widget.saveButtonText,
            maxWidth: false,
            icon: const Icon(Icons.done),
            active: false,
            onTap: changed
                ? () {
                    final pbCubit = context.read<PocketBaseCubit>();
                    pbCubit.setCredentials(
                      url: _urlController.text,
                      email: _emailController.text,
                      password: _passwordController.text,
                    );
                  }
                : null,
          ),
        ],
      ),
    );
  }
}
