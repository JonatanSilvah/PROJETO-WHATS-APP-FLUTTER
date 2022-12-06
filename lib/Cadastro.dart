import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:whatsapp/Home.dart';
import 'package:whatsapp/Route.dart';
import 'model/Usuario.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Cadastro extends StatefulWidget {
  const Cadastro({super.key});

  @override
  State<Cadastro> createState() => _CadastroState();
}

class _CadastroState extends State<Cadastro> {
  TextEditingController _controllerNome = TextEditingController();
  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerSenha = TextEditingController();
  String _mensagemErro = "";
  String? idUsuario;
  _validarCampos() {
    String nome = _controllerNome.text;
    String email = _controllerEmail.text;
    String senha = _controllerSenha.text;

    if (nome.isNotEmpty) {
      if (email.isNotEmpty && email.contains("@")) {
        if (senha.isNotEmpty && senha.length > 6) {
          setState(() {
            _mensagemErro = "";
          });
          Usuario usuario = Usuario();
          usuario.nome = nome;
          usuario.senha = senha;
          usuario.email = email;

          _cadastrarUsurio(usuario);
        } else {
          setState(() {
            _mensagemErro = "Preenche a senha e utilize mais de 6 caracteres";
          });
        }
      } else {
        setState(() {
          _mensagemErro = "Preencha o email utilizando o @";
        });
      }
    } else {
      setState(() {
        _mensagemErro = "O nome não pode ficar vazio";
      });
    }
  }

  Future _cadastrarUsurio(Usuario usuario) async {
    FirebaseAuth auth = FirebaseAuth.instance;

    await auth
        .createUserWithEmailAndPassword(
            email: usuario.email, password: usuario.senha)
        .then((value) {
      FirebaseFirestore db = FirebaseFirestore.instance;
      usuario.idUsuario = value.user!.uid;

      db.collection("usuarios").doc(value.user!.uid).set(usuario.toMap());
      Navigator.pushAndRemoveUntil(
          context, MaterialPageRoute(builder: (_) => Home()), (_) => false);
    }).catchError((error) {
      setState(() {
        _mensagemErro = "Erro ao cadastrar";
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cadastro"),
        backgroundColor: Color(0xff075E54),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(color: Color(0xff075E54)),
        child: Center(
            child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset(
                "images/usuario.png",
                width: 175,
                height: 125,
              ),
              Gap(25),
              TextField(
                  controller: _controllerNome,
                  autofocus: false,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                    hintText: "Nome",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  )),
              Gap(8),
              TextField(
                  controller: _controllerEmail,
                  autofocus: false,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                    hintText: "E-mail",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  )),
              Gap(8),
              TextField(
                  controller: _controllerSenha,
                  autofocus: false,
                  obscureText: true,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                    hintText: "Senha",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  )),
              Gap(10),
              ElevatedButton(
                onPressed: () {
                  _validarCampos();
                },
                child: Text(
                  "Cadastrar",
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
              Gap(8),
              Text(
                _mensagemErro,
                style: TextStyle(color: Colors.red, fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        )),
      ),
    );
  }
}
