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
  final DatabaseConnection dbConnection;
  bool _conectado = false;

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

  // ========== MÉTODOS DE CONEXÃO ==========
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
  }

  Future<void> _carregarDadosDoBanco() async {
    if (!_conectado) return;

    try {
      print('\n📥 CARREGANDO DADOS DO BANCO...');
      // Aqui você pode carregar dados existentes se quiser
      print('✅ Sistema pronto para uso!');
    } catch (e) {
      print('❌ Erro ao carregar dados do banco: $e');
    }
  }

  // ========== MÉTODOS DE CADASTRO ==========
  Future<void> _cadastrarEmpresa() async {
    try {
      print('\n🏢 CADASTRAR EMPRESA');

      String nome;
      do {
        stdout.write('Nome: ');
        nome = stdin.readLineSync()?.trim() ?? '';
        if (nome.isEmpty) {
          print('❌ Nome é obrigatório!');
        }
      } while (nome.isEmpty);

      String cnpj;
      do {
        stdout.write('CNPJ: ');
        cnpj = stdin.readLineSync()?.trim() ?? '';
        if (cnpj.isEmpty) {
          print('❌ CNPJ é obrigatório!');
        }
      } while (cnpj.isEmpty);

      final empresa = Empresa(0, nome, cnpj);
      _empresas.add(empresa);

      if (_conectado) {
        try {
          await dbConnection.connection!.query(
            'INSERT INTO empresas (nome, cnpj) VALUES (?, ?)',
            [empresa.nome, empresa.cnpj],
          );
          print('💾 Salvo no banco de dados!');
        } catch (e) {
          print('❌ Erro ao salvar no banco: $e');
        }
      }

      print('✅ Empresa cadastrada com sucesso!');
      empresa.exibirDados();
    } catch (e) {
      print('❌ Erro ao cadastrar empresa: $e');
    }
  }

  Future<void> _cadastrarLocal() async {
    try {
      print('\n🏠 CADASTRAR LOCAL');

      String nome;
      do {
        stdout.write('Nome: ');
        nome = stdin.readLineSync()?.trim() ?? '';
        if (nome.isEmpty) {
          print('❌ Nome é obrigatório!');
        }
      } while (nome.isEmpty);

      String referencia;
      do {
        stdout.write('Referência: ');
        referencia = stdin.readLineSync()?.trim() ?? '';
        if (referencia.isEmpty) {
          print('❌ Referência é obrigatória!');
        }
      } while (referencia.isEmpty);

      final local = Local(0, nome, referencia);
      _locais.add(local);

      if (_conectado) {
        try {
          await dbConnection.connection!.query(
            'INSERT INTO locais (nome, referencia) VALUES (?, ?)',
            [local.nome, local.referencia],
          );
          print('💾 Salvo no banco de dados!');
        } catch (e) {
          print('❌ Erro ao salvar no banco: $e');
        }
      }

      print('✅ Local cadastrado com sucesso!');
      local.exibirDados();
    } catch (e) {
      print('❌ Erro ao cadastrar local: $e');
    }
  }

  Future<void> _cadastrarTanque() async {
    try {
      print('\n🛢️ CADASTRAR TANQUE');

      double? altura;
      do {
        stdout.write('Altura (m): ');
        final input = stdin.readLineSync()?.trim() ?? '';
        altura = double.tryParse(input);
        if (altura == null || altura <= 0) {
          print('❌ Altura deve ser um número positivo!');
        }
      } while (altura == null);

      double? volumeMax;
      do {
        stdout.write('Volume Máximo (m³): ');
        final input = stdin.readLineSync()?.trim() ?? '';
        volumeMax = double.tryParse(input);
        if (volumeMax == null || volumeMax <= 0) {
          print('❌ Volume máximo deve ser um número positivo!');
        }
      } while (volumeMax == null);

      double? volumeAtual;
      do {
        stdout.write('Volume Atual (m³): ');
        final input = stdin.readLineSync()?.trim() ?? '';
        volumeAtual = double.tryParse(input);
        if (volumeAtual == null || volumeAtual < 0 || volumeAtual > volumeMax) {
          print('❌ Volume atual deve estar entre 0 e $volumeMax!');
        }
      } while (volumeAtual == null);

      final tanque = Tanque(0, altura, volumeMax, volumeAtual);
      _tanques.add(tanque);

      if (_conectado) {
        try {
          await dbConnection.connection!.query(
            'INSERT INTO tanques (altura, volume_max, volume_atual) VALUES (?, ?, ?)',
            [tanque.altura, tanque.volumeMax, tanque.volumeAtual],
          );
          print('💾 Salvo no banco de dados!');
        } catch (e) {
          print('❌ Erro ao salvar no banco: $e');
        }
      }

      print('✅ Tanque cadastrado com sucesso!');
      tanque.exibirDados();
    } catch (e) {
      print('❌ Erro ao cadastrar tanque: $e');
    }
  }

  Future<void> _cadastrarDispositivo() async {
    try {
      print('\n⚙️ CADASTRAR DISPOSITIVO');

      String modelo;
      do {
        stdout.write('Modelo: ');
        modelo = stdin.readLineSync()?.trim() ?? '';
        if (modelo.isEmpty) {
          print('❌ Modelo é obrigatório!');
        }
      } while (modelo.isEmpty);

      String status;
      do {
        stdout.write('Status: ');
        status = stdin.readLineSync()?.trim() ?? '';
        if (status.isEmpty) {
          print('❌ Status é obrigatório!');
        }
      } while (status.isEmpty);

      final dispositivo = Dispositivo(0, modelo, status);
      _dispositivos.add(dispositivo);

      if (_conectado) {
        try {
          await dbConnection.connection!.query(
            'INSERT INTO dispositivos (modelo, status) VALUES (?, ?)',
            [dispositivo.modelo, dispositivo.status],
          );
          print('💾 Salvo no banco de dados!');
        } catch (e) {
          print('❌ Erro ao salvar no banco: $e');
        }
      }

      print('✅ Dispositivo cadastrado com sucesso!');
      dispositivo.exibirDados();
    } catch (e) {
      print('❌ Erro ao cadastrar dispositivo: $e');
    }
  }

  Future<void> _cadastrarSensor() async {
    try {
      print('\n📡 CADASTRAR SENSOR');

      String tipo;
      do {
        stdout.write('Tipo: ');
        tipo = stdin.readLineSync()?.trim() ?? '';
        if (tipo.isEmpty) {
          print('❌ Tipo é obrigatório!');
        }
      } while (tipo.isEmpty);

      String unidade;
      do {
        stdout.write('Unidade: ');
        unidade = stdin.readLineSync()?.trim() ?? '';
        if (unidade.isEmpty) {
          print('❌ Unidade é obrigatória!');
        }
      } while (unidade.isEmpty);

      final sensor = SensorUltrassonico(0, tipo, unidade);
      _sensores.add(sensor);

      if (_conectado) {
        try {
          await dbConnection.connection!.query(
            'INSERT INTO sensores (tipo, unidade_medida) VALUES (?, ?)',
            [sensor.tipo, sensor.unidadeMedida],
          );
          print('💾 Salvo no banco de dados!');
        } catch (e) {
          print('❌ Erro ao salvar no banco: $e');
        }
      }

      print('✅ Sensor cadastrado com sucesso!');
      sensor.exibirDados();
    } catch (e) {
      print('❌ Erro ao cadastrar sensor: $e');
    }
  }

  Future<void> _cadastrarUsuario() async {
    try {
      print('\n👤 CADASTRAR USUÁRIO');

      String nome;
      do {
        stdout.write('Nome: ');
        nome = stdin.readLineSync()?.trim() ?? '';
        if (nome.isEmpty) {
          print('❌ Nome é obrigatório!');
        }
      } while (nome.isEmpty);

      String email;
      bool emailValido = false;
      do {
        stdout.write('Email: ');
        email = stdin.readLineSync()?.trim() ?? '';

        if (email.isEmpty) {
          print('❌ Email é obrigatório!');
          continue;
        }

        if (!email.contains('@') || !email.contains('.')) {
          print('❌ Email inválido! Deve conter @ e .');
          continue;
        }

        emailValido = true;
      } while (!emailValido);

      String senha;
      do {
        stdout.write('Senha: ');
        senha = stdin.readLineSync()?.trim() ?? '';
        if (senha.isEmpty) {
          print('❌ Senha é obrigatória!');
        }
      } while (senha.isEmpty);

      String perfil;
      do {
        print('\nPerfis disponíveis:');
        for (int i = 0; i < PerfilUsuario.todos.length; i++) {
          print('${i + 1} - ${PerfilUsuario.todos[i]}');
        }
        stdout.write('Escolha o perfil (1-${PerfilUsuario.todos.length}): ');
        final perfilInput = stdin.readLineSync()?.trim() ?? '';
        final perfilIndex = int.tryParse(perfilInput) ?? -1;

        if (perfilIndex < 1 || perfilIndex > PerfilUsuario.todos.length) {
          print(
              '❌ Perfil inválido! Escolha entre 1 e ${PerfilUsuario.todos.length}');
          perfil = '';
        } else {
          perfil = PerfilUsuario.todos[perfilIndex - 1];
        }
      } while (perfil.isEmpty);

      final usuario = Usuario.criarUsuario(
        id: 0,
        nome: nome,
        email: email,
        senha: senha,
        perfil: perfil,
      );

      _usuarios.add(usuario);

      if (_conectado) {
        try {
          await dbConnection.connection!.query(
            'INSERT INTO usuarios (nome, email, senha, perfil, data_criacao, ultimo_login) VALUES (?, ?, ?, ?, ?, ?)',
            [
              usuario.nome,
              usuario.email,
              usuario.senhaLogin,
              usuario.perfil,
              usuario.dataCriacao, // Já está em UTC
              usuario.ultimoLogin // Já está em UTC
            ],
          );
          print('💾 Salvo no banco de dados!');
        } catch (e) {
          print('❌ Erro ao salvar no banco: $e');
        }
      }

      print('✅ Usuário cadastrado com perfil $perfil!');
      usuario.exibirDados();
    } catch (e) {
      print('❌ Erro ao cadastrar usuário: $e');
    }
  }

  // ========== MÉTODO PRINCIPAL ==========
  Future<void> executar() async {
    print("\n");
    print('╔════════════════════════════════════╗');
    print('║      SISTEMA DE MONITORAMENTO      ║');
    print('║         🛢️  TANKSENSE 🛢️             ║');
    print('╚════════════════════════════════════╝');

    if (_conectado) {
      print('✅ CONECTADO AO BANCO DE DADOS');
    } else {
      print('❌ SEM CONEXÃO COM BANCO - Dados apenas locais');
    }

    bool executando = true;

    while (executando) {
      print('\n' + '═' * 50);
      print('🔧 MENU PRINCIPAL - TANKSENSE');
      print('═' * 50);
      print('1️⃣  - 🏢 Cadastrar Empresa');
      print('2️⃣  - 🏠 Cadastrar Local');
      print('3️⃣  - 🛢️  Cadastrar Tanque');
      print('4️⃣  - ⚙️  Cadastrar Dispositivo');
      print('5️⃣  - 📡 Cadastrar Sensor');
      print('6️⃣  - 👤 Cadastrar Usuário');
      print('═' * 50);
      print('0️⃣  - ❌ Sair');
      print('─' * 50);

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
          await _cadastrarTanque();
          break;
        case '4':
          await _cadastrarDispositivo();
          break;
        case '5':
          await _cadastrarSensor();
          break;
        case '6':
          await _cadastrarUsuario();
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
        _aguardarEnter();
      }
    }

    print('\n🛢️ Tanksense finalizado. Até logo!');
  }

  void _aguardarEnter() {
    print('\n⏎ Pressione Enter para continuar...');
    stdin.readLineSync();
  }
}
