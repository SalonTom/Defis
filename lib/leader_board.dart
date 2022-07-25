import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:defis_inte/liste_defis.dart';
import 'package:defis_inte/model/equipe.dart';
import 'package:flutter/material.dart';

class LeaderBoard extends StatefulWidget {
  const LeaderBoard({Key? key, required this.uidUtilisateur}) : super(key: key);
  final String uidUtilisateur;

  @override
  State<LeaderBoard> createState() => _LeaderBoardState();
}

class _LeaderBoardState extends State<LeaderBoard> {

  FirebaseFirestore bdd = FirebaseFirestore.instance;
  List<Equipe> equipes = [];

  Future<List<Equipe>> getEquipes() async {
    var donnees = await bdd.collection('equipes').orderBy('points', descending: true).get();
    var equipes = donnees.docs.map((defiValide) => Equipe.fromMap(defiValide)).toList();

    return equipes;
  }

  Color getColor(int index) {
    Color? color;
    if (index == 0) {
      color = const Color.fromRGBO(255, 215, 0, 1);
    } else if (index == 1) {
      color = const Color.fromRGBO(192, 192, 192, 1);
    } else if (index == 2) {
      color = const Color.fromRGBO(196, 156, 72, 1);
    } else {
      color = Colors.black;
    }

    return color;
  }

  @override
  void initState() {
    getEquipes().then((liste) => {
      setState(() => {
        equipes = liste
      })
    });
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LeaderBoard'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: ListView.builder(
          itemCount: equipes.length,
          itemBuilder: (context, index) {
            var equipe = equipes[index];
            return Container(
              margin: const EdgeInsets.only(top: 5.0, left: 5.0, right: 5.0),
              decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                color: Colors.white,
              ),
              child: ListTile(
                style: ListTileStyle.list,
                leading: Container(
                  width: 35,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(width: 2.0, color: getColor(index)),
                  ),
                  child : Center(
                    child: Text(
                      '#${index+1}',
                      style: TextStyle(
                        color: getColor(index),
                      ),
                    )
                  ),
                ),
                title: Text(equipe.nom as String),
                trailing: Text(
                  '${equipe.points}',
                ),
              ),
            );
          }
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
            const IconButton(
              onPressed: null,
              icon: Icon(Icons.leaderboard, color: Colors.white,),
            ),
          ]
        )
      ),
    );
  }
}