import 'package:flutter/material.dart';

class DialogoTexto extends StatefulWidget {
  const DialogoTexto({
    super.key,
    required this.titulo,
    required this.etiqueta,
    required this.mensajeObligatorio,
    this.subtitulo,
    this.hint,
    this.maxLength,
  });

  final String titulo;
  final String etiqueta;
  final String mensajeObligatorio;
  final String? subtitulo;
  final String? hint;
  final int? maxLength;

  static Future<String?> mostrar(
    BuildContext context, {
    required String titulo,
    required String etiqueta,
    required String mensajeObligatorio,
    String? subtitulo,
    String? hint,
    int? maxLength,
  }) {
    return showDialog<String>(
      context: context,
      builder: (_) => DialogoTexto(
        titulo: titulo,
        etiqueta: etiqueta,
        mensajeObligatorio: mensajeObligatorio,
        subtitulo: subtitulo,
        hint: hint,
        maxLength: maxLength,
      ),
    );
  }

  @override
  State<DialogoTexto> createState() => _DialogoTextoState();
}

class _DialogoTextoState extends State<DialogoTexto> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _continuar() {
    final texto = _controller.text.trim();
    if (texto.isEmpty) {
      setState(() => _error = widget.mensajeObligatorio);
      return;
    }
    Navigator.of(context).pop(texto);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.titulo),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.subtitulo != null) ...[
              Text(widget.subtitulo!),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: _controller,
              autofocus: true,
              maxLines: 3,
              maxLength: widget.maxLength,
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
              decoration: InputDecoration(
                labelText: widget.etiqueta,
                hintText: widget.hint,
                errorText: _error,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _continuar, child: const Text('Continuar')),
      ],
    );
  }
}
