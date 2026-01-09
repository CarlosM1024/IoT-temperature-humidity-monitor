import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:Tarea02_ESP32/login_screen.dart';
import 'dart:async';
import 'package:intl/intl.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with SingleTickerProviderStateMixin {
  // --- ESTADO Y CONFIGURACIÓN ---
  bool isLoading = true;
  bool isConnected = false;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final databaseReference = FirebaseDatabase.instance.ref('lecturas');

  // --- DATOS DEL SENSOR ---
  double currentTemp = 0.0;
  double currentHumidity = 0.0;
  int lastUpdateTimestamp = 0;

  // --- HISTÓRICO DE DATOS ---
  final List<Map<String, dynamic>> dataHistory = [];

  // --- ANIMACIONES ---
  late AnimationController progressController;
  late Animation<double> tempAnimation;
  late Animation<double> humidityAnimation;

  // --- STREAMS Y TIMERS ---
  StreamSubscription? _dataSubscription;
  Timer? _connectionCheckTimer;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupRealtimeListener();
    _startConnectionChecker();
  }

  @override
  void dispose() {
    progressController.dispose();
    _dataSubscription?.cancel();
    _connectionCheckTimer?.cancel();
    super.dispose();
  }

  void _initializeAnimations() {
    progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    tempAnimation = _createAnimation(0);
    humidityAnimation = _createAnimation(0);
  }

  Animation<double> _createAnimation(double endValue, {double beginValue = 0}) {
    return Tween<double>(begin: beginValue, end: endValue)
        .animate(CurvedAnimation(parent: progressController, curve: Curves.easeInOut))
      ..addListener(() => setState(() {}));
  }

  void _setupRealtimeListener() {
    _dataSubscription = databaseReference.onValue.listen(
          (event) {
        if (event.snapshot.exists && event.snapshot.value != null) {
          _processData(event.snapshot.value as Map<dynamic, dynamic>);
        } else {
          setState(() {
            isConnected = false;
            isLoading = false;
          });
        }
      },
      onError: (error) {
        print("Error en el stream de Firebase: $error");
        setState(() { isConnected = false; });
      },
    );
  }

  void _processData(Map<dynamic, dynamic> data) {
    try {
      final double newTemp = (data['temperatura'] ?? 0.0).toDouble();
      final double newHumidity = (data['humedad'] ?? 0.0).toDouble();
      final int nowTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      setState(() {
        currentTemp = newTemp;
        currentHumidity = newHumidity;
        lastUpdateTimestamp = nowTimestamp;
        isConnected = true;
        if (isLoading) isLoading = false;

        _updateAnimations(newTemp, newHumidity);
        _addToHistory(newTemp, newHumidity, nowTimestamp);
      });
    } catch (e) {
      print("Error al procesar los datos: $e");
      setState(() { isConnected = false; });
    }
  }

  void _updateAnimations(double temp, double humidity) {
    tempAnimation = _createAnimation(temp, beginValue: tempAnimation.value);
    humidityAnimation = _createAnimation(humidity, beginValue: humidityAnimation.value);
    progressController.reset();
    progressController.forward();
  }

  void _addToHistory(double temp, double humidity, int timestamp) {
    dataHistory.insert(0, {
      'temperature': temp,
      'humedad': humidity, // Corregido aquí
      'timestamp': timestamp,
    });
    if (dataHistory.length > 10) {
      dataHistory.removeLast();
    }
  }

  void _startConnectionChecker() {
    _connectionCheckTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (lastUpdateTimestamp == 0) return;
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final timeDiff = now - lastUpdateTimestamp;
      if (timeDiff > 30) {
        if (isConnected) {
          setState(() { isConnected = false; });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitor ESP32'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: _handleLogout,
          icon: const Icon(Icons.logout),
          tooltip: 'Cerrar sesión',
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Icon(
              isConnected ? Icons.cloud_done : Icons.cloud_off,
              color: isConnected ? Colors.green.shade400 : Colors.red.shade400,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final event = await databaseReference.once();
          if (event.snapshot.exists) {
            _processData(event.snapshot.value as Map<dynamic, dynamic>);
          }
        },
        child: isLoading
            ? const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Esperando datos del ESP32...', style: TextStyle(fontSize: 18)),
            ],
          ),
        )
            : _buildDashboardContent(),
      ),
    );
  }

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStatusCard(),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildGauge('Temperatura', tempAnimation.value, '°C', Icons.thermostat, _getTemperatureColor(tempAnimation.value)),
              _buildGauge('Humedad', humidityAnimation.value, '%', Icons.water_drop, Colors.blue.shade400),
            ],
          ),
          const SizedBox(height: 20),
          _buildHistoryCard(),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    final statusText = isConnected ? "En línea" : "Apagado";
    final statusColor = isConnected ? Colors.green.shade400 : Colors.red.shade400;

    String lastUpdateText = 'Nunca';
    if (lastUpdateTimestamp > 0) {
      final timeDiff = (DateTime.now().millisecondsSinceEpoch ~/ 1000) - lastUpdateTimestamp;
      lastUpdateText = _formatTimeDifference(timeDiff);
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Estado del Dispositivo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(20)),
                  child: Text(statusText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Última actualización:'),
                Text(
                  lastUpdateText,
                  style: TextStyle(
                    color: (lastUpdateTimestamp > 0 && ((DateTime.now().millisecondsSinceEpoch ~/ 1000) - lastUpdateTimestamp) > 30) ? Colors.orange : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildGauge(String title, double value, String unit, IconData icon, Color color) {
    return Column(
      children: [
        CustomPaint(
          foregroundPainter: _CircleProgressPainter(value: value, maxValue: title == 'Temperatura' ? 50 : 100, color: color),
          child: SizedBox(
            width: 150,
            height: 150,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 30, color: Colors.grey.shade700),
                  const SizedBox(height: 4),
                  Text('${value.toStringAsFixed(1)}$unit', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryCard() {
    if (dataHistory.isEmpty) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Historial Reciente', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: dataHistory.length,
              itemBuilder: (context, index) => _buildHistoryItem(dataHistory[index]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> data) {
    final time = DateTime.fromMillisecondsSinceEpoch((data['timestamp'] as int) * 1000);
    final timeStr = DateFormat('HH:mm:ss').format(time);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(timeStr, style: const TextStyle(color: Colors.grey)),
          Text('${(data['temperature'] as double).toStringAsFixed(1)}°C', style: const TextStyle(fontWeight: FontWeight.w500)),
          // ¡ERROR CORREGIDO AQUÍ!
          Text('${(data['humedad'] as double).toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  String _formatTimeDifference(int seconds) {
    if (seconds < 5) return 'Ahora mismo';
    if (seconds < 60) return 'Hace $seconds seg';
    final minutes = seconds ~/ 60;
    return 'Hace $minutes min';
  }

  Color _getTemperatureColor(double temp) {
    if (temp < 18) return Colors.blue.shade300;
    if (temp < 25) return Colors.green.shade400;
    if (temp < 32) return Colors.orange.shade400;
    return Colors.red.shade400;
  }

  void _handleLogout() async {
    await googleSignIn.signOut();
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        // ¡CAMBIO IMPORTANTE! Navega a LoginScreen, no a una clase de main.dart
        MaterialPageRoute(builder: (context) => const LoginScreen(title: 'ESP32 temp & humid App')),
            (Route<dynamic> route) => false,
      );
    }
  }
}

class _CircleProgressPainter extends CustomPainter {
  final double value;
  final double maxValue;
  final Color color;

  _CircleProgressPainter({required this.value, required this.maxValue, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 10.0;
    const startAngle = -3.14 / 2;
    final sweepAngle = (value / maxValue) * 3.14 * 2;

    final backgroundPaint = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, backgroundPaint);

    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweepAngle, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
