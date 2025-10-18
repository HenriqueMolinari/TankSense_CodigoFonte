import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'Empresa.dart';
import 'Local.dart';
import 'Tanque.dart';
import 'Dispositivo.dart';
import 'SensorUltrassonico.dart';
import 'Leitura.dart';
import 'Producao.dart';
import 'Usuario.dart';
import 'DatabaseConnection.dart';

class Menu {
  final DatabaseConnection dbConnection;
  bool _conectado = false;

  // 🔥 CONFIGURAÇÕES FIREBASE - REAIS
  static const String _baseUrl = 'tanksense---v2-default-rtdb.firebaseio.com';
  static const String _authToken = 'XALK5M3Yuc7jQgS62iDXpnAKvsBJEWKij0hR02tx';

  // Listas locais
  final List<Empresa> _empresas = [];
  final List<Local> _locais = [];
  final List<Tanque> _tanques = [];
  final List<Dispositivo> _dispositivos = [];
  final List<SensorUltrassonico> _sensores = [];
  final List<Leitura> _leituras = [];
  final List<Producao> _producoes = [];
  final List<Usuario> _usuarios = [];

  Menu(this.dbConnection);

  Future<void> inicializar() async {
    print('\n🔄 INICIALIZANDO SISTEMA TANKSENSE...');
    _conectado = await dbConnection.connect();

    if (_conectado) {
      print('🎉 CONEXÃO COM BANCO ESTABELECIDA COM SUCESSO!');
      await _carregarDadosDoBanco();
    } else {
      print('❌ FALHA NA CONEXÃO COM BANCO');
      print('⚠️  Os dados serão salvos apenas localmente');
    }

    // ✅ CARREGAR DADOS DO FIREBASE
    print('\n🔥 CONECTANDO AO FIREBASE...');
    await _carregarLeiturasFirebase();
  }

  // ========== MÉTODOS FIREBASE ==========

  Future<void> _carregarLeiturasFirebase() async {
    try {
      print('📡 Buscando leituras no Firebase...');

      final url = Uri.https(_baseUrl, '/leituras.json', {'auth': _authToken});
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _leituras.clear();

        if (data != null && data is Map) {
          data.forEach((key, value) {
            try {
              if (value is Map<String, dynamic>) {
                final leitura = Leitura.fromFirebase(value, key);
                _leituras.add(leitura);
                print(
                    '📥 Leitura carregada: ${leitura.nivelCm}cm (${leitura.porcentagem}%)');
              } else {
                print('⚠️  Dados inválidos para a leitura $key: $value');
              }
            } catch (e) {
              print('❌ Erro ao processar leitura $key: $e');
            }
          });

          print('✅ ${_leituras.length} leituras carregadas do Firebase');
        } else {
          print('ℹ️  Nenhuma leitura encontrada no Firebase');
        }
      } else {
        print('❌ Erro ao carregar do Firebase: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erro de conexão com Firebase: $e');
    }
  }

  // ========== CARREGAR DADOS DO BANCO - CORRIGIDO ==========
  Future<void> _carregarDadosDoBanco() async {
    if (!_conectado) return;

    try {
      print('\n📥 CARREGANDO DADOS DO BANCO...');

      // Limpar todas as listas
      _empresas.clear();
      _locais.clear();
      _dispositivos.clear();
      _sensores.clear();
      _tanques.clear();
      _usuarios.clear();

      // MÉTODO ROBUSTO PARA CARREGAMENTO
      await _carregarDadosRobusto();

      print('\n✅ RESUMO DO CARREGAMENTO:');
      print('🏢 Empresas: ${_empresas.length}');
      print('🏠 Locais: ${_locais.length}');
      print('⚙️  Dispositivos: ${_dispositivos.length}');
      print('📡 Sensores: ${_sensores.length}');
      print('🛢️  Tanques: ${_tanques.length}');
      print('👤 Usuários: ${_usuarios.length}');
    } catch (e) {
      print('❌ Erro ao carregar dados do banco: $e');
    }
  }

