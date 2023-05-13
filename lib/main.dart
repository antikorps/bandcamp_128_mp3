import 'package:flutter/material.dart';
import 'bandcamp.dart' as bandcamp;
import 'modelos.dart' as modelos;
import 'utilidades.dart' as utilidades;

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bandcamp 128 mp3',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: const PaginaInicio(title: 'Bandcamp 128 mp3'),
    );
  }
}

class PaginaInicio extends StatefulWidget {
  const PaginaInicio({super.key, required this.title});

  final String title;

  @override
  State<PaginaInicio> createState() => _PaginaInicio();
}

class _PaginaInicio extends State<PaginaInicio> {
  late modelos.BandcampInfo bandcampInfo;

  final controladorUrl = TextEditingController();
  final controladorGrupo = TextEditingController();
  final controladorDisco = TextEditingController();
  final controladorFecha = TextEditingController();

  var visibilidadAnalisis = false;
  var visibilidadProgreso = false;

  void crearSnackBar(String mensaje, String tipo) {
    var colorFondo = Colors.green.shade900;
    if (tipo == "error") {
      colorFondo = Colors.red.shade300;
    }
    if (tipo == "advertencia") {
      colorFondo = Colors.blueGrey;
    }

    final snackBar = SnackBar(
      backgroundColor: colorFondo,
      content: Text(mensaje),
      duration: const Duration(minutes: 15),
      action: SnackBarAction(
        textColor: Colors.white,
        label: 'OK',
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void analizarURL() async {
    visibilidadAnalisis = false;
    final analisis = await bandcamp.consultarUrl(controladorUrl.text);
    bandcampInfo = analisis;
    if (analisis.error != "") {
      crearSnackBar(analisis.error, "error");
      return;
    }

    setState(() {
      controladorGrupo.text = bandcampInfo.grupo;
      controladorDisco.text = bandcampInfo.disco;
      controladorFecha.text = bandcampInfo.fecha;
      visibilidadAnalisis = true;
    });
  }

  void descargar() async {
    var directorioDescarga = await utilidades.seleccionarCarpeta();
    if (directorioDescarga == null) {
      return;
    }
    setState(() {
      visibilidadProgreso = true;
    });
    bandcampInfo.grupo = controladorGrupo.text;
    bandcampInfo.disco = controladorDisco.text;
    bandcampInfo.fecha = controladorFecha.text;
    bandcampInfo.directorio = directorioDescarga;
    var resultadoDescargas = await bandcamp.gestionarDescargas(bandcampInfo);
    if (resultadoDescargas.errores != "") {
      crearSnackBar(resultadoDescargas.errores, "error");
      setState(() {
        visibilidadProgreso = false;
      });
      return;
    }

    var tipo = "exito";
    var mensajeExito = "Disco descargado correctamente.";
    if (resultadoDescargas.advertencias != "") {
      mensajeExito = "$mensajeExito\n¡ATENCIÓN! El disco no está completo";
      tipo = "advertencia";
    }
    crearSnackBar(mensajeExito, tipo);
    setState(() {
      visibilidadProgreso = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      floatingActionButton: Visibility(
          visible: visibilidadAnalisis,
          child: FloatingActionButton(
            onPressed: descargar,
            tooltip: 'Descargar',
            child: const Icon(Icons.download),
          )),
      body: Center(
        child: SingleChildScrollView(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
                width: 600,
                margin: const EdgeInsets.all(5.0),
                child: const Text(
                  "Bancamp URL:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                )),
            Container(
                width: 600,
                margin: const EdgeInsets.all(5.0),
                child: TextField(
                  controller: controladorUrl,
                  decoration: InputDecoration(
                      suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        controladorUrl.clear();
                      });
                    },
                  )),
                )),
            Container(
                margin: const EdgeInsets.all(20.0),
                child: ElevatedButton(
                    onPressed: analizarURL, child: const Text("Analizar URL"))),
            Visibility(
              visible: visibilidadAnalisis,
              child: Container(
                  width: 600,
                  margin: const EdgeInsets.all(5.0),
                  child: const Text(
                    "Grupo:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
            ),
            Visibility(
                visible: visibilidadAnalisis,
                child: Container(
                    width: 600,
                    margin: const EdgeInsets.all(5.0),
                    child: TextField(
                      controller: controladorGrupo,
                    ))),
            Visibility(
                visible: visibilidadAnalisis,
                child: Container(
                    width: 600,
                    margin: const EdgeInsets.all(5.0),
                    child: const Text(
                      "Disco:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ))),
            Visibility(
                visible: visibilidadAnalisis,
                child: Container(
                    width: 600,
                    margin: const EdgeInsets.all(5.0),
                    child: TextField(
                      controller: controladorDisco,
                    ))),
            Visibility(
                visible: visibilidadAnalisis,
                child: Container(
                    width: 600,
                    margin: const EdgeInsets.all(5.0),
                    child: const Text(
                      "Fecha:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ))),
            Visibility(
                visible: visibilidadAnalisis,
                child: Container(
                    width: 600,
                    margin: const EdgeInsets.all(5.0),
                    child: TextField(
                      controller: controladorFecha,
                    ))),
            Visibility(
                visible: visibilidadProgreso,
                child: SizedBox(
                    width: 600,
                    child: Column(
                      children: <Widget>[
                        Container(
                          margin: const EdgeInsets.all(10),
                          child: const Text(
                            'Descargando disco. Por favor, espere...',
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.all(10),
                          child: const CircularProgressIndicator(
                            value: null,
                            semanticsLabel: 'Progreso descarga',
                          ),
                        ),
                      ],
                    )))
          ],
        )),
      ),
    );
  }
}
