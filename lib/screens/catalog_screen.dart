import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'movie_detail_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'admin_screen.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('SE ESTA ABRIENDO EL CATALOGO');
    debugPrint('UID SESION: ${FirebaseAuth.instance.currentUser?.uid}');
    debugPrint('UID ADMIN: $adminUid');
    return Scaffold(
      backgroundColor: const Color(0xFF171326),
      appBar: AppBar(
        title: const Text('Catálogo de películas'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,

        actions: [
          if (FirebaseAuth.instance.currentUser?.uid == adminUid)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              tooltip: 'Administrar películas',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminScreen(),
                  ),
                );
              },
            ),

          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();

              if (!context.mounted) return;

              Navigator.pushNamedAndRemoveUntil(
                context,
                '/',
                    (route) => false,
              );
            },
          ),
        ],

      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('peliculas')
            .snapshots(),
        builder: (context, snapshot) {

          debugPrint('ESTADO FIRESTORE: ${snapshot.connectionState}');
          debugPrint('ERROR FIRESTORE: ${snapshot.error}');
          debugPrint('TIENE DATOS: ${snapshot.hasData}');

          debugPrint('CANTIDAD DE PELICULAS: ${snapshot.data?.docs.length}');

          if (snapshot.hasData) {
            for (var doc in snapshot.data!.docs) {
              debugPrint('PELICULA: ${doc.data()}');
            }
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Error al cargar las películas.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            );
          }

          final peliculas = snapshot.data?.docs ?? [];

          if (peliculas.isEmpty) {
            return const Center(
              child: Text(
                'Todavía no hay películas registradas.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }


          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: peliculas.length,
            itemBuilder: (context, index) {
              final pelicula =
              peliculas[index].data() as Map<String, dynamic>;

              final titulo = (
                  pelicula['titulo'] ??
                      pelicula['nombre'] ??
                      'Sin título'
              ).toString();

              final anio = (pelicula['anio'] ?? '').toString();

              final imagenUrl =
              (pelicula['imagenUrl'] ?? '').toString();

              return Card(
                color: const Color(0xFF29223D),
                margin: const EdgeInsets.only(bottom: 18),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: imagenUrl.isNotEmpty
                        ? Image.network(
                      imagenUrl,
                      width: 75,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 75,
                          height: 100,
                          color: Colors.deepPurple,
                          child: const Icon(
                            Icons.movie,
                            color: Colors.white,
                            size: 35,
                          ),
                        );
                      },
                    )
                        : Container(
                      width: 75,
                      height: 100,
                      color: Colors.deepPurple,
                      child: const Icon(
                        Icons.movie,
                        color: Colors.white,
                        size: 35,
                      ),
                    ),
                  ),
                  title: Text(
                    titulo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      anio.isNotEmpty
                          ? 'Año: $anio'
                          : 'Año no disponible',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MovieDetailScreen(
                          pelicula: pelicula,
                        ),
                      ),
                    );
                  },

                ),
              );
            },
          );

        },
      ),
    );
  }
}


