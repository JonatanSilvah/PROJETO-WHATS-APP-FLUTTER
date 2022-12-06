import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:whatsapp/model/Usuario.dart';

class InformacaoContato extends StatefulWidget {
  Usuario usuario;
  InformacaoContato(this.usuario);

  @override
  State<InformacaoContato> createState() => _InformacaoContatoState();
}

class _InformacaoContatoState extends State<InformacaoContato> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Informações"), backgroundColor: Color(0xff075E54)),
      body: Container(
        decoration: BoxDecoration(color: Color.fromARGB(255, 255, 253, 233)),
        padding: EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CircleAvatar(
                maxRadius: 120,
                backgroundColor: Colors.grey,
                backgroundImage: widget.usuario != null
                    ? NetworkImage(widget.usuario.urlImagem)
                    : null,
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      "Nome:",
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                    Gap(10),
                    Text(
                      widget.usuario.nome,
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.normal),
                    )
                  ],
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      "E-mail:",
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                    Gap(10),
                    Text(
                      widget.usuario.email,
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.normal),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
