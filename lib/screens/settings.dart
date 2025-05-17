import 'package:onyx/cubit/origin/directory_cubit.dart';
import 'package:onyx/cubit/origin/origin_cubit.dart';
import 'package:onyx/cubit/origin/pb_cubit.dart';
import 'package:onyx/service/directory_service.dart';
import 'package:onyx/service/pb_service.dart';
import 'package:onyx/cubit/ai_cubit.dart';
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
          padding: const EdgeInsets.only(top: 30.0),
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
                BlocBuilder<PocketBaseCubit, OriginState>(
                  builder: (context, state) {
                    if (state is OriginSuccess) {
                      final cred = state.credentials;
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
                              subtitle: Text(cred.url),
                            ),
                          ),
                          _PocketBaseForm(
                            initialUrl: cred.url,
                            initialEmail: cred.email,
                            initialPassword: cred.password,
                            saveButtonText: 'Update credentials',
                          ),
                        ],
                      );
                    } else if (state is OriginError) {
                      final cred = state.credentials;
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
                            initialUrl: cred?.url ?? '',
                            initialEmail: cred?.email ?? '',
                            initialPassword: cred?.password ?? '',
                            saveButtonText: 'Fix credentials',
                          ),
                        ],
                      );
                    } else if (state is OriginPrompt) {
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
                ),
                BlocBuilder<DirectoryCubit, OriginState>(
                  builder: (context, state) {
                    if (state is OriginSuccess) {
                      final cred = state.credentials;
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _SettingsCard(
                            child: ListTile(
                              leading: const Icon(
                                Icons.done_all,
                                color: Colors.green,
                              ),
                              title: const Text('Directory sync path set'),
                              subtitle: Text(cred.path),
                            ),
                          ),
                          _DirectoryForm(
                            initialPath: cred.path,
                            saveButtonText: 'Update path',
                          ),
                        ],
                      );
                    } else if (state is OriginError) {
                      final cred = state.credentials;
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _SettingsCard(
                            child: ListTile(
                              leading: const Icon(
                                Icons.warning_amber_outlined,
                                color: Colors.red,
                              ),
                              title: const Text('Directory sync path error'),
                              subtitle: Text(state.message),
                            ),
                          ),
                          _DirectoryForm(
                            initialPath: cred?.path ?? '',
                            saveButtonText: 'Fix path',
                          ),
                        ],
                      );
                    } else if (state is OriginPrompt) {
                      return const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _SettingsCard(
                            child: ListTile(
                              leading: Icon(
                                Icons.info_outline,
                                color: Colors.yellow,
                              ),
                              title: Text('Directory sync configuration'),
                              subtitle: Text('Please provide your path'),
                            ),
                          ),
                          _DirectoryForm(
                            initialPath: '',
                            saveButtonText: 'Set path',
                          ),
                        ],
                      );
                    } else {
                      return const _SettingsCard(
                        child: ListTile(
                          leading: CircularProgressIndicator(),
                          title: Text('Directory sync loading'),
                          subtitle: Text('Trying to setup folder'),
                        ),
                      );
                    }
                  },
                ),
                const _AiSettings(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PocketBaseSettings extends StatelessWidget {
  const _PocketBaseSettings();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PocketBaseCubit, OriginState>(
      builder: (context, state) {
        if (state is OriginSuccess) {
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
                  subtitle: Text(state.credentials.url),
                ),
              ),
              _PocketBaseForm(
                initialUrl: state.credentials.url,
                initialEmail: state.credentials.email,
                initialPassword: state.credentials.password,
                saveButtonText: 'Update credentials',
              ),
            ],
          );
        } else if (state is OriginError) {
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
                initialUrl: state.credentials.url,
                initialEmail: state.credentials.email,
                initialPassword: state.credentials.password,
                saveButtonText: 'Fix credentials',
              ),
            ],
          );
        } else if (state is OriginPrompt) {
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
                      PocketBaseCredentials(
                        url: _urlController.text,
                        email: _emailController.text,
                        password: _passwordController.text,
                      ),
                    );
                  }
                : null,
          ),
        ],
      ),
    );
  }
}

class _DirectoryForm extends StatefulWidget {
  final String initialPath;
  final String saveButtonText;

  const _DirectoryForm({
    required this.initialPath,
    required this.saveButtonText,
  });

  @override
  State<_DirectoryForm> createState() => _DirectoryFormState();
}

class _DirectoryFormState extends State<_DirectoryForm> {
  late final TextEditingController _pathController;
  bool changed = false;

  @override
  void initState() {
    _pathController = TextEditingController(text: widget.initialPath);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _pathController,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Directory sync path...',
            ),
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
                    final dirCubit = context.read<DirectoryCubit>();
                    dirCubit.setCredentials(
                      DirectoryCredentials(
                        path: _pathController.text,
                      ),
                    );
                  }
                : null,
          ),
        ],
      ),
    );
  }
}

class _AiSettings extends StatelessWidget {
  const _AiSettings();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AiServiceCubit, AiServiceState>(
      builder: (context, state) {
        return _AiForm(
          initialModel: state.model,
          initialApiToken: state.apiToken,
          saveButtonText: 'Update credentials',
        );
      },
    );
  }
}

class _AiForm extends StatefulWidget {
  final String initialModel;
  final String initialApiToken;
  final String saveButtonText;

  const _AiForm({
    required this.initialModel,
    required this.initialApiToken,
    required this.saveButtonText,
  });

  @override
  State<_AiForm> createState() => _AiFormState();
}

class _AiFormState extends State<_AiForm> {
  late final TextEditingController _modelController;
  late final TextEditingController _apiTokenController;
  bool changed = false;

  @override
  void initState() {
    _modelController = TextEditingController(text: widget.initialModel);
    _apiTokenController = TextEditingController(text: widget.initialApiToken);
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
            controller: _modelController,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Open Ai model',
            ),
            cursorColor: Colors.black,
            onChanged: (v) {
              setState(() {
                changed = true;
              });
            },
          ),
          TextField(
            controller: _apiTokenController,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'api token',
            ),
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
                    final aiServiceCubit = context.read<AiServiceCubit>();
                    aiServiceCubit.apiToken = _apiTokenController.text;
                    aiServiceCubit.model = _modelController.text;
                    changed = false;
                  }
                : null,
          ),
        ],
      ),
    );
  }
}
