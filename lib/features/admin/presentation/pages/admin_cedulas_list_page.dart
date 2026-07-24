import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sums/core/di/providers.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../cedula_orquestador/presentation/viewmodels/cedula_viewmodel.dart';

class AdminCedulasListPage extends ConsumerStatefulWidget {
  const AdminCedulasListPage({super.key});
  @override
  ConsumerState<AdminCedulasListPage> createState() =>
      _AdminCedulasListPageState();
}

class _AdminCedulasListPageState extends ConsumerState<AdminCedulasListPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;
  
  String _searchQuery = '';
  List<CedulaListItem>? _remoteCedulas;
  String? _errorMessage;
  
  int _page = 1;
  int _totalPages = 1;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRemoteCedulas(isRefresh: true);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _hasMore && _errorMessage == null) {
        _loadRemoteCedulas(isRefresh: false);
      }
    }
  }

  Future<void> _loadRemoteCedulas({bool isRefresh = false}) async {
    if (isRefresh) {
      setState(() {
        _page = 1;
        _hasMore = true;
        _errorMessage = null;
      });
    } else {
      setState(() {
        _isLoadingMore = true;
        _errorMessage = null;
      });
    }

    try {
      final paginatedData = await ref.read(cedulaViewModelProvider).cedulaRepository.getRemoteCedulas(
        page: _page,
        limit: 50,
        search: _searchQuery,
      );
      
      if (mounted) {
        setState(() {
          if (isRefresh) {
            _remoteCedulas = paginatedData.data;
          } else {
            _remoteCedulas?.addAll(paginatedData.data);
          }
          
          _totalPages = paginatedData.totalPages;
          _hasMore = _page < _totalPages;
          
          if (_hasMore) {
            _page++;
          }
          
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoadingMore = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cédulas Registradas'),
        backgroundColor: AppColors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _remoteCedulas = null;
              });
              _loadRemoteCedulas(isRefresh: true);
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Filtros próximamente')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Theme.of(context).colorScheme.surface,
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre del informante...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusM),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) {
                if (_debounce?.isActive ?? false) _debounce!.cancel();
                _debounce = Timer(const Duration(milliseconds: 500), () {
                  setState(() {
                    _searchQuery = value.trim();
                    _remoteCedulas = null;
                  });
                  _loadRemoteCedulas(isRefresh: true);
                });
              },
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                'Error al cargar las cédulas: $_errorMessage',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _errorMessage = null;
                  });
                  if (_remoteCedulas == null) {
                    _loadRemoteCedulas(isRefresh: true);
                  } else {
                    _loadRemoteCedulas(isRefresh: false);
                  }
                },
                child: const Text('Reintentar'),
              )
            ],
          ),
        ),
      );
    }

    if (_remoteCedulas == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final records = _remoteCedulas!;

    if (records.isEmpty) {
      return const Center(
        child: Text(
          'No se encontraron cédulas.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: records.length + (_isLoadingMore ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == records.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        final record = records[index];
        final informante = record.informanteNombre ?? 'Sin nombre';
        final fechaStr = record.fechaRegistro != null 
            ? '${record.fechaRegistro!.year}-${record.fechaRegistro!.month.toString().padLeft(2, '0')}-${record.fechaRegistro!.day.toString().padLeft(2, '0')}' 
            : '';
        final statusText = record.estado.toUpperCase();
        Color statusColor = AppColors.green;
        
        if (record.estado == 'borrador') {
          statusColor = Colors.orange;
        } else if (record.estado == 'cerrada') {
          statusColor = Colors.grey;
        }

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusM),
            side: BorderSide(
              color: Theme.of(context).dividerTheme.color ?? AppColors.line,
            ),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: statusColor.withOpacity(0.1),
              child: Icon(Icons.assignment, color: statusColor),
            ),
            title: Text(
              informante,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Fecha: $fechaStr\nEstado: $statusText',
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  context.push(AppRoutes.cedula);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit,
                        size: 20,
                        color: AppColors.ink,
                      ),
                      SizedBox(width: 8),
                      Text('Ver / Editar Cédula'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
