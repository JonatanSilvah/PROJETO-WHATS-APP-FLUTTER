import 'package:firebase_core/firebase_core.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:whatsapp/Cadastro.dart';
import 'package:whatsapp/Route.dart';

import 'Home.dart';
import 'model/Usuario.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerSenha = TextEditingController();
  String _mensagemErro = "";

  _validarCampos() {
    String email = _controllerEmail.text;
    String senha = _controllerSenha.text;

    if (email.isNotEmpty && email.contains("@")) {
      if (senha.isNotEmpty) {
        setState(() {
          _mensagemErro = "";
        });
        Usuario usuario = Usuario();

        usuario.senha = senha;
        usuario.email = email;
        _logarUsuario(usuario);
      } else {
        setState(() {
          _mensagemErro = "Preenche a senha";
        });
      }
    } else {
      setState(() {
        _mensagemErro = "Preencha o email utilizando o @";
      });
    }
  }

  Future _logarUsuario(Usuario usuario) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    auth
        .signInWithEmailAndPassword(
            email: usuario.email, password: usuario.senha)
        .then((value) {
      Navigator.pushReplacementNamed(context, RouteGenerator.ROTA_HOME);
    }).catchError((erro) {
      setState(() {
        _mensagemErro = "Não foi possível logar, verifique o email e a senha.";
      });
    });
  }

  Future verificaUsuarioLogado() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? usuarioAtual = await auth.currentUser;

    if (usuarioAtual != null) {
      Navigator.pushAndRemoveUntil(
          context, MaterialPageRoute(builder: (_) => Home()), (_) => false);
    }
  }

  @override
  void initState() {
    verificaUsuarioLogado();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: Color(0xff075E54)),
        padding: EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset(
                  "images/logo.png",
                  width: 200,
                  height: 150,
                ),
                Gap(32),
                TextField(
                    controller: _controllerEmail,
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
                    obscureText: true,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      hintText: "Senha",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    )),
                Gap(16),
                ElevatedButton(
                  onPressed: () {
                    _validarCampos();
                  },
                  child: Text(
                    "Entrar",
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
                Gap(16),
                Center(
                  child: GestureDetector(
                    child: Text(
                      "Não tem conta? cadastrase-se",
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                          context, RouteGenerator.ROTA_CADASTRO);
                    },
                  ),
                ),
                Gap(8),
                Text(
                  _mensagemErro,
                  style: TextStyle(color: Colors.red, fontSize: 20),
                  textAlign: TextAlign.center,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
