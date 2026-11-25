import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'catalog_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final correoController = TextEditingController();
  final passwordController = TextEditingController();

  bool cargando = false;

  Future<void> iniciarSesion() async {
    if (correoController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos')),
      );
      return;
    }

    setState(() => cargando = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: correoController.text.trim(),
        password: passwordController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Bienvenido a CineSan!'),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const CatalogScreen(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String mensaje = 'No se pudo iniciar sesión';

      if (e.code == 'user-not-found' ||
          e.code == 'invalid-credential') {
        mensaje = 'Correo o contraseña incorrectos';
      } else if (e.code == 'wrong-password') {
        mensaje = 'La contraseña es incorrecta';
      } else if (e.code == 'invalid-email') {
        mensaje = 'El correo no es válido';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensaje)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => cargando = false);
    }
  }

  @override
  void dispose() {
    correoController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar sesión'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            const Icon(
              Icons.movie_filter,
              size: 85,
              color: Colors.deepPurple,
            ),
            const SizedBox(height: 25),
            TextField(
              controller: correoController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: cargando ? null : iniciarSesion,
                child: cargando
                    ? const CircularProgressIndicator()
                    : const Text('Ingresar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
