import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/credentials_storage_service.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _credentialsService = CredentialsStorageService();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _rememberMe = false;
  bool _isLoadingCredentials = true;

  @override
  void initState() {
    super.initState();
    // Solo pre-llenar credenciales, NO auto-login
    _loadSavedCredentials();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedCredentials() async {
    setState(() => _isLoadingCredentials = true);

    try {
      final hasCredentials = await _credentialsService.hasCredentials();
      if (hasCredentials) {
        final credentials = await _credentialsService.getCredentials();
        if (credentials != null && mounted) {
          setState(() {
            _emailController.text = credentials.email;
            _passwordController.text = credentials.password;
            _rememberMe = true;
          });
        }
      }
    } catch (e) {
      // Si falla la autenticación biométrica, simplemente no pre-llena
    } finally {
      if (mounted) {
        setState(() => _isLoadingCredentials = false);
      }
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim().toLowerCase();
      final password = _passwordController.text;

      // Llamar al provider de autenticación (sin parámetro rememberMe)
      final success = await ref.read(authProvider.notifier).login(email, password);

      if (!mounted) {
        setState(() => _isLoading = false);
        return;
      }

      if (success) {
        // Guardar credenciales DESPUÉS del login exitoso
        await _credentialsService.saveCredentials(
          email: email,
          password: password,
          rememberMe: _rememberMe,
        );

        if (!mounted) return;

        // Login exitoso, navegar al main
        context.go('/main');
      } else {
        setState(() => _isLoading = false);
        // Mostrar error
        final error = ref.read(authProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Error al iniciar sesión'),
            backgroundColor: const Color(0xFFdc3545),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: const Color(0xFFdc3545),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mostrar loading mientras carga las credenciales
    if (_isLoadingCredentials) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF0d6efd),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Container(
              constraints: BoxConstraints(maxWidth: 400.w),
              decoration: BoxDecoration(
                color: const Color(0xFF1a1a1a),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: const Color(0xFF363636),
                  width: 1,
                ),
              ),
              padding: EdgeInsets.all(32.w),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo
                    Image.asset(
                      'assets/images/logo.png',
                      width: 120.w,
                      height: 120.w,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      'Sistema de Gestión para Restaurantes',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFFB0B0B0),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 32.h),

                    // Email field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      enableSuggestions: false,
                      textCapitalization: TextCapitalization.none,
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
                    SizedBox(height: 16.h),

                    // Remember me checkbox
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (value) {
                            setState(() {
                              _rememberMe = value ?? true;
                            });
                          },
                          fillColor: WidgetStateProperty.resolveWith<Color>(
                            (Set<WidgetState> states) {
                              if (states.contains(WidgetState.selected)) {
                                return const Color(0xFF0d6efd);
                              }
                              return Colors.transparent;
                            },
                          ),
                          side: const BorderSide(color: Color(0xFF363636), width: 1.5),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _rememberMe = !_rememberMe;
                              });
                            },
                            child: Text(
                              'Recordar credenciales (Biometría)',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: const Color(0xFFB0B0B0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),

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
                        color: const Color(0xFF808080),
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
