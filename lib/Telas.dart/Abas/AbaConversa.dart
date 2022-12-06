import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:whatsapp/Telas.dart/Tela%20Mensagem/teste.dart';
import 'package:whatsapp/model/Conversas.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/model/Usuario.dart';

import '../Tela Mensagem/Mensagens.dart';

class AbaConversa extends StatefulWidget {
  const AbaConversa({super.key});

  @override
  State<AbaConversa> createState() => _AbaConversaState();
}

class _AbaConversaState extends State<AbaConversa> {
  final _controller = StreamController<QuerySnapshot>.broadcast();

  FirebaseFirestore db = FirebaseFirestore.instance;

  List<Conversa> listaConversas = [];

  String? _idUsuarioLogado;

  @override
  void initState() {
    super.initState();

    _recuperarDadosUsuario();

    Conversa conversa = Conversa();

    conversa.nome = "Ficticio 1";
    conversa.mensagem = "Ola tudo bem?";
    conversa.urlImagem =
        "https://firebasestorage.googleapis.com/v0/b/whatsapp-70a73.appspot.com/o/perfil%2Fperfil5.jpg?alt=media&token=68cda70e-bc7c-4b53-805f-ab80adc4547c";

    listaConversas.add(conversa);
  }

  adicionandoListenController() {
    final stream = db
        .collection("conversas")
        .doc(_idUsuarioLogado)
        .collection("ultima conversa")
        .snapshots()
        .listen((event) {
      _controller.add(event);
    });
  }

  _recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? usuarioAtual = await auth.currentUser;
    _idUsuarioLogado = usuarioAtual!.uid;
    adicionandoListenController();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _controller.stream,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Column(
                  children: [
                    Text("Carregando Mensagens"),
                    CircularProgressIndicator()
                  ],
                ),
              );
              break;
            case ConnectionState.active:
            case ConnectionState.done:
              if (snapshot.hasError) {
                return Expanded(
                  child: Text("Erro ao carregar mensagens"),
                );
              }
              QuerySnapshot? querySnapshot = snapshot.data;

              return ListView.builder(
                  itemCount: querySnapshot!.docs.length,
                  itemBuilder: (context, index) {
                    List<DocumentSnapshot> conversas =
                        querySnapshot.docs.toList();

                    DocumentSnapshot item = conversas[index];
                    String urlImagem = item["fotoDestinatario"];
                    String nome = item["nome"];
                    String tipo = item["tipo"];
                    String mensagem = item["mensagem"];
                    String idDestinatario = item["idDestinatario"];
                    Usuario usuario = Usuario();
                    usuario.nome = nome;
                    usuario.urlImagem = urlImagem;
                    usuario.idUsuario = idDestinatario;

                    return ListTile(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Mensagens(usuario)));
                      },
                      contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                      leading: CircleAvatar(
                        maxRadius: 30,
                        backgroundColor: Colors.grey,
                        backgroundImage:
                            urlImagem != null ? NetworkImage(urlImagem) : null,
                      ),
                      title: Text(nome),
                      subtitle: Text(tipo != "imagem" ? mensagem : "imagem..."),
                    );
                  });
          }
        });
  }
}
