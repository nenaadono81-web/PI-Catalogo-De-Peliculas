import 'package:flutter/material.dart';

class MovieDetailScreen extends StatelessWidget {
  final Map<String, dynamic> pelicula;

  const MovieDetailScreen({
    super.key,
    required this.pelicula,
  });

  @override
  Widget build(BuildContext context) {
    final titulo = (
        pelicula['titulo'] ??
            pelicula['nombre'] ??
            'Sin título'
    ).toString();

    final anio = (pelicula['anio'] ?? '').toString();
    final director = (
        pelicula['director'] ?? 'No disponible'
    ).toString();
    final genero = (
        pelicula['genero'] ?? 'No disponible'
    ).toString();
    final sinopsis = (
        pelicula['sinopsis'] ?? 'Sin sinopsis disponible'
    ).toString();
    final imagenUrl = (
        pelicula['imagenUrl'] ?? ''
    ).toString();

    return Scaffold(
      backgroundColor: const Color(0xFF171326),
      appBar: AppBar(
        title: const Text('Detalles de la película'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (imagenUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  imagenUrl,
                  height: 280,
                  width: 190,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.movie,
                      color: Colors.white,
                      size: 100,
                    );
                  },
                ),
              )
            else
              const Icon(
                Icons.movie,
                color: Colors.white,
                size: 100,
              ),

            const SizedBox(height: 20),

            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            _dato('Año de estreno', anio),
            _dato('Director', director),
            _dato('Género', genero),

            const SizedBox(height: 20),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Sinopsis',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),

            Text(
              sinopsis,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                height: 1.5,
              ),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }

  Widget _dato(String etiqueta, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$etiqueta: ',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Text(
              valor.isEmpty ? 'No disponible' : valor,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
