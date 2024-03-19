import 'package:flutter/material.dart';
import 'package:ft_v2/SignIn%20&%20SignUp/sign_in.dart';
import 'package:ft_v2/service/auth_service.dart';

import '../utils/appvalidator.dart';

class SignUpPage extends StatefulWidget {
  SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _userNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  var authService = AuthService();
  var isLoader = false;

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoader = true;
      });

      var data = {
        "username": _userNameController.text,
        "email": _emailController.text,
        "password": _passwordController.text,
        "phone": _phoneController.text,
      };

      await authService.createUser(data, context);
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
                const SizedBox(
                  height: 50,
                  width: 250,
                ),
                const SizedBox(
                  child: Text("Create new Account",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      )),
                ),
                const SizedBox(
                  height: 40,
                ),
                TextFormField(
                  controller: _userNameController,
                  keyboardType: TextInputType.emailAddress,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: appValidator.validateUserName,
                  decoration: _buildInputDecoration("User", Icons.person),
                ),
                const SizedBox(
                  height: 10,
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
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: appValidator.validatePhoneNumber,
                    decoration:
                        _buildInputDecoration("Phone Number", Icons.phone)),
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
                            "Submit",
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
                    const Text("Already have Account?"),
                    const SizedBox(
                      width: 10,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignInPage()),
                        );
                      },
                      child: const Text(
                        "Sign In",
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
