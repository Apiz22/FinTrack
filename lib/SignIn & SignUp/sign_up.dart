import 'package:flutter/material.dart';
import 'package:ft_v2/service/auth_service.dart';
import 'package:ft_v2/SignIn%20&%20SignUp/sign_in.dart';
import 'package:ft_v2/utils/appvalidator.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _userNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _reConfirmpasswordController = TextEditingController();

  var authService = AuthService();
  var isLoader = false;

  @override
  void dispose() {
    _userNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _reConfirmpasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoader = true;
      });

      // Initial data setup first time
      var data = {
        "username": _userNameController.text,
        "email": _emailController.text,
        "password": _passwordController.text,
        "phone": _phoneController.text,
        "totalBadgesObtained": 0,
        "currentRule": "80/20",
        "ruleStreak": 0,
      };

      try {
        await authService.createUser(data, context);
      } catch (e) {
        // Show error message as a SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error occurred: $e")),
        );
      }

      setState(() {
        isLoader = false;
      });
    }
  }

  var appValidator = AppValidator();

  // Function to build input decoration
  InputDecoration _buildInputDecoration(String label, IconData suffixIcon) {
    return InputDecoration(
      labelText: label,
      suffixIcon: Icon(suffixIcon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 50, width: 250),
                const SizedBox(
                  child: Text(
                    "Create new Account",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 40),
                // Username
                TextFormField(
                  controller: _userNameController,
                  keyboardType: TextInputType.emailAddress,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: appValidator.validateUserName,
                  decoration: _buildInputDecoration("User", Icons.person),
                ),
                const SizedBox(height: 10),
                // Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: appValidator.validateEmail,
                  decoration: _buildInputDecoration("Email", Icons.email),
                ),
                const SizedBox(height: 10),
                // Phone number
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: appValidator.validatePhoneNumber,
                  decoration:
                      _buildInputDecoration("Phone Number", Icons.phone),
                ),
                const SizedBox(height: 10),
                // Password
                TextFormField(
                  controller: _passwordController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: appValidator.validatePassword,
                  obscureText: true,
                  decoration: _buildInputDecoration("Password", Icons.lock),
                ),
                const SizedBox(height: 10),
                // Confirm Password
                TextFormField(
                  controller: _reConfirmpasswordController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                  obscureText: true,
                  decoration:
                      _buildInputDecoration("Confirm Password", Icons.lock),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      isLoader ? print("Loading") : _submitForm();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                    ),
                    child: isLoader
                        ? const Center(child: CircularProgressIndicator())
                        : const Text(
                            "Submit",
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have Account?"),
                    const SizedBox(width: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignInPage()),
                        );
                      },
                      child: const Text(
                        "Sign In",
                        style: TextStyle(color: Colors.blue),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
