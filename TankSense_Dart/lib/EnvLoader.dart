// lib/EnvLoader.dart
import 'dart:io';

class EnvLoader {
  static Map<String, String> _envVars = {};

  static Future<void> load() async {
    try {
      final file = File('.env');
      if (await file.exists()) {
        final contents = await file.readAsString();
        _envVars = _parseEnvContents(contents);
        print('✅ Arquivo .env carregado com sucesso');
      } else {
        print('⚠️  Arquivo .env não encontrado, usando valores padrão');
        _setDefaultValues();
      }
    } catch (e) {
      print('❌ Erro ao carregar .env: $e');
      _setDefaultValues();
    }
  }

  static Map<String, String> _parseEnvContents(String contents) {
    final vars = <String, String>{};
    final lines = contents.split('\n');

    for (final line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.isEmpty || trimmedLine.startsWith('#')) continue;

      final parts = trimmedLine.split('=');
      if (parts.length >= 2) {
        final key = parts[0].trim();
        final value = parts.sublist(1).join('=').trim();
        vars[key] = value;
      }
    }

    return vars;
  }

  static void _setDefaultValues() {
    _envVars = {
      'DB_HOST': 'localhost',
      'DB_PORT': '3306',
      'DB_USER': 'root',
      'DB_PASSWORD': '',
      'DB_NAME': 'tanksense',
      'FIREBASE_BASE_URL': 'tanksense---v2-default-rtdb.firebaseio.com',
      'FIREBASE_AUTH_TOKEN': 'XALK5M3Yuc7jQgS62iDXpnAKvsBJEWKij0hR02tx',
    };
  }

  static String get(String key, [String defaultValue = '']) {
    return _envVars[key] ?? defaultValue;
  }

  static int getInt(String key, [int defaultValue = 0]) {
    return int.tryParse(_envVars[key] ?? '') ?? defaultValue;
  }
}
