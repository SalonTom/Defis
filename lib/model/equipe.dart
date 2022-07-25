class Equipe {
  final String? id;
  final String? nom;
  int? points;

  Equipe(this.id, this.nom, this.points);

  static Equipe fromMap(dynamic object) {
    return Equipe(object.id, object['nom'], object['points']);
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> propertiesMap = <String, dynamic>{};
    propertiesMap['points'] = points;
    propertiesMap['nom'] = nom;

    return propertiesMap;
  }
}