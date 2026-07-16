import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sums/features/mineria/data/datasources/remote/mineria_remote_datasource.dart';
import 'package:sums/features/mineria/data/models/mineria_result_model.dart';
import 'package:sums/features/mineria/data/models/riesgo_familiar_model.dart';

void main() {
  group('MineriaRemoteDataSource Tests', () {
    test('buscarCasos retorna una lista de MineriaResultModel cuando el status es 200', () async {
      // MOCK DATA
      final mockResponse = {
        "resultados": [
          {
            "posicion": 1,
            "id": "ced123",
            "titulo": "Juan Perez",
            "score": 0.95,
            "texto": "Nota médica..."
          }
        ]
      };

      final mockClient = MockClient((request) async {
        return http.Response(jsonEncode(mockResponse), 200, headers: {
          'content-type': 'application/json; charset=utf-8',
        });
      });

      final dataSource = MineriaRemoteDataSourceImpl(client: mockClient);

      // EJECUCIÓN
      final result = await dataSource.buscarCasos('consulta');

      // VERIFICACIÓN
      expect(result, isA<List<MineriaResultModel>>());
      expect(result.length, 1);
      expect(result.first.titulo, 'Juan Perez');
      expect(result.first.score, 0.95);
    });

    test('getRiesgoLista retorna una lista de RiesgoFamiliarModel cuando el status es 200', () async {
      // MOCK DATA
      final mockResponse = [
        {
          "index": 0,
          "informante_nombre": "Maria Lopez",
          "colonia": "Centro",
          "probabilidad_alto": 0.98
        }
      ];

      final mockClient = MockClient((request) async {
        return http.Response(jsonEncode(mockResponse), 200, headers: {
          'content-type': 'application/json; charset=utf-8',
        });
      });

      final dataSource = MineriaRemoteDataSourceImpl(client: mockClient);

      // EJECUCIÓN
      final result = await dataSource.getRiesgoLista();

      // VERIFICACIÓN
      expect(result, isA<List<RiesgoFamiliarModel>>());
      expect(result.length, 1);
      expect(result.first.informanteNombre, 'Maria Lopez');
      expect(result.first.probabilidadAlto, 0.98);
    });

    test('Lanza ServerException cuando hay un error inesperado', () async {
      final mockClient = MockClient((request) async {
        throw http.ClientException('Error de red');
      });
      
      final dataSource = MineriaRemoteDataSourceImpl(client: mockClient);

      expect(() => dataSource.buscarCasos('q'), throwsA(isA<ServerException>()));
    });
  });
}
