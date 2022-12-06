import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // FirebaseFirestore db = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  String email = "jonatanda25@gmail.com";
  String senha = "123456";
/*
  auth
      .createUserWithEmailAndPassword(email: email, password: senha)
      .then(((value) {
    value.user?.email;
  })).catchError((error) {});*/

  /*User? usuarioAtual = await auth.currentUser;

  if (usuarioAtual != null) {
    print(usuarioAtual.email);
  } else {
    print("usuario deslogado");
  }

  auth.signOut();*/
/*
  auth.signInWithEmailAndPassword(email: email, password: senha).then((value) {}).catchError( (error) {

  });
  */

  /*db.collection("usuarios").doc("002").set({"nome": "jonatan", "idade": "30"});
  DocumentReference ref =
      await db.collection("usuarios").add({"nome": "gabriella", "idade": "13"});*/
  //db.collection("usuarios").doc("002").delete();
  /*DocumentSnapshot snapshot = await db.collection("usuarios").doc("001").get();

  var dados = snapshot.data();*/
  /* QuerySnapshot querySnapshot = await db.collection("usuarios").get();

  var dados;

  for (DocumentSnapshot item in querySnapshot.docs) {
    dados = item.data();
  }*/
  /*
  db.collection("usuarios").snapshots().listen(
    (event) {
      for (DocumentSnapshot item in event.docs) {
        var dados = item.data();
      }
    },
  );*/
  /*var dados;

  QuerySnapshot querySnapshot =
      await db.collection("usuarios").where("nome", isEqualTo: "Jonatan").get();
  for (DocumentSnapshot item in querySnapshot.docs) {
    dados = item.data();
  }*/

  //Firebase AUHT

  runApp(MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  File? _imagem;
  String _statusUpload = "Upload não iniciado";
  String? _urlImagemRecuperada = null;

  Future _recuperarImagem(bool daCamera) async {
    final ImagePicker _picker = ImagePicker();
    XFile? imagemSelecionada;

    if (daCamera) {
      imagemSelecionada = await _picker.pickImage(source: ImageSource.camera);
    } else {
      imagemSelecionada = await _picker.pickImage(source: ImageSource.gallery);
    }

    File file = File(imagemSelecionada!.path);

    setState(() {
      _imagem = file;
    });
  }

 Future _uploadImagem() async {

    //Referenciar arquivo
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference pastaRaiz = storage.ref();
    Reference arquivo = pastaRaiz
        .child("fotos")
        .child("foto1.jpg");

    //Fazer upload da imagem
    UploadTask task = arquivo.putFile(_imagem!);

    //Controlar progresso do upload
    task.snapshotEvents.listen((TaskSnapshot taskSnapshot){

      if( taskSnapshot.state == TaskState.running ){
        setState(() {
          _statusUpload = "Em progresso";
        });
      }else if( taskSnapshot.state == TaskState.success ){
        _recuperarUrlImagem( taskSnapshot );
        setState(() {
          _statusUpload = "Upload realizado com sucesso!";
        });
      }

    });

    //Recuperar url da imagem
//    task.onComplete.then((StorageTaskSnapshot snapshot){
//
//      _recuperarUrlImagem( snapshot );
//
//    });

  }


  Future _recuperarUrlImagem(TaskSnapshot taskSnapshot) async {
    String url = await taskSnapshot.ref.getDownloadURL();

    setState(() {
      _urlImagemRecuperada = url;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Recupear url"),
      ),
      body: Container(
          padding: EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(_statusUpload),
                
                ElevatedButton(
                    onPressed: (() {
                      _recuperarImagem(true);
                    }),
                    child: Text("Camera")),
                ElevatedButton(
                    onPressed: () {
                      _recuperarImagem(false);
                    },
                    child: Text("Galeria")),
                _imagem == null ? Container() : Image.file(_imagem!),
                _imagem == null
                    ? Container()
                    : ElevatedButton(
                        onPressed: () {
                          _uploadImagem();
                        },
                        child: Text("Upload")),
                        _urlImagemRecuperada == null ? Container() : Image.network(_urlImagemRecuperada!)
              ],
            ),
          )),
    );
  }
}
