// ignore_for_file: avoid_print

import 'package:defis_inte/liste_defis.dart';
import 'package:defis_inte/utils/authentification.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _estConnectable = true;
  String? _message;

  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtMdp = TextEditingController();

  late Authentification authentification;

  bool get estConnectable {
    return _estConnectable;
  }

  set estConnectable(value) {
    _estConnectable = value;
  }

  String? get message {
    return _message;
  }

  set message(value) {
    _message = value;
  }

    @override
  void initState() {
    authentification = Authentification();
    super.initState();
  }

  Future<void> soumettre() async {
    message = null;

    try {
      String userUid = await authentification.connexion(txtEmail.text, txtMdp.text);

      print('Utilisateur connecté ==> $userUid');

      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(
          builder: (context) => ListeDefis(uidUtilisateur : userUid)
        )
      );
    } catch (error) {
      setState(() {
        message = "Erreur. Veuillez vérifier vos identifiants et votre mot de passe.";
        print(error.toString());
      });
    }
  }

  void changerEtat() {
    setState(() {
      estConnectable = !estConnectable;
    });
  }

  Widget saisirEmail() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child : TextFormField(
        controller: txtEmail,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(
          hintText: 'Adresse mail',
          prefixIcon: Icon(
            Icons.mail_outline,
            color: Colors.black,
          ),
          filled: true,
          fillColor: Colors.white,
        ), 
      )
    );
  }

  Widget saisirMdp() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child : TextFormField(
        controller: txtMdp,
        keyboardType: TextInputType.visiblePassword,
        decoration: const InputDecoration(
          hintText: 'Mot de passe',
          prefixIcon: Icon(
            Icons.lock_outline_rounded,
            color: Colors.black,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        obscureText: true,
      )
    );
  }

  Widget boutonPrincipal() {
    return ElevatedButton(
      style: ButtonStyle(
        shape : MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)
          )
        ),
        backgroundColor: MaterialStateProperty.all<Color>(
          Colors.black
        ),
      ),
      onPressed: soumettre,
      child: const Text("Se connecter", style: TextStyle(color: Colors.white),)
    );
  }

  Widget messageValidation() {
    return Text(message != null ? '$message' : '', style: const TextStyle(color: Colors.red),);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Page de connexion"),
        backgroundColor: Colors.black,
      ),
      body : SingleChildScrollView(child: Form(
        child: Container(
          height: 5*MediaQuery.of(context).size.height/6,
          margin: const EdgeInsets.all(15),
          padding: const EdgeInsets.all(5),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const CircleAvatar(
                backgroundImage: AssetImage('assets/logo_comite.png'),
                radius: 100,
              ),
              const Text(
                'Bonjour cher bizuth !',
                style: TextStyle(
                  fontSize: 25,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Tu t\'apprêtes à consulter les défis que nous avons réservés pour cette intégration ! Donne toi à fond pour permettre à ton équipe de remporter la victoire !',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  height: 1.5
                ),
                textAlign: TextAlign.center,
              ),
              saisirEmail(),
              saisirMdp(),
              messageValidation(),
              boutonPrincipal(),
            ]
          ),
        )
      )
    ));
  }
}