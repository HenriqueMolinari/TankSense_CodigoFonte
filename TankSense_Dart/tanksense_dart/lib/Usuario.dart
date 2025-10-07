class Usuario {
  // Atributos privados
  int _idUsuario;
  String _nome;
  String _email;
  String _senhaLogin;
  String _perfil;
  DateTime _dataCriacao;
  DateTime _ultimoLogin;

  // Construtor
  Usuario({
    required int idUsuario,
    required String nome,
    required String email,
    required String senhaLogin,
    required String perfil,
    required DateTime dataCriacao,
    required DateTime ultimoLogin,
  })  : _idUsuario = idUsuario,
        _nome = nome,
        _email = email,
        _senhaLogin = senhaLogin,
        _perfil = perfil,
        _dataCriacao = dataCriacao,
        _ultimoLogin = ultimoLogin;

  // Getters
  int get idUsuario => _idUsuario;
  String get nome => _nome;
  String get email => _email;
  String get senhaLogin => _senhaLogin;
  String get perfil => _perfil;
  DateTime get dataCriacao => _dataCriacao;
  DateTime get ultimoLogin => _ultimoLogin;

  // Métodos de negócio
  void atualizarUltimoLogin() {
    _ultimoLogin = DateTime.now();
  }

  bool isAdmin() => _perfil == PerfilUsuario.admin;
  bool isManutencao() => _perfil == PerfilUsuario.manutencao;
  bool isShopFloor() => _perfil == PerfilUsuario.shopFloor;
  bool isAnalistaDados() => _perfil == PerfilUsuario.analistaDados;

  void exibirDados() {
    print('---- Dados do Usuário ---');
    print('ID: $_idUsuario');
    print('Nome: $_nome');
    print('Email: $_email');
    print('Perfil: $_perfil');
    print('Data de Criação: ${_formatarData(_dataCriacao)}');
    print('Último Login: ${_formatarData(_ultimoLogin)}');
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year} '
        '${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}';
  }

  // Método estático para criar usuário
  static Usuario criarUsuario({
    required int id,
    required String nome,
    required String email,
    required String senha,
    required String perfil,
  }) {
    final agora = DateTime.now();
    return Usuario(
      idUsuario: id,
      nome: nome,
      email: email,
      senhaLogin: senha,
      perfil: perfil,
      dataCriacao: agora,
      ultimoLogin: agora,
    );
  }

  @override
  String toString() {
    return 'Usuario{id: $_idUsuario, nome: $_nome, perfil: $_perfil}';
  }
}

class PerfilUsuario {
  // Constantes para os tipos de perfil
  static const String admin = 'Admin';
  static const String shopFloor = 'ShopFloor';
  static const String manutencao = 'Manutenção';
  static const String analistaDados = 'Analista de Dados';

  static const List<String> todos = [admin, shopFloor, manutencao, analistaDados];

  // Método estático para validação
  static bool isValid(String perfil) {
    return todos.contains(perfil);
  }

  // Método estático para obter nível de acesso
  static int getNivelAcesso(String perfil) {
    switch (perfil) {
      case admin:
        return 4;
      case analistaDados:
        return 3;
      case manutencao:
        return 2;
      case shopFloor:
        return 1;
      default:
        return 0;
    }
  }
}