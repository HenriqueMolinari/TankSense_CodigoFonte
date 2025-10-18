class Local {
  int _id;
  String _nome;
  String _referencia;

  Local(this._id, this._nome, this._referencia);

  int get id => _id;
  set id(int value) => _id = value;

  String get nome => _nome;
  set nome(String value) => _nome = value;

  String get referencia => _referencia;
  set referencia(String value) => _referencia = value;

  void exibirDados() {
    print('---- Dados do Local ---');
    print('ID: $_id');
    print('Nome: $_nome');
    print('Referência: $_referencia');
  }
}
