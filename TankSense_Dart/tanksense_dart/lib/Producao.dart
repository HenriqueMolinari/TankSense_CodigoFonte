class Producao {
  // Atributos privados
  int _id;
  double _quantidade;
  DateTime _timestamp;

  // Construtor
  Producao(this._id, this._quantidade, this._timestamp);

  // Getters e Setters
  int get id => _id;
  set id(int value) => _id = value;

  double get quantidade => _quantidade;
  set quantidade(double value) => _quantidade = value;

  DateTime get timestamp => _timestamp;
  set timestamp(DateTime value) => _timestamp = value;

  void exibirDados() {
    print('---- Dados da Produção ---');
    print('ID: $_id');
    print('Quantidade: $_quantidade');
    print('Timestamp: ${_formatarData(_timestamp)}');
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year} '
        '${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}';
  }

  String formatarDados() {
    return 'Produção $_id - Quantidade: $_quantidade - ${_formatarData(_timestamp)}';
  }

  @override
  String toString() {
    return 'Producao{id: $_id, quantidade: $_quantidade, timestamp: $_timestamp}';
  }
}