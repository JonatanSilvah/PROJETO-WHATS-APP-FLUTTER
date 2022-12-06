import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:whatsapp/Login.dart';
import 'package:whatsapp/model/Conversas.dart';

import '../../model/Mensage.dart';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whatsapp/Telas.dart/Tela Mensagem/InformacaoContato.dart';
import 'package:whatsapp/model/Usuario.dart';
import 'package:gap/gap.dart';
import 'package:path_provider/path_provider.dart';

class Mensagens extends StatefulWidget {
  Usuario contato;
  Mensagens(this.contato);

  @override
  State<Mensagens> createState() => _MensagensState();
}

class _MensagensState extends State<Mensagens> {
  final _controller = StreamController<QuerySnapshot>.broadcast();
  FirebaseFirestore db = FirebaseFirestore.instance;
  var documents;
  ScrollController _scrollController = ScrollController();

  List<String> listaMensagens = [];

  File? _imagem;
  bool _subindoImagem = false;
  TextEditingController _controllerMensagem = TextEditingController();

  String? _idUsuarioLogado;

  Future _enviarFoto() async {
    final ImagePicker _picker = ImagePicker();
    final imagemSelecionada =
        await _picker.pickImage(source: ImageSource.camera);
    if (imagemSelecionada == null) return;

    setState(() {
      _subindoImagem = true;
    });

    File file = File(imagemSelecionada.path);

    setState(() {
      _imagem = file;
    });

    //File file = File(imagemSelecionada);

    _uploadImagem();
  }

  Future _uploadImagem() async {
    String nomeFoto = DateTime.now().microsecondsSinceEpoch.toString();
    //Referenciar arquivo
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference pastaRaiz = storage.ref();
    Reference arquivo = pastaRaiz
        .child("mensagens")
        .child(_idUsuarioLogado!)
        .child(nomeFoto + ".jpg");

    //Fazer upload da imagem
    UploadTask task = arquivo.putFile(_imagem!);

    //Controlar progresso do upload
    task.snapshotEvents.listen((TaskSnapshot taskSnapshot) {
      if (taskSnapshot.state == TaskState.running) {
        setState(() {
          _subindoImagem = true;
        });
      } else if (taskSnapshot.state == TaskState.success) {
        _recuperarUrlImagem(taskSnapshot);

        setState(() {
          _subindoImagem = false;
        });
      }
    });
  }

  Future _recuperarUrlImagem(TaskSnapshot taskSnapshot) async {
    String url = await taskSnapshot.ref.getDownloadURL();
    String dataMsg = DateTime.now().microsecondsSinceEpoch.toString();

    Mensagem mensagem = Mensagem();
    mensagem.createdOn = dataMsg;
    mensagem.idUsuario = _idUsuarioLogado!;
    mensagem.mensagem = "";
    mensagem.urlImagem = url;
    mensagem.tipo = "imagem";

    _salvarMensagem(_idUsuarioLogado!, widget.contato.idUsuario, mensagem);
    _salvarMensagem(widget.contato.idUsuario, _idUsuarioLogado!, mensagem);
    _salvarConversa(mensagem);
  }

  _enviarMensagem() async {
    String dataMsg = DateTime.now().microsecondsSinceEpoch.toString();
    String msgDigitada = _controllerMensagem.text;
    String url;
    setState(() {
      _controllerMensagem.text = "";
    });

    if (msgDigitada.isNotEmpty) {
      Mensagem mensagem = Mensagem();
      mensagem.createdOn = dataMsg;
      mensagem.idUsuario = _idUsuarioLogado!;
      mensagem.mensagem = msgDigitada;
      mensagem.urlImagem = "";
      mensagem.tipo = "texto";

      setState(() {
        listaMensagens.add(msgDigitada);
      });

      _salvarMensagem(_idUsuarioLogado!, widget.contato.idUsuario, mensagem);
      _salvarMensagem(widget.contato.idUsuario, _idUsuarioLogado!, mensagem);
      _salvarConversa(mensagem);
    }
  }

  Future _salvarMensagem(
      String idRemetente, String idDestinatario, Mensagem msg) async {
    await db
        .collection("mensagens")
        .doc(idRemetente)
        .collection(idDestinatario)
        .add(msg.toMap());
  }

  _salvarConversa(Mensagem msg) async {
    String dataMsg = DateTime.now().microsecondsSinceEpoch.toString();
    Conversa cRemetente = Conversa();
    cRemetente.createdOn = dataMsg;
    cRemetente.idUsuario = _idUsuarioLogado!;
    cRemetente.idDestinatario = widget.contato.idUsuario;
    cRemetente.mensagem = msg.mensagem;
    cRemetente.nome = widget.contato.nome;
    cRemetente.urlImagem = widget.contato.urlImagem;
    cRemetente.tipo = msg.tipo;
    cRemetente.salvar();

    Conversa cDestinatario = Conversa();
    cDestinatario.createdOn = dataMsg;
    cRemetente.idDestinatario = widget.contato.idUsuario;
    cRemetente.idUsuario = _idUsuarioLogado!;
    cRemetente.mensagem = msg.mensagem;
    cRemetente.nome = widget.contato.nome;
    cRemetente.urlImagem = widget.contato.urlImagem;
    cRemetente.tipo = msg.tipo;

    cRemetente.salvar();
  }

