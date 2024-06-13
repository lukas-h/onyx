import 'package:onyx/cubit/origin/origin_cubit.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:onyx/service/pb_service.dart';
import 'package:pocketbase/pocketbase.dart';

class PocketBaseCredentials {
  final String url;
  final String email;
  final String password;

  PocketBaseCredentials({
    required this.url,
    required this.email,
    required this.password,
  });
}

class PocketBaseCubit extends OriginCubit<PocketBaseCredentials> {
  @override
  Future<OriginState> init(FlutterSecureStorage storage) async {
    final url = await storage.read(key: 'url');
    final email = await storage.read(key: 'email');
    final password = await storage.read(key: 'password');

    if (url != null && email != null && password != null) {
      final pb = PocketBase(url);
      await pb.admins.authWithPassword(email, password);
      return OriginSuccess(
        credentials: PocketBaseCredentials(
          url: url,
          email: email,
          password: password,
        ),
        service: PocketBaseService(pb),
      );
    } else {
      return OriginPrompt();
    }
  }

  @override
  Future<OriginSuccess> reInit(
    FlutterSecureStorage storage,
    PocketBaseCredentials credentials,
  ) async {
    await storage.write(key: 'url', value: credentials.url);
    await storage.write(key: 'email', value: credentials.email);
    await storage.write(key: 'password', value: credentials.password);
    final pb = PocketBase(credentials.url);
    await pb.admins.authWithPassword(
      credentials.email,
      credentials.password,
    );
    return OriginSuccess<PocketBaseCredentials, PocketBaseService>(
      credentials: credentials,
      service: PocketBaseService(pb),
    );
  }
}
