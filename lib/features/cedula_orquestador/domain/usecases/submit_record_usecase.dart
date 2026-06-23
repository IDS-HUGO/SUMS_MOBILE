import '../repositories/cedula_repository.dart';

class SubmitRecordUseCase {
  final CedulaRepository repository;

  const SubmitRecordUseCase(this.repository);

  Future<Map<String, dynamic>> submitCompleta(Map<String, dynamic> body) {
    return repository.submitCapturaCompleta(body);
  }

  /// Envío individual a un endpoint específico (uso secundario).
  Future<Map<String, dynamic>> call(
    String path,
    Map<String, dynamic> body, {
    bool patch = false,
  }) {
    if (patch) {
      return repository.patchRecord(path, body);
    }
    return repository.createRecord(path, body);
  }
}
