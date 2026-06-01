import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../models/enums.dart';
import '../models/insumo.dart';
import '../services/auth_service.dart';
import '../services/movement_service.dart';
import '../services/service_registry.dart';

class MovementPage extends StatefulWidget {
  const MovementPage({super.key, required this.insumo});

  final Insumo insumo;

  @override
  State<MovementPage> createState() => _MovementPageState();
}

class _MovementPageState extends State<MovementPage> {
  static const Color primaryPurple = Color(0xFF8F5DFA);
  static const Color accentGreen = Color(0xFFB0FA5D);

  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final AuthService _authService = AuthService();
  final MovementService _movementService = ServiceRegistry.movementService;
  MovementType _type = MovementType.outbound;
  DateTime? _expirationDate;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
      initialDate: _expirationDate ?? now,
    );
    if (picked != null) {
      setState(() {
        _expirationDate = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = _authService.currentUser;
    if (user == null) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      return;
    }

    final qty = int.tryParse(_quantityController.text.trim()) ?? 0;
    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      if (_type == MovementType.inbound) {
        await _movementService.registerInbound(
          insumo: widget.insumo,
          quantity: qty,
          userId: user.uid,
          expirationDate: _expirationDate,
        );
      } else {
        await _movementService.registerOutbound(
          insumo: widget.insumo,
          quantity: qty,
          userId: user.uid,
        );
      }
      await ServiceRegistry.syncService.syncAll();
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _error = 'No se pudo registrar el movimiento.';
      });
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
    final insumo = widget.insumo;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        title: const Text(
          'Registrar movimiento',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        primaryPurple,
                        Color(0xFF7B4FE0),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Insumo: ${insumo.name}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Registra entradas o salidas con control de lotes.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                      ),
                      const SizedBox(height: 12),
                      Chip(
                        label: Text(
                          _type == MovementType.inbound ? 'Entrada' : 'Salida',
                          style: const TextStyle(color: Colors.black87),
                        ),
                        backgroundColor: accentGreen,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                DropdownButtonFormField<MovementType>(
                  value: _type,
                  items: const [
                    DropdownMenuItem(
                      value: MovementType.outbound,
                      child: Text('Salida'),
                    ),
                    DropdownMenuItem(
                      value: MovementType.inbound,
                      child: Text('Entrada'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    setState(() {
                      _type = value;
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Tipo de movimiento'),
                ),
                const SizedBox(height: 16),
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
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 16),
                if (_type == MovementType.inbound)
                  OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.event),
                    label: Text(
                      _expirationDate == null
                          ? 'Seleccionar vencimiento'
                          : 'Vence: ${_expirationDate!.toLocal().toString().split(' ').first}',
                    ),
                  ),
                const SizedBox(height: 16),
                if (_error != null) ...[
                  Text(
                    _error!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                  const SizedBox(height: 12),
                ],
                FilledButton(
                  onPressed: _submitting ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: accentGreen,
                    foregroundColor: Colors.black87,
                  ),
                  child: _submitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Guardar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MovementArgs {
  MovementArgs(this.insumo);

  final Insumo insumo;
}
