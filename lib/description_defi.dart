import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:defis_inte/leader_board.dart';
import 'package:defis_inte/liste_defis.dart';
import 'package:defis_inte/model/defi.dart';
import 'package:defis_inte/model/defi_valide.dart';
import 'package:defis_inte/model/equipe.dart';
import 'package:flutter/material.dart';

class DescriptionDefi extends StatefulWidget {
  const DescriptionDefi({
    Key? key,
    required this.defi,
    required this.isAdmin,
    required this.uidUtilisateur
  }) : super(key: key);

  final Defi defi;
  final bool isAdmin;
  final String? uidUtilisateur;

  @override
  State<DescriptionDefi> createState() => _DescriptionDefiState();
}

class _DescriptionDefiState extends State<DescriptionDefi> {
  FirebaseFirestore bdd = FirebaseFirestore.instance;
  List<Equipe> equipes = [];
  List<DefiValide> listeDefisValides = [];
  String? selectedEquipe;

  Future getEquipes() async {
    var donnees = await bdd.collection('equipes').get();

    setState(() {
      equipes = donnees.docs.map((equipe) => Equipe.fromMap(equipe)).toList();
      // selectedEquipe = equipes[0].nom as String;
    });
  }

  Future getDefiValide() async {
    var donnees = await bdd.collection('defis_valides_equipes').where("id_defi", isEqualTo: widget.defi.id).get();
    setState(() {
      listeDefisValides = donnees.docs.map((e) => DefiValide.fromMap(e)).toList();
    });
  }

  Future addDefiValide() async {
    DefiValide newDefiValide = DefiValide(null, widget.defi.id, selectedEquipe);
    await bdd.collection('defis_valides_equipes').add(newDefiValide.toMap());
    var data = await bdd.collection('equipes').where("nom", isEqualTo: selectedEquipe).get();
    Equipe equipe = (data.docs.map((user) => Equipe.fromMap(user)).toList())[0];

    equipe.points = (equipe.points as int) + (widget.defi.points as int);

    await bdd.collection('equipes').doc(equipe.id).update(equipe.toMap());

    setState(() {
      selectedEquipe = null;
    });
  }

  Widget getDesciptionScreen() {
    if (widget.isAdmin) {
      bool defiOkByAllTeams = false;
      List<String?> listeNomEquipeDoneDefi = listeDefisValides.map((e) => e.nom_equipe).toList();

      if(listeNomEquipeDoneDefi.length == equipes.length) {
        defiOkByAllTeams = true;
      }

      if (!defiOkByAllTeams) {
        return Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width/2,
              child: DropdownButton<String>(
                value: selectedEquipe,
                isExpanded: true,
                hint: const Text('Saisir une équipe'),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedEquipe = newValue;
                  });
                },
                items: equipes.map((equipe) {
                  return DropdownMenuItem(
                    value: equipes.isEmpty ? "Chargement" : equipe.nom,
                    enabled: !listeNomEquipeDoneDefi.contains(equipe.nom),
                    child: Text(
                      equipe.nom as String,
                      style: TextStyle(
                        color: !listeNomEquipeDoneDefi.contains(equipe.nom) ? Colors.black : Colors.grey
                      ),
                    ),
                  );
                }).toList()
              )
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width/2,
              child: ElevatedButton(
                onPressed: selectedEquipe == null ? null : 
                () {
                  addDefiValide().then((value) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DescriptionDefi(defi: widget.defi, isAdmin: widget.isAdmin, uidUtilisateur: widget.uidUtilisateur,)
                      )
                    );
                  });
                },
                child: const Text("Valider pour cette équipe"),),
            )
          ]
        );
      } else {
        return const Text('Défi ok pour toutes les teams');
      }
    } else {
      return const Text('');
    }
  }

  @override
  void initState() {
    getEquipes().then((value) {});
    getDefiValide().then((value) {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.defi.titre as String),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(child:Text(widget.defi.description as String), ),
            ],
          ),
          Row(
            children: [
              getDesciptionScreen(),
            ],
          )
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children : [
            TextButton(
              onPressed: () {
                if (widget.isAdmin) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ListeDefis(uidUtilisateur: widget.uidUtilisateur as String)
                    )
                  );
                } else {
                  Navigator.pop(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ListeDefis(uidUtilisateur: widget.uidUtilisateur as String)
                    )
                  );
                }
              }, 
              child: const Text("Retour à la liste")
            ),
          ]
        )
      ),
    );
  }
}