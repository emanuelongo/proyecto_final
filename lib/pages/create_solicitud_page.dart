import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../models/enums.dart';
import '../models/insumo.dart';
import '../models/solicitud.dart';
import '../services/auth_service.dart';
import '../services/rules_service.dart';
import '../services/service_registry.dart';
import '../widgets/loading_state.dart';

class CreateSolicitudPage extends StatefulWidget {
  const CreateSolicitudPage({super.key});

  @override
  State<CreateSolicitudPage> createState() => _CreateSolicitudPageState();
}

class _CreateSolicitudPageState extends State<CreateSolicitudPage> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final RulesService _rulesService = const RulesService();
  final AuthService _authService = AuthService();
  
  // CORRECCIÓN ANTERIOR: Mantenemos el ID como un String plano
  String? _selectedInsumoId; 
  
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _submit(List<Insumo> insumos) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = _authService.currentUser;
    if (user == null) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      return;
    }

    final selectedId = _selectedInsumoId;
    if (selectedId == null) {
      setState(() {
        _error = 'Selecciona un insumo.';
      });
      return;
    }

    final selectedInsumo = insumos.firstWhere((insumo) => insumo.id == selectedId);

    final lotes = await ServiceRegistry.lotes.getByInsumo(selectedInsumo.id);
    final hasValidLote = lotes.any((lote) => !_rulesService.isLoteExpired(lote) && lote.quantity > 0);
    if (!hasValidLote) {
      setState(() {
        _error = 'No hay lotes vigentes disponibles.';
      });
      return;
    }

    final qty = int.tryParse(_quantityController.text.trim()) ?? 0;
    if (!_rulesService.validateStock(selectedInsumo.totalQuantity, qty)) {
      setState(() {
        _error = 'Cantidad no disponible en inventario.';
      });
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    final solicitud = Solicitud(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      insumoId: selectedInsumo.id,
      requestedBy: user.uid,
      quantity: qty,
      status: SolicitudStatus.requested,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      syncStatus: SyncStatus.pendingSync,
    );

    try {
      await ServiceRegistry.solicitudes.upsertLocal(solicitud, markPending: true);
      await ServiceRegistry.syncService.syncAll();
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'No se pudo crear la solicitud.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final stream = ServiceRegistry.insumos.watchLocal();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva solicitud'),
      ),
      body: StreamBuilder<List<Insumo>>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingState();
          }
          final insumos = snapshot.data ?? [];
          if (insumos.isEmpty) {
            return const Center(
              child: Text('No hay insumos disponibles.'),
            );
          }

          return SafeArea(
            // NUEVA CORRECCIÓN: LayoutBuilder nos da las restricciones exactas de altura libre en pantalla
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  // Forzamos a que el scroll sea responsivo ante el teclado físico y en pantalla
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      // El alto mínimo se adapta dinámicamente restando el espacio que ocupe el teclado
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Completa la solicitud',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Verifica el stock disponible antes de enviar.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 16),
                            
                            DropdownButtonFormField<String>(
                              value: _selectedInsumoId,
                              items: insumos
                                  .map(
                                    (insumo) => DropdownMenuItem<String>(
                                      value: insumo.id,
                                      child: Text('${insumo.name} (${insumo.totalQuantity} ${insumo.unit})'),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedInsumoId = value;
                                });
                              },
                              decoration: const InputDecoration(labelText: 'Insumo'),
                              validator: (value) => value == null ? 'Selecciona un insumo.' : null,
                            ),
                            
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _quantityController,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.done,
                              decoration: const InputDecoration(labelText: 'Cantidad'),
                              validator: (value) {
                                final parsed = int.tryParse(value ?? '');
                                if (parsed == null || parsed <= 0) {
                                  return 'Cantidad invalida.';
                                }
                                return null;
                              },
                              onFieldSubmitted: (_) => _submit(insumos),
                            ),
                            const SizedBox(height: 16),
                            if (_error != null) ...[
                              Text(
                                _error!,
                                style: TextStyle(color: Theme.of(context).colorScheme.error),
                              ),
                              const SizedBox(height: 12),
                            ],
                            
                            // Un Spacer flexible para empujar el botón al fondo si hay espacio libre, 
                            // pero que se encoge a cero si el teclado se levanta.
                            const Spacer(),
                            const SizedBox(height: 16),
                            
                            FilledButton(
                              onPressed: _submitting ? null : () => _submit(insumos),
                              child: _submitting
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Text('Enviar solicitud'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}