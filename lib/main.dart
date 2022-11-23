import 'package:cripto_wallet/app/common/models/moedas.dart';
import 'package:cripto_wallet/app/common/repositories/moedas_repository.dart';
import 'package:cripto_wallet/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cripto_wallet/app/common/repositories/conta_repository.dart';
import 'package:cripto_wallet/my_app.dart';
import 'app/common/repositories/favoritas_repository.dart';
import 'configs/app_settings.dart';
import 'configs/hive_config.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveConfig.start();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthService()),
        ChangeNotifierProvider(create: (context) => MoedasRepository()),
        ChangeNotifierProvider(create: (context) => ContaRepository(
          moedas: context.read<MoedasRepository>()),
          ),
        ChangeNotifierProvider(create: (context) => AppSettings()),
        ChangeNotifierProvider(
          create: (context) => FavoritasRepository(
            auth: context.read<AuthService>(),
            moedas: context.read<MoedasRepository>(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
