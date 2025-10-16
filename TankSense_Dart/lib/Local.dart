class Local {
  // Atributos privados
  int _id;
  String _nome;
  String _referencia;

  // Construtor
  Local(this._id, this._nome, this._referencia);

  // Getters e Setters
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

  @override
  String toString() {
    return 'Local{id: $_id, nome: $_nome, referencia: $_referencia}';
  }
}
