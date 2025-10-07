import 'Sensor.dart';

class SensorUltrassonico extends Sensor {
  // Construtor
  SensorUltrassonico(int id, String tipo, String unidadeMedida)
      : super(id, tipo, unidadeMedida);

  // Implementação do método abstrato (Polimorfismo)
  @override
  double coletarDado() {
    double distancia = 50.0 + (DateTime.now().millisecond % 350);
    print('Coletando dado: $distancia $unidadeMedida');
    return distancia;
  }

  // Método específico da subclasse
  double calibrarSensor() {
    print('Calibrando sensor ultrassônico...');
    return 0.0;
  }
}