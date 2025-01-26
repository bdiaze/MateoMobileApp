import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mateo/src/contador_series/presentation/cronometro.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
    overlays: []
  );

  runApp(MaterialApp(
    initialRoute: '/cronometro',
    routes: {
      '/cronometro': (context) => Cronometro(),
    },
  ));
}
