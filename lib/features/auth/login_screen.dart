import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth_controller.dart';
import 'registro_screen.dart';
import 'validadores.dart';
import 'widgets/auth_widgets.dart';

/// Inicio de sesión con correo y contraseña.
///
/// No navega por sí misma al terminar: el [AuthGate] escucha el perfil del
/// [AuthController] y muestra la pantalla del rol correspondiente.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    final auth = context.read<AuthController>();
    // El controlador ya ignora llamadas repetidas; esta guarda evita además
    // validar el formulario mientras hay una operación en curso.
    if (auth.cargando) return;
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await auth.iniciarSesion(email: _email.text, password: _password.text);
  }

  void _irARegistro() {
    context.read<AuthController>().limpiarError();
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const RegistroScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final error = auth.mensajeError;

    return Scaffold(
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
                    Icon(
                      Icons.devices_other,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Préstamo de Equipos',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Inicia sesión para continuar',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      key: const Key('login_email'),
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
                      key: const Key('login_password'),
                      controller: _password,
                      enabled: !auth.cargando,
                      etiqueta: 'Contraseña',
                      validator: Validadores.password,
                      onFieldSubmitted: (_) => _enviar(),
                    ),
                    const SizedBox(height: 24),
                    if (error != null) ...[
                      MensajeErrorAuth(mensaje: error),
                      const SizedBox(height: 16),
                    ],
                    BotonCargando(
                      key: const Key('login_enviar'),
                      texto: 'Iniciar sesión',
                      cargando: auth.cargando,
                      onPressed: _enviar,
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: auth.cargando ? null : _irARegistro,
                      child: const Text('¿No tienes cuenta? Regístrate'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
