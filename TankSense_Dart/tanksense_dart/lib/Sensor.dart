abstract class Sensor {
  // Atributos protegidos
  int _id;
  String _tipo;
  String _unidadeMedida;

  // Construtor
  Sensor(this._id, this._tipo, this._unidadeMedida);

  // Getters
  int get id => _id;
  String get tipo => _tipo;
  String get unidadeMedida => _unidadeMedida;

  // Método abstrato - deve ser implementado pelas subclasses
  double coletarDado();

  void exibirDados() {
    print('---- Dados do Sensor ---');
    print('ID: $_id');
    print('Tipo: $_tipo');
    print('Unidade de Medida: $_unidadeMedida');
  }

  @override
  String toString() {
    return 'Sensor{id: $_id, tipo: $_tipo, unidadeMedida: $_unidadeMedida}';
  }
}