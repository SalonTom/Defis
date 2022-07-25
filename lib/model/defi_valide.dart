class DefiValide {
  final String? id;
  final String? id_defi;
  final String? nom_equipe;

  DefiValide(this.id, this.id_defi, this.nom_equipe, );

  static DefiValide fromMap(dynamic object) {
    return DefiValide(object.id, object['id_defi'], object['nom_equipe']);
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> propertiesMap = <String, dynamic>{};
    propertiesMap['id_defi'] = id_defi;
    propertiesMap['nom_equipe'] = nom_equipe;

    return propertiesMap;
  }
}