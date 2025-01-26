import 'package:flutter/material.dart';
import 'package:mateo/src/contador_series/domain/resumen_serie.dart';

class HistorialSerie extends StatelessWidget {
  final ResumenSerie serie;

  HistorialSerie({required this.serie});

  String segundosToString(int segundos) {
    int cantMinutos = (segundos / 60).truncate();
    int cantSegundos = segundos - cantMinutos * 60;
    return '${cantMinutos.toString().padLeft(2, '0')}:${cantSegundos.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[300],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Text(
                  'Serie N°',
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.grey[800],
                  ),
                ),
                Text(
                  serie.numSerie!.toString(),
                  style: TextStyle(
                    fontSize: 21.0,
                    color: Colors.grey[800],
                    fontWeight: FontWeight.bold,
                    fontFamily: 'RobotoMono',
                  ),
                ),
              ],
            ),
            SizedBox(width: 13.0),
            Column(
              children: [
                Row(
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/images/contador_series/musculo.png',
                        color: Colors.grey[800],
                        height: 18,
                      ),
                    ),
                    SizedBox(width: 12.0),
                    Text(
                      '${segundosToString(serie.segundosEntrenamiento!)}',
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.grey[800],
                        fontWeight: FontWeight.bold,
                        fontFamily: 'RobotoMono',
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/images/contador_series/zzz.png',
                        color: Colors.grey[800],
                        height: 17,
                      ),
                    ),
                    SizedBox(width: 13.0),
                    Text(
                      '${segundosToString(serie.segundosDescanso!)}',
                      style: TextStyle(
                        fontSize: 13.0,
                        color: Colors.grey[800],
                        fontWeight: FontWeight.bold,
                        fontFamily: 'RobotoMono',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
