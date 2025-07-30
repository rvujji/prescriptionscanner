// login_screen.dart
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../prescription_list.dart';
import '../../services/hive_service.dart';
import '../../services/medication_scheduler.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../auth/google_signin.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onRegisterTap;

  const LoginScreen({Key? key, required this.onRegisterTap}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailOrPhoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  void _submitLogin(String emailOrPhone, String password) async {
    try {
      await HiveService.validateUser(emailOrPhone, password);
    } catch (e) {
      _showError("$e");
      return;
    }

    // Login success
    final cameras = await availableCameras();
    final FlutterTts flutterTts = FlutterTts();
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
    final medicationScheduler = MedicationScheduler(
      HiveService.getPrescriptionBox(),
    );

    await medicationScheduler.initialize();
    await medicationScheduler.scheduleAllMedications();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (_) => PrescriptionListScreen(
              initialPrescriptions: HiveService.getAllPrescriptions(),
              cameras: cameras,
            ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _emailOrPhoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.center, // Center align content
              children: [
                const Text(
                  "Login",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _emailOrPhoneController,
                  decoration: const InputDecoration(
                    labelText: 'Email or Phone Number',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email or phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.trim().length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        _submitLogin(
                          _emailOrPhoneController.text.trim(),
                          _passwordController.text.trim(),
                        );
                      }
                    },
                    child: const Text("Login"),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: Icon(Icons.login, color: Colors.red),
                    label: Text("Continue with Google"),
                    onPressed: _signInWithGoogle,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? "),
                    TextButton(
                      onPressed: widget.onRegisterTap,
                      child: const Text("Register"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _signInWithGoogle() async {
    final googleService = GoogleSignInService();
    try {
      final account = await googleService.signIn();
      if (account == null) {
        _showError("Google sign-in canceled");
        return;
      }

      final cameras = await availableCameras();
      final FlutterTts flutterTts = FlutterTts();
      await flutterTts.setLanguage("en-US");
      await flutterTts.setSpeechRate(0.5);
      final medicationScheduler = MedicationScheduler(
        HiveService.getPrescriptionBox(),
      );

      await medicationScheduler.initialize();
      await medicationScheduler.scheduleAllMedications();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (_) => PrescriptionListScreen(
                initialPrescriptions: HiveService.getAllPrescriptions(),
                cameras: cameras,
              ),
        ),
      );
    } catch (e) {
      _showError(e.toString());
    }
  }
}
