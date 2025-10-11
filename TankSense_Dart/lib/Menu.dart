import 'dart:io';
import 'dart:convert';
import 'Empresa.dart';
import 'Local.dart';
import 'Tanque.dart';
import 'Dispositivo.dart';
import 'SensorUltrassonico.dart';
import 'Leitura.dart';
import 'Producao.dart';
import 'Usuario.dart';
import 'DatabaseConfig.dart';
import 'DatabaseConnection.dart';

class Menu {
  // Firebase Configuration
  static const String _baseUrl = 'tanksense---v2-default-rtdb.firebaseio.com';
  static const String _authToken = 'XALK5M3Yuc7jQgS62iDXpnAKvsBJEWKij0hR02tx';

  // Listas privadas com encapsulamento
  final List<Empresa> _empresas = [];
  final List<Local> _locais = [];
  final List<Tanque> _tanques = [];
  final List<Dispositivo> _dispositivos = [];
  final List<SensorUltrassonico> _sensores = [];
  final List<Leitura> _leituras = [];
  final List<Producao> _producoes = [];
  final List<Usuario> _usuarios = [];

  // Configuração e conexão com banco de dados
  DatabaseConfig? _dbConfig;
  DatabaseConnection? _dbConnection;
  bool _dbConectado = false;

  // Getters para acesso controlado
  List<Empresa> get empresas => List.from(_empresas);
  List<Local> get locais => List.from(_locais);
  List<Tanque> get tanques => List.from(_tanques);
  List<Dispositivo> get dispositivos => List.from(_dispositivos);
  List<SensorUltrassonico> get sensores => List.from(_sensores);
  List<Leitura> get leituras => List.from(_leituras);
  List<Producao> get producoes => List.from(_producoes);
  List<Usuario> get usuarios => List.from(_usuarios);

  // ========== MÉTODOS FIREBASE ==========

