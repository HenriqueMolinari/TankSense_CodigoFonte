// Tanque.dart
class Tanque {
  final int id;
  final double altura;
  final double volumeMax;
  double volumeAtual;

  Tanque(this.id, this.altura, this.volumeMax, this.volumeAtual);

  // Métodos getters
  int get getId => id;
  double get getAltura => altura;
  double get getVolumeMax => volumeMax;
  double get getVolumeAtual => volumeAtual;

  // Métodos setters
  set setVolumeAtual(double volume) {
    if (volume >= 0 && volume <= volumeMax) {
      volumeAtual = volume;
    } else {
      print('❌ Volume inválido! Deve estar entre 0 e $volumeMax');
    }
  }

  // Método para exibir dados
  void exibirDados() {
    print('🛢️  DADOS DO TANQUE');
    print('─' * 30);
    print('ID: $id');
    print('Altura: ${altura}m');
    print('Volume Máximo: ${volumeMax}L');
    print('Volume Atual: ${volumeAtual}L');
    print('Capacidade: ${calcularCapacidade().toStringAsFixed(1)}%');
    print('─' * 30);
  }

  // Método para calcular capacidade em porcentagem
  double calcularCapacidade() {
    return (volumeAtual / volumeMax) * 100;
  }

  // Método para adicionar volume
  void adicionarVolume(double volume) {
    if (volume > 0) {
      double novoVolume = volumeAtual + volume;
      if (novoVolume <= volumeMax) {
        volumeAtual = novoVolume;
        print('✅ Volume adicionado: ${volume}L');
      } else {
        print('❌ Volume excede a capacidade máxima!');
      }
    } else {
      print('❌ Volume deve ser positivo!');
    }
  }

  // Método para remover volume
  void removerVolume(double volume) {
    if (volume > 0) {
      if (volume <= volumeAtual) {
        volumeAtual -= volume;
        print('✅ Volume removido: ${volume}L');
      } else {
        print('❌ Volume insuficiente no tanque!');
      }
    } else {
      print('❌ Volume deve ser positivo!');
    }
  }

  // Método para verificar se está vazio
  bool estaVazio() {
    return volumeAtual == 0;
  }

  // Método para verificar se está cheio
  bool estaCheio() {
    return volumeAtual >= volumeMax;
  }

  // Método toMap para conversão
  Map<String, dynamic> toMap() {
    return {
      'idTanque': id,
      'altura': altura,
      'volumeMax': volumeMax,
      'volumeAtual': volumeAtual,
    };
  }

  @override
  String toString() {
    return 'Tanque{id: $id, altura: ${altura}m, volumeMax: ${volumeMax}L, volumeAtual: ${volumeAtual}L}';
  }
}
