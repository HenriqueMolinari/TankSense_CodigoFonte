class Leitura {
  // Atributos privados
  final int _id;
  final DateTime _timestamp;
  final double _distanciaCm;
  final double _nivelCm;
  final double _porcentagem;
  final String _statusTanque;
  final bool _displayPiscando;

  // Construtor
  Leitura(
    this._id,
    this._timestamp,
    this._distanciaCm,
    this._nivelCm,
    this._porcentagem,
    this._statusTanque,
    this._displayPiscando,
  );

  // Construtor a partir do Firebase
  factory Leitura.fromFirebase(Map<String, dynamic> data, String id) {
    DateTime timestamp;
    try {
      final dateStr = data['timestamp'] ?? '';
      if (dateStr.contains('/')) {
        final parts = dateStr.split(' ');
        final dateParts = parts[0].split('/');
        final timeParts = parts[1].split(':');

        timestamp = DateTime(
          int.parse(dateParts[2]),
          int.parse(dateParts[1]),
          int.parse(dateParts[0]),
          int.parse(timeParts[0]),
          int.parse(timeParts[1]),
          int.parse(timeParts[2]),
        );
      } else {
        timestamp = DateTime.now();
      }
    } catch (e) {
      timestamp = DateTime.now();
    }

    return Leitura(
      int.tryParse(id) ?? 0,
      timestamp,
      (data['distancia_cm'] ?? 0.0).toDouble(),
      (data['nivel_cm'] ?? 0.0).toDouble(),
      (data['porcentagem'] ?? 0.0).toDouble(),
      data['status'] ?? 'Desconhecido',
      false,
    );
  }

  // Getters
  int get id => _id;
  DateTime get timestamp => _timestamp;
  double get distanciaCm => _distanciaCm;
  double get nivelCm => _nivelCm;
  double get porcentagem => _porcentagem;
  String get statusTanque => _statusTanque;
  bool get displayPiscando => _displayPiscando;

  void exibirDados() {
    print('---- Dados da Leitura ---');
    print('ID: $_id');
    print('Timestamp: ${_formatarData(_timestamp)}');
    print('Distância: ${_distanciaCm.toStringAsFixed(2)} cm');
    print('Nível: ${_nivelCm.toStringAsFixed(2)} cm');
    print('Porcentagem: ${_porcentagem.toStringAsFixed(1)}%');
    print('Status do Tanque: $_statusTanque');
    print('Display Piscando: $_displayPiscando');
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year} '
        '${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}:${data.second.toString().padLeft(2, '0')}';
  }

  @override
  String toString() {
    return 'Leitura $id - ${_formatarData(_timestamp)} - Nível: ${_nivelCm.toStringAsFixed(1)}cm ($_porcentagem%) - Status: $_statusTanque';
  }
}