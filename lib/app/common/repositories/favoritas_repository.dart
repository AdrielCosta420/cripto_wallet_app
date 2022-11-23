import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cripto_wallet/app/common/repositories/moedas_repository.dart';
import 'package:cripto_wallet/app/database/db_firestore.dart';
import 'package:cripto_wallet/services/auth_service.dart';
import '../models/moedas.dart';
import 'package:flutter/material.dart';

class FavoritasRepository extends ChangeNotifier {
  List<Moedas> _lista = [];
  late FirebaseFirestore db;
  late AuthService auth;
  MoedasRepository moedas;

  FavoritasRepository({required this.auth, required this.moedas}) {
    _startRepository();
  }

  _startRepository() async {
    await _startFirestore();
    await _readFavoritas();
  }

  _startFirestore() {
    db = DbFirestore.get();
  }

  _readFavoritas() async {
    if (auth.usuario != null && _lista.isEmpty) {
      try {
        final snapshot = await db
            .collection('Usuarios/${auth.usuario!.uid}/favoritas')
            .get();

        snapshot.docs.forEach((doc) {
          Moedas moeda = moedas.tabela
              .firstWhere((moeda) => moeda.sigla == doc.get('sigla'));
          _lista.add(moeda);
          notifyListeners();
        });
      } catch (e) {
      }
    }
  }

  UnmodifiableListView<Moedas> get lista => UnmodifiableListView(_lista);

  saveAll(List<Moedas> moedas) {
    moedas.forEach((moeda) async {
      if (!_lista.any((atual) => atual.sigla == moeda.sigla)) {
        _lista.add(moeda);
        await db
            .collection('usuarios/${auth.usuario!.uid}/favoritas')
            .doc(moeda.sigla)
            .set({
          'moeda': moeda.nome,
          'sigla': moeda.sigla,
          'preco': moeda.preco
        });
      }
    });
    notifyListeners();
  }

  Future<void> save(Moedas moeda) async {
    _lista.add(moeda);
    await db
        .collection('usuarios/${auth.usuario!.uid}/favoritas')
        .doc(moeda.sigla)
        .set({
      'moeda': moeda.nome,
      'sigla': moeda.sigla,
      'preco': moeda.preco,
    });
    notifyListeners();
  }

  remove(Moedas moeda) async {
    await db
        .collection('usuarios/${auth.usuario!.uid}/favoritas')
        .doc(moeda.sigla)
        .delete();
    _lista.remove(moeda);
    notifyListeners();
  }
}
