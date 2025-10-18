// Producao.dart
class Producao {
  final int id;
  final int tanqueId;
  final DateTime dataHora;
  final double quantidade;
  final String tipoProducao;
  final String? observacoes;

  Producao({
    required this.id,
    required this.tanqueId,
    required this.dataHora,
    required this.quantidade,
    required this.tipoProducao,
    this.observacoes,
  });

  // Métodos getters
  int get getId => id;
  int get getTanqueId => tanqueId;
  DateTime get getDataHora => dataHora;
  double get getQuantidade => quantidade;
  String get getTipoProducao => tipoProducao;
  String? get getObservacoes => observacoes;

  // Método para exibir dados
  void exibirDados() {
    print('🏭 DADOS DA PRODUÇÃO');
    print('─' * 30);
    print('ID: $id');
    print('Tanque ID: $tanqueId');
    print('Data/Hora: ${_formatarDataHora(dataHora)}');
    print('Quantidade: ${quantidade}L');
    print('Tipo: $tipoProducao');
    if (observacoes != null && observacoes!.isNotEmpty) {
      print('Observações: $observacoes');
    }
    print('─' * 30);
  }

  // Método privado para formatar data/hora
  String _formatarDataHora(DateTime dataHora) {
    return '${dataHora.day}/${dataHora.month}/${dataHora.year} ${dataHora.hour}:${dataHora.minute.toString().padLeft(2, '0')}';
  }

  // Método para calcular produção por hora
  double calcularProducaoPorHora() {
    // Simulação - na prática, precisaria de mais dados temporais
    return quantidade * 0.8; // Fator de conversão exemplo
  }

  // Método para verificar se é produção válida
  bool producaoValida() {
    return quantidade > 0 &&
        tipoProducao.isNotEmpty &&
        dataHora.isBefore(DateTime.now());
  }

  // Método para obter resumo da produção
  String obterResumo() {
    return 'Produção $tipoProducao: ${quantidade}L em ${_formatarDataHora(dataHora)}';
  }

  // Método para atualizar observações
  void atualizarObservacoes(String novasObservacoes) {
    print('📝 Observações atualizadas para: $novasObservacoes');
  }

  // Método toMap para conversão
  Map<String, dynamic> toMap() {
    return {
      'idProducao': id,
      'tanque_idTanque': tanqueId,
      'dataHora': dataHora.toIso8601String(),
      'quantidade': quantidade,
      'tipoProducao': tipoProducao,
      'observacoes': observacoes,
    };
  }

  @override
  String toString() {
    return 'Producao{id: $id, tanqueId: $tanqueId, quantidade: ${quantidade}L, tipo: $tipoProducao, data: ${_formatarDataHora(dataHora)}}';
  }
}
