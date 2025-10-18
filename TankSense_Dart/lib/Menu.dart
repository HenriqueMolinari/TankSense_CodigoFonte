import 'dart:io';
import 'dart:convert';
import 'dart:math';
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

  /* Future<void> _enviarLeituraFirebase(double distanciaCm, double nivelCm, double porcentagem, String status) async {
    try {
      final novaLeitura = {
        'timestamp': DateTime.now().toIso8601String(),
        'distancia_cm': distanciaCm,
        'nivel_cm': nivelCm,
        'porcentagem': porcentagem,
        'status': status,
      };

      final url = Uri.https(_baseUrl, '/leituras.json', {'auth': _authToken});
      final response = await http.post(
        url,
        body: json.encode(novaLeitura),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final leituraId = responseData['name']; // ID gerado pelo Firebase
        
        print('✅ Leitura enviada para Firebase:');
        print('   📏 Distância: ${distanciaCm.toStringAsFixed(2)} cm');
        print('   🌊 Nível: ${nivelCm.toStringAsFixed(2)} cm');
        print('   📊 Porcentagem: ${porcentagem.toStringAsFixed(1)}%');
        print('   🚦 Status: $status');

        // Adicionar localmente também
        final novaLeituraLocal = Leitura(
          DateTime.now().millisecondsSinceEpoch,
          DateTime.now(),
          distanciaCm,
          nivelCm,
          porcentagem,
          status,
        );
        _leituras.add(novaLeituraLocal);
      } else {
        print('❌ Erro ao enviar para Firebase: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erro ao enviar leitura para Firebase: $e');
    }
  }
*/

  // ========== CARREGAR DADOS DO BANCO - CORRIGIDO ==========
  Future<void> _carregarDadosDoBanco() async {
    if (!_conectado) return;

    try {
      print('\n📥 CARREGANDO DADOS DO BANCO...');

      // Carregar empresas
      try {
        var resultados =
            await dbConnection.connection!.query('SELECT * FROM empresa');
        if (resultados.isNotEmpty) {
          for (var row in resultados) {
            int id = row['idEmpresa'] ?? row[0] as int;
            String nome = row['nome'] ?? row[1] as String;
            String cnpj = row['cnpj'] ?? row[2] as String;
            _empresas.add(Empresa(id, nome, cnpj));
          }
          print('🏢 Empresas carregadas: ${_empresas.length}');
        } else {
          print('ℹ️  Nenhuma empresa encontrada no banco');
        }
      } catch (e) {
        print('ℹ️  Nenhuma empresa encontrada no banco: $e');
      }

      // Carregar locais
      try {
        var resultados =
            await dbConnection.connection!.query('SELECT * FROM local');
        if (resultados.isNotEmpty) {
          for (var row in resultados) {
            int id = row['idLocal'] ?? row[0] as int;
            String nome = row['nome'] ?? row[1] as String;
            String referencia = row['referencia'] ?? row[2] as String;
            _locais.add(Local(id, nome, referencia));
          }
          print('🏠 Locais carregados: ${_locais.length}');
        } else {
          print('ℹ️  Nenhum local encontrado no banco');
        }
      } catch (e) {
        print('ℹ️  Nenhum local encontrado no banco: $e');
      }

      // Carregar dispositivos
      try {
        var resultados =
            await dbConnection.connection!.query('SELECT * FROM dispositivo');
        for (var row in resultados) {
          _dispositivos.add(Dispositivo(row['idDispositivo'] ?? row[0],
              row['modelo'] ?? row[1], row['status'] ?? row[2]));
        }
        print('⚙️  Dispositivos carregados: ${_dispositivos.length}');
      } catch (e) {
        print('ℹ️  Nenhum dispositivo encontrado no banco: $e');
      }

      // Carregar sensores
      try {
        var resultados =
            await dbConnection.connection!.query('SELECT * FROM sensor');
        for (var row in resultados) {
          _sensores.add(SensorUltrassonico(row['idSensor'] ?? row[0],
              row['tipo'] ?? row[1], row['unidadeMedida'] ?? row[2]));
        }
        print('📡 Sensores carregados: ${_sensores.length}');
      } catch (e) {
        print('ℹ️  Nenhum sensor encontrado no banco: $e');
      }

      // Carregar tanques
      try {
        var resultados =
            await dbConnection.connection!.query('SELECT * FROM tanque');
        for (var row in resultados) {
          _tanques.add(Tanque(
              row['idTanque'] ?? row[0],
              (row['altura'] ?? row[1]).toDouble(),
              (row['volumeMax'] ?? row[2]).toDouble(),
              (row['volumeAtual'] ?? row[3]).toDouble()));
        }
        print('🛢️  Tanques carregados: ${_tanques.length}');
      } catch (e) {
        print('ℹ️  Nenhum tanque encontrado no banco: $e');
      }

      // Carregar usuários
      try {
        var resultados =
            await dbConnection.connection!.query('SELECT * FROM usuario');
        for (var row in resultados) {
          _usuarios.add(Usuario(
            idUsuario: row['idUsuario'] ?? row[0],
            nome: row['nome'] ?? row[1],
            email: row['email'] ?? row[2],
            senhaLogin: row['senhaLogin'] ?? row[3],
            perfil: row['perfil'] ?? row[4],
            dataCriacao: row['dataCriacao'] ?? DateTime.now(),
            ultimoLogin: row['ultimoLogin'] ?? DateTime.now(),
            empresaId: row['empresa_idEmpresa'] ?? row[7] ?? 1,
          ));
        }
        print('👤 Usuários carregados: ${_usuarios.length}');
      } catch (e) {
        print('ℹ️  Nenhum usuário encontrado no banco: $e');
      }

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

    stdout.write('Tipo: ');
    final tipo = stdin.readLineSync()?.trim() ?? '';

    stdout.write('Unidade de Medida: ');
    final unidadeMedida = stdin.readLineSync()?.trim() ?? '';

    if (tipo.isEmpty || unidadeMedida.isEmpty) {
      print('❌ Tipo e unidade de medida são obrigatórios!');
      return;
    }

    int novoId = _sensores.isEmpty
        ? 1
        : (_sensores.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1);
    final sensor = SensorUltrassonico(novoId, tipo, unidadeMedida);
    _sensores.add(sensor);

    if (_conectado) {
      try {
        await dbConnection.connection!.query(
          'INSERT INTO sensor (tipo, unidadeMedida) VALUES (?, ?)',
          [sensor.tipo, sensor.unidadeMedida],
        );
        print('💾 Sensor salvo no banco de dados!');
      } catch (e) {
        print('❌ Erro ao salvar sensor no banco: $e');
      }
    }

    print('✅ Sensor cadastrado com sucesso!');
    sensor.exibirDados();
  }

  Future<void> _cadastrarTanque() async {
    print('\n🛢️  CADASTRAR TANQUE');

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

    int novoId = _tanques.isEmpty
        ? 1
        : (_tanques.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1);
    final tanque = Tanque(novoId, altura, volumeMax, 0.0);
    _tanques.add(tanque);

    if (_conectado) {
      try {
        await dbConnection.connection!.query(
          'INSERT INTO tanque (altura, volumeMax, volumeAtual) VALUES (?, ?, ?)',
          [tanque.altura, tanque.volumeMax, tanque.volumeAtual],
        );
        print('💾 Tanque salvo no banco de dados!');
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

  Future<void> _calcularProducao() async {
    print('\n🏭 CALCULAR PRODUÇÃO');
    print('═' * 50);

    if (_tanques.isEmpty) {
      print('❌ Nenhum tanque cadastrado para calcular produção');
      return;
    }

    final random = Random();
    final tanque = _tanques[random.nextInt(_tanques.length)];
    final quantidade = random.nextDouble() * 1000;

    int novoId = _producoes.isEmpty
        ? 1
        : (_producoes.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1);
    final producao = Producao(
      id: novoId,
      tanqueId: tanque.id,
      dataHora: DateTime.now(),
      quantidade: quantidade,
      tipoProducao: 'Automática',
      observacoes: 'Produção calculada automaticamente',
    );

    _producoes.add(producao);

    if (_conectado) {
      try {
        await dbConnection.connection!.query(
          'INSERT INTO producao (tanque_idTanque, dataHora, quantidade, tipoProducao, observacoes) VALUES (?, ?, ?, ?, ?)',
          [
            producao.tanqueId,
            producao.dataHora.toIso8601String(),
            producao.quantidade,
            producao.tipoProducao,
            producao.observacoes,
          ],
        );
        print('💾 Produção salva no banco de dados!');
      } catch (e) {
        print('❌ Erro ao salvar produção no banco: $e');
      }
    }

    print('✅ Produção calculada e salva com sucesso!');
    producao.exibirDados();
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
      print('📈 FIREBASE & PRODUÇÃO:');
      print('14  - 🔄 Visualizar Última Leitura');
      print('15  - 📈 Visualizar Últimas 10 Leituras');
      print('16  - 📊 Listar Todas as Leituras');
      print('17  - 🏭 Calcular Produção');
      print('18  - 📋 Listar Produções');
      print('═' * 60);
      print(' 0  - ❌ Sair');
      print('─' * 60);

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
        case '17':
          await _calcularProducao();
          break;
        case '18':
          _listarProducoes();
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
