import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:diacritic/diacritic.dart';
import 'package:file_picker/file_picker.dart';
import 'package:eztags/eztags.dart';
import 'package:html_unescape/html_unescape.dart';

import 'modelos.dart' as modelos;

modelos.BandcampInfo extraerInfo(String html) {
  var bandcampInfo = modelos.BandcampInfo();

  // Portada
  final expRegPortada = RegExp(
      r'.*?id="tralbumArt".{0,30}<a class="popupImage".{0,5}href="(.*?)".*');
  final coincidenciasPortada = expRegPortada.firstMatch(html);
  if (coincidenciasPortada == null) {
    bandcampInfo.error = "ERROR: no se ha encontrado la portada";
    return bandcampInfo;
  }

  if (coincidenciasPortada.groupCount != 1) {
    bandcampInfo.error =
        "ERROR: se han encontrado varias coincidencias para la portada";
    return bandcampInfo;
  }
  final portada = coincidenciasPortada.group(1)!;

  // Tralbum

  final expRegInfo = RegExp(r'.*?data-tralbum="(.*?)".*');
  final coincidenciasInfo = expRegInfo.firstMatch(html);
  if (coincidenciasInfo == null) {
    bandcampInfo.error = "ERROR: no se ha encontrado la información general";
    return bandcampInfo;
  }
  if (coincidenciasInfo.groupCount != 1) {
    bandcampInfo.error =
        "ERROR: se han encontrado varias coincidencias la información general";
    return bandcampInfo;
  }
  var info = coincidenciasInfo.group(1)!;
  final expRegComillas = RegExp("&quot;");
  info = info.replaceAll(expRegComillas, '"');

  try {
    final infoJSON = jsonDecode(info);

    var grupo = "";
    if (infoJSON["artist"] != null) {
      grupo = infoJSON["artist"];
    }

    var disco = "";
    if (infoJSON["current"]["title"] != null) {
      disco = infoJSON["current"]["title"];
    }

    var fecha = "";
    if (infoJSON["current"]["publish_date"] != null) {
      final fechaCompleta = infoJSON["current"]["publish_date"];
      final datosFecha = fechaCompleta.split(" ");
      if (datosFecha.length > 3) {
        fecha = datosFecha[2];
      }
    }

    List<modelos.BandcampCancion> canciones = [];
    var completo = true;
    for (final registro in infoJSON["trackinfo"]) {
      String mp3Url;
      try {
        mp3Url = registro["file"]["mp3-128"];
      } catch (error) {
        completo = false;
        continue;
      }
      var cancion = modelos.BandcampCancion();
      cancion.mp3 = mp3Url;
      cancion.titulo = sanearCaracteresEspecialesHTML(registro["title"]);
      cancion.numero = registro["track_num"];
      canciones.add(cancion);
    }

    if (canciones.isEmpty) {
      bandcampInfo.error =
          "ERROR: no se han encontrado mp3 en la información general";
      return bandcampInfo;
    }

    bandcampInfo.grupo = sanearCaracteresEspecialesHTML(grupo);
    bandcampInfo.disco = sanearCaracteresEspecialesHTML(disco);
    bandcampInfo.fecha = fecha;
    bandcampInfo.portada = portada;
    bandcampInfo.canciones = canciones;
    bandcampInfo.completo = completo;

    return bandcampInfo;
  } catch (error) {
    bandcampInfo.error =
        "ERROR: imposible analizar el JSON de la información general $error";
    return bandcampInfo;
  }
}

Future<String?> seleccionarCarpeta() async {
  String? carpetaSeleccionada = await FilePicker.platform.getDirectoryPath();
  if (carpetaSeleccionada == null) {
    return null;
  }
  return carpetaSeleccionada;
}

Future<String?> descargarPortada(String url, String ruta) async {
  try {
    final respuestaUrl = await http.get(Uri.parse(url));
    if (respuestaUrl.statusCode != 200) {
      return "ERROR: status code incorrecto descargando la portada: ${respuestaUrl.statusCode}";
    }
    File(ruta).writeAsBytes(respuestaUrl.bodyBytes);
  } catch (error) {
    return "ERROR: descargando la portada: $error";
  }
  return null;
}

Future<String> descargarMp3(String url, String ruta, String grupo, String disco,
    String fecha, int numero, String titulo, String portada) async {
  try {
    final mp3Respuesta = await http.get(Uri.parse(url));
    if (mp3Respuesta.statusCode != 200) {
      return "ERROR: canción $numero no descargada al recibir un status code incorrecto: ${mp3Respuesta.statusCode}";
    }
    File(ruta).writeAsBytes(mp3Respuesta.bodyBytes);
  } catch (error) {
    return "ERROR: canción $numero no descargada por $error";
  }

  final mp3Tags = <String, String>{
    "title": titulo,
    "artist": grupo,
    "album": disco,
    "artwork": portada
  };

  await addTagsToFile(TagList.fromMap(mp3Tags), ruta);

  return "";
}

String normalizarNombreFichero(String nombre) {
  nombre = removeDiacritics(nombre);
  final expRegNoAlfaNumerico = RegExp(r"\W");
  nombre = nombre.replaceAll(expRegNoAlfaNumerico, "_");
  final expRegDoblesGuiones = RegExp(r"_{2,}");
  nombre = nombre.replaceAll(expRegDoblesGuiones, "_");
  return nombre.toLowerCase();
}

String sanearCaracteresEspecialesHTML(String texto) {
  var saneador = HtmlUnescape();
  var textoSaneado = saneador.convert(texto);
  return textoSaneado;
}
