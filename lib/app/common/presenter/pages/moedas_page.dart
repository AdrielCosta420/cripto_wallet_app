import 'package:cripto_wallet/app/common/repositories/favoritas_repository.dart';
import 'package:cripto_wallet/app/common/repositories/moedas_repository.dart';
import 'package:dio/dio.dart';
import '../../../../configs/app_settings.dart';
import 'package:provider/provider.dart';
import '../../models/moedas.dart';
import 'moedas_detalhes_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MoedasPage extends StatefulWidget {
  const MoedasPage({Key? key}) : super(key: key);

  @override
  State<MoedasPage> createState() => _MoedasPageState();
}

class _MoedasPageState extends State<MoedasPage> {
  late List<Moedas> tabela;
  late NumberFormat real;
  late Map<String, String> loc;
  List<Moedas> selecionadas = [];
  late FavoritasRepository favoritas;
  late MoedasRepository moedas;
  double dolarAtual = 0;

  readNumberFormat() {
    loc = context.watch<AppSettings>().locale;
    real = NumberFormat.currency(locale: loc['locale'], name: loc['name']);
  }

  changeLanguageButton() {
    final locale = loc['locale'] == 'pt_BR' ? 'en_US' : 'pt_BR';
    final name = loc['locale'] == 'pt_BR' ? '\$' : 'R\$';

    return PopupMenuButton(
      icon: const Icon(Icons.language),
      itemBuilder: (context) => [
        PopupMenuItem(
          child: ListTile(
            leading: const Icon(Icons.swap_vert, color: Colors.black),
            title: Text(
              'Usar $locale',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            onTap: () {
              context.read<AppSettings>().setLocale(locale, name);
              Navigator.pop(context);
            },
          ),
        ),
      ],
    );
  }

  appBarDinamica() {
    if (selecionadas.isEmpty) {
      return AppBar(
        centerTitle: true,
        actions: [
          changeLanguageButton(),
        ],
        backgroundColor: const Color.fromARGB(255, 59, 59, 190),
        // centerTitle: true,
        title: const Text(
          'Cripto Moedas',
          style: TextStyle(letterSpacing: 0.8, fontSize: 22),
        ),
      );
    } else {
      return AppBar(
        backgroundColor: const Color.fromRGBO(83, 109, 254, 1),
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
            onPressed: () {
              setState(() {
                selecionadas = [];
              });
            },
            icon: const Icon(Icons.arrow_back_ios_new)),
        title: Text('${selecionadas.length} selecionadas'),
        centerTitle: true,
      );
    }
  }

  mostrarDetalhes(Moedas moeda) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MoedasDetalhesPage(moeda: moeda),
      ),
    );
  }

  limparSelecionadas() {
    setState(() {
      selecionadas = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    favoritas = Provider.of<FavoritasRepository>(context);
    moedas = Provider.of<MoedasRepository>(context);
    tabela = moedas.tabela;
    readNumberFormat();

    return Scaffold(
      appBar: appBarDinamica(),
      body: RefreshIndicator(
        onRefresh: () => moedas.checkPreco(),
        child: ListView.separated(
          itemBuilder: (BuildContext context, int pos) {
            return ListTile(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12))),
              leading: (selecionadas.contains(tabela[pos]))
                  ? const CircleAvatar(
                      child: Icon(Icons.check),
                    )
                  : SizedBox(
                      width: 40,
                      child: Image.network(tabela[pos].icone),
                    ),
              title: Row(
                children: [
                  Text(
                    tabela[pos].nome,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                  ),
                  if (favoritas.lista
                      .any((fav) => fav.sigla == tabela[pos].sigla))
                    const Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 15,
                      ),
                    ),
                ],
              ),
              trailing: Text(
                context.read<AppSettings>().locale['locale'] == 'pt_BR'
                    ? real.format(tabela[pos].preco)
                    : real.format(tabela[pos].precoDolar),
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              selected: selecionadas.contains(tabela[pos]),
              selectedTileColor: Colors.indigo[50],
              onLongPress: () {
                setState(() {
                  (selecionadas.contains(tabela[pos]))
                      ? selecionadas.remove(tabela[pos])
                      : selecionadas.add(tabela[pos]);
                });
              },
              onTap: () => mostrarDetalhes(tabela[pos]),
            );
          },
          padding: const EdgeInsets.all(16),
          separatorBuilder: (_, __) => const Divider(),
          itemCount: tabela.length,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: selecionadas.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                favoritas.saveAll(selecionadas);
                limparSelecionadas();
              },
              icon: const Icon(Icons.star),
              label: const Text(
                'FAVORITAR',
                style:
                    TextStyle(letterSpacing: 0.5, fontWeight: FontWeight.bold),
              ),
              backgroundColor: const Color.fromARGB(255, 29, 49, 163),
            )
          : null,
    );
  }
}
