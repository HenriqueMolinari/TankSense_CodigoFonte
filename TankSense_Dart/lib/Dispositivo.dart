// Dispositivo.dart
class Dispositivo {
  final int id;
  final String modelo;
  final String status;

  Dispositivo(this.id, this.modelo, this.status);

  // Métodos getters
  int get getId => id;
  String get getModelo => modelo;
  String get getStatus => status;

  // Método para exibir dados
  void exibirDados() {
    print('⚙️  DADOS DO DISPOSITIVO');
    print('─' * 30);
    print('ID: $id');
    print('Modelo: $modelo');
    print('Status: $status');
    print('─' * 30);
  }

  // Método para atualizar status
  void atualizarStatus(String novoStatus) {
    print('Status atualizado de $status para $novoStatus');
  }

  // Método para verificar se está ativo
  bool estaAtivo() {
    return status.toLowerCase() == 'ativo';
  }

  // Método toMap para conversão
  Map<String, dynamic> toMap() {
    return {
      'idDispositivo': id,
      'modelo': modelo,
      'status': status,
    };
  }

  @override
  String toString() {
    return 'Dispositivo{id: $id, modelo: $modelo, status: $status}';
  }
}
