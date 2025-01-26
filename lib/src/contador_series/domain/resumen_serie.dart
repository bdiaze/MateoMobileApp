class ResumenSerie {
  int? numSerie;
  int? segundosEntrenamiento;
  int? segundosDescanso;
  int? cantidadRepeticiones;
  int? tipoEjercicio;
  double? peso;
  int?  medidaPeso;

  ResumenSerie({
    required this.numSerie,
    required this.segundosEntrenamiento,
    required this.segundosDescanso,
    this.cantidadRepeticiones,
    this.tipoEjercicio,
    this.peso,
    this.medidaPeso,
  });

  @override
  String toString() {
    return 'Serie N°${ this.numSerie } - Entrenamiento ${ this.segundosEntrenamiento } seg - Descano ${ this.segundosDescanso } seg';
  }
}