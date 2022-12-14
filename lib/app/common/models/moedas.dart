// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Moedas {
  String baseId;
  String icone;
  String nome;
  String sigla;
  double preco;
  double? precoDolar;
  DateTime timestamp;
  double mudancaHora;
  double mudancaDia;
  double mudancaSemana;
  double mudancaMes;
  double mudancaAno;
  double mudancaPeriodoTotal;

  Moedas({
    required this.baseId,
    required this.icone,
    required this.nome,
    required this.sigla,
    required this.preco,
    this.precoDolar,
    required this.timestamp,
    required this.mudancaHora,
    required this.mudancaDia,
    required this.mudancaSemana,
    required this.mudancaMes,
    required this.mudancaAno,
    required this.mudancaPeriodoTotal,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'baseId': baseId,
      'icone': icone,
      'nome': nome,
      'sigla': sigla,
      'preco': preco,
      'precoDolar': precoDolar,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'mudancaHora': mudancaHora,
      'mudancaDia': mudancaDia,
      'mudancaSemana': mudancaSemana,
      'mudancaMes': mudancaMes,
      'mudancaAno': mudancaAno,
      'mudancaPeriodoTotal': mudancaPeriodoTotal,
    };
  }

  factory Moedas.fromMap(Map<String, dynamic> map) {
    return Moedas(
      baseId: map['id'] as String,
      icone: map['image_url'] as String,
      nome: map['name'] as String,
      sigla: map['symbol'] as String,
      preco: double.parse(map['latest']),
      timestamp: DateTime.parse(map['latest_price']['timestamp']),
      mudancaHora: map['latest_price']['percent_change']['hour'],
      mudancaDia: map['latest_price']['percent_change']['day'],
      mudancaSemana: map['latest_price']['percent_change']['week'],
      mudancaMes: map['latest_price']['percent_change']['month'],
      mudancaAno: map['latest_price']['percent_change']['year'],
      mudancaPeriodoTotal: map['latest_price']['percent_change']['all'],
    );
  }

  factory Moedas.fromMapDatabase(Map<String, dynamic> map) {
    return Moedas(
      baseId: map['baseId'],
      icone: map['icone'],
      nome: map['nome'],
      sigla: map['sigla'],
      preco: map['preco'],
      precoDolar: double.parse(map['precoDolar']),
      timestamp: DateTime.fromMicrosecondsSinceEpoch(map['timestamp']),
      mudancaHora: map['mudancaHora'],
      mudancaDia: map['mudancaDia'],
      mudancaSemana: map['mudancaSemana'],
      mudancaMes: map['mudancaMes'],
      mudancaAno: map['mudancaAno'],
      mudancaPeriodoTotal: map['mudancaPeriodoTotal'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Moedas.fromJson(String source) =>
      Moedas.fromMap(json.decode(source) as Map<String, dynamic>);

  Moedas copyWith({
    String? baseId,
    String? icone,
    String? nome,
    String? sigla,
    double? preco,
    double? precoDolar,
    DateTime? timestamp,
    double? mudancaHora,
    double? mudancaDia,
    double? mudancaSemana,
    double? mudancaMes,
    double? mudancaAno,
    double? mudancaPeriodoTotal,
  }) {
    return Moedas(
      baseId: baseId ?? this.baseId,
      icone: icone ?? this.icone,
      nome: nome ?? this.nome,
      sigla: sigla ?? this.sigla,
      preco: preco ?? this.preco,
      precoDolar: precoDolar ?? this.precoDolar,
      timestamp: timestamp ?? this.timestamp,
      mudancaHora: mudancaHora ?? this.mudancaHora,
      mudancaDia: mudancaDia ?? this.mudancaDia,
      mudancaSemana: mudancaSemana ?? this.mudancaSemana,
      mudancaMes: mudancaMes ?? this.mudancaMes,
      mudancaAno: mudancaAno ?? this.mudancaAno,
      mudancaPeriodoTotal: mudancaPeriodoTotal ?? this.mudancaPeriodoTotal,
    );
  }
}
