import 'package:flutter/material.dart';
import 'package:mateo/src/contador_series/presentation/cronometro.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MaterialApp(
      initialRoute: '/cronometro',
      routes: {
        '/cronometro': (context) => Cronometro(),
      }
  ));
}
