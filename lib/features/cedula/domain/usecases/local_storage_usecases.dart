import '../entities/pending_cedula.dart';
import '../repositories/cedula_repository.dart';

class GetPendingRecordsUseCase {
  final CedulaRepository repository;
  GetPendingRecordsUseCase(this.repository);
  Future<List<PendingCedula>> call() => repository.getPendingRecords();
}

class SaveLocalRecordUseCase {
  final CedulaRepository repository;
  SaveLocalRecordUseCase(this.repository);
  Future<int> call(PendingCedula record) => repository.saveLocalRecord(record);
}

class DeleteLocalRecordUseCase {
  final CedulaRepository repository;
  DeleteLocalRecordUseCase(this.repository);
  Future<void> call(int id) => repository.deleteLocalRecord(id);
}
