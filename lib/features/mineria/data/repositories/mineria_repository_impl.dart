import 'dart:io';
import '../../domain/entities/ocr_result.dart';
import '../../domain/repositories/mineria_repository.dart';
import '../datasources/remote/mineria_remote_datasource.dart';

class MineriaRepositoryImpl implements MineriaRepository {
  final MineriaRemoteDataSource remoteDataSource;
  const MineriaRepositoryImpl({required this.remoteDataSource});
  @override
  Future<OcrResult> procesarPdf(File archivo) async {
    return await remoteDataSource.procesarPdf(archivo);
  }

  @override
  Future<bool> checkSalud() async {
    return await remoteDataSource.checkSalud();
  }

  @override
  Future<Map<String, List<String>>> getCatalogos() {
    return remoteDataSource.getCatalogos();
  }

  @override
  Future<Map<String, dynamic>> predecirRiesgo(Map<String, dynamic> payload) {
    return remoteDataSource.predecirRiesgo(payload);
  }
}
