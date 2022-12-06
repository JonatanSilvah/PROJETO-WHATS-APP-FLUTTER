import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Home.dart';
import 'Login.dart';
import 'Route.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  

  
  /* FirebaseFirestore db = FirebaseFirestore.instance;

  db.collection("usuarios").doc("001").set({"nome": "Jonatan"}); */
  runApp(MaterialApp(
    initialRoute: "/",
    onGenerateRoute: RouteGenerator.generateRoute,
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
        primaryColor: Color(0xff075E54), accentColor: Color(0xff25D366)),
    home: Login(),
  ));
}