  adicionarListenController() {
    final stream = db
        .collection("mensagens")
        .doc(_idUsuarioLogado)
        .collection(widget.contato.idUsuario)
        .orderBy("createdOn", descending: false)
        .snapshots()
        .listen((event) {
      if (event.docs.isNotEmpty) {
        _controller.add(event);
        Timer(Duration(milliseconds: 500), () {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        });
      }
    });
  }

  Future verificaUsuarioLogado() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? usuarioAtual = await auth.currentUser;

    setState(() {
      _idUsuarioLogado = usuarioAtual!.uid;
    });

    adicionarListenController();

    if (usuarioAtual == null) {
      Navigator.pushAndRemoveUntil(
          context, MaterialPageRoute(builder: (_) => Login()), (_) => false);
    }
  }

  @override
  void initState() {
    verificaUsuarioLogado();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.close();
  }

  @override
  Widget build(BuildContext context) {
    var stream = StreamBuilder(
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
            return Expanded(
              child: ListView.builder(
                  controller: _scrollController,
                  itemCount: querySnapshot!.docs.length,
                  itemBuilder: (_, index) {
                    List<DocumentSnapshot> mensagens =
                        querySnapshot.docs.toList();
                    DocumentSnapshot item = mensagens[index];

                    double larguraContanier =
                        MediaQuery.of(context).size.width * 0.7;
                    Alignment alinhamento = Alignment.centerRight;
                    Color cor = Color(0xffd2ffa5);
                    CrossAxisAlignment textoAlinhamento =
                        CrossAxisAlignment.end;
                    if (widget.contato.idUsuario == item["id"]) {
                      cor = Colors.white;
                      alinhamento = Alignment.centerLeft;
                      textoAlinhamento = CrossAxisAlignment.start;
                    }

                    return Align(
                        alignment: alinhamento,
                        child: Padding(
                            padding: EdgeInsets.all(6),
                            child: Container(
                                width: larguraContanier,
                                decoration: BoxDecoration(
                                    color: cor,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8))),
                                padding: EdgeInsets.all(16),
                                child: item["tipo"] == "texto"
                                    ? Text(
                                        item["mensagem"],
                                        style: TextStyle(fontSize: 18),
                                      )
                                    : Image.network(item["urlImage"]))));
                  }),
            );
        }
      },
    );

    var digitarMsg = Container(
      padding: EdgeInsets.all(8),
      child: Row(children: [
        Expanded(
            child: Padding(
          padding: EdgeInsets.only(right: 8),
          child: TextField(
              controller: _controllerMensagem,
              autofocus: false,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                prefixIcon: IconButton(
                  icon: _subindoImagem == true
                      ? CircularProgressIndicator()
                      : Icon(Icons.camera_alt),
                  onPressed: _enviarFoto,
                ),
                contentPadding: EdgeInsets.fromLTRB(32, 8, 32, 8),
                hintText: "Digite uma mensagem",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
              )),
        )),
        FloatingActionButton(
          backgroundColor: Color(0xff075E54),
          mini: true,
          onPressed: () {
            _enviarMensagem();
          },
          child: Icon(
            Icons.send,
            color: Colors.white,
          ),
        )
      ]),
    );

    return Scaffold(
      appBar: AppBar(
        titleSpacing: -10,
        backgroundColor: Color(0xff075E54),
        title: Row(
          children: [
            GestureDetector(
              onTap: (() {
                showDialog(
                    context: context,
                    builder: (_) {
                      return Container(
                        padding: EdgeInsets.all(42),
                        child: CircleAvatar(
                          backgroundColor: Colors.grey,
                          backgroundImage: widget.contato.urlImagem != null
                              ? NetworkImage(widget.contato.urlImagem)
                              : null,
                        ),
                      );
                    });
              }),
              child: CircleAvatar(
                maxRadius: 20,
                backgroundColor: Colors.grey,
                backgroundImage: widget.contato.urlImagem != null
                    ? NetworkImage(widget.contato.urlImagem)
                    : null,
              ),
            ),
            Gap(15),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => InformacaoContato(widget.contato)));
              },
              child: Text(widget.contato.nome),
            )
          ],
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage(
                  "images/bg.png",
                ),
                fit: BoxFit.cover)),
        child: SafeArea(
            child: Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [stream, digitarMsg],
                ))),
      ),
    );
  }
}
