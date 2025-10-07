class Empresa {
  // Atributos privados
  int _id;
  String _nome;
  String _cnpj;

  // Construtor
  Empresa(this._id, this._nome, this._cnpj);

  // Getters e Setters
  int get id => _id;
  set id(int value) => _id = value;

  String get nome => _nome;
  set nome(String value) => _nome = value;

  String get cnpj => _cnpj;
  set cnpj(String value) => _cnpj = value;

  void exibirDados() {
    print('---- Dados da Empresa ---');
    print('ID: $_id');
    print('Nome: $_nome');
    print('CNPJ: $_cnpj');
  }

  @override
  String toString() {
    return 'Empresa{id: $_id, nome: $_nome, cnpj: $_cnpj}';
  }
}