import 'package:flutter/material.dart';
import 'package:ft_v2/service/auth_service.dart';
import 'package:ft_v2/utils/appvalidator.dart';

import 'sign_up.dart';

class SignInPage extends StatefulWidget {
  SignInPage({super.key});

  // final _emailController = TextEditingController();
  // final _passwordController = TextEditingController();
  // if define here need to add widget

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _emailController; // Define here
  late TextEditingController _passwordController; // Define here

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(); // Initialize here
    _passwordController = TextEditingController(); // Initialize here
  }

  var isLoader = false;
  var authService = AuthService();

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoader = true;
      });

      var data = {
        "email": _emailController.text,
        "password": _passwordController.text,
      };

      await authService.validateUser(data, context);
      setState(() {
        isLoader = false;
      });
      // ScaffoldMessenger.of(_formKey.currentContext!).showSnackBar(
      //     const SnackBar(content: Text("Form Submitted succesfully")));
    }
  }

  var appValidator = AppValidator();

  // function
  InputDecoration _buildInputDecoration(String label, IconData suffixIcon) {
    return InputDecoration(
        labelText: label,
        suffixIcon: Icon(suffixIcon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(
                  height: 50,
                  width: 250,
                ),
                const SizedBox(
                  child: Text(
                    "Welcome",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: appValidator.validateEmail,
                  decoration: _buildInputDecoration("Email", Icons.email),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                    controller: _passwordController,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: appValidator.validatePassword,
                    decoration: _buildInputDecoration("Password", Icons.lock)),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      isLoader ? print("loading") : _submitForm();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.black, // Sets the background color to black
                    ),
                    child: isLoader
                        ? const Center(child: CircularProgressIndicator())
                        : const Text(
                            "Login",
                            style: TextStyle(
                              color:
                                  Colors.white, // Sets the text color to white
                            ),
                          ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Dont have an account?"),
                    const SizedBox(
                      width: 10,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignUpPage()),
                        );
                      },
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(
                          color: Colors.blue,
                        ),
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
