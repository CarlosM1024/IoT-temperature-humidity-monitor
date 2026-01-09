import 'package:Tarea02_ESP32/dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.title});

  final String title;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>['email'],
  );

  GoogleSignInAccount? _currentUser;
  bool _isSigningIn = false;

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account;
      });
      if (_currentUser != null) {
        _handleFirebase();
      }
    });
    _googleSignIn.signInSilently().catchError((error) {
      print('Error al iniciar sesión automáticamente: $error');
    });
  }

  /// Maneja la autenticación en Firebase con Google
  Future<void> _handleFirebase() async {
    if (_currentUser == null) return;

    try {
      final GoogleSignInAuthentication googleAuth =
      await _currentUser!.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      final UserCredential userCredential =
      await firebaseAuth.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        print('Login exitoso: ${firebaseUser.email}');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Login exitoso: ${firebaseUser.email}'),
        ));
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const Dashboard()),
        );
      }
    } catch (e) {
      print('Error al autenticar con Firebase: $e');
    }
  }

  /// Maneja el inicio de sesión con Google
  Future<void> _handleSignIn() async {
    setState(() {
      _isSigningIn = true;
    });

    try {
      GoogleSignInAccount? account = await _googleSignIn.signIn();

      if (account != null) {
        _handleFirebase();
      } else {
        setState(() {
          _isSigningIn = false;
        });
        print('El usuario canceló el inicio de sesión');
      }
    } catch (e) {
      setState(() {
        _isSigningIn = false;
      });
      print('Error al iniciar sesión con Google: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: _isSigningIn
            ? const CircularProgressIndicator()
            : FloatingActionButton.extended(
          label: const Text('Google Sign In'),
          onPressed: _handleSignIn,
          backgroundColor: Colors.amber,
        ),
      ),
    );
  }
}