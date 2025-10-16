class Dispositivo {
  // Atributos privados com encapsulamento
  int _id;
  String _modelo;
  String _status;

  // Construtor
  Dispositivo(this._id, this._modelo, this._status);

  // Getters e Setters
  int get id => _id;
  set id(int value) => _id = value;

  String get modelo => _modelo;
  set modelo(String value) => _modelo = value;

  String get status => _status;
  set status(String value) => _status = value;

  // Métodos de negócio
  void ativar() {
    _status = 'Ativo';
    print('Dispositivo $_modelo ativado');
  }

  void desativar() {
    _status = 'Inativo';
    print('Dispositivo $_modelo desativado');
  }

  void exibirDados() {
    print('---- Dados do Dispositivo ---');
    print('ID: $_id');
    print('Modelo: $_modelo');
    print('Status: $_status');
  }

  @override
  String toString() {
    return 'Dispositivo{id: $_id, modelo: $_modelo, status: $_status}';
  }
}
