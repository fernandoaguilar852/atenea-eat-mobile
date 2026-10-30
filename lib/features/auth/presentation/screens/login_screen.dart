import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Simulación de login - aquí irá la lógica real con la API
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isLoading = false);

    if (mounted) {
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Container(
              constraints: BoxConstraints(maxWidth: 400.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: EdgeInsets.all(32.w),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo
                    Icon(
                      Icons.restaurant_menu,
                      size: 80.sp,
                      color: const Color(0xFF0d6efd),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'ATENEA EAT',
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF212529),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Sistema de Gestión para Restaurantes',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF6c757d),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 32.h),

                    // Email field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Correo electrónico',
                        hintText: 'Ingresa tu correo',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El correo es requerido';
                        }
                        if (!value.contains('@')) {
                          return 'Ingresa un correo válido';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),

                    // Password field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        hintText: 'Ingresa tu contraseña',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'La contraseña es requerida';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 24.h),

                    // Login button
                    SizedBox(
                      width: double.infinity,
                      height: 50.h,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0d6efd),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: _isLoading
                            ? SizedBox(
                                width: 24.w,
                                height: 24.h,
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.login),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'Ingresar',
                                    style: TextStyle(fontSize: 16.sp),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Forgot password
                    TextButton(
                      onPressed: () {
                        // TODO: Implementar recuperación de contraseña
                      },
                      child: Text(
                        '¿Olvidaste tu contraseña?',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF0d6efd),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Footer
                    Text(
                      '© 2026 Atenea POS',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF6c757d),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
