import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cripto_wallet/app/common/models/moedas.dart';
import 'package:cripto_wallet/app/database/db.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:http/http.dart' as http;

class MoedasRepository extends ChangeNotifier {
  List<Moedas> _tabela = [];
  late Timer intervalo;

  List<Moedas> get tabela => _tabela;

  MoedasRepository() {
    _setupMoedasTable();
    _setupDadosTableMoeda();
    _readMoedasTable();
    _refreshPrecos();
  }

  _refreshPrecos() async {
    intervalo = Timer.periodic(const Duration(minutes: 5), (_) => checkPreco());
  }

  getHistoricoMoeda(Moedas moeda) async {
    final response = await http.get(
      Uri.parse(
        'https://api.coinbase.com/v2/assets/prices/${moeda.baseId}?base=BRL',
      ),
    );
    List<Map<String, dynamic>> preco = [];

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final Map<String, dynamic> moeda = json['data']['prices'];

      preco.add(moeda['hour']);
      preco.add(moeda['day']);
      preco.add(moeda['week']);
      preco.add(moeda['month']);
      preco.add(moeda['year']);
      preco.add(moeda['all']);
    }

    return preco;
  }

  checkPreco() async {
    String uri = 'https://api.coinbase.com/v2/assets/prices?base=BRL';
    final response = await http.get(Uri.parse(uri));

    var dolarAtual = await getDolarAtual();

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List<dynamic> moedas = json['data'];

      Database db = await Db.instance.database;
      Batch batch = db.batch();

      _tabela.forEach((atual) {
        moedas.forEach((novaMoeda) {
          if (atual.baseId == novaMoeda['base_id']) {
            final moeda = novaMoeda['prices'];
            final preco = moeda['latest_price'];
            final timestamp = DateTime.parse(preco['timestamp']);

            batch.update(
              'moeda',
              {
                'preco': moeda['latest'],
                'precoDolar':converterRealDolar(double.parse(moeda['latest']), dolarAtual),
                'timestamp': timestamp.millisecondsSinceEpoch,
                'mudancaHora': preco['percent_change']['hour'].toString(),
                'mudancaDia': preco['percent_change']['day'].toString(),
                'mudancaSemana': preco['percent_change']['week'].toString(),
                'mudancaMes': preco['percent_change']['month'].toString(),
                'mudancaAno': preco['percent_change']['year'].toString(),
                'mudancaPeriodoTotal':
                    preco['percent_change']['all'].toString(),
              },
              where: 'baseId = ?',
              whereArgs: [atual.baseId],
            );
          }
        });
      });
      await batch.commit(noResult: true);
      await _readMoedasTable();
    }
  }

  _readMoedasTable() async {
    Database db = await Db.instance.database;
    List<Map<String, dynamic>> resultados = await db.query('moeda');

    _tabela = resultados.map((row) {
      return Moedas.fromMapDatabase(row);
    }).toList();

    notifyListeners();
  }

  _moedasTableIsEmpty() async {
    Database db = await Db.instance.database;
    List resultados = await db.query('moeda');
    return resultados.isEmpty;
  }

  _setupDadosTableMoeda() async {
    if (await _moedasTableIsEmpty()) {
      String uri = 'https://api.coinbase.com/v2/assets/search?base=BRL';

      final response = await http.get(Uri.parse(uri));
      var dolarAtual = await getDolarAtual();

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        final List<dynamic> moedas = json['data'];

        List<Moedas> moedasList = [];

        for (var element in moedas) {
          Moedas moedas = Moedas.fromMap(element);
          var moedasComDolar = moedas.copyWith(
              precoDolar: converterRealDolar(moedas.preco, dolarAtual));
          moedasList.add(moedasComDolar);
        }

        Database db = await Db.instance.database;
        Batch batch = db.batch();

        for (var element in moedasList) {
          batch.insert('moeda', element.toMap());
        }

        await batch.commit(noResult: true);
      }
    }
  }

  Future<double> getDolarAtual() async {
    Dio dio = Dio();
    var response =
        await dio.get('http://economia.awesomeapi.com.br/json/last/USD-BRL');
    return double.parse(response.data['USDBRL']['ask']);
  }

  double converterRealDolar(double real, double dolar) {
    var valorDolar = real / dolar;
    var valorDolar2 = valorDolar;
    return valorDolar2;
  }

  _setupMoedasTable() async {
    const String table = '''
      CREATE TABLE IF NOT EXISTS moedas (
        baseId TEXT PRIMARY KEY,
        sigla TEXT,
        nome TEXT,
        icone TEXT,
        preco TEXT,
        precoDolar TEXT,
        timestamp INTEGER,
        mudancaHora TEXT,
        mudancaDia TEXT,
        mudancaSemana TEXT,
        mudancaMes TEXT,
        mudancaAno TEXT,
        mudancaPeriodoTotal TEXT
      );
''';
    final db = await Db.instance.database;
    await db.execute(table);
  }
}
