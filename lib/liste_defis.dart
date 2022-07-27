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
  List<Equipe> equipes = [];
  Authentification authentification = Authentification();

  Equipe equipe = Equipe('', '', 0);
  User user = User("", false, "", "");
  Color iconColor = Colors.white;

  Future<List<Defi>> getDefis() async {
    var donnees = await bdd.collection('defis').get();
    defis = donnees.docs.map((defi) => Defi.fromMap(defi)).toList();
    for (var defi in defis) {
      print('====> DEFI : ${defi.id}');
    }

    return defis;
  }

  
  Future getEquipes() async {
    var donnees = await bdd.collection('equipes').get();

    setState(() {
      equipes = donnees.docs.map((equipe) => Equipe.fromMap(equipe)).toList();
    });
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
          defis = listeDefis;
        },),
        getDefisValides().then((listeDefisValides) => {
          setState(() {
            defisValidesId = listeDefisValides.map((defi) => defi.id_defi).toList();
          }),
          getEquipes().then((value) => null),
          getTeam().then((value) => null),
        })
      }),
    });
    super.initState();
  }

  Color getCheckColor(String? defiId) {
    return defiIsDone(defiId) ? Colors.green : Colors.yellow.shade700;
  }

  bool defiIsDone(String? defiId) {
    return defisValidesId.contains(defiId);
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
      return "Aucune équipe n'a fait ce défi.";
    } else {
      return temp.join(', ');
    }
  }

  Widget getCompletion() {
    double completion = defis.isNotEmpty ? defisValides.length/defis.length : 0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            value: completion,
            color: Colors.green,
            backgroundColor: Colors.grey,
          )
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            '${(completion*100).truncate()}% des défis validés !',
          )
        )
      ],
    );
  }

  Widget getHeader() {
    return Container(
      height: 150,
      margin: const EdgeInsets.all(5.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: const BorderRadius.all(Radius.circular(5.0)),
        color: Colors.white
      ),
      child: Row(
        children: [
          SizedBox(
            width: 2*MediaQuery.of(context).size.width/3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  user.nom_equipe as String,
                  style: const TextStyle(
                    fontSize: 40
                  ) 
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: user.isAdmin ? null : getCompletion()
                )             
              ],
            ),
          ),
          Expanded(
            child: Center(
              child : Container(
                margin: const EdgeInsets.only(right: 5, top: 5),
                width: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade900
                ),
                child: Center(
                  child: user.isAdmin ? 
                    const Icon(Icons.shield_outlined, size: 70, color: Colors.white,) : 
                      Text('${equipe.points}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 35
                      ),
                  )
                )
              ),
            )
          )
        ],
      )
    );
  }

  double? getLinearCompletion(String? defiId) {
    var count = defisValidesId.where((e) => e == defiId).toList().length;
    return equipes.isEmpty ? 0 : count/equipes.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
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
          Expanded(
            child: user.isAdmin ? listeDefiAdmin() : listeDefisNonAdmin()
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children : [
            IconButton(
              onPressed: null, 
              icon: Icon(Icons.view_list_rounded, color: iconColor)
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
              icon: Icon(Icons.leaderboard, color: iconColor,),
            ),
          ]
        )
      ),
    );
  }


  Widget listeDefisNonAdmin() {

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: defis.length,
      itemBuilder: (context, index) {
        var defi = defis[index];
        return Container(
          margin: const EdgeInsets.only(top: 5.0, left: 5.0, right: 5.0),
          decoration: BoxDecoration(
            border: Border.all(),
            borderRadius: const BorderRadius.all(Radius.circular(5.0)),
            color: defiIsDone(defi.id) ? Colors.green.shade100 : Colors.white
          ),
          child: ListTile(
            style: ListTileStyle.list,
            leading: Container(
              width: 35,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(width: 2.0, color: getCheckColor(defi.id)),
              ),
              child : Center(
                child: Text(
                  '${defi.points}',
                  style: TextStyle(
                    color: getCheckColor(defi.id),
                  ),
                )
              ),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start, 
              children: [
                Text(defi.titre as String)
              ]
            ),
            trailing: Icon(
              defiIsDone(defi.id) ? Icons.check : Icons.access_time_outlined,
              color: getCheckColor(defi.id),
              size: 35,
            ),
            subtitle: user.isAdmin ? 
              Text(getSubtitles(defi)) : null,
            onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DescriptionDefi(defi: defi, isAdmin: user.isAdmin, uidUtilisateur: user.uid,)
                )
              )
            },
          ),
        );
      }
    );
  }

  Widget listeDefiAdmin() {

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: defis.length,
      itemBuilder: (context, index) {
        var defi = defis[index];
        return Container(
          margin: const EdgeInsets.only(top: 5.0, left: 5.0, right: 5.0),
          decoration: BoxDecoration(
            border: Border.all(),
            borderRadius: const BorderRadius.all(Radius.circular(5.0)),
            color: Colors.white
          ),
          child: ListTile(
            style: ListTileStyle.list,
            leading: Container(
              width: 35,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(width: 2.0, color: Colors.black),
              ),
              child : Center(
                child: Text(
                  '${defi.points}',
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                )
              ),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start, 
              children: [
                Text(defi.titre as String),
              ]
            ),
            trailing: CircularProgressIndicator(
              value: getLinearCompletion(defi.id),
              color: Colors.green,
              backgroundColor: Colors.grey,
            ),
            subtitle: Text(getSubtitles(defi)),
            onTap: () => {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => DescriptionDefi(defi: defi, isAdmin: user.isAdmin, uidUtilisateur: user.uid,)
                )
              )
            },
          ),
        );
      }
    );
  }
}
