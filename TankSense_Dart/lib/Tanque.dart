class Tanque {
  // Atributos privados
  int _id;
  double _altura;
  double _volumeMax;
  double _volumeAtual;

  // Construtor
  Tanque(this._id, this._altura, this._volumeMax, this._volumeAtual);

  // Getters e Setters
  int get id => _id;
  set id(int value) => _id = value;

  double get altura => _altura;
  set altura(double value) => _altura = value;

  double get volumeMax => _volumeMax;
  set volumeMax(double value) => _volumeMax = value;

  double get volumeAtual => _volumeAtual;
  set volumeAtual(double value) {
    if (value > _volumeMax) {
      throw ArgumentError('Volume atual não pode ser maior que volume máximo');
    }
    _volumeAtual = value;
  }

  // Método de negócio
  double calcularVolumeAtual(double nivel) {
    double areaBase = _volumeMax / _altura;
    _volumeAtual = areaBase * nivel;

    if (_volumeAtual > _volumeMax) {
      _volumeAtual = _volumeMax;
    }

    return _volumeAtual;
  }

  double getCapacidadePercentual() {
    return (_volumeAtual / _volumeMax) * 100;
  }

  void exibirDados() {
    print('---- Dados do Tanque ---');
    print('ID: $_id');
    print('Altura: $_altura m');
    print('Volume Máximo: $_volumeMax m³');
    print('Volume Atual: $_volumeAtual m³');
    print('Capacidade: ${getCapacidadePercentual().toStringAsFixed(1)}%');
  }

  @override
  String toString() {
    return 'Tanque{id: $_id, altura: $_altura, volumeMax: $_volumeMax, volumeAtual: $_volumeAtual}';
  }
}
