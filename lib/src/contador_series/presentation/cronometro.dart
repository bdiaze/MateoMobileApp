import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class Cronometro extends StatefulWidget {
  @override
  _CronometroState createState() => _CronometroState();
}

class _CronometroState extends State<Cronometro> with SingleTickerProviderStateMixin {
  final int maxMinutos = 999;
  final Map<int, Map> alertasDescanso = {
    110: { 'cantRepeticiones': 1, 'cambioPermanente': false }, // Cuando queden 10 segundos para los 2 minutos de descanso se manda
    120: { 'cantRepeticiones': 2, 'cambioPermanente': false } // Cuando se cumplan los 2 minutos
  };

  int tipoEjecucion = 0; // 0: Aún no ejecuta - 1: Contando Serie - 2: Contando Descando
  int tiempo = 0;
  Timer? timer;
  Color? colorFondo = Colors.blue[800];

  AnimationController? controladorAnimacionFondo;
  Animation<Color?>? animacionFondo;

  @override
  void initState() {
    super.initState();
    controladorAnimacionFondo = AnimationController(duration: Duration(milliseconds: 500), vsync: this);
    controladorAnimacionFondo!.addListener(() {
      setState(() {
        colorFondo = animacionFondo!.value;
      });
    });
  }

  void gatillarCambioFondo({ required List<Color?> nuevosColores, int duracion = 500, int repeticiones = 1}) {
    Color? colorAnterior = colorFondo;
    List<TweenSequenceItem<Color?>> tweenlist = [];
    for (Color? nuevoColor in nuevosColores) {
      tweenlist.add(TweenSequenceItem(tween: ColorTween(begin: colorAnterior, end: nuevoColor), weight: 1.0,));
      colorAnterior = nuevoColor;
    }
    animacionFondo = TweenSequence<Color?>(tweenlist).animate(controladorAnimacionFondo!);
    controladorAnimacionFondo!.duration = Duration(milliseconds: duracion);
    controladorAnimacionFondo!.reset();
    controladorAnimacionFondo!.forward();
  }

  void gatillarAlertaDescanso(int cantRepeticiones, bool cambioPermanente) {
    Vibration.vibrate(duration: 500 * cantRepeticiones);

    List<Color?> listaColores= [];
    for (int i = 0; i < cantRepeticiones; i++) {
      listaColores.add(Colors.red[900]);
      listaColores.add(colorFondo);
    }

    int deltaTiempoCambioPermanente = 0;
    if (cambioPermanente) {
      listaColores.add(Colors.red[900]);
      deltaTiempoCambioPermanente = 250;
    }

    gatillarCambioFondo(
      nuevosColores: listaColores,
      duracion: 500 * cantRepeticiones + deltaTiempoCambioPermanente,
    );
  }

  String tiempoContadorToString() {
    int cantMinutos = (tiempo / 60).truncate();
    int cantSegundos = tiempo - cantMinutos * 60;
    return '${cantMinutos.toString().padLeft(2, '0')}:${cantSegundos.toString().padLeft(2, '0')}';
  }

  void clickBotonCronometro() {
    int tipoEjecucionAnterior = tipoEjecucion;
    setState(() {
      tipoEjecucion = tipoEjecucion != 2 ? tipoEjecucion + 1 : 1;
      tiempo = 0;
    });
    
    if (tipoEjecucion == 2) {
      gatillarCambioFondo(nuevosColores: [Colors.grey[800]]);
    } else if (tipoEjecucion == 1 && tipoEjecucionAnterior == 2) {
      gatillarCambioFondo(nuevosColores: [Colors.blue[800]]);
    }

    if (timer != null && timer!.isActive) {
      timer!.cancel();
    }
    timer = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() {
        tiempo++;
        // Si el tiempo supera los 99 minutos, se reinicia a 0
        if (tiempo >= maxMinutos * 60) tiempo = 0;
      });
      // Si estamos en un descanso y el tiempo que llevamos requiere una alerta, se gatilla la alerta
      if (tipoEjecucion == 2 && alertasDescanso.containsKey(tiempo)) {
        gatillarAlertaDescanso(alertasDescanso[tiempo]!['cantRepeticiones']!, alertasDescanso[tiempo]!['cambioPermanente']!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    WakelockPlus.enable();

    return Scaffold(
      backgroundColor: colorFondo,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (tipoEjecucion == 1)
                  Center(
                    child: Image.asset(
                      'assets/images/contador_series/musculo.png',
                      color: Colors.grey[300],
                      height: 140,
                    ),
                  ),
                if (tipoEjecucion == 2)
                  Center(
                    child: Image.asset(
                      'assets/images/contador_series/zzz.png',
                      color: Colors.grey[300],
                      height: 140,
                    ),
                  ),
                if ([1,2].contains(tipoEjecucion))
                  SizedBox(height: 20.0),
                if (tipoEjecucion != 0)
                  Center(
                    child: Text(
                      tiempoContadorToString(),
                      style: TextStyle(
                        fontSize: 90.0,
                        color: Colors.grey[300],
                        fontFamily: 'RobotoMono'
                      ),
                    ),
                  ),
                if (tipoEjecucion != 0)
                  SizedBox(height: 30.0),
                Center(
                  child: FilledButton.icon(
                      onPressed: clickBotonCronometro,
                      icon: Icon(
                          [0, 2].contains(tipoEjecucion) ? Icons.play_arrow : Icons.pause,
                          color: colorFondo,
                          size: 40
                      ),
                      label: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          [0, 2].contains(tipoEjecucion) ? '¡A Entrenar!' : 'Descanso',
                          style: TextStyle(
                            fontSize: 25.0,
                            color: colorFondo,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                      )
                  ),
                ),
                if ([1,2].contains(tipoEjecucion))
                  SizedBox(height: 70.0),
              ]
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    controladorAnimacionFondo!.dispose();
    WakelockPlus.disable();
    super.dispose();
  }
}