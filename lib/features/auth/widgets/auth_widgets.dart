import 'package:flutter/material.dart';

/// Mensaje de error de autenticación visible sobre el botón principal.
class MensajeErrorAuth extends StatelessWidget {
  const MensajeErrorAuth({super.key, required this.mensaje});

  final String mensaje;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colores.errorContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: colores.onErrorContainer),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                mensaje,
                style: TextStyle(color: colores.onErrorContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Botón principal que se deshabilita y muestra un indicador mientras hay
/// una operación pendiente, para impedir envíos repetidos.
class BotonCargando extends StatelessWidget {
  const BotonCargando({
    super.key,
    required this.texto,
    required this.cargando,
    required this.onPressed,
  });

  final String texto;
  final bool cargando;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton(
        onPressed: cargando ? null : onPressed,
        child: cargando
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              )
            : Text(texto),
      ),
    );
  }
}

/// Campo de contraseña con botón para mostrar u ocultar el texto.
class CampoPassword extends StatefulWidget {
  const CampoPassword({
    super.key,
    required this.controller,
    required this.etiqueta,
    required this.validator,
    this.textInputAction = TextInputAction.done,
    this.onFieldSubmitted,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String etiqueta;
  final FormFieldValidator<String> validator;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final bool enabled;

  @override
  State<CampoPassword> createState() => _CampoPasswordState();
}

class _CampoPasswordState extends State<CampoPassword> {
  bool _oculto = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      enabled: widget.enabled,
      obscureText: _oculto,
      autocorrect: false,
      enableSuggestions: false,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onFieldSubmitted,
      validator: widget.validator,
      decoration: InputDecoration(
        labelText: widget.etiqueta,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          tooltip: _oculto ? 'Mostrar contraseña' : 'Ocultar contraseña',
          icon: Icon(_oculto ? Icons.visibility : Icons.visibility_off),
          onPressed: () => setState(() => _oculto = !_oculto),
        ),
      ),
    );
  }
}
