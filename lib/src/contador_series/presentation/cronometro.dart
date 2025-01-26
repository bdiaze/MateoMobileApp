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
  final Map<int, int> alertasDescanso = {
    110: 1, // Cuando queden 10 segundos para los 2 minutos de descanso se manda
    115: 2, // Cuando queden 5 segundos para los 2 minutos de descanso
    120: 3 // Cuando se cumplan los 2 minutos
  };

  final coloresFondo = <TweenSequenceItem<Color?>>[
    TweenSequenceItem(
      tween: ColorTween(begin: Colors.blue[800], end: Colors.red[800]),
      weight: 1.0,
    ),
    TweenSequenceItem(
      tween: ColorTween(begin: Colors.red[800], end: Colors.blue[800]),
      weight: 1.0,
    ),
  ];

  final coloresLetras = <TweenSequenceItem<Color?>>[
    TweenSequenceItem(
      tween: ColorTween(begin: Colors.blue[600], end: Colors.red[600]),
      weight: 1.0,
    ),
    TweenSequenceItem(
      tween: ColorTween(begin: Colors.red[600], end: Colors.blue[600]),
      weight: 1.0,
    ),
  ];

  int tipoEjecucion = 0; // 0: Aún no ejecuta - 1: Contando Serie - 2: Contando Descando
  int tiempo = 0;
  Timer? timer;

  AnimationController? controladorAnimacionAlerta;
  Animation<Color?>? animacionColorFondo;
  Animation<Color?>? animacionColorLetras;

  @override
  void initState() {
    super.initState();
    controladorAnimacionAlerta = AnimationController(
        duration: Duration(milliseconds: 750),
        vsync: this
    );

    animacionColorFondo = TweenSequence<Color?>(coloresFondo).animate(controladorAnimacionAlerta!);
    animacionColorLetras = TweenSequence<Color?>(coloresLetras).animate(controladorAnimacionAlerta!);
  }

  void gatillarAlertaDescanso(int tipoAlerta) {
    switch (tipoAlerta) {
      case 1: // Alerta Liviana
        Vibration.vibrate(duration: 500);
        controladorAnimacionAlerta!.reset();
        controladorAnimacionAlerta!.repeat(
          period: Duration(milliseconds: 500),
          count: 1
        );
        break;
      case 2: // Alerta Mediana
        Vibration.vibrate(duration: 1000);
        controladorAnimacionAlerta!.reset();
        controladorAnimacionAlerta!.repeat(
            period: Duration(milliseconds: 500),
            count: 2
        );
        break;
      case 3: // Alerta Fuerte
        Vibration.vibrate(duration: 1500);
        controladorAnimacionAlerta!.reset();
        controladorAnimacionAlerta!.repeat(
            period: Duration(milliseconds: 500),
            count: 3
        );
        break;
    }
  }

  String tiempoContadorToString() {
    int cantMinutos = (tiempo / 60).truncate();
    int cantSegundos = tiempo - cantMinutos * 60;
    return '${cantMinutos.toString().padLeft(2, '0')}:${cantSegundos.toString().padLeft(2, '0')}';
  }

  void clickBotonCronometro() {
    setState(() {
      tipoEjecucion = tipoEjecucion != 2 ? tipoEjecucion + 1 : 1;
      tiempo = 0;
    });

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
        gatillarAlertaDescanso(alertasDescanso[tiempo]!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    WakelockPlus.enable();

    return AnimatedBuilder(
      animation: controladorAnimacionAlerta!,
      builder: (BuildContext context, _) {
        return Scaffold(
          backgroundColor: animacionColorFondo!.value,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    if (tipoEjecucion == 1)
                      Center(
                        child: Image.asset(
                          'assets/images/musculo.png',
                          color: Colors.grey[300],
                          height: 140,
                        ),
                      ),
                    if (tipoEjecucion == 2)
                      Center(
                        child: Image.asset(
                          'assets/images/zzz.png',
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
                              color: Colors.grey[300]
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
                              color: animacionColorLetras!.value,
                              size: 40
                          ),
                          label: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              [0, 2].contains(tipoEjecucion) ? '¡A Entrenar!' : 'Descanso',
                              style: TextStyle(
                                fontSize: 25.0,
                                color: animacionColorLetras!.value,
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
      },
    );
  }

  @override
  void dispose() {
    controladorAnimacionAlerta!.dispose();
    WakelockPlus.disable();
    super.dispose();
  }
}