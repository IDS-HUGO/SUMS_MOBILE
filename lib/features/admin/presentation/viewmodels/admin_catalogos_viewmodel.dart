import 'package:flutter/foundation.dart';
import '../../../cedula_orquestador/domain/entities/catalog_item.dart';
import '../../domain/repositories/admin_repository.dart';
import '../../../cedula_orquestador/domain/usecases/load_catalogs_usecase.dart';

enum AdminCatalogosStatus { initial, loading, loaded, error }

class AdminCatalogosViewModel extends ChangeNotifier {
  final AdminRepository repository;
  final LoadCatalogsUseCase loadCatalogsUseCase;

  AdminCatalogosViewModel({
    required this.repository,
    required this.loadCatalogsUseCase,
  });

  AdminCatalogosStatus _status = AdminCatalogosStatus.initial;
  Map<String, List<CatalogItem>> _catalogos = {};
  String? _errorMessage;

  AdminCatalogosStatus get status => _status;
  Map<String, List<CatalogItem>> get catalogos => _catalogos;
  String? get errorMessage => _errorMessage;

  final List<String> catalogKeys = [
    'roles',
    'vacunas',
    'material_techo',
    'material_pared',
    'material_piso',
    'estado_civil',
    'enfermedades_cronicas',
    'padecimientos_detectados'
  ];

  Future<void> fetchAllCatalogs() async {
    _status = AdminCatalogosStatus.loading;
    notifyListeners();

    try {
      final Map<String, List<CatalogItem>> newCatalogs = {};
      for (final key in catalogKeys) {
        newCatalogs[key] = await repository.getCatalog(key);
      }
      _catalogos = newCatalogs;
      _status = AdminCatalogosStatus.loaded;
      _errorMessage = null;
    } catch (e) {
      _status = AdminCatalogosStatus.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<bool> createCatalogItem(String catalogName, String nombre, String? descripcion) async {
    _status = AdminCatalogosStatus.loading;
    notifyListeners();

    try {
      final body = {
        'nombre': nombre,
        if (descripcion != null && descripcion.isNotEmpty) 'descripcion': descripcion
      };
      
      final success = await repository.createCatalogItem(catalogName, body);
      if (success) {
        // Refrescar el catalogo localmente mandando llamar fetch
        await fetchAllCatalogs();
        // Forzar resincronización local en la base de datos sqlite
        await loadCatalogsUseCase();
        return true;
      } else {
        _status = AdminCatalogosStatus.error;
        _errorMessage = 'No se pudo crear la opción en el catálogo remoto';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _status = AdminCatalogosStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
