// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:defis_inte/description_defi.dart';
import 'package:defis_inte/login.dart';
import 'package:defis_inte/model/equipe.dart';
import 'package:defis_inte/model/user.dart';
import 'package:defis_inte/utils/authentification.dart';
import 'package:flutter/material.dart';
import 'package:defis_inte/leader_board.dart';
import 'package:defis_inte/model/defi.dart';
import 'package:defis_inte/model/defi_valide.dart';

class ListeDefis extends StatefulWidget {
  const ListeDefis({Key? key, required this.uidUtilisateur}) : super(key: key);

  final String uidUtilisateur;

  @override
  State<ListeDefis> createState() => _ListeDefisState();
}

class _ListeDefisState extends State<ListeDefis> {

  FirebaseFirestore bdd = FirebaseFirestore.instance;
  List<Defi> defis = [];
  List<DefiValide> defisValides = [];
  List<String?> defisValidesId = [];
  Authentification authentification = Authentification();

  Equipe equipe = Equipe('', '', 0);
  User user = User("", false, "", "");

  Future<List<Defi>> getDefis() async {
    var donnees = await bdd.collection('defis').get();
    defis = donnees.docs.map((defi) => Defi.fromMap(defi)).toList();
    for (var defi in defis) {
      print('====> DEFI : ${defi.id}');
    }

    return defis;
  }

  Future<List<DefiValide>> getDefisValides() async {
    QuerySnapshot<Map<String, dynamic>> donnees;
    if (user.isAdmin) {
      donnees = await bdd.collection('defis_valides_equipes').get();
    } else {
      donnees = await bdd.collection('defis_valides_equipes').where("nom_equipe", isEqualTo: user.nom_equipe).get();
    }
    defisValides = donnees.docs.map((defiValide) => DefiValide.fromMap(defiValide)).toList();
    for (var defi in defisValides) {
      print('====> DEFI VALIDE : ${defi.id}');
    }

    return defisValides;
  }

  Future<User> getUser() async {
    var donnees = await bdd.collection('users').where('uid', isEqualTo: widget.uidUtilisateur).get();
    user = (donnees.docs.map((user) => User.fromMap(user)).toList())[0];

    print('====> USER CONNECTED : ${user.email}');

    return user;
  }

  Future<Equipe> getTeam() async {
    var donnees = await bdd.collection('equipes').where('nom', isEqualTo: user.nom_equipe).get();
    var team = (donnees.docs.map((team) => Equipe.fromMap(team)).toList())[0];

    print('====> TEAM CONNECTED : ${team.nom}');

    setState(() {
      equipe = team;
    });

    return equipe;
  }

  @override
  void initState() {
    getUser().then((value) => {
      setState(() {
        user = value;
      }),
      getDefis().then((listeDefis) => {
        setState(() {
          this.defis = listeDefis;
        },),
        getDefisValides().then((listeDefisValides) => {
          setState(() {
            this.defisValidesId = listeDefisValides.map((defi) => defi.id_defi).toList();
          })
        })
      }),
      getTeam().then((value) => null)
    });
    super.initState();
  }

  Color? getTileColor(String? defiId) {
    var color;
    color = defisValidesId.contains(defiId) ? Colors.green : null;
    return color;
  }

  getSubtitles(Defi defi) {
    List<dynamic> temp = defisValides.map((defiValide) {
        if(defiValide.id_defi == defi.id) {
          return defiValide.nom_equipe;
        }
        return null;
      }).toList();
    
    temp.removeWhere((element) => element == null);
    if (temp.isEmpty) {
      return "Aucune equipe n'a fait ce défi.";
    } else {
      return temp.join(', ');
    }
  }

  Widget getHeader() {
    return Container(
      height: MediaQuery.of(context).size.height/6,
      margin: const EdgeInsets.all(5.0),
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: const BorderRadius.all(Radius.circular(5.0))
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text(user.nom_equipe as String),
              Text('${equipe.points}')                
            ],
          ),
          const Center(
            child : Text("#1")
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des défis'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ListeDefis(uidUtilisateur: widget.uidUtilisateur)
                )
              );
            },
            icon: const Icon(Icons.refresh)
          ),
          IconButton(
            onPressed: () {
              authentification.deconnexion().then((value) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Login()
                  )
                );
              });
            },
            icon: const Icon(Icons.logout)
          ),
        ],
      ),
      body: Column(
        children: [
          getHeader(),
          ListView.builder(
            shrinkWrap: true,
            itemCount: defis.length,
            itemBuilder: (context, index) {
              var defi = defis[index];
              return Container(
                margin: const EdgeInsets.only(top: 5.0, left: 5.0, right: 5.0),
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                  color: !user.isAdmin ? getTileColor(defi.id) : null
                ),
                child: ListTile(
                  style: ListTileStyle.list,
                  leading: SizedBox(
                    width: 20,
                    child : Center(child: Text('#${index + 1}')),
                  ),
                  title: Text(defi.titre as String),
                  trailing: Text('${defi.points}'),
                  subtitle: user.isAdmin ? 
                    Text(getSubtitles(defi)) : null,
                  onTap: () => {
                    if(user.isAdmin) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DescriptionDefi(defi: defi, isAdmin: user.isAdmin, uidUtilisateur: user.uid,)
                        )
                      )
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DescriptionDefi(defi: defi, isAdmin: user.isAdmin, uidUtilisateur: user.uid,)
                        )
                      )
                    }
                  },
                ),
              );
            }
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children : [
            const IconButton(
              onPressed: null, 
              icon: Icon(Icons.view_list_rounded)
            ),
            IconButton(
              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LeaderBoard(uidUtilisateur: widget.uidUtilisateur,),
                  )
                );
              }, 
              icon: const Icon(Icons.leaderboard),
            ),
          ]
        )
      ),
    );
  }
}
