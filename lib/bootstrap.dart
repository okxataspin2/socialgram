import 'dart:async';
import 'dart:developer';

import 'package:app_ui/app_ui.dart';
import 'package:env/env.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config_repository/firebase_remote_config_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_instagram_offline_first_clone/app/app.dart';
import 'package:flutter_instagram_offline_first_clone/firebase_options.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:persistent_storage/persistent_storage.dart';
import 'package:powersync_repository/powersync_repository.dart';
import 'package:shared/shared.dart';

typedef AppBuilder =
    FutureOr<Widget> Function(
      PowerSyncRepository,
      FirebaseMessaging,
      SharedPreferences,
      FirebaseRemoteConfigRepository,
    );

class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    log('onError ${bloc.runtimeType}', error: error, stackTrace: stackTrace);
    super.onError(bloc, error, stackTrace);
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  logI('Handling a background message: ${message.toMap()}');
}

Future<void> bootstrap(
  AppBuilder builder, {
  required AppFlavor appFlavor,
}) async {
  FlutterError.onError = (details) {
    logE(details.exceptionAsString(), stackTrace: details.stack);
  };

  Bloc.observer = const AppBlocObserver();

  final bootErrors = <String>[];
  SharedPreferences? sharedPreferences;
  FirebaseRemoteConfigRepository? remoteConfigRepository;

  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      await _guard('Firebase', bootErrors, () async {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      });

      await _guard('Local storage', bootErrors, () async {
        HydratedBloc.storage = await HydratedStorage.build(
          storageDirectory: kIsWeb
              ? HydratedStorageDirectory.web
              : HydratedStorageDirectory((await getTemporaryDirectory()).path),
        );
      });

      final powerSyncRepository = PowerSyncRepository(env: appFlavor.getEnv);
      await _guard('Offline database', bootErrors, () async {
        await powerSyncRepository
            .initialize()
            .timeout(const Duration(seconds: 30));
      });

      await _guard('Zegocloud calls', bootErrors, () async {
        ZegoVideoService.configure(
          appId: int.tryParse(appFlavor.getEnv(Env.zegoAppId)) ?? 0,
          appSign: appFlavor.getEnv(Env.zegoAppSign),
        );
      });

      FirebaseMessaging? firebaseMessaging;
      await _guard('Push notifications', bootErrors, () async {
        firebaseMessaging = FirebaseMessaging.instance;
        FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler,
        );
      });
      final messaging = firebaseMessaging ?? FirebaseMessaging.instance;

      await _guard('Preferences', bootErrors, () async {
        sharedPreferences = await SharedPreferences.getInstance();
      });
      sharedPreferences ??= await SharedPreferences.getInstance();

      await _guard('Remote config', bootErrors, () async {
        final firebaseRemoteConfig = FirebaseRemoteConfig.instance;
        remoteConfigRepository = FirebaseRemoteConfigRepository(
          firebaseRemoteConfig: firebaseRemoteConfig,
        );
      });

      SystemUiOverlayTheme.setPortraitOrientation();

      Widget appWidget;
      try {
        appWidget = await builder(
          powerSyncRepository,
          messaging,
          sharedPreferences!,
          remoteConfigRepository ??
              FirebaseRemoteConfigRepository(
                firebaseRemoteConfig: FirebaseRemoteConfig.instance,
              ),
        );
      } catch (error, stackTrace) {
        logE('App builder failed', error: error, stackTrace: stackTrace);
        bootErrors.add('App: $error');
        appWidget = const SizedBox.shrink();
      }

      runApp(
        AppBootGate(
          bootErrors: bootErrors,
          child: appWidget,
        ),
      );
    },
    (error, stack) {
      logE(error.toString(), stackTrace: stack);
    },
  );
}

Future<void> _guard(
  String label,
  List<String> bootErrors,
  Future<void> Function() action,
) async {
  try {
    await action();
  } catch (error, stackTrace) {
    logE('$label initialization failed', error: error, stackTrace: stackTrace);
    bootErrors.add('$label: $error');
  }
}