  // ========== MÉTODO ROBUSTO PARA CARREGAMENTO ==========
  Future<void> _carregarDadosRobusto() async {
    try {
      // 🏢 CARREGAR EMPRESAS

      try {
        var resultados =
            await dbConnection.connection!.query('SELECT * FROM empresa');
        for (var row in resultados) {
          var dados = row.toList();
          print('🔍 Dados brutos da empresa: $dados');

          // SÓ CARREGA SE TIVER DADOS VÁLIDOS DE VERDADE
          if (dados.length >= 3 &&
              _safeString(dados[1]).isNotEmpty &&
              _safeString(dados[2]).isNotEmpty) {
            // Estrutura normal: [id, nome, cnpj] com dados reais
            _empresas.add(Empresa(_safeInt(dados[0]), _safeString(dados[1]),
                _safeString(dados[2])));
            print('✅ Empresa carregada: ${dados[1]}');
          } else {
            print('⚠️  Dados de empresa incompletos ou inválidos: $dados');
          }
        }
        print('🏢 Empresas carregadas: ${_empresas.length}');
      } catch (e) {
        print('❌ Erro ao carregar empresas: $e');
      }

      // 🏠 CARREGAR LOCAIS - CORREÇÃO SIMPLES
      try {
        var resultados =
            await dbConnection.connection!.query('SELECT * FROM local');
        for (var row in resultados) {
          var dados = row.toList();
          print('🔍 Dados brutos do local: $dados');

          if (dados.length >= 3) {
            String nomeLocal = _safeString(dados[1]);
            String referenciaLocal = _safeString(dados[2]);

            // ✅ CORREÇÃO: Filtro simples para evitar confusão com empresas
            if (nomeLocal.length > 3 && referenciaLocal.length > 3) {
              _locais
                  .add(Local(_safeInt(dados[0]), nomeLocal, referenciaLocal));
              print('✅ Local carregado: $nomeLocal');
            } else {
              print('⚠️  Ignorado - Dados inválidos para local');
            }
          }
        }
        print('🏠 Locais carregados: ${_locais.length}');
      } catch (e) {
        print('❌ Erro ao carregar locais: $e');
      }

      // ⚙️ CARREGAR DISPOSITIVOS
      try {
        var resultados =
            await dbConnection.connection!.query('SELECT * FROM dispositivo');
        for (var row in resultados) {
          var dados = row.toList();
          print('🔍 Dados brutos do dispositivo: $dados');

          if (dados.length >= 3) {
            _dispositivos.add(Dispositivo(_safeInt(dados[0]),
                _safeString(dados[1]), _safeString(dados[2])));
            print('✅ Dispositivo carregado: ${dados[1]}');
          }
        }
        print('⚙️  Dispositivos carregados: ${_dispositivos.length}');
      } catch (e) {
        print('❌ Erro ao carregar dispositivos: $e');
      }

      // 📡 CARREGAR SENSORES
      try {
        var resultados =
            await dbConnection.connection!.query('SELECT * FROM sensor');
        for (var row in resultados) {
          var dados = row.toList();
          print('🔍 Dados brutos do sensor: $dados');

          if (dados.length >= 3) {
            int dispositivoId = dados.length >= 4 ? _safeInt(dados[3]) : 0;
            _sensores.add(SensorUltrassonico(
              _safeInt(dados[0]),
              _safeString(dados[1]),
              _safeString(dados[2]),
              dispositivoId: dispositivoId,
            ));
            print('✅ Sensor carregado: ${dados[1]}');
          }
        }
        print('📡 Sensores carregados: ${_sensores.length}');
      } catch (e) {
        print('❌ Erro ao carregar sensores: $e');
      }

      // 🛢️ CARREGAR TANQUES
      try {
        var resultados =
            await dbConnection.connection!.query('SELECT * FROM tanque');
        for (var row in resultados) {
          var dados = row.toList();
          print('🔍 Dados brutos do tanque: $dados');

          if (dados.length >= 4) {
            _tanques.add(Tanque(_safeInt(dados[0]), _safeDouble(dados[1]),
                _safeDouble(dados[2]), _safeDouble(dados[3])));
            print('✅ Tanque carregado: ID ${dados[0]}');
          }
        }
        print('🛢️  Tanques carregados: ${_tanques.length}');
      } catch (e) {
        print('❌ Erro ao carregar tanques: $e');
      }

      // 👤 CARREGAR USUÁRIOS
      try {
        var resultados =
            await dbConnection.connection!.query('SELECT * FROM usuario');
        for (var row in resultados) {
          var dados = row.toList();
          print('🔍 Dados brutos do usuário: $dados');

          if (dados.length >= 3) {
            _usuarios.add(Usuario(
              idUsuario: _safeInt(dados[0]),
              nome: _safeString(dados[1]),
              email: dados.length > 2
                  ? _safeString(dados[2])
                  : 'email@exemplo.com',
              senhaLogin: dados.length > 3 ? _safeString(dados[3]) : 'senha',
              perfil: dados.length > 4 ? _safeString(dados[4]) : 'Usuario',
              dataCriacao: DateTime.now(),
              ultimoLogin: DateTime.now(),
              empresaId: dados.length > 7 ? _safeInt(dados[7]) : 1,
            ));
            print('✅ Usuário carregado: ${dados[1]}');
          }
        }
        print('👤 Usuários carregados: ${_usuarios.length}');
      } catch (e) {
        print('❌ Erro ao carregar usuários: $e');
      }
    } catch (e) {
      print('❌ Erro geral no carregamento: $e');
    }
  }

