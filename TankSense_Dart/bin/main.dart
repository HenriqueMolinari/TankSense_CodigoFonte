import 'package:tanksense/DatabaseConfig.dart';
import 'package:tanksense/DatabaseConnection.dart';
import 'package:tanksense/menu.dart';

void main() async {
  final config = DatabaseConfig(
    host: 'localhost',
    porta: 3306,
    usuario: 'root',
    senha: '@#Hrk15072006',
    dbName: 'tanksense',
  );

  final db = DatabaseConnection(config);
  final menu = Menu(db);

  try {
    await menu.inicializar();
    await menu.executar();
  } catch (e) {
    print('❌ Erro fatal: $e');
  } finally {
    await db.close();
  }
}
