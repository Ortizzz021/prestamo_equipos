import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth_controller.dart';
import 'validadores.dart';
import 'widgets/auth_widgets.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmar = TextEditingController();

  @override
  void dispose() {
    _nombre.dispose();
    _email.dispose();
    _password.dispose();
    _confirmar.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    final auth = context.read<AuthController>();
    if (auth.cargando) return;
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    await auth.registrar(
      nombre: _nombre.text,
      email: _email.text,
      password: _password.text,
    );

    if (!mounted) return;
    if (auth.mensajeError == null && auth.perfil != null) {
      Navigator.of(context).popUntil((ruta) => ruta.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final error = auth.mensajeError;

    return PopScope(
      canPop: !auth.cargando,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) auth.limpiarError();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Crear cuenta')),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Las cuentas nuevas se crean con el rol Solicitante. '
                        'Los roles de coordinación y bodega los asigna el '
                        'administrador.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        key: const Key('registro_nombre'),
                        controller: _nombre,
                        enabled: !auth.cargando,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        validator: Validadores.nombre,
                        decoration: const InputDecoration(
                          labelText: 'Nombre completo',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        key: const Key('registro_email'),
                        controller: _email,
                        enabled: !auth.cargando,
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        textInputAction: TextInputAction.next,
                        validator: Validadores.email,
                        decoration: const InputDecoration(
                          labelText: 'Correo electrónico',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),
                      CampoPassword(
                        key: const Key('registro_password'),
                        controller: _password,
                        enabled: !auth.cargando,
                        etiqueta: 'Contraseña',
                        textInputAction: TextInputAction.next,
                        validator: Validadores.password,
                      ),
                      const SizedBox(height: 16),
                      CampoPassword(
                        key: const Key('registro_confirmar'),
                        controller: _confirmar,
                        enabled: !auth.cargando,
                        etiqueta: 'Confirmar contraseña',
                        validator: (v) =>
                            Validadores.confirmarPassword(v, _password.text),
                        onFieldSubmitted: (_) => _enviar(),
                      ),
                      const SizedBox(height: 24),
                      if (error != null) ...[
                        MensajeErrorAuth(mensaje: error),
                        const SizedBox(height: 16),
                      ],
                      BotonCargando(
                        key: const Key('registro_enviar'),
                        texto: 'Crear cuenta',
                        cargando: auth.cargando,
                        onPressed: _enviar,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
