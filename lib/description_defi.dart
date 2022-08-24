import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:defis_inte/liste_defis.dart';
import 'package:defis_inte/model/defi.dart';
import 'package:defis_inte/model/defi_valide.dart';
import 'package:defis_inte/model/equipe.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class DescriptionDefi extends StatefulWidget {
  const DescriptionDefi({
    Key? key,
    required this.defi,
    required this.isAdmin,
    required this.uidUtilisateur,
    required this.equipe
  }) : super(key: key);

  final Defi defi;
  final bool isAdmin;
  final String? uidUtilisateur;
  final Equipe equipe;

  @override
  State<DescriptionDefi> createState() => _DescriptionDefiState();
}

class _DescriptionDefiState extends State<DescriptionDefi> {
  FirebaseFirestore bdd = FirebaseFirestore.instance;
  List<Equipe> equipes = [];
  List<DefiValide> listeDefisValides = [];
  List<String?> listeDefisValidesId = [];
  String? selectedEquipe;

  Future getEquipes() async {
    var donnees = await bdd.collection('equipes').get();

    setState(() {
      equipes = donnees.docs.map((equipe) => Equipe.fromMap(equipe)).toList();
    });
  }

  Future getDefiValide() async {
    var donnees = await bdd.collection('defis_valides_equipes').where("id_defi", isEqualTo: widget.defi.id).get();
    setState(() {
      listeDefisValides = donnees.docs.map((e) => DefiValide.fromMap(e)).toList();
      listeDefisValidesId = listeDefisValides.map((defi) => defi.id_defi).toList();
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

  bool defiIsDone(String? defiId) {
    return listeDefisValidesId.contains(defiId);
  }

  Color getCheckColor(String? defiId) {
    return defiIsDone(defiId) && listeDefisValides.map((e) => e.nom_equipe).toList().contains(widget.equipe.nom) ? Colors.green : Colors.yellow.shade700;
  }

  Widget getDesciptionScreen() {
    if (widget.isAdmin) {
      bool defiOkByAllTeams = false;
      List<String?> listeNomEquipeDoneDefi = listeDefisValides.map((e) => e.nom_equipe).toList();

      if(listeNomEquipeDoneDefi.length == equipes.length) {
        defiOkByAllTeams = true;
      }

      if (!defiOkByAllTeams) {
        return Column(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width - 20,
              child: DropdownButton<String>(
                value: selectedEquipe,
                isExpanded: true,
                style: const TextStyle(color: Colors.white),
                hint: const Center(child:Text('Saisir une équipe', style: TextStyle(color: Colors.white))),
                icon: const Icon(
                  Icons.arrow_drop_down, 
                  color: Colors.white, // <-- SEE HERE
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedEquipe = newValue;
                  });
                },
                selectedItemBuilder: (BuildContext context) { //<-- SEE HERE
                  return equipes
                      .map((value) {
                    return Center(child: Text(
                      selectedEquipe == null ? '' : selectedEquipe as String,
                      style: const TextStyle(color: Colors.white),
                    ));
                  }).toList();
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
              width: MediaQuery.of(context).size.width - 20,
              child: OutlinedButton(
                onPressed: selectedEquipe == null ? null : 
                () {
                  addDefiValide().then((value) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DescriptionDefi(defi: widget.defi, isAdmin: widget.isAdmin, uidUtilisateur: widget.uidUtilisateur, equipe: widget.equipe)
                      )
                    );
                  });
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.black,
                  primary: Colors.white,
                  side: const BorderSide(color: Colors.white, width: 2), //<-- SEE HERE
                ),
                child: const Text("Valider pour cette équipe", style: TextStyle(color: Colors.white),),),
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

  double? getCompletion() {
    var count = listeDefisValidesId.map((e) => e == widget.defi.id).length;
    return equipes.isEmpty ? 0 : count/equipes.length;
  }

  getCount() {
    if (!widget.isAdmin) {
      return Icon(
        defiIsDone(widget.defi.id) ? Icons.check : Icons.access_time_outlined,
        color: widget.isAdmin ? Colors.black : getCheckColor(widget.defi.id),
        size: 85,
      );
    } else {
      var count = listeDefisValidesId.map((e) => e == widget.defi.id).length;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('$count / ${equipes.length}', style: const TextStyle(fontSize: 20)),
          const Text('équipes ont complété le défi', textAlign: TextAlign.center)
        ]
      );
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
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 200,
                  margin: const EdgeInsets.all(10.0),
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                    color: Colors.white
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child : Column(
                          children: [
                            Row(
                              children: [
                                Expanded(child: Text(widget.defi.titre as String, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),)
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 5.0),
                              child: Row(
                                children: [
                                  Expanded(child: Text(widget.defi.description as String))
                                ],
                              ),
                            ) 
                          ],
                        )
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: Container(
                              height: 85,
                              width: 85,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(width: 2.0, color: widget.isAdmin? Colors.black : getCheckColor(widget.defi.id)),
                              ),
                              child : Center(
                                child: Text(
                                  '${widget.defi.points}',
                                  style: TextStyle(
                                    color: widget.isAdmin ? Colors.black : getCheckColor(widget.defi.id),
                                    fontSize: 25,
                                  ),
                                )
                              ),
                            ),
                          ),
                          Container(
                            height: 80,
                            decoration: const BoxDecoration(border: Border(right: BorderSide(color: Colors.grey, width: 3.0))),
                            child: const Text('')
                          ),
                          Expanded(
                            child: Container(child: getCount(), padding: const EdgeInsets.only(left: 10.0),),
                          )
                        ],
                      )
                    ],
                  )
                )
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10.0),
            child: getDesciptionScreen(),
          )
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children : [
            IconButton(
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
              icon: const Icon(Icons.view_list_rounded, color: Colors.white,)
            ),
          ]
        )
      ),
    );
  }
}