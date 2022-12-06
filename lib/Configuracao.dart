import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gap/gap.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Configuracao extends StatefulWidget {
  const Configuracao({super.key});

  @override
  State<Configuracao> createState() => _ConfiguracaoState();
}

class _ConfiguracaoState extends State<Configuracao>
    with TickerProviderStateMixin {
  late AnimationController controller;
  String? _emailUsuario;
  TextEditingController _controllerNome = TextEditingController();
  bool uploadImagem = false;

  File? _imagem;

  String? _urlImagem = null;
  String _statusUpload = "Upload não iniciado";

  String? _idUsuarioLogado;
  String? _nomeUsuarioLogado;
  String? teste;
  String emailcontato = "teste@gmail.com";

  
  Future _recuperarImagem(daCamera) async {
    final ImagePicker _picker = ImagePicker();
    XFile? imagemSelecionada;

    if (daCamera) {
      imagemSelecionada = await _picker.pickImage(source: ImageSource.camera);
    } else {
      imagemSelecionada = await _picker.pickImage(source: ImageSource.gallery);
    }

    if (imagemSelecionada == null) {
    } else if (imagemSelecionada != null) {
      File file = File(imagemSelecionada.path);

      setState(() {
        _imagem = file;
      });
    }
    await _uploadImagem();
  }

  Future _uploadImagem() async {
    //Referenciar arquivo
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference pastaRaiz = storage.ref();
    Reference arquivo =
        pastaRaiz.child("perfil").child(_idUsuarioLogado! + ".jpg");

    //Fazer upload da imagem
    UploadTask task = arquivo.putFile(_imagem!);

    //Controlar progresso do upload
    task.snapshotEvents.listen((TaskSnapshot taskSnapshot) {
      if (taskSnapshot.state == TaskState.running) {
        setState(() {
          uploadImagem = true;
        });
      } else if (taskSnapshot.state == TaskState.success) {
        _recuperarUrlImagem(taskSnapshot);
        setState(() {
          uploadImagem = false;
        });
      }
    });
  }

  Future _recuperarUrlImagem(TaskSnapshot taskSnapshot) async {
    String url = await taskSnapshot.ref.getDownloadURL();
    _autalizarUrlImagem(url);
    setState(() {
      _urlImagem = url;
    });
  }

  _autalizarUrlImagem(String url) {
    FirebaseFirestore db = FirebaseFirestore.instance;
    Map<String, dynamic> dadosAtt = {"urlImage": url};

    db.collection("usuarios").doc(_idUsuarioLogado).update(dadosAtt);
  }

  _atualizarNome() async {
    String nome = _controllerNome.text;
    FirebaseFirestore db = FirebaseFirestore.instance;

    Map<String, dynamic> dadosAtt = {"nome": nome};

    if (nome.isNotEmpty) {
      db.collection("usuarios").doc(_idUsuarioLogado).update(dadosAtt);

      setState(() {
        _controllerNome.text = "";
        _nomeUsuarioLogado = nome;
      });
    } else {}
  }

  _recuperarDadosUsuario() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    FirebaseAuth auth = FirebaseAuth.instance;
    User? usuarioAtual = await auth.currentUser;
    _idUsuarioLogado = usuarioAtual!.uid;
    _emailUsuario = usuarioAtual.email;

    final snapshot =
        await db.collection("usuarios").doc(usuarioAtual.uid).get();

    final dados = snapshot.data();

    setState(() {
      _nomeUsuarioLogado = dados!["nome"];
      _urlImagem = dados!["urlImage"];
    });
  }

  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuario();
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("WhatsApp"),
        backgroundColor: Color(0xff075E54),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                CircleAvatar(
                    radius: 100,
                    backgroundColor: Colors.grey,
                    child: (uploadImagem == true)
                        ? CircularProgressIndicator()
                        : null,
                    backgroundImage:
                        _urlImagem != null ? NetworkImage(_urlImagem!) : null),
                Gap(10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      child: Text("Camera",
                          style: TextStyle(
                            fontSize: 15,
                          )),
                      onTap: () {
                        _recuperarImagem(true);
                      },
                    ),
                    Gap(25),
                    GestureDetector(
                      child: Text(
                        "Galeria",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      onTap: (() {
                        _recuperarImagem(false);
                      }),
                    )
                  ],
                ),
                Gap(20),
                TextField(
                    controller: _controllerNome,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      hintText: _nomeUsuarioLogado,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32),
                          borderSide: BorderSide(
                            color: Colors.black,
                          )),
                    )),
                Gap(15),
                ElevatedButton(
                  onPressed: () {
                    _atualizarNome();
                  },
                  child: Text(
                    "Salvar",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.normal),
                  ),
                  style: ElevatedButton.styleFrom(
                      primary: Colors.green,
                      padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32))),
                ),
              
              ],
            ),
          ),
        ),
      ),
    );
  }
}
