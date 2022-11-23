import 'package:cripto_wallet/widgets/grafico_historico.dart';

import '../../repositories/conta_repository.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/moedas.dart';
import 'package:flutter/material.dart';

class MoedasDetalhesPage extends StatefulWidget {
  Moedas moeda;
  MoedasDetalhesPage({Key? key, required this.moeda}) : super(key: key);

  @override
  State<MoedasDetalhesPage> createState() => _MoedasDetalhesPageState();
}

class _MoedasDetalhesPageState extends State<MoedasDetalhesPage> {
  NumberFormat real = NumberFormat.currency(locale: 'pt_BR', name: 'R\$');
  final _form = GlobalKey<FormState>();
  final _valor = TextEditingController();
  double quantidade = 0;
  late ContaRepository conta;
  Widget grafico = Container();
  bool graficoLoaded = false;

  getGrafico() {
    if (!graficoLoaded) {
      grafico = GraficoHistorico(moeda: widget.moeda);
      graficoLoaded = true;
    }
    return grafico;
  }

  comprar() async {
    if (_form.currentState!.validate()) {
      //salvar a compra
      await conta.comprar(widget.moeda, double.parse(_valor.text));

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('COMPRA REALIZADA COM SUCESSO!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    conta = Provider.of<ContaRepository>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 59, 59, 190),
        centerTitle: true,
        title: Text(widget.moeda.nome),
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  left: 24, right: 24, top: 10, bottom: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    child: Image.network(
                      widget.moeda.icone,
                      scale: 2.5,
                    ),
                  ),
                  Container(
                    width: 10,
                  ),
                  Text(
                    real.format(widget.moeda.preco),
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -1,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
            getGrafico(),
            (quantidade > 0)
                ? SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.all(12),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.05),
                      ),
                      child: Text(
                        '$quantidade ${widget.moeda.sigla}',
                        style:
                            const TextStyle(fontSize: 20, color: Colors.teal),
                      ),
                    ),
                  )
                : Container(
                    margin: const EdgeInsets.only(bottom: 24),
                  ),
            Form(
              key: _form,
              child: TextFormField(
                controller: _valor,
                style: const TextStyle(fontSize: 20),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Valor',
                  prefixIcon: Icon(Icons.monetization_on_outlined),
                  suffix: Text(
                    'reais',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Informe o valor da compra';
                  } else if (double.parse(value) < 50) {
                    return 'Compra mínima de R\$ 50,00';
                  } else if (double.parse(value) > conta.saldo) {
                    return 'Você não tem saldo suficiente';
                  }
                  return null;
                },
                //calcaular o valor em reais para a criptomoeda escolhida
                onChanged: (value) {
                  setState(() {
                    quantidade = (value.isEmpty)
                        ? 0
                        : double.parse(value) / widget.moeda.preco;
                  });
                },
              ),
            ),
            Container(
              alignment: Alignment.bottomCenter,
              margin: const EdgeInsets.only(top: 24),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 59, 59, 190)),
                onPressed: comprar,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.check),
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Comprar',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
