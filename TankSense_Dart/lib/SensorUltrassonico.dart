class SensorUltrassonico {
  final int id;
  final String tipo;
  final String unidadeMedida;
  final int dispositivoId; // ⬅️ NOVO ATRIBUTO

  SensorUltrassonico(this.id, this.tipo, this.unidadeMedida,
      {this.dispositivoId = 0});

  void exibirDados() {
    print('📡 DADOS DO SENSOR');
    print('─' * 30);
    print('ID: $id');
    print('Tipo: $tipo');
    print('Unidade de Medida: $unidadeMedida');
    if (dispositivoId > 0) {
      print('Dispositivo ID: $dispositivoId');
    }
    print('─' * 30);
  }
}
