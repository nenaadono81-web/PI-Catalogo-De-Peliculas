import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

const String adminUid = 'BhWfamOVISg8scyuBSOe1lKjQ6x1';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _formKey = GlobalKey<FormState>();

  final nombreController = TextEditingController();
  final anioController = TextEditingController();
  final directorController = TextEditingController();
  final generoController = TextEditingController();
  final sinopsisController = TextEditingController();
  final imagenUrlController = TextEditingController();

  final CollectionReference peliculas =
  FirebaseFirestore.instance.collection('peliculas');

  @override
  void dispose() {
    nombreController.dispose();
    anioController.dispose();
    directorController.dispose();
    generoController.dispose();
    sinopsisController.dispose();
    imagenUrlController.dispose();
    super.dispose();
  }

  Future<void> agregarPelicula() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await peliculas.add({
        'nombre': nombreController.text.trim(),
        'anio': int.parse(anioController.text.trim()),
        'director': directorController.text.trim(),
        'genero': generoController.text.trim(),
        'sinopsis': sinopsisController.text.trim(),
        'imagenUrl': imagenUrlController.text.trim(),
        'fechaRegistro': FieldValue.serverTimestamp(),
      });

      nombreController.clear();
      anioController.clear();
      directorController.clear();
      generoController.clear();
      sinopsisController.clear();
      imagenUrlController.clear();

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Película agregada correctamente'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al agregar película: $e')),
      );
    }
  }

  void mostrarFormulario() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Agregar película'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  campo(nombreController, 'Título'),
                  campo(anioController, 'Año', esNumero: true),
                  campo(directorController, 'Director'),
                  campo(generoController, 'Género'),
                  campo(sinopsisController, 'Sinopsis', maxLines: 3),
                  campo(imagenUrlController, 'URL de la imagen'),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: agregarPelicula,
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Widget campo(
      TextEditingController controller,
      String etiqueta, {
        bool esNumero = false,
        int maxLines = 1,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType:
        esNumero ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: etiqueta,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Completa este campo';
          }

          if (esNumero && int.tryParse(value.trim()) == null) {
            return 'Ingresa un año válido';
          }

          return null;
        },
      ),
    );
  }

  Future<void> eliminarPelicula(String id) async {
    try {
      await peliculas.doc(id).delete();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Película eliminada correctamente'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar película: $e')),
      );
    }
  }

  void confirmarEliminacion(String id, String nombre) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar película'),
          content: Text('¿Deseas eliminar "$nombre" del catálogo?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                eliminarPelicula(id);
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final usuario = FirebaseAuth.instance.currentUser;

    if (usuario == null || usuario.uid != adminUid) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Acceso restringido'),
        ),
        body: const Center(
          child: Text(
            'No tienes permiso para acceder a esta sección.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Administrar películas'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: mostrarFormulario,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: peliculas.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Error al cargar las películas'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final documentos = snapshot.data!.docs;

          if (documentos.isEmpty) {
            return const Center(
              child: Text('No hay películas registradas'),
            );
          }

          return ListView.builder(
            itemCount: documentos.length,
            itemBuilder: (context, index) {
              final documento = documentos[index];
              final datos = documento.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: ListTile(
                  title: Text(datos['nombre'] ?? 'Sin título'),
                  subtitle: Text(
                    'Año: ${datos['anio'] ?? 'No especificado'}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onPressed: () => confirmarEliminacion(
                      documento.id,
                      datos['nombre'] ?? 'esta película',
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
