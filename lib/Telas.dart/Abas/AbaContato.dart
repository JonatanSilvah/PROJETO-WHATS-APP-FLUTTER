import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gap/gap.dart';
import 'package:whatsapp/Route.dart';
import 'package:whatsapp/Telas.dart/Tela Mensagem/Mensagens.dart';

import 'package:whatsapp/model/Usuario.dart';

class AbaContato extends StatefulWidget {
  @override
  State<AbaContato> createState() => _AbaContatoState();
}

class _AbaContatoState extends State<AbaContato> {
  TextEditingController _controllerEmailContato = TextEditingController();
  FirebaseFirestore db = FirebaseFirestore.instance;
  String? _idUsuarioLogado;
  String? _emailUsuario;

  String? idUsuario;

  List<Usuario> listaUsuarios = [];

  Future<List<Usuario>> _recuperarContatos() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? usuarioAtual = await auth.currentUser;

    _emailUsuario = usuarioAtual!.email;
    _idUsuarioLogado = usuarioAtual.uid;

    QuerySnapshot snapshot = await db
        .collection("usuarios")
        .doc(_idUsuarioLogado)
        .collection("Contatos")
        .get();

    List<Usuario> contatosSalvos = [];
    for (DocumentSnapshot item in snapshot.docs) {
      var dados = item.data() as Map;

      if (dados["email"] == _emailUsuario) continue;

      Usuario usuario = Usuario();
      usuario.email = dados["email"];
      usuario.nome = dados["nome"];
      usuario.idUsuario = dados["id"];
      if (dados["urlImage"] == null) {
        usuario.urlImagem = "";
      } else {
        usuario.urlImagem = dados["urlImage"];
      }
      contatosSalvos.add(usuario);
    }

    return contatosSalvos;
  }

  _adicionarContato() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? usuarioAtual = await auth.currentUser;

    _emailUsuario = usuarioAtual!.email;
    _idUsuarioLogado = usuarioAtual.uid;

    String emailContato = _controllerEmailContato.text;

    QuerySnapshot snapshot = await db
        .collection("usuarios")
        .where("email", isEqualTo: emailContato)
        .get();

    for (DocumentSnapshot item in snapshot.docs) {
      var dados = item.data() as Map;

      if (dados["email"] == _emailUsuario) continue;

      Usuario usuario = Usuario();
      usuario.email = dados["email"];
      usuario.nome = dados["nome"];
      usuario.idUsuario = dados["id"];
      if (dados["urlImage"] == null) {
        usuario.urlImagem = "";
      } else {
        usuario.urlImagem = dados["urlImage"];
      }

      db
          .collection("usuarios")
          .doc(_idUsuarioLogado)
          .collection("Contatos")
          .doc(usuario.idUsuario)
          .set(usuario.toMap());

      setState(() {
        _controllerEmailContato.text = "";
      });
    }
    _recuperarContatos();
  }

  _recuperarDadosUsuario() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    FirebaseAuth auth = FirebaseAuth.instance;
    User? usuarioAtual = await auth.currentUser;
    _idUsuarioLogado = usuarioAtual!.uid;
    _emailUsuario = usuarioAtual.email;
  }

  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuario();
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder(
            future: _recuperarContatos(),
            builder: (_, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return Center(
                    child: Column(
                      children: [
                        Text("Carregando Contatos"),
                        CircularProgressIndicator()
                      ],
                    ),
                  );
                  break;
                case ConnectionState.active:
                case ConnectionState.done:
                  return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (_, index) {
                        List<Usuario>? listaItens = snapshot.data;
                        Usuario usuario = listaItens![index];

                        return ListTile(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Mensagens(usuario)));
                          },
                          contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                          leading: GestureDetector(
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (_) {
                                    return Container(
                                      padding: EdgeInsets.all(42),
                                      child: CircleAvatar(
                                        backgroundColor: Colors.grey,
                                        backgroundImage: usuario.urlImagem !=
                                                null
                                            ? NetworkImage(usuario.urlImagem)
                                            : null,
                                      ),
                                    );
                                  });
                            },
                            child: CircleAvatar(
                              maxRadius: 30,
                              backgroundColor: Colors.grey,
                              backgroundImage: usuario.urlImagem != null
                                  ? NetworkImage(usuario.urlImagem)
                                  : null,
                            ),
                          ),
                          title: Text(usuario.nome),
                        );
                      });
                  break;
              }
            }),
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: (() {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      backgroundColor: Color(0xff075E54),
                      title: Text(
                        "Adicionar Contato",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      content: TextField(
                          controller: _controllerEmailContato,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: "Digite o e-mail do contato",
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                          )),
                      actions: [
                        ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text("Cancelar"),
                            style: ElevatedButton.styleFrom(
                                primary: Colors.green,
                                padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(32)))),
                        ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _adicionarContato();
                              });
                              Navigator.pop(context);
                            },
                            child: Text("Adicionar"),
                            style: ElevatedButton.styleFrom(
                                primary: Colors.green,
                                padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(32)))),
                      ],
                    );
                  });
            })));
  }
}
