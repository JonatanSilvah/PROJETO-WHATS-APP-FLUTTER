import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:whatsapp/Login.dart';
import 'package:whatsapp/Route.dart';
import 'package:whatsapp/Telas.dart/Abas/AbaContato.dart';
import 'package:whatsapp/Telas.dart/Abas/AbaConversa.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  String? emailUsuario;
  List<String> itensMenu = ["Configurações", "Deslogar"];
  String _emailContato = "";

  _recuperarEmail() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? usuarioAtual = await auth.currentUser;

    setState(() {
      emailUsuario = usuarioAtual?.email!;
    });
  }

  _escolhaMenuItem(String itemEscolhido) {
    switch (itemEscolhido) {
      case "Configurações":
        _configuracao();
        break;
      case "Deslogar":
        _deslogarUsuario();
        break;
    }
    //print("Item escolhido: " + itemEscolhido );
  }

  _deslogarUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;

    await auth.signOut();
    Navigator.pushReplacementNamed(context, RouteGenerator.ROTA_LOGIN);
  }

  _configuracao() {
    Navigator.pushNamed(context, RouteGenerator.ROTA_CONFIG);
  }

  Future _verificaUsuarioLogado() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? usuarioAtual = await auth.currentUser;

    if (usuarioAtual != null) {
    } else {
      Navigator.pushAndRemoveUntil(
          context, MaterialPageRoute(builder: (_) => Login()), (_) => false);
    }
  }

  @override
  void initState() {
    super.initState();
    _verificaUsuarioLogado();
    _recuperarEmail();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("WhatsApp"),
        backgroundColor: Color(0xff075E54),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          indicatorWeight: 4,
          labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: [
            Tab(
              text: "Conversas",
            ),
            Tab(
              text: "Contatos",
            )
          ],
        ),
        actions: <Widget>[
          PopupMenuButton<String>(
              onSelected: _escolhaMenuItem,
              itemBuilder: (context) {
                return itensMenu.map((String item) {
                  return PopupMenuItem(value: item, child: Text(item));
                }).toList();
              })
        ],
      ),
      body: TabBarView(
          controller: _tabController, children: [AbaConversa(), AbaContato()]),
    );
  }
}
