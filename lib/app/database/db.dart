import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqlite_api.dart';

class Db {
  // Cpnstrutor com acesso privado
  Db._();
  //criar instancia de DB
  static final Db instance = Db._();
  //Instancia de SQlite
  static Database? _dataBase;

  Future<Database> get database async {
    if (_dataBase != null) {
      return _dataBase!;
    }

    return await _initDatabase();
  }

  Future<Database> _initDatabase() async {
    return await openDatabase(
      join(await getDatabasesPath(), 'cripto.db'),
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(db, versao) async {
    await db.execute(_conta);
    await db.execute(_carteira);
    await db.execute(_historico);
    await db.execute(_moeda);
    await db.insert('conta', {'saldo': 0});
  }

  String get _conta => '''
    CREATE TABLE conta (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      saldo REAL 
    );
''';

  String get _carteira => '''
    CREATE TABLE carteira (
      sigla TEXT PRIMARY KEY,
      moeda TEXT,
      quantidade TEXT
    );
''';

  String get _historico => '''
    CREATE TABLE historico (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      data_operacao INT,
      tipo_operacao TEXT,
      moeda TEXT,
      sigla TEXT,
      valor REAL,
      quantidade TEXT
    );
''';

  String get _moeda => '''
    CREATE TABLE moeda (
      baseId TEXT,
      icone TEXT,
      nome TEXT,
      sigla TEXT,
      preco REAL,
      timestamp INTEGER,
      mudancaHora REAL,
      mudancaDia REAL,
      mudancaSemana REAL,
      mudancaMes REAL,
      mudancaAno REAL,
      mudancaPeriodoTotal REAL
    );
''';
}
