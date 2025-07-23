import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/hive_service.dart';
import '../../models/user.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  DateTime? dob;

  void _register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text;

    if (name.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        dob == null) {
      _showError("Please fill all fields");
      return;
    }

    final user = User(
      name: name,
      email: email,
      phone: phone,
      password: password,
      dob: dob!,
    );
    try {
      await HiveService.saveUser(user);
    } catch (e) {
      _showError("$e");
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Registered as $name")));

    Navigator.pop(context);
  }

  void _pickDob() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (selected != null) setState(() => dob = selected);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _dobText() {
    return dob == null
        ? "Select Date of Birth"
        : DateFormat.yMMMd().format(dob!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name"),
                validator: (value) {
                  if (value == null || value.trim().isEmpty)
                    return "Name is required";
                  if (value.trim().length < 2)
                    return "Name must be at least 2 characters";
                  return null;
                },
              ),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty)
                    return "Email is required";
                  final emailRegex = RegExp(r"^[\w\.-]+@[\w\.-]+\.\w+$");
                  if (!emailRegex.hasMatch(value.trim()))
                    return "Enter a valid email";
                  return null;
                },
              ),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: "Phone No"),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty)
                    return "Phone number is required";
                  final phoneRegex = RegExp(r"^[0-9]{10}$");
                  if (!phoneRegex.hasMatch(value.trim()))
                    return "Enter a valid 10-digit phone number";
                  return null;
                },
              ),
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return "Password is required";
                  if (value.length < 6)
                    return "Password must be at least 6 characters";
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: Text(_dobText())),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _pickDob,
                    child: const Text("Pick DOB"),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _register,
                child: const Text("Register"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
