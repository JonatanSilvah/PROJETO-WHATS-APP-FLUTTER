class Mensagem {
  String? _mensagem;
  String? _tipo;
  String? _createdOn;
  String? _urlImagem;
  String? _idUsuario;

  Mensagem();

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "createdOn": this.createdOn,
      "mensagem": this.mensagem,
      "tipo": this.tipo,
      "id": this.idUsuario,
      "urlImage": this.urlImagem
    };

    return map;
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
