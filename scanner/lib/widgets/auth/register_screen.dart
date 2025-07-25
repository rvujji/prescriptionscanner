import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../services/hive_service.dart';
import '../../models/appuser.dart';
import '../../utils/password_manager.dart';

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
  String? gender;
  String? country;

  final List<String> genderOptions = ['Male', 'Female', 'Other'];
  final List<String> countryOptions = ['India', 'USA', 'UK', 'Other'];

  void _register() async {
    if (!_formKey.currentState!.validate() ||
        dob == null ||
        gender == null ||
        country == null) {
      _showError("Please fill all fields including DOB, Gender, and Country");
      return;
    }
    final hashedPassword = PasswordUtils.hashPassword(passwordController.text);

    final appUser = AppUser(
      id: const Uuid().v4(),
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      passwordHash: hashedPassword,
      phone: phoneController.text.trim(),
      dob: dob!,
      gender: gender!,
      country: country!,
      loggedIn: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      await HiveService.saveUser(appUser);
    } catch (e) {
      _showError("Failed to save user: $e");
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Registered as ${appUser.name}")));

    Navigator.pop(context);
  }

  void _pickDob() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (selected != null) {
      setState(() => dob = selected);
    }
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
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: gender,
                items:
                    genderOptions
                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                onChanged: (value) => setState(() => gender = value),
                decoration: const InputDecoration(labelText: "Gender"),
                validator:
                    (value) => value == null ? "Please select gender" : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: country,
                items:
                    countryOptions
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                onChanged: (value) => setState(() => country = value),
                decoration: const InputDecoration(labelText: "Country"),
                validator:
                    (value) => value == null ? "Please select country" : null,
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
