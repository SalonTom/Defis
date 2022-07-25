class User {
  final String? email;
  final bool isAdmin;
  final String? uid;
  final String? nom_equipe;

  User(this.email, this.isAdmin, this.uid, this.nom_equipe);

  static User fromMap(dynamic objet) {
    return User(objet["email"], objet["isAdmin"], objet["uid"], objet["nom_equipe"]);
  }
}