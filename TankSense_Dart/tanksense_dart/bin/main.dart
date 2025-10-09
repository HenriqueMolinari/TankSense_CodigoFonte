import '../lib/Menu.dart';

void main() {
  try {
    final menu = Menu();
    menu.executar();
  } catch (e) {
    print('❌ Erro fatal: $e');
  }
}