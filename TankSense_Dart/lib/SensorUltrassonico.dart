import 'dart:math';

// SensorUltrassonico.dart

class SensorUltrassonico {
  final int id;
  final String tipo;
  final String unidadeMedida;

  SensorUltrassonico(this.id, this.tipo, this.unidadeMedida);

  // Métodos getters
  int get getId => id;
  String get getTipo => tipo;
  String get getUnidadeMedida => unidadeMedida;

  // Método para exibir dados
  void exibirDados() {
    print('📡 DADOS DO SENSOR');
    print('─' * 30);
    print('ID: $id');
    print('Tipo: $tipo');
    print('Unidade de Medida: $unidadeMedida');
    print('─' * 30);
  }

  // Método para simular leitura
  double simularLeitura(double distanciaMaxima) {
    final random = Random();
    double leitura = random.nextDouble() * distanciaMaxima;
    print('📊 Leitura simulada: ${leitura.toStringAsFixed(2)} $unidadeMedida');
    return leitura;
  }

  // Método para calibrar sensor
  void calibrar() {
    print('🔧 Sensor $id calibrado com sucesso!');
  }

  // Método para verificar status
  String verificarStatus() {
    return 'Sensor $tipo operando normalmente';
  }

  // Método toMap para conversão
  Map<String, dynamic> toMap() {
    return {
      'idSensor': id,
      'tipo': tipo,
      'unidadeMedida': unidadeMedida,
    };
  }

  @override
  String toString() {
    return 'SensorUltrassonico{id: $id, tipo: $tipo, unidadeMedida: $unidadeMedida}';
  }
}
