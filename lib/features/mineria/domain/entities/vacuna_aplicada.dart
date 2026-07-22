class VacunaAplicada {
  String? vacuna;
  String? dosis;
  VacunaAplicada({this.vacuna, this.dosis});
  Map<String, dynamic> toJson() => {'vacuna': vacuna, 'dosis': dosis};
  bool get isValid => vacuna != null && dosis != null;
}
