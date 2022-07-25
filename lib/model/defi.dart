class Defi {
  final String? id;
  final String? titre;
  final String? description;
  final int? points;

  Defi(this.id, this.titre, this.description, this.points);

  static Defi fromMap(dynamic object) {
    return Defi(object.id, object['titre'], object['description'], object['points']);
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> propertiesMap = <String, dynamic>{};
    propertiesMap['titre'] = titre;
    propertiesMap['description'] = description;
    propertiesMap['points'] = points;

    return propertiesMap;
  }
}