  // Método privado p/ Firebase
  static Future<dynamic> _fetchData(String path) async {
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      final uri = Uri(
        scheme: 'https',
        host: _baseUrl,
        path: '$path.json',
        queryParameters: {'auth': _authToken},
      );

      print('🔗 Conectando ao Firebase...');

      final request = await client.getUrl(uri);
      final response = await request.close();

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();

        if (responseBody.isEmpty || responseBody == 'null') {
          return null;
        }
        return jsonDecode(responseBody);
      } else {
        throw HttpException('Erro HTTP ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão com Firebase: $e');
    }
  }

  // Métodos estáticos para Firebase
  static Future<Map<String, dynamic>?> getUltimaLeitura() async {
    final data = await _fetchData('ultima_leitura');
    return data != null && data is Map ? Map<String, dynamic>.from(data) : null;
  }

  static Future<List<Map<String, dynamic>>> getUltimas10Leituras() async {
    final data = await _fetchData('leituras');
    if (data == null || data is! Map) return [];

    final List<Map<String, dynamic>> leituras = [];
    data.forEach((key, value) {
      if (value != null && value is Map) {
        leituras.add({'id': key, ...Map<String, dynamic>.from(value)});
      }
    });

    leituras.sort((a, b) {
      final timestampA = a['timestamp'] ?? '';
      final timestampB = b['timestamp'] ?? '';
      return timestampB.compareTo(timestampA);
    });

    return leituras.take(10).toList();
  }

  static Future<List<Map<String, dynamic>>> getTodasLeituras() async {
    final data = await _fetchData('leituras');
    if (data == null || data is! Map) return [];

    final List<Map<String, dynamic>> leituras = [];
    data.forEach((key, value) {
      if (value != null && value is Map) {
        leituras.add({'id': key, ...Map<String, dynamic>.from(value)});
      }
    });

    return leituras;
  }

  // ========== MÉTODOS AUXILIARES ==========

  String _calcularStatus(double porcentagem) {
    if (porcentagem > 75) return "Alto";
    if (porcentagem > 30) return "Médio";
    return "Baixo";
  }

  void _listarItens(String titulo, List<dynamic> lista) {
    print('\n--- $titulo ---');
    if (lista.isEmpty) {
      print('Nenhum item cadastrado');
    } else {
      for (var item in lista) {
        try {
          if (item is Empresa) {
            item.exibirDados();
          } else if (item is Local) {
            item.exibirDados();
          } else if (item is Tanque) {
            item.exibirDados();
          } else if (item is Dispositivo) {
            item.exibirDados();
          } else if (item is SensorUltrassonico) {
            item.exibirDados();
          } else if (item is Leitura) {
            item.exibirDados();
          } else if (item is Producao) {
            item.exibirDados();
          } else if (item is Usuario) {
            item.exibirDados();
          } else {
            print('Item: ${item.toString()}');
          }
        } catch (e) {
          print('Erro ao exibir item: $e');
        }
        print('');
      }
    }
  }

  // ========== MÉTODOS DE CADASTRO ==========

  void cadastrarEmpresa() {
    try {
      stdout.write('ID: ');
      final id = int.parse(stdin.readLineSync()!);
      stdout.write('Nome: ');
      final nome = stdin.readLineSync()!;
      stdout.write('CNPJ: ');
      final cnpj = stdin.readLineSync()!;

      _empresas.add(Empresa(id, nome, cnpj));
      print('✅ Empresa cadastrada!');
    } catch (e) {
      print('❌ Erro ao cadastrar empresa: $e');
    }
  }

  void cadastrarLocal() {
    try {
      stdout.write('ID: ');
      final id = int.parse(stdin.readLineSync()!);
      stdout.write('Nome: ');
      final nome = stdin.readLineSync()!;
      stdout.write('Referência: ');
      final referencia = stdin.readLineSync()!;

      _locais.add(Local(id, nome, referencia));
      print('✅ Local cadastrado!');
    } catch (e) {
      print('❌ Erro ao cadastrar local: $e');
    }
  }

  void cadastrarTanque() {
    try {
      stdout.write('ID: ');
      final id = int.parse(stdin.readLineSync()!);
      stdout.write('Altura (m): ');
      final altura = double.parse(stdin.readLineSync()!);
      stdout.write('Volume Máx (m³): ');
      final volMax = double.parse(stdin.readLineSync()!);
      stdout.write('Volume Atual (m³): ');
      final volAtual = double.parse(stdin.readLineSync()!);

      _tanques.add(Tanque(id, altura, volMax, volAtual));
      print('✅ Tanque cadastrado!');
    } catch (e) {
      print('❌ Erro ao cadastrar tanque: $e');
    }
  }

  void cadastrarDispositivo() {
    try {
      stdout.write('ID: ');
      final id = int.parse(stdin.readLineSync()!);
      stdout.write('Modelo: ');
      final modelo = stdin.readLineSync()!;
      stdout.write('Status: ');
      final status = stdin.readLineSync()!;

      _dispositivos.add(Dispositivo(id, modelo, status));
      print('✅ Dispositivo cadastrado!');
    } catch (e) {
      print('❌ Erro ao cadastrar dispositivo: $e');
    }
  }

  void cadastrarSensor() {
    try {
      stdout.write('ID: ');
      final id = int.parse(stdin.readLineSync()!);
      stdout.write('Tipo: ');
      final tipo = stdin.readLineSync()!;
      stdout.write('Unidade: ');
      final unidade = stdin.readLineSync()!;

      _sensores.add(SensorUltrassonico(id, tipo, unidade));
      print('✅ Sensor cadastrado!');
    } catch (e) {
      print('❌ Erro ao cadastrar sensor: $e');
    }
  }

  void cadastrarUsuario() {
    try {
      print('\n--- CADASTRAR USUÁRIO ---');
      stdout.write('ID: ');
      final id = int.parse(stdin.readLineSync()!);
      stdout.write('Nome: ');
      final nome = stdin.readLineSync()!;
      stdout.write('Email: ');
      final email = stdin.readLineSync()!;
      stdout.write('Senha: ');
      final senha = stdin.readLineSync()!;

      print('\nPerfis disponíveis:');
      for (int i = 0; i < PerfilUsuario.todos.length; i++) {
        print('${i + 1} - ${PerfilUsuario.todos[i]}');
      }
      stdout.write('Escolha o perfil (1-${PerfilUsuario.todos.length}): ');
      final perfilIndex = int.parse(stdin.readLineSync()!) - 1;

      if (perfilIndex < 0 || perfilIndex >= PerfilUsuario.todos.length) {
        throw ArgumentError('Perfil inválido');
      }

      final perfil = PerfilUsuario.todos[perfilIndex];
      final usuario = Usuario.criarUsuario(
        id: id,
        nome: nome,
        email: email,
        senha: senha,
        perfil: perfil,
      );

      _usuarios.add(usuario);
      print('✅ Usuário cadastrado com perfil $perfil!');
    } catch (e) {
      print('❌ Erro ao cadastrar usuário: $e');
    }
  }

  // ========== MÉTODOS FIREBASE ==========

  Future<void> visualizarUltimaLeitura() async {
    print('\n📊 BUSCANDO ÚLTIMA LEITURA DO TANKSENSE...');

    try {
      final ultimaLeituraData = await Menu.getUltimaLeitura();

      if (ultimaLeituraData == null) {
        print('❌ Nenhuma leitura encontrada no Firebase');
        return;
      }

      final leitura = Leitura.fromFirebase(ultimaLeituraData, 'ultima');
      print('\n🔄 DADOS EM TEMPO REAL - TANKSENSE_ENTREGA06');
      print('═' * 50);
      leitura.exibirDados();
      print('═' * 50);
    } catch (e) {
      print('❌ Erro ao buscar última leitura: $e');
    }
  }

  Future<void> visualizarUltimas10Leituras() async {
    print('\n📊 BUSCANDO ÚLTIMAS 10 LEITURAS DO TANKSENSE...');

    try {
      final leiturasData = await Menu.getUltimas10Leituras();

      if (leiturasData.isEmpty) {
        print('❌ Nenhuma leitura encontrada no Firebase');
        return;
      }

      print('\n📈 HISTÓRICO - ÚLTIMAS ${leiturasData.length} LEITURAS');
      print('═' * 60);

      for (int i = 0; i < leiturasData.length; i++) {
        final data = leiturasData[i];
        final leitura = Leitura.fromFirebase(data, data['id'] ?? i.toString());

        print('📋 Leitura ${i + 1}');
        leitura.exibirDados();
        if (i < leiturasData.length - 1) print('─' * 40);
      }
      print('═' * 60);
      print('📊 Total de leituras: ${leiturasData.length}');
    } catch (e) {
      print('❌ Erro ao buscar leituras: $e');
    }
  }

  Future<void> visualizarProducao() async {
    print('\n🏭 CALCULANDO PRODUÇÃO BASEADA NAS LEITURAS...');

    try {
      final todasLeituras = await Menu.getTodasLeituras();

      if (todasLeituras.isEmpty) {
        print('❌ Nenhuma leitura encontrada para cálculo de produção');
        return;
      }

      double producaoTotal = 0.0;
      int leiturasComVariacao = 0;

      todasLeituras.sort((a, b) {
        final timestampA = a['timestamp'] ?? '';
        final timestampB = b['timestamp'] ?? '';
        return timestampA.compareTo(timestampB);
      });

      for (int i = 1; i < todasLeituras.length; i++) {
        final leituraAnterior = todasLeituras[i - 1];
        final leituraAtual = todasLeituras[i];

        final nivelAnterior = (leituraAnterior['nivel_cm'] ?? 0.0).toDouble();
        final nivelAtual = (leituraAtual['nivel_cm'] ?? 0.0).toDouble();

        if (nivelAtual < nivelAnterior) {
          final variacao = nivelAnterior - nivelAtual;
          producaoTotal += variacao;
          leiturasComVariacao++;
        }
      }

      print('\n🏭 RELATÓRIO DE PRODUÇÃO - TANKSENSE_ENTREGA06');
      print('═' * 50);
      print('📊 Total de leituras analisadas: ${todasLeituras.length}');
      print('🔄 Leituras com variação: $leiturasComVariacao');
      print(
          '📦 Produção total estimada: ${producaoTotal.toStringAsFixed(2)} cm³');
      print(
          '📈 Média por variação: ${leiturasComVariacao > 0 ? (producaoTotal / leiturasComVariacao).toStringAsFixed(2) : 0} cm³');

      if (producaoTotal > 0) {
        final producao = Producao(
          _producoes.length + 1,
          producaoTotal,
          DateTime.now(),
        );
        _producoes.add(producao);
        print('\n✅ Produção registrada no sistema!');
      }

      print('═' * 50);
    } catch (e) {
      print('❌ Erro ao calcular produção: $e');
    }
  }

  Future<void> testarConexaoFirebase() async {
    print('\n🧪 TESTANDO CONEXÃO COM FIREBASE...');

    try {
      final testData = await Menu.getUltimaLeitura();
      if (testData != null) {
        print('✅ Conexão com Firebase OK!');
      } else {
        print('❌ Falha na conexão com Firebase');
      }
    } catch (e) {
      print('❌ Erro no teste de conexão: $e');
    }
  }

  // ========== MÉTODOS BANCO DE DADOS ==========

  void configurarBancoDados() {
    print('\n🔧 CONFIGURAR BANCO DE DADOS');
    print('─' * 30);

    try {
      stdout.write('📍 Host (ex: localhost): ');
      final host = stdin.readLineSync() ?? 'localhost';

      stdout.write('🚪 Porta (ex: 3306): ');
      final porta = int.parse(stdin.readLineSync() ?? '3306');

      stdout.write('👤 Usuário (ex: root): ');
      final usuario = stdin.readLineSync() ?? 'root';

      stdout.write('🔑 Senha: ');
      final senha = stdin.readLineSync() ?? '';

      stdout.write('🗃️  Nome do Database (ex: tanksense): ');
      final dbName = stdin.readLineSync() ?? 'tanksense';

      _dbConfig = DatabaseConfig(
        host: host,
        porta: porta,
        usuario: usuario,
        senha: senha,
        dbName: dbName,
      );

      _dbConnection = DatabaseConnection(_dbConfig!);

      print('\n✅ Configuração salva!');
      _dbConfig!.exibirConfig();
    } catch (e) {
      print('❌ Erro na configuração: $e');
    }
  }

  Future<void> conectarBancoDados() async {
    if (_dbConfig == null) {
      print('❌ Configure o banco de dados primeiro!');
      return;
    }

    print('\n🔗 CONECTANDO AO BANCO DE DADOS...');
    _dbConectado = await _dbConnection!.connect();

    if (_dbConectado) {
      print('✅ Conectado com sucesso ao banco de dados!');
    } else {
      print('❌ Falha na conexão com o banco de dados');
    }
  }

  void desconectarBancoDados() async {
    if (_dbConnection != null && _dbConectado) {
      await _dbConnection!.close();
      _dbConectado = false;
      print('🔌 Desconectado do banco de dados');
    } else {
      print('ℹ️  Nenhuma conexão ativa para desconectar');
    }
  }

  void exibirStatusBanco() {
    print('\n📊 STATUS DO BANCO DE DADOS');
    print('─' * 25);

    if (_dbConfig == null) {
      print('❌ Banco não configurado');
      return;
    }

    _dbConfig!.exibirConfig();
    print('🔌 Status: ${_dbConectado ? '✅ Conectado' : '❌ Desconectado'}');
  }

  Future<void> sincronizarFirebaseParaMySQL() async {
    if (!_dbConectado) {
      print('❌ Conecte ao banco de dados primeiro!');
      return;
    }

    print('\n🔄 SINCRONIZANDO FIREBASE → MYSQL');
    print('═' * 35);

    try {
      final leiturasFirebase = await Menu.getTodasLeituras();

      if (leiturasFirebase.isEmpty) {
        print('📭 Nenhuma leitura encontrada no Firebase');
        return;
      }

      print('📥 Encontradas ${leiturasFirebase.length} leituras no Firebase');
      print('💾 Iniciando sincronização...');

      int sincronizadas = 0;
      for (final data in leiturasFirebase) {
        final leitura =
            Leitura.fromFirebase(data, data['id'] ?? 'sync_$sincronizadas');
        await _dbConnection!.salvarLeitura(leitura as dynamic);
        sincronizadas++;

        if (sincronizadas % 5 == 0) {
          print(
              '   📦 $sincronizadas/${leiturasFirebase.length} leituras processadas...');
        }
      }

      print('\n✅ Sincronização concluída!');
      print('   📊 Total de leituras sincronizadas: $sincronizadas');
    } catch (e) {
      print('❌ Erro na sincronização: $e');
    }
  }

  Future<void> backupDadosLocais() async {
    if (!_dbConectado) {
      print('❌ Conecte ao banco de dados primeiro!');
      return;
    }

    print('\n💾 FAZENDO BACKUP DOS DADOS LOCAIS');
    print('═' * 35);

    try {
      int totalBackup = 0;

      // Backup de empresas
      for (final empresa in _empresas) {
        print('💼 Backup empresa: ${empresa.nome}');
        totalBackup++;
      }

      // Backup de locais
      for (final local in _locais) {
        print('🏠 Backup local: ${local.nome}');
        totalBackup++;
      }

      // Backup de leituras
      for (final leitura in _leituras) {
        await _dbConnection!.salvarLeitura(leitura as dynamic);
        totalBackup++;
      }

      print('\n✅ Backup concluído!');
      print('   📦 Total de registros backup: $totalBackup');
    } catch (e) {
      print('❌ Erro no backup: $e');
    }
  }

  // ========== OUTROS MÉTODOS ==========

  void listarTodosDados() {
    print('\n${'═' * 60}');
    print('📋 LISTAGEM COMPLETA - TANKSENSE_ENTREGA06');
    print('═' * 60);

    _listarItens('🏢 EMPRESAS', _empresas);
    _listarItens('🏠 LOCAIS', _locais);
    _listarItens('🛢️ TANQUES', _tanques);
    _listarItens('⚙️ DISPOSITIVOS', _dispositivos);
    _listarItens('📡 SENSORES', _sensores);
    _listarItens('📊 LEITURAS', _leituras);
    _listarItens('🏭 PRODUÇÕES', _producoes);
    _listarItens('👤 USUÁRIOS', _usuarios);

    if (_dbConfig != null) {
      print('\n🗃️  CONFIGURAÇÃO DO BANCO:');
      _dbConfig!.exibirConfig();
      print('🔌 Status: ${_dbConectado ? '✅ Conectado' : '❌ Desconectado'}');
    }

    print('═' * 60);
  }

  void simularSistema() {
    print('\n=== SIMULAÇÃO DO SISTEMA ===');

    if (_tanques.isEmpty || _sensores.isEmpty) {
      print('⚠️ Cadastre um tanque e um sensor primeiro');
      return;
    }

    print('Simulando 3 leituras...');
    for (int i = 1; i <= 3; i++) {
      final distancia = _sensores.first.coletarDado();
      final nivel = 200 - distancia;
      final porcentagem = (nivel / 200) * 100;

      final leitura = Leitura(
        _leituras.length + 1,
        DateTime.now().add(Duration(seconds: i * 5)),
        distancia,
        nivel,
        porcentagem,
        _calcularStatus(porcentagem),
      );

      _leituras.add(leitura);
      leitura.exibirDados();

      if (porcentagem < 30) {
        print('⚠️ ALERTA: Nível Baixo!');
      }
    }
    print('✅ Simulação concluída!');
  }

  // ========== MÉTODO PRINCIPAL ==========

  void executar() {
    print("\n");
    print('''
╔════════════════════════════════════╗
║      SISTEMA DE MONITORAMENTO      ║
║         🛢️  TANKSENSE 🛢️             ║
╚════════════════════════════════════╝
  ''');

    bool executando = true;

    while (executando) {
      print('═' * 50);
      print('🔧 MENU PRINCIPAL - TANKSENSE');
      print('═' * 50);
      print('1️⃣  - 🏢 Cadastrar Empresa');
      print('2️⃣  - 🏠 Cadastrar Local');
      print('3️⃣  - 🛢️  Cadastrar Tanque');
      print('4️⃣  - ⚙️  Cadastrar Dispositivo');
      print('5️⃣  - 📡 Cadastrar Sensor');
      print('6️⃣  - 👤 Cadastrar Usuário');
      print('═' * 50);
      print('📊 CONSULTAS EM TEMPO REAL - FIREBASE');
      print('7️⃣  - 🔄 Visualizar Última Leitura');
      print('8️⃣  - 📈 Visualizar Últimas 10 Leituras');
      print('9️⃣  - 🏭 Visualizar Produção');
      print('🔟 - 🧪 Testar Conexão Firebase');
      print('═' * 50);
      print('🗃️  BANCO DE DADOS MYSQL');
      print('1️⃣1️⃣ - ⚙️  Configurar Banco');
      print('1️⃣2️⃣ - 🔗 Conectar Banco');
      print('1️⃣3️⃣ - 🔌 Desconectar Banco');
      print('1️⃣4️⃣ - 📊 Status do Banco');
      print('1️⃣5️⃣ - 🔄 Sincronizar Firebase→MySQL');
      print('1️⃣6️⃣ - 💾 Backup Dados Locais');
      print('═' * 50);
      print('🔧 OUTRAS OPÇÕES');
      print('1️⃣7️⃣ - 📋 Listar Todos os Dados Locais');
      print('1️⃣8️⃣ - 🧪 Simular Sistema');
      print('0️⃣  - ❌ Sair');
      print('─' * 50);

      stdout.write('👉 Escolha: ');
      final opcao = stdin.readLineSync();

      switch (opcao) {
        case '1':
          cadastrarEmpresa();
          break;
        case '2':
          cadastrarLocal();
          break;
        case '3':
          cadastrarTanque();
          break;
        case '4':
          cadastrarDispositivo();
          break;
        case '5':
          cadastrarSensor();
          break;
        case '6':
          cadastrarUsuario();
          break;
        case '7':
          visualizarUltimaLeitura();
          break;
        case '8':
          visualizarUltimas10Leituras();
          break;
        case '9':
          visualizarProducao();
          break;
        case '10':
          testarConexaoFirebase();
          break;
        case '11':
          configurarBancoDados();
          break;
        case '12':
          conectarBancoDados();
          break;
        case '13':
          desconectarBancoDados();
          break;
        case '14':
          exibirStatusBanco();
          break;
        case '15':
          sincronizarFirebaseParaMySQL();
          break;
        case '16':
          backupDadosLocais();
          break;
        case '17':
          listarTodosDados();
          break;
        case '18':
          simularSistema();
          break;
        case '0':
          desconectarBancoDados();
          print('\n👋 Encerrando Tanksense_Entrega06...');
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

    print('\n🛢️ tanksense_entrega06 finalizado. Até logo!');
  }
}