  // ========== MÉTODOS AUXILIARES SEGUROS ==========
  int _safeInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  double _safeDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  String _safeString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    return value.toString();
  }

  // ========== MÉTODOS DE CADASTRO ==========
  Future<void> _cadastrarEmpresa() async {
    print('\n🏢 CADASTRAR EMPRESA');

    stdout.write('Nome: ');
    final nome = stdin.readLineSync()?.trim() ?? '';

    stdout.write('CNPJ: ');
    final cnpj = stdin.readLineSync()?.trim() ?? '';

    if (nome.isEmpty || cnpj.isEmpty) {
      print('❌ Nome e CNPJ são obrigatórios!');
      return;
    }

    final empresaExistente = _empresas.firstWhere(
      (empresa) => empresa.cnpj == cnpj,
      orElse: () => Empresa(0, '', ''),
    );

    if (empresaExistente.cnpj.isNotEmpty) {
      print('❌ Já existe uma empresa com este CNPJ!');
      return;
    }

    int novoId = _empresas.isEmpty
        ? 1
        : (_empresas.map((e) => e.idEmpresa).reduce((a, b) => a > b ? a : b) +
            1);
    final empresa = Empresa(novoId, nome, cnpj);
    _empresas.add(empresa);

    if (_conectado) {
      try {
        await dbConnection.connection!.query(
          'INSERT INTO empresa (nome, cnpj) VALUES (?, ?)',
          [empresa.nome, empresa.cnpj],
        );
        print('💾 Empresa salva no banco de dados!');
      } catch (e) {
        print('❌ Erro ao salvar empresa no banco: $e');
      }
    }

    print('✅ Empresa cadastrada com sucesso!');
    empresa.exibirDados();
  }

  Future<void> _cadastrarLocal() async {
    print('\n🏠 CADASTRAR LOCAL');

    if (_empresas.isEmpty) {
      print('❌ É necessário cadastrar uma empresa primeiro!');
      return;
    }

    print('\n📋 Empresas disponíveis:');
    for (int i = 0; i < _empresas.length; i++) {
      print('${i + 1} - ${_empresas[i].nome} (CNPJ: ${_empresas[i].cnpj})');
    }

    int? empresaIndex;
    do {
      stdout.write('Selecione a empresa (1-${_empresas.length}): ');
      final input = stdin.readLineSync()?.trim();
      empresaIndex = int.tryParse(input ?? '');

      if (empresaIndex == null ||
          empresaIndex < 1 ||
          empresaIndex > _empresas.length) {
        print('❌ Selecione uma empresa válida!');
      }
    } while (empresaIndex == null);

    final empresaSelecionada = _empresas[empresaIndex - 1];

    stdout.write('Nome do local: ');
    final nome = stdin.readLineSync()?.trim() ?? '';

    stdout.write('Referência: ');
    final referencia = stdin.readLineSync()?.trim() ?? '';

    if (nome.isEmpty || referencia.isEmpty) {
      print('❌ Nome e referência são obrigatórios!');
      return;
    }

    final localExistente = _locais.firstWhere(
      (local) => local.nome == nome && local.referencia == referencia,
      orElse: () => Local(0, '', ''),
    );

    if (localExistente.nome.isNotEmpty) {
      print('❌ Já existe um local com este nome e referência!');
      return;
    }

    int novoId = _locais.isEmpty
        ? 1
        : (_locais.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1);
    final local = Local(novoId, nome, referencia);
    _locais.add(local);

    if (_conectado) {
      try {
        await dbConnection.connection!.query(
          'INSERT INTO local (nome, referencia, empresa_idEmpresa) VALUES (?, ?, ?)',
          [local.nome, local.referencia, empresaSelecionada.idEmpresa],
        );
        print('💾 Local salvo no banco de dados!');
      } catch (e) {
        print('❌ Erro ao salvar local no banco: $e');
      }
    }

    print('✅ Local cadastrado com sucesso!');
    print('🏢 Vinculado à empresa: ${empresaSelecionada.nome}');
    local.exibirDados();
  }

  Future<void> _cadastrarDispositivo() async {
    print('\n⚙️  CADASTRAR DISPOSITIVO');

    stdout.write('Modelo: ');
    final modelo = stdin.readLineSync()?.trim() ?? '';

    stdout.write('Status (Ativo/Inativo): ');
    final status = stdin.readLineSync()?.trim() ?? '';

    if (modelo.isEmpty || status.isEmpty) {
      print('❌ Modelo e status são obrigatórios!');
      return;
    }

    int novoId = _dispositivos.isEmpty
        ? 1
        : (_dispositivos.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1);
    final dispositivo = Dispositivo(novoId, modelo, status);
    _dispositivos.add(dispositivo);

    if (_conectado) {
      try {
        await dbConnection.connection!.query(
          'INSERT INTO dispositivo (modelo, status) VALUES (?, ?)',
          [dispositivo.modelo, dispositivo.status],
        );
        print('💾 Dispositivo salvo no banco de dados!');
      } catch (e) {
        print('❌ Erro ao salvar dispositivo no banco: $e');
      }
    }

    print('✅ Dispositivo cadastrado com sucesso!');
    dispositivo.exibirDados();
  }

  Future<void> _cadastrarSensor() async {
    print('\n📡 CADASTRAR SENSOR');

    // Verificar se existem dispositivos cadastrados
    if (_dispositivos.isEmpty) {
      print('❌ É necessário cadastrar um dispositivo primeiro!');
      return;
    }

    // Mostrar dispositivos disponíveis
    print('\n📋 Dispositivos disponíveis:');
    for (int i = 0; i < _dispositivos.length; i++) {
      print(
          '${i + 1} - ${_dispositivos[i].modelo} (Status: ${_dispositivos[i].status}) [ID: ${_dispositivos[i].id}]');
    }

    // Selecionar dispositivo
    int? dispositivoIndex;
    do {
      stdout.write('Selecione o dispositivo (1-${_dispositivos.length}): ');
      final input = stdin.readLineSync()?.trim();
      dispositivoIndex = int.tryParse(input ?? '');

      if (dispositivoIndex == null ||
          dispositivoIndex < 1 ||
          dispositivoIndex > _dispositivos.length) {
        print('❌ Selecione um dispositivo válido!');
      }
    } while (dispositivoIndex == null);

    final dispositivoSelecionado = _dispositivos[dispositivoIndex - 1];

    // Dados do sensor
    stdout.write('Tipo: ');
    final tipo = stdin.readLineSync()?.trim() ?? '';

    stdout.write('Unidade de Medida: ');
    final unidadeMedida = stdin.readLineSync()?.trim() ?? '';

    if (tipo.isEmpty || unidadeMedida.isEmpty) {
      print('❌ Tipo e unidade de medida são obrigatórios!');
      return;
    }

    // Criar sensor COM DISPOSITIVO_ID
    int novoId = _sensores.isEmpty
        ? 1
        : (_sensores.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1);

    final sensor = SensorUltrassonico(
      novoId,
      tipo,
      unidadeMedida,
      dispositivoId: dispositivoSelecionado.id,
    );
    _sensores.add(sensor);

    // Salvar no banco COM O DISPOSITIVO_ID
    if (_conectado) {
      try {
        await dbConnection.connection!.query(
          'INSERT INTO sensor (tipo, unidadeMedida, dispositivo_idDispositivo) VALUES (?, ?, ?)',
          [sensor.tipo, sensor.unidadeMedida, dispositivoSelecionado.id],
        );
        print('💾 Sensor salvo no banco de dados!');
        print(
            '⚙️  Vinculado ao dispositivo: ${dispositivoSelecionado.modelo} (ID: ${dispositivoSelecionado.id})');
      } catch (e) {
        print('❌ Erro ao salvar sensor no banco: $e');
      }
    }

    print('✅ Sensor cadastrado com sucesso!');
    sensor.exibirDados();
  }

  Future<void> _cadastrarTanque() async {
    print('\n🛢️  CADASTRAR TANQUE');

    // Verificar se existem locais cadastrados
    if (_locais.isEmpty) {
      print('❌ É necessário cadastrar um local primeiro!');
      return;
    }

    // Verificar se existem dispositivos cadastrados
    if (_dispositivos.isEmpty) {
      print('❌ É necessário cadastrar um dispositivo primeiro!');
      return;
    }

    // Mostrar locais disponíveis
    print('\n📋 Locais disponíveis:');
    for (int i = 0; i < _locais.length; i++) {
      print('${i + 1} - ${_locais[i].nome} (Ref: ${_locais[i].referencia})');
    }

    // Selecionar local
    int? localIndex;
    do {
      stdout.write('Selecione o local (1-${_locais.length}): ');
      final input = stdin.readLineSync()?.trim();
      localIndex = int.tryParse(input ?? '');

      if (localIndex == null || localIndex < 1 || localIndex > _locais.length) {
        print('❌ Selecione um local válido!');
      }
    } while (localIndex == null);

    final localSelecionado = _locais[localIndex - 1];

    // Mostrar dispositivos disponíveis
    print('\n📋 Dispositivos disponíveis:');
    for (int i = 0; i < _dispositivos.length; i++) {
      print(
          '${i + 1} - ${_dispositivos[i].modelo} (Status: ${_dispositivos[i].status})');
    }

    // Selecionar dispositivo
    int? dispositivoIndex;
    do {
      stdout.write('Selecione o dispositivo (1-${_dispositivos.length}): ');
      final input = stdin.readLineSync()?.trim();
      dispositivoIndex = int.tryParse(input ?? '');

      if (dispositivoIndex == null ||
          dispositivoIndex < 1 ||
          dispositivoIndex > _dispositivos.length) {
        print('❌ Selecione um dispositivo válido!');
      }
    } while (dispositivoIndex == null);

    final dispositivoSelecionado = _dispositivos[dispositivoIndex - 1];

    // Dados do tanque
    double? altura;
    do {
      stdout.write('Altura (metros): ');
      final inputAltura = stdin.readLineSync()?.trim();
      altura = double.tryParse(inputAltura ?? '');

      if (altura == null || altura <= 0) {
        print('❌ Altura deve ser um número positivo!');
      }
    } while (altura == null || altura <= 0);

    double? volumeMax;
    do {
      stdout.write('Volume Máximo (litros): ');
      final inputVolume = stdin.readLineSync()?.trim();
      volumeMax = double.tryParse(inputVolume ?? '');

      if (volumeMax == null || volumeMax <= 0) {
        print('❌ Volume máximo deve ser um número positivo!');
      }
    } while (volumeMax == null || volumeMax <= 0);

    // Criar tanque
    int novoId = _tanques.isEmpty
        ? 1
        : (_tanques.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1);

    final tanque = Tanque(novoId, altura, volumeMax, 0.0);
    _tanques.add(tanque);

    // Salvar no banco COM OS IDs DE LOCAL E DISPOSITIVO
    if (_conectado) {
      try {
        await dbConnection.connection!.query(
          'INSERT INTO tanque (altura, volumeMax, volumeAtual, local_idLocal, dispositivo_idDispositivo) VALUES (?, ?, ?, ?, ?)',
          [
            tanque.altura,
            tanque.volumeMax,
            tanque.volumeAtual,
            localSelecionado.id, // local_idLocal
            dispositivoSelecionado.id // dispositivo_idDispositivo
          ],
        );
        print('💾 Tanque salvo no banco de dados!');
        print('🏠 Vinculado ao local: ${localSelecionado.nome}');
        print('⚙️  Vinculado ao dispositivo: ${dispositivoSelecionado.modelo}');
      } catch (e) {
        print('❌ Erro ao salvar tanque no banco: $e');
      }
    }

    print('✅ Tanque cadastrado com sucesso!');
    tanque.exibirDados();
  }

  Future<void> _cadastrarUsuario() async {
    print('\n👤 CADASTRAR USUÁRIO');

    if (_empresas.isEmpty) {
      print('❌ É necessário cadastrar uma empresa primeiro!');
      return;
    }

    stdout.write('Nome: ');
    final nome = stdin.readLineSync()?.trim() ?? '';

    stdout.write('Email: ');
    final email = stdin.readLineSync()?.trim() ?? '';

    stdout.write('Senha: ');
    final senha = stdin.readLineSync()?.trim() ?? '';

    stdout.write('Perfil (Administrador/Operador/Visualizador): ');
    final perfil = stdin.readLineSync()?.trim() ?? '';

    if (nome.isEmpty || email.isEmpty || senha.isEmpty || perfil.isEmpty) {
      print('❌ Todos os campos são obrigatórios!');
      return;
    }

    print('\n📋 Empresas disponíveis:');
    for (int i = 0; i < _empresas.length; i++) {
      print('${i + 1} - ${_empresas[i].nome}');
    }

    int? empresaIndex;
    do {
      stdout.write('Selecione a empresa (1-${_empresas.length}): ');
      final input = stdin.readLineSync()?.trim();
      empresaIndex = int.tryParse(input ?? '');

      if (empresaIndex == null ||
          empresaIndex < 1 ||
          empresaIndex > _empresas.length) {
        print('❌ Selecione uma empresa válida!');
      }
    } while (empresaIndex == null);

    final empresaSelecionada = _empresas[empresaIndex - 1];

    int novoId = _usuarios.isEmpty
        ? 1
        : (_usuarios.map((e) => e.idUsuario).reduce((a, b) => a > b ? a : b) +
            1);
    final usuario = Usuario(
      idUsuario: novoId,
      nome: nome,
      email: email,
      senhaLogin: senha,
      perfil: perfil,
      dataCriacao: DateTime.now(),
      ultimoLogin: DateTime.now(),
      empresaId: empresaSelecionada.idEmpresa,
    );

    _usuarios.add(usuario);

    if (_conectado) {
      try {
        await dbConnection.connection!.query(
          'INSERT INTO usuario (nome, email, senhaLogin, perfil, dataCriacao, ultimoLogin, empresa_idEmpresa) VALUES (?, ?, ?, ?, ?, ?, ?)',
          [
            usuario.nome,
            usuario.email,
            usuario.senhaLogin,
            usuario.perfil,
            usuario.dataCriacao.toIso8601String(),
            usuario.ultimoLogin.toIso8601String(),
            usuario.empresaId
          ],
        );
        print('💾 Usuário salvo no banco de dados!');
      } catch (e) {
        print('❌ Erro ao salvar usuário no banco: $e');
      }
    }

    print('✅ Usuário cadastrado com sucesso!');
    usuario.exibirDados();
  }

  // ========== MÉTODOS DE CONSULTA ==========
  void _listarTodasEntidades() {
    print('\n📋 RESUMO GERAL DO SISTEMA');
    print('═' * 50);
    print('🏢 EMPRESAS: ${_empresas.length}');
    for (var empresa in _empresas) {
      print('   • ${empresa.nome} (CNPJ: ${empresa.cnpj})');
    }

    print('\n🏠 LOCAIS: ${_locais.length}');
    for (var local in _locais) {
      print('   • ${local.nome} (Ref: ${local.referencia})');
    }

    print('\n⚙️  DISPOSITIVOS: ${_dispositivos.length}');
    for (var dispositivo in _dispositivos) {
      print('   • ${dispositivo.modelo} (Status: ${dispositivo.status})');
    }

    print('\n📡 SENSORES: ${_sensores.length}');
    for (var sensor in _sensores) {
      print('   • ${sensor.tipo} (Unidade: ${sensor.unidadeMedida})');
    }

    print('\n🛢️  TANQUES: ${_tanques.length}');
    for (var tanque in _tanques) {
      print('   • Tanque ${tanque.id} (Altura: ${tanque.altura}m)');
    }

    print('\n👤 USUÁRIOS: ${_usuarios.length}');
    for (var usuario in _usuarios) {
      print('   • ${usuario.nome} (Perfil: ${usuario.perfil})');
    }

    print('\n📊 LEITURAS: ${_leituras.length}');
    if (_leituras.isNotEmpty) {
      final ultimaLeitura = _leituras.last;
      print(
          '   • Última: ${ultimaLeitura.nivelCm.toStringAsFixed(1)}cm (${ultimaLeitura.porcentagem.toStringAsFixed(1)}%) - ${ultimaLeitura.status}');
    }

    print('🏭 PRODUÇÕES: ${_producoes.length}');
    print('═' * 50);
  }

  void _listarEmpresas() {
    print('\n🏢 LISTA DE EMPRESAS');
    print('═' * 50);

    if (_empresas.isEmpty) {
      print('📭 Nenhuma empresa cadastrada');
    } else {
      for (var empresa in _empresas) {
        print('ID: ${empresa.idEmpresa}');
        print('Nome: ${empresa.nome}');
        print('CNPJ: ${empresa.cnpj}');
        print('─' * 30);
      }
      print('📊 Total: ${_empresas.length} empresa(s)');
    }
  }

  void _listarLocais() {
    print('\n🏠 LISTA DE LOCAIS');
    print('═' * 50);

    if (_locais.isEmpty) {
      print('📭 Nenhum local cadastrado');
    } else {
      for (var local in _locais) {
        print('ID: ${local.id}');
        print('Nome: ${local.nome}');
        print('Referência: ${local.referencia}');
        print('─' * 30);
      }
      print('📊 Total: ${_locais.length} local(is)');
    }
  }

  void _listarDispositivos() {
    print('\n⚙️  LISTA DE DISPOSITIVOS');
    print('═' * 50);

    if (_dispositivos.isEmpty) {
      print('📭 Nenhum dispositivo cadastrado');
    } else {
      for (var dispositivo in _dispositivos) {
        dispositivo.exibirDados();
      }
      print('📊 Total: ${_dispositivos.length} dispositivo(s)');
    }
  }

  void _listarSensores() {
    print('\n📡 LISTA DE SENSORES');
    print('═' * 50);

    if (_sensores.isEmpty) {
      print('📭 Nenhum sensor cadastrado');
    } else {
      for (var sensor in _sensores) {
        sensor.exibirDados();
      }
      print('📊 Total: ${_sensores.length} sensor(es)');
    }
  }

  void _listarTanques() {
    print('\n🛢️  LISTA DE TANQUES');
    print('═' * 50);

    if (_tanques.isEmpty) {
      print('📭 Nenhum tanque cadastrado');
    } else {
      for (var tanque in _tanques) {
        tanque.exibirDados();
      }
      print('📊 Total: ${_tanques.length} tanque(s)');
    }
  }

  void _listarUsuarios() {
    print('\n👤 LISTA DE USUÁRIOS');
    print('═' * 50);

    if (_usuarios.isEmpty) {
      print('📭 Nenhum usuário cadastrado');
    } else {
      for (var usuario in _usuarios) {
        usuario.exibirDados();
      }
      print('📊 Total: ${_usuarios.length} usuário(s)');
    }
  }

  void _listarProducoes() {
    print('\n🏭 LISTA DE PRODUÇÕES');
    print('═' * 50);

    if (_producoes.isEmpty) {
      print('📭 Nenhuma produção registrada');
    } else {
      for (var producao in _producoes) {
        producao.exibirDados();
      }
      print('📊 Total: ${_producoes.length} produção(ões)');
    }
  }

  void _listarLeituras() {
    print('\n📊 LISTA DE LEITURAS');
    print('═' * 50);

    if (_leituras.isEmpty) {
      print('📭 Nenhuma leitura registrada');
    } else {
      for (var leitura in _leituras) {
        print(leitura.toString());
      }
      print('📊 Total: ${_leituras.length} leitura(s)');
    }
  }

  // ========== MÉTODOS DE LEITURA E PRODUÇÃO ==========
  Future<void> _visualizarUltimaLeitura() async {
    print('\n📊 ÚLTIMA LEITURA');
    print('═' * 50);

    if (_leituras.isEmpty) {
      print('📭 Nenhuma leitura registrada');
    } else {
      final ultimaLeitura = _leituras.last;
      ultimaLeitura.exibirDados();
    }
  }

  Future<void> _visualizarUltimas10Leituras() async {
    print('\n📈 ÚLTIMAS 10 LEITURAS');
    print('═' * 50);

    if (_leituras.isEmpty) {
      print('📭 Nenhuma leitura registrada');
    } else {
      final ultimasLeituras = _leituras.length <= 10
          ? _leituras
          : _leituras.sublist(_leituras.length - 10);

      for (int i = 0; i < ultimasLeituras.length; i++) {
        final leitura = ultimasLeituras[i];
        print('${i + 1}. ${leitura.toString()}');
      }
      print('📊 Total exibido: ${ultimasLeituras.length} leitura(s)');
    }
  }

  Future<void> _enviarLeiturasParaMySQL() async {
    print('\n📤 ENVIAR LEITURAS DO FIREBASE PARA MYSQL');
    print('═' * 50);

    if (_leituras.isEmpty) {
      print('❌ Nenhuma leitura disponível para enviar');
      return;
    }

    if (!_conectado) {
      print('❌ Sem conexão com o banco MySQL');
      return;
    }

    if (_sensores.isEmpty) {
      print('❌ Nenhum sensor cadastrado no MySQL');
      return;
    }

    // Usar o primeiro sensor disponível
    final sensorId = _sensores.first.id;
    int leiturasEnviadas = 0;
    int leiturasComErro = 0;

    print('📊 Total de leituras no Firebase: ${_leituras.length}');
    print('📡 Usando sensor ID: $sensorId');
    print('🚀 Enviando todas as leituras...');

    for (final leitura in _leituras) {
      try {
        // ✅ CORREÇÃO: usar timestamp minúsculo (como está na classe Leitura)
        String dataFormatada = _formatarDataParaMySQL(leitura.timestamp);

        // APENAS ENVIAR - SEM VERIFICAR DUPLICATAS
        await dbConnection.connection!.query(
          '''INSERT INTO leitura 
           (timestamp, distanciaCm, nivelCm, porcentagem, statusTanque, sensor_idSensor) 
           VALUES (?, ?, ?, ?, ?, ?)''',
          [
            dataFormatada,
            leitura.distanciaCm,
            leitura.nivelCm,
            leitura.porcentagem,
            leitura.status,
            sensorId,
          ],
        );

        leiturasEnviadas++;
        print('✅ $dataFormatada - ${leitura.porcentagem.toStringAsFixed(1)}%');
      } catch (e) {
        leiturasComErro++;
        // ✅ CORREÇÃO: usar timestamp minúsculo
        print('❌ ${leitura.timestamp}: $e');
      }
    }

    print('\n📊 RESUMO DO ENVIO:');
    print('✅ Leituras enviadas com sucesso: $leiturasEnviadas');
    print('❌ Leituras com erro: $leiturasComErro');
    print('📋 Total processado: ${_leituras.length}');

    if (leiturasEnviadas > 0) {
      print('🎉 Leituras enviadas para MySQL!');
    }
  }

