import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'core/logging/app_logger.dart';
import 'data/repositories/auth_repository.dart';
import 'firebase_options.dart';

const String _versionApp = '1.0.0+1';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (!kIsWeb) {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
      !kDebugMode,
    );
    await AppLogger.setAppContext(
      version: _versionApp,
      buildMode: kDebugMode
          ? 'debug'
          : kProfileMode
          ? 'profile'
          : 'release',
    );

    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(
        error.runtimeType,
        stack,
        reason: 'Excepción asíncrona no controlada',
        fatal: true,
      );
      return true;
    };
  }

  runApp(
    PrestamoEquiposApp(
      authRepository: AuthRepository(
        auth: FirebaseAuth.instance,
        db: FirebaseFirestore.instance,
      ),
    ),
  );
}
