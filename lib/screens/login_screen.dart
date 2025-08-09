import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController(
    text: 'admin',
  );
  final TextEditingController _passwordController = TextEditingController(
    text: '12345',
  );
  final _formKey = GlobalKey<FormState>();
  bool _obscure = true;
  String? _error;

  void _login() {
    if (_formKey.currentState!.validate()) {
      if (_usernameController.text == 'admin' &&
          _passwordController.text == '12345') {
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        setState(() {
          _error = 'Username atau password salah!';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppTheme.cream,
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Ilustrasi belanja (gunakan asset/placeholder)
                  SizedBox(
                    height: 160,
                    child: Image.asset(
                      'assets/images/shopping_illustration.png',
                      fit: BoxFit.contain,
                      errorBuilder: (c, o, s) => const Icon(
                        Icons.shopping_cart,
                        size: 100,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    color: AppTheme.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 28,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Login dulu yu!',
                              style: GoogleFonts.poppins(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryGreen,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _usernameController,
                              decoration: const InputDecoration(
                                labelText: 'Username',
                                prefixIcon: Icon(Icons.person),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                              ),
                              validator: (v) => v == null || v.isEmpty
                                  ? 'Username wajib diisi'
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscure,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: const Icon(Icons.lock),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscure
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: () =>
                                      setState(() => _obscure = !_obscure),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                              ),
                              validator: (v) => v == null || v.isEmpty
                                  ? 'Password wajib diisi'
                                  : null,
                            ),
                            if (_error != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                _error!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ],
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _login,
                                child: const Text('Login'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'by. Endah Nursalamah',
                    style: GoogleFonts.dancingScript(
                      fontSize: 18,
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
