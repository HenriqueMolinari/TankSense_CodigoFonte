class Leitura {
  // Atributos privados
  final int _id;
  final DateTime _timestamp;
  final double _distanciaCm;
  final double _nivelCm;
  final double _porcentagem;
  final String _status;

  // Construtor
  Leitura(
    this._id,
    this._timestamp,
    this._distanciaCm,
    this._nivelCm,
    this._porcentagem,
    this._status,
  );

  // Construtor a partir do Firebase - CORRIGIDO
  factory Leitura.fromFirebase(Map<String, dynamic> data, String id) {
    DateTime timestamp;

    try {
      final timestampData = data['timestamp'];

      // Debug: Mostrar o que veio do Firebase
      print(
          '🔍 Timestamp do Firebase: $timestampData (Tipo: ${timestampData.runtimeType})');

      if (timestampData == null) {
        print('⚠️  Timestamp é nulo, usando data atual');
        timestamp = DateTime.now().toUtc();
      }
      // Se for uma string ISO (formato padrão do Firebase)
      else if (timestampData is String && timestampData.contains('T')) {
        try {
          timestamp = DateTime.parse(timestampData).toUtc();
          print('✅ Timestamp ISO parseado: $timestamp');
        } catch (e) {
          print('❌ Erro ao parsear timestamp ISO: $e');
          timestamp = DateTime.now().toUtc();
        }
      }
      // Se for uma string no formato dd/MM/yyyy HH:mm:ss
      else if (timestampData is String && timestampData.contains('/')) {
        try {
          final parts = timestampData.split(' ');
          final dateParts = parts[0].split('/');
          final timeParts = parts[1].split(':');

          // CORREÇÃO: A ordem estava errada (dia/mês/ano)
          timestamp = DateTime(
            int.parse(dateParts[2]), // ano
            int.parse(dateParts[1]), // mês
            int.parse(dateParts[0]), // dia
            int.parse(timeParts[0]), // hora
            int.parse(timeParts[1]), // minuto
            int.parse(timeParts[2]), // segundo
          ).toUtc();
          print('✅ Timestamp formato BR parseado: $timestamp');
        } catch (e) {
          print('❌ Erro ao parsear timestamp BR: $e');
          timestamp = DateTime.now().toUtc();
        }
      }
      // Se for um número (timestamp em milissegundos)
      else if (timestampData is int || timestampData is double) {
        try {
          timestamp = DateTime.fromMillisecondsSinceEpoch(timestampData.toInt(),
              isUtc: true);
          print('✅ Timestamp numérico parseado: $timestamp');
        } catch (e) {
          print('❌ Erro ao parsear timestamp numérico: $e');
          timestamp = DateTime.now().toUtc();
        }
      }
      // Fallback
      else {
        print('⚠️  Formato de timestamp não reconhecido, usando data atual');
        timestamp = DateTime.now().toUtc();
      }
    } catch (e) {
      print('❌ Erro crítico ao processar timestamp: $e');
      timestamp = DateTime.now().toUtc();
    }

    // Debug dos dados recebidos
    print('📦 Dados recebidos do Firebase:');
    print('   ID: $id');
    print('   Distância: ${data['distancia_cm']}');
    print('   Nível: ${data['nivel_cm']}');
    print('   Porcentagem: ${data['porcentagem']}');
    print('   Status: ${data['status']}');

    return Leitura(
      int.tryParse(id) ?? DateTime.now().millisecondsSinceEpoch,
      timestamp,
      (data['distancia_cm'] ?? 0.0).toDouble(),
      (data['nivel_cm'] ?? 0.0).toDouble(),
      (data['porcentagem'] ?? 0.0).toDouble(),
      data['status'] ?? 'Desconhecido',
    );
  }

  // Getters
  int get id => _id;
  DateTime get timestamp => _timestamp;
  double get distanciaCm => _distanciaCm;
  double get nivelCm => _nivelCm;
  double get porcentagem => _porcentagem;
  String get status => _status;

  // Getter para compatibilidade
  double get valor => _nivelCm;
  int get tanqueId => 1;

  DateTime get dataHora => _timestamp;

  void exibirDados() {
    print('---- Dados da Leitura ---');
    print('ID: $_id');
    print('Timestamp: ${_formatarData(_timestamp)}');
    print('Distância: ${_distanciaCm.toStringAsFixed(2)} cm');
    print('Nível: ${_nivelCm.toStringAsFixed(2)} cm');
    print('Porcentagem: ${_porcentagem.toStringAsFixed(1)}%');
    print('Status: $_status');
  }

  String _formatarData(DateTime data) {
    // Converte UTC para horário local para exibição
    final localTime = data.toLocal();
    return '${localTime.day.toString().padLeft(2, '0')}/${localTime.month.toString().padLeft(2, '0')}/${localTime.year} '
        '${localTime.hour.toString().padLeft(2, '0')}:${localTime.minute.toString().padLeft(2, '0')}:${localTime.second.toString().padLeft(2, '0')}';
  }

  @override
  String toString() {
    return 'Leitura $id - ${_formatarData(_timestamp)} - Nível: ${_nivelCm.toStringAsFixed(1)}cm ($_porcentagem%) - Status: $_status';
  }
}
