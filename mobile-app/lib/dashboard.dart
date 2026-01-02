import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:tarea_esp32/circle_progress.dart';
import 'package:tarea_esp32/main.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with SingleTickerProviderStateMixin {
  bool isLoading = false;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final databaseReference = FirebaseDatabase.instance.ref();

  late AnimationController progressController;
  late Animation<double> tempAnimation;
  late Animation<double> humidityAnimation;

  bool _animationInitialized = false; // Para asegurarse de que la animación solo se inicialice una vez

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final snapshot = await databaseReference.child('ESP32_Device').once();

      if (snapshot.snapshot.value != null) {
        // Extraemos los valores de temperatura y humedad de manera segura
        final data = snapshot.snapshot.value as Map<dynamic, dynamic>;
        double temp = data['Temperature']['Data'].toDouble();
        double humidity = data['Humidity']['Data'].toDouble();

        setState(() {
          isLoading = true;
        });

        if (!_animationInitialized) {
          _DashboardInit(temp, humidity);
          _animationInitialized = true; // Asegurarse de que la animación se inicie solo una vez
        }
      } else {
        print("No se encontró el dispositivo ESP32_Device.");
      }
    } catch (e) {
      print("Error al obtener datos: $e");
    }
  }

  _DashboardInit(double temp, double humid) {
    progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    );

    tempAnimation = Tween<double>(begin: -50, end: temp).animate(progressController)
      ..addListener(() {
        setState(() {});
      });

    humidityAnimation = Tween<double>(begin: 0, end: humid).animate(progressController)
      ..addListener(() {
        setState(() {});
      });

    progressController.forward();
  }

  @override
  void dispose() {
    progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: handleLoginOutPopup,
          icon: const Icon(Icons.logout),
        ),
      ),
      body: Center(
        child: isLoading
            ? Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            CustomPaint(
              foregroundPainter: CircleProgress(
                tempAnimation.value,
                true,
              ),
              child: SizedBox(
                width: 200,
                height: 200,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text('Temperatura'),
                      Text(
                        '${tempAnimation.value.toInt()}',
                        style: const TextStyle(
                            fontSize: 50, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        '°C',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            CustomPaint(
              foregroundPainter: CircleProgress(
                humidityAnimation.value,
                false,
              ),
              child: SizedBox(
                width: 200,
                height: 200,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text('Humedad'),
                      Text(
                        '${humidityAnimation.value.toInt()}',
                        style: const TextStyle(
                            fontSize: 50, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        '°C',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        )
            : const Text(
          'Cargando...',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
  handleLoginOutPopup(){
    Alert(
      context: context,
      type: AlertType.info,
      title: "Salir sesión",
      desc: "¿Quieres salir de la sesión?",
      buttons: [
        DialogButton(
            child: const Text(
              'No',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20
              ),
            ),
            onPressed: ()=> Navigator.pop(context),
          width: 120,
        ),
        DialogButton(
          child: const Text(
            'Si',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20
            ),
          ),
          onPressed: handleSignOut,
          width: 120,
        )
      ],
    ).show();
  }

  Future<Null> handleSignOut() async{
    this.setState(() {
      isLoading == true;
    });

    await FirebaseAuth.instance.signOut();
    await googleSignIn.signOut();

    this.setState(() {
      isLoading == false;
    });
    
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=> MyApp()), (Route<dynamic> route)=>false);
  }

}
