import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class Conversa {
  String? _nome;
  String? _mensagem;
  String? _tipo;
  String? _createdOn;
  String? _urlImagem;
  String? _idUsuario;
  String? _idDestinatario;

  Conversa();

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "createdOn": this.createdOn,
      "idRemetente": this.idUsuario,
      "idDestinatario": this.idDestinatario,
      "nome": this.nome,
      "mensagem": this.mensagem,
      "tipo": this.tipo,
      "fotoDestinatario": this.urlImagem
    };

    return map;
  }

  salvar() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    await db
        .collection("conversas")
        .doc(this.idUsuario)
        .collection("ultima conversa")
        .doc(this.idDestinatario)
        .set(this.toMap());
  }

  String get idDestinatario => _idDestinatario!;
  set idDestinatario(String value) {
    _idDestinatario = value;
  }

  String get nome => _nome!;
  set nome(String value) {
    _nome = value;
  }

  String get createdOn => _createdOn!;
  set createdOn(String value) {
    _createdOn = value;
  }

  String get idUsuario => _idUsuario!;
  set idUsuario(String value) {
    _idUsuario = value;
  }

  String get urlImagem => _urlImagem!;
  set urlImagem(String value) {
    _urlImagem = value;
  }

  String get mensagem => _mensagem!;
  set mensagem(String value) {
    _mensagem = value;
  }

  String get tipo => _tipo!;
  set tipo(String value) {
    _tipo = value;
  }
}
