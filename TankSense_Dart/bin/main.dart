import 'package:TankSense_CodigoFonte/DatabaseConfig.dart';
import 'package:TankSense_CodigoFonte/DatabaseConnection.dart';
import 'package:TankSense_CodigoFonte/Menu.dart';

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
