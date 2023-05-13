class BandcampInfo {
  var grupo = "";
  var disco = "";
  var fecha = "";
  var portada = "";
  var directorio = "";
  List<BandcampCancion> canciones = [];
  bool completo = true;
  String error = "";
}

class BandcampCancion {
  late String mp3;
  late String titulo;
  late int numero;
}

class DescargarCancionInfo {
  String mp3;
  String rutaArchivo;
  String grupo;
  String disco;
  String fecha;
  int numero;
  String titulo;
  String rutaPortada;

  DescargarCancionInfo(this.mp3, this.rutaArchivo, this.grupo, this.disco,
      this.fecha, this.numero, this.titulo, this.rutaPortada);
}

class ResultadoDescargas {
  String errores;
  String advertencias;

  ResultadoDescargas(this.errores, this.advertencias);
}

// class Tralbum {
//   Current? current;
//   String? artist;
//   List<Trackinfo>? trackinfo;

//   Tralbum.fromJson(Map<String, dynamic> json) {
//     current =
//         json['current'] != null ? Current.fromJson(json['current']) : null;
//     artist = json['artist'];
//     if (json['trackinfo'] != null) {
//       trackinfo = <Trackinfo>[];
//       json['trackinfo'].forEach((v) {
//         trackinfo!.add(Trackinfo.fromJson(v));
//       });
//     }
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     if (current != null) {
//       data['current'] = current!.toJson();
//     }

//     data['artist'] = artist;

//     if (trackinfo != null) {
//       data['trackinfo'] = trackinfo!.map((v) => v.toJson()).toList();
//     }

//     return data;
//   }
// }

// class Current {
//   String? title;
//   String? publishDate;

//   Current({this.title, this.publishDate});

//   Current.fromJson(Map<String, dynamic> json) {
//     title = json['title'];
//     publishDate = json['publish_date'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['title'] = title;
//     data['publish_date'] = publishDate;
//     return data;
//   }
// }

// class Trackinfo {
//   File? file;
//   String? title;
//   int? trackNum;

//   Trackinfo({this.file, this.title, this.trackNum});

//   Trackinfo.fromJson(Map<String, dynamic> json) {
//     file = json['file'] != null ? File.fromJson(json['file']) : null;
//     title = json['title'];
//     trackNum = json['track_num'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     if (file != null) {
//       data['file'] = file!.toJson();
//     }
//     data['title'] = title;
//     data['track_num'] = trackNum;
//     return data;
//   }
// }

// class File {
//   String? mp3128;

//   File({this.mp3128});

//   File.fromJson(Map<String, dynamic> json) {
//     mp3128 = json['mp3-128'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['mp3-128'] = mp3128;
//     return data;
//   }
// }
