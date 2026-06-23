abstract class VacunacionRepository {
  Future<List<String>> getVacunasOpts();
  Future<List<String>> getDosisOpts();
}
