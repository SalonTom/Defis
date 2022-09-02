import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:defis_inte/liste_defis.dart';
import 'package:defis_inte/model/defi.dart';
import 'package:flutter/material.dart';

class AddDefi extends StatefulWidget {
  const AddDefi({super.key, required this.uidUtilisateur});

  final String uidUtilisateur;
  @override
  State<AddDefi> createState() => _AddDefiState();
}

class _AddDefiState extends State<AddDefi> {

  TextEditingController txtTitre = TextEditingController();
  TextEditingController txtDescription = TextEditingController();
  TextEditingController txtPoints = TextEditingController();

  FirebaseFirestore bdd = FirebaseFirestore.instance;

  Widget saisirPoints() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child : TextFormField(
        controller: txtPoints,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          hintText: 'Nombre de points',
          prefixIcon: Icon(
            Icons.filter_9_plus,
            color: Colors.black,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      )
    );
  }

  Widget champSaisie(String hintText, TextEditingController? controller, Widget? icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child : TextFormField(
        controller: controller,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: icon,
          filled: true,
          fillColor: Colors.white,
        ),
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
      onPressed: addDefi,
      child: const Text("Ajouter un défi", style: TextStyle(color: Colors.white),)
    );
  }


  Future<void> addDefi() async {

    try {
      bdd.collection('defis').add(Defi(null, txtTitre.text, txtDescription.text, int.tryParse(txtPoints.text)).toMap());
      setState(() {
        txtTitre.text = '';
        txtDescription.text = '';
        txtPoints.text = '';
      });
    } catch (error) {
      // ignore: avoid_print
      print(error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un défi'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Form(
          child: Container(
            height: 5*MediaQuery.of(context).size.height/6,
            margin: const EdgeInsets.all(15),
            padding: const EdgeInsets.all(5),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                champSaisie(
                  'Titre', 
                  txtTitre, 
                  const Icon(
                    Icons.title,
                    color: Colors.black,
                  ),
                ),
                champSaisie(
                  'Description', 
                  txtDescription, 
                  const Icon(
                    Icons.description_outlined,
                    color: Colors.black,
                  ),
                ),
                saisirPoints(),
                boutonPrincipal()
              ],
            ),
          ),
        )
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children : [
            IconButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ListeDefis(uidUtilisateur: widget.uidUtilisateur)
                  )
                );
              }, 
              icon: const Icon(Icons.view_list_rounded, color: Colors.white,)
            ),
          ]
        )
      )
    );
  }
}