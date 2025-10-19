# 🛢️ TankSense - Sistema de Monitoramento de Tanques

## 📋 Sobre o Projeto

O **TankSense** é um sistema completo de monitoramento e gestão de tanques industriais que combina leituras em tempo real do Firebase com armazenamento robusto em MySQL. Desenvolvido em Dart, o sistema oferece controle total sobre empresas, locais, tanques, dispositivos e sensores.

### 🎯 Funcionalidades Principais

- **📊 Monitoramento em Tempo Real**: Leituras do Firebase atualizadas automaticamente
- **🏢 Gestão Completa**: Empresas, locais, tanques, dispositivos e sensores
- **📈 Cálculo de Produção**: Conversão automática de variações do tanque em metros de fio produzido
- **💾 Armazenamento Duplo**: Dados sincronizados entre Firebase e MySQL
- **👤 Controle de Usuários**: Sistema de perfis e autenticação

## 🚀 Como Executar o Projeto

### 📥 Pré-requisitos

1. **Dart SDK** (versão 2.19 ou superior)
2. **Banco de Dados MySQL** (versão 8.0 ou superior)
3. **Conta Firebase** com Realtime Database

### 🗄️ Configuração do Banco de Dados

**⚠️ IMPORTANTE**: Para executar o projeto, você precisa do banco de dados que está disponível no link abaixo:

🔗 **[CLIQUE AQUI PARA BAIXAR O BANCO DE DADOS](https://drive.google.com/drive/folders/1boGAz1gOadWonlMCtYqtITNkeIaC2rZ0?usp=sharing)**

Após baixar, importe o arquivo SQL no seu MySQL:

```sql
-- Exemplo de importação
mysql -u seu_usuario -p nome_do_banco < arquivo_backup.sql
```

### 🏃‍♂️ Executando a Aplicação

```bash
# Navegue até a pasta bin
cd bin

# Execute o projeto
dart run main.dart
```

## 🏗️ Estrutura do Banco de Dados

### 📊 Tabelas Principais

| Tabela | Descrição |
|--------|-----------|
| `empresa` | Cadastro de empresas |
| `local` | Locais vinculados às empresas |
| `tanque` | Tanques com volume e capacidade |
| `dispositivo` | Dispositivos de monitoramento |
| `sensor` | Sensores ultrassônicos |
| `leitura` | Leituras de nível dos tanques |
| `producao` | Produção calculada baseada nas leituras |
| `usuario` | Usuários do sistema |

### 🔗 Relacionamentos

```
Empresa (1) → (N) Local
Local (1) → (N) Tanque
Dispositivo (1) → (N) Sensor
Sensor (1) → (N) Leitura
Leitura → Produção (cálculo automático)
```

## 🎮 Menu do Sistema

### 📋 Cadastros
- `1` - 🏢 Cadastrar Empresa
- `2` - 🏠 Cadastrar Local  
- `3` - ⚙️ Cadastrar Dispositivo
- `4` - 📡 Cadastrar Sensor
- `5` - 🛢️ Cadastrar Tanque
- `6` - 👤 Cadastrar Usuário

### 🔍 Consultas
- `7` - 📊 Listar Todas as Entidades
- `8` - 🏢 Listar Empresas
- `9` - 🏠 Listar Locais
- `10` - ⚙️ Listar Dispositivos
- `11` - 📡 Listar Sensores
- `12` - 🛢️ Listar Tanques
- `13` - 👤 Listar Usuários

### 📈 Firebase & Produção
- `14` - 🔄 Visualizar Última Leitura
- `15` - 📈 Visualizar Últimas 10 Leituras
- `16` - 📊 Listar Todas as Leituras
- `17` - 📤 Enviar Leituras para MySQL
- `18` - 🏭 Calcular Produção
- `19` - 📋 Listar Todas as Produções
- `20` - 🚀 Enviar Produções para MySQL

## 🔥 Configuração do Firebase

### 📡 Estrutura dos Dados no Firebase

```json
{
  "leituras": {
    "leitura_001": {
      "timestamp": "2024-01-01T10:00:00Z",
      "distanciaCm": 45.2,
      "nivelCm": 154.8,
      "porcentagem": 65.5,
      "status": "Normal"
    }
  }
}
```

### ⚙️ Variáveis de Configuração

No código, configure as variáveis:

```dart
static const String _baseUrl = 'seu-projeto.firebaseio.com';
static const String _authToken = 'seu-token-de-autenticacao';
```

## 📈 Cálculo de Produção

### 🔢 Fórmula de Produção

O sistema calcula automaticamente a produção baseada nas variações do tanque:

```
Produção (metros) = Variação Percentual × 1 metro
```

**Exemplo**: 
- Leitura anterior: 80%
- Leitura atual: 75%
- Variação: 5%
- **Produção**: 5 metros de fio

### 🏭 Fluxo de Produção

1. **Leituras** são coletadas do Firebase
2. **Variações** são calculadas entre leituras consecutivas  
3. **Produção** é gerada automaticamente
4. **Dados** são armazenados no MySQL

## 🛠️ Tecnologias Utilizadas

| Tecnologia | Versão | Uso |
|------------|--------|-----|
| **Dart** | 2.19+ | Linguagem principal |
| **MySQL** | 8.0+ | Banco de dados relacional |
| **Firebase** | Realtime | Banco em tempo real |
| **mysql1** | ^0.20.0 | Driver MySQL para Dart |
| **http** | ^1.1.0 | Requisições HTTP para Firebase |

## 📁 Estrutura do Projeto

```
bin/
├── main.dart             
lib/
├── DatabaseConfig.dart
├── DatabaseConnection.dart         
├── Empresa.dart
├── Local.dart
├── Tanque.dart
├── Dispositivo.dart
├── SensorUltrassonico.dart
├── Leitura.dart
├── Producao.dart
├── Usuario.dart
└── Menu.dart              
```

## 🐛 Solução de Problemas

### ❌ Erros Comuns

1. **"Connection refused"**
   - Verifique se o MySQL está rodando
   - Confirme usuário e senha

2. **"Firebase authentication failed"**
   - Verifique o token de autenticação
   - Confirme a URL do Firebase

3. **"Unknown column" errors**
   - Importe o banco de dados correto do link do Drive

### 🔧 Comandos Úteis

```bash
# Verificar versão do Dart
dart --version

# Instalar dependências
dart pub get

# Executar em modo debug
dart run --enable-asserts main.dart
```

## 📞 Contato/Suporte

Henrique de O. Molinari (Desenvolvedor do Código)
E-mail: hhenrique.molinari@sou.unifeob.edu.br

Luiz Gustavo P. Diniz (Desenvolvedor do Banco de Dados)
E-mail: luiz.g.diniz@sou.unifeob.edu.br

Nicolas Victorio B. De Souza 
E-mail: nicolas.victorio@sou.unifeob.edu.br

Matteo Enrico F. Bonvento
E-mail: matteo.bonvento@sou.unifeob.edu.br

**Em caso de dúvidas ou problemas:**

*1. Verifique se o banco de dados foi importado corretamente*
*2. Confirme as configurações do Firebase*
*3. Execute `cd bin` e `dart run main.dart`*

---

**Desenvolvido com 💙 para o monitoramento inteligente de tanques**
