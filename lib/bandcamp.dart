import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'dart:io';
import 'utilidades.dart' as utilidades;
import 'modelos.dart' as modelos;

Future<modelos.BandcampInfo> consultarUrl(String url) async {
  var html = "";
  var bandcampInfo = modelos.BandcampInfo();

  try {
    final respuestaUrl = await http.get(Uri.parse(url));
    if (respuestaUrl.statusCode != 200) {
      bandcampInfo.error = "status code incorrecto: ${respuestaUrl.statusCode}";
      return bandcampInfo;
    }
    html = respuestaUrl.body;
  } catch (error) {
    bandcampInfo.error = error.toString();
    return bandcampInfo;
  }

  final expRegMin = RegExp(r"\n");
  html = html.replaceAll(expRegMin, "");

  return utilidades.extraerInfo(html);
}

Future<modelos.ResultadoDescargas> gestionarDescargas(
    modelos.BandcampInfo info) async {
  final nombreBase = utilidades
      .normalizarNombreFichero("${info.grupo}_${info.fecha}_${info.disco}");

  var rutaDescargas = path.join(info.directorio, nombreBase);

  try {
    Directory(rutaDescargas).createSync(recursive: true);
  } catch (error) {
    return modelos.ResultadoDescargas(
        "ERROR: no se ha podido crear el directorio necesario $error", "");
  }

  // Descargar portada
  final portadaExtension = path.extension(info.portada);
  final portadaRuta = path.join(rutaDescargas, "cover$portadaExtension");
  final portadaDescargada =
      await utilidades.descargarPortada(info.portada, portadaRuta);
  if (portadaDescargada != null) {
    return modelos.ResultadoDescargas(portadaDescargada, "");
  }

  // Descargas simultáneas Mp3
  var descargasMaximas = 3;
  if (info.canciones.length < descargasMaximas) {
    descargasMaximas = info.canciones.length;
  }
  var descargasGestionadas = 0;
  var descargasEnBucle = true;
  var descargasErrores = "";

  while (descargasEnBucle) {
    List<Future<String>> descargasPromesas = [];

    for (var i = 0; i < descargasMaximas; i++) {
      final cancion = info.canciones[descargasGestionadas];
      var cancionNombre = utilidades.normalizarNombreFichero(
          "${nombreBase}_${cancion.numero.toString().padLeft(2, "0")}_${cancion.titulo}");
      cancionNombre += ".mp3";
      final cancionRuta = path.join(rutaDescargas, cancionNombre);
      descargasPromesas.add(utilidades.descargarMp3(
          cancion.mp3,
          cancionRuta,
          info.grupo,
          info.disco,
          info.fecha,
          cancion.numero,
          cancion.titulo,
          info.portada));
      descargasGestionadas++;

      if (descargasGestionadas == info.canciones.length) {
        descargasEnBucle = false;
        break;
      }
    }

    final descargasFinalizadas = await Future.wait(descargasPromesas);
    for (final descarga in descargasFinalizadas) {
      if (descarga != "") {
        descargasErrores += "$descarga \n";
      }
    }
  }

  if (descargasErrores != "") {
    return modelos.ResultadoDescargas(descargasErrores, "");
  }

  if (info.completo == false) {
    return modelos.ResultadoDescargas("", "el disco no está completo");
  }

  return modelos.ResultadoDescargas("", "");
}