// MÉTODO AUXILIAR PARA FORMATAR DATA PARA MYSQL
  String _formatarDataParaMySQL(DateTime dateTime) {
    // Formato: YYYY-MM-DD HH:MM:SS (sem T e Z)
    String year = dateTime.year.toString();
    String month = dateTime.month.toString().padLeft(2, '0');
    String day = dateTime.day.toString().padLeft(2, '0');
    String hour = dateTime.hour.toString().padLeft(2, '0');
    String minute = dateTime.minute.toString().padLeft(2, '0');
    String second = dateTime.second.toString().padLeft(2, '0');

    return '$year-$month-$day $hour:$minute:$second';
  }

  Future<void> _calcularProducao() async {
    print('\n🏭 CALCULAR PRODUÇÃO POR LEITURA');
    print('═' * 50);

    if (_leituras.isEmpty) {
      print('❌ Nenhuma leitura disponível para calcular produção');
      return;
    }

    // Encontrar um sensor válido
    int sensorId = _sensores.isNotEmpty ? _sensores.first.id : 1;

    // 🔥 CALCULAR PRODUÇÃO PARA CADA LEITURA
    int producoesCriadas = 0;

    for (int i = 1; i < _leituras.length; i++) {
      final leituraAtual = _leituras[i];
      final leituraAnterior = _leituras[i - 1];

      // Calcular variação percentual
      double variacaoPercentual =
          leituraAnterior.porcentagem - leituraAtual.porcentagem;

      // Só cria produção se o tanque baixou (variação positiva)
      if (variacaoPercentual > 0) {
        double metrosFio = variacaoPercentual; // 1% = 1 metro

        int novoId = _producoes.isEmpty
            ? 1
            : (_producoes.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1);

        final producao = Producao(
          id: novoId,
          tanqueId: 1,
          dataHora: leituraAtual.timestamp, // ✅ Usar timestamp da leitura
          quantidade: metrosFio,
          tipoProducao: 'Automática',
          observacoes:
              'Leitura ${i}: ${variacaoPercentual.toStringAsFixed(2)}% = ${metrosFio.toStringAsFixed(2)}m de fio',
        );

        _producoes.add(producao);
        producoesCriadas++;

        // Salvar no banco COM FORMATO CORRETO
        if (_conectado) {
          try {
            // ✅ CORREÇÃO: Usar timestamp minúsculo e data formatada
            String dataFormatada = _formatarDataParaMySQL(producao.dataHora);

            await dbConnection.connection!.query(
              'INSERT INTO producao (quantidade, timestamp, sensor_idSensor) VALUES (?, ?, ?)',
              [
                producao.quantidade,
                dataFormatada, // ✅ Data formatada para MySQL
                sensorId
              ],
            );
            print(
                '✅ Produção ${novoId}: ${metrosFio.toStringAsFixed(2)}m de fio');
          } catch (e) {
            print('❌ Erro ao salvar produção $novoId: $e');
          }
        }
      }
    }

    if (producoesCriadas > 0) {
      print('✅ $producoesCriadas produção(ões) calculada(s) com sucesso!');

      // Calcular total de fio produzido
      double totalFio =
          _producoes.map((p) => p.quantidade).reduce((a, b) => a + b);
      print('📊 Total de fio produzido: ${totalFio.toStringAsFixed(2)} metros');
    } else {
      print('📭 Nenhuma produção calculada - sem variações no nível do tanque');
    }
  }

  Future<void> _enviarProducoesParaMySQL() async {
    print('\n📤 ENVIAR PRODUÇÕES PARA MYSQL');
    print('═' * 50);

    if (_producoes.isEmpty) {
      print('❌ Nenhuma produção disponível para enviar');
      return;
    }

    if (!_conectado) {
      print('❌ Sem conexão com o banco MySQL');
      return;
    }

    if (_sensores.isEmpty) {
      print('❌ Nenhum sensor cadastrado no MySQL');
      return;
    }

    // Usar o primeiro sensor disponível
    final sensorId = _sensores.first.id;
    int producoesEnviadas = 0;
    int producoesComErro = 0;

    print('📊 Total de produções locais: ${_producoes.length}');
    print('📡 Usando sensor ID: $sensorId');
    print('🚀 Enviando todas as produções...');

    for (final producao in _producoes) {
      try {
        // Converter data para formato MySQL
        String dataFormatada = _formatarDataParaMySQL(producao.dataHora);

        // ✅ ENVIAR PRODUÇÃO PARA MYSQL
        await dbConnection.connection!.query(
          '''INSERT INTO producao 
           (quantidade, timestamp, sensor_idSensor) 
           VALUES (?, ?, ?)''',
          [
            producao.quantidade,
            dataFormatada,
            sensorId,
          ],
        );

        producoesEnviadas++;
        print(
            '✅ ${dataFormatada} - ${producao.quantidade.toStringAsFixed(2)}m de fio');
      } catch (e) {
        producoesComErro++;
        print('❌ ${producao.dataHora}: $e');
      }
    }

    print('\n📊 RESUMO DO ENVIO:');
    print('✅ Produções enviadas com sucesso: $producoesEnviadas');
    print('❌ Produções com erro: $producoesComErro');
    print('📋 Total processado: ${_producoes.length}');

    if (producoesEnviadas > 0) {
      print('🎉 Produções enviadas para MySQL!');
    }
  }

  // ========== MÉTODO PRINCIPAL ==========
  Future<void> executar() async {
    print("\n");
    print('╔══════════════════════════════════════════════╗');
    print('║           SISTEMA DE MONITORAMENTO           ║');
    print('║                🛢️  TANKSENSE 🛢️                ║');
    print('╚══════════════════════════════════════════════╝');

    if (_conectado) {
      print('✅ CONECTADO AO BANCO DE DADOS');
      print(
          '📊 Dados carregados: ${_empresas.length} empresas, ${_locais.length} locais, ${_dispositivos.length} dispositivos');
    } else {
      print('❌ SEM CONEXÃO COM BANCO - Dados apenas locais');
    }

    print('🔥 CONECTADO AO FIREBASE');
    print('📊 Leituras carregadas: ${_leituras.length}');

    bool executando = true;

    while (executando) {
      print('\n' + '═' * 60);
      print('🔧 MENU PRINCIPAL - TANKSENSE');
      print('═' * 60);
      print('📋 CADASTROS:');
      print(' 1  - 🏢 Cadastrar Empresa');
      print(' 2  - 🏠 Cadastrar Local');
      print(' 3  - ⚙️  Cadastrar Dispositivo');
      print(' 4  - 📡 Cadastrar Sensor');
      print(' 5  - 🛢️  Cadastrar Tanque');
      print(' 6  - 👤 Cadastrar Usuário');
      print('═' * 60);
      print('🔍 CONSULTAS:');
      print(' 7  - 📊 Listar Todas as Entidades');
      print(' 8  - 🏢 Listar Empresas');
      print(' 9  - 🏠 Listar Locais');
      print('10  - ⚙️  Listar Dispositivos');
      print('11  - 📡 Listar Sensores');
      print('12  - 🛢️  Listar Tanques');
      print('13  - 👤 Listar Usuários');
      print('═' * 60);
      print('═' * 60);
      print('📈 FIREBASE & PRODUÇÃO:');
      print('14 - 🔄 Visualizar Última Leitura');
      print('15 - 📈 Visualizar Últimas 10 Leituras');
      print('16 - 📊 Listar Todas as Leituras');
      print('17 - 📤 Enviar Leituras para MySQL');
      print('18 - 🏭 Calcular Produção');
      print('19 - 📋 Listar Todas as Produções');
      print('20 - 🚀 Enviar Produções para MySQL');
      print('═' * 60);

      stdout.write('👉 Escolha: ');
      final opcao = stdin.readLineSync();

      switch (opcao) {
        case '1':
          await _cadastrarEmpresa();
          break;
        case '2':
          await _cadastrarLocal();
          break;
        case '3':
          await _cadastrarDispositivo();
          break;
        case '4':
          await _cadastrarSensor();
          break;
        case '5':
          await _cadastrarTanque();
          break;
        case '6':
          await _cadastrarUsuario();
          break;
        case '7':
          _listarTodasEntidades();
          break;
        case '8':
          _listarEmpresas();
          break;
        case '9':
          _listarLocais();
          break;
        case '10':
          _listarDispositivos();
          break;
        case '11':
          _listarSensores();
          break;
        case '12':
          _listarTanques();
          break;
        case '13':
          _listarUsuarios();
          break;
        case '14':
          await _visualizarUltimaLeitura();
          break;
        case '15':
          await _visualizarUltimas10Leituras();
          break;
        case '16':
          _listarLeituras();
          break;
        case '17': // ← ENVIAR LEITURAS PARA MYSQL
          await _enviarLeiturasParaMySQL();
          break;
        case '18': // ← CALCULAR PRODUÇÃO
          await _calcularProducao();
          break;
        case '19': // ← LISTAR TODAS AS PRODUÇÕES
          _listarProducoes();
          break;
        case '20': // ← ENVIAR PRODUÇÕES PARA MYSQL
          await _enviarProducoesParaMySQL();
          break;
        case '0':
          await dbConnection.close();
          print('\n👋 Encerrando Tanksense...');
          executando = false;
          break;
        default:
          print('❌ Opção inválida!');
      }

      if (executando) {
        print('\n⏎ Pressione Enter para continuar...');
        stdin.readLineSync();
      }
    }

    print('\n🛢️ Tanksense finalizado. Até logo!');
  }
}
