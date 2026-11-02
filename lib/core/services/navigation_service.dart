import 'package:go_router/go_router.dart';

/// Servicio de navegación global para navegar sin BuildContext
class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  GoRouter? _router;

  /// Configura el router
  void setRouter(GoRouter router) {
    _router = router;
  }

  /// Navega a una ruta específica
  void navigateTo(String route) {
    if (_router != null) {
      _router!.go(route);
    }
  }

  /// Navega al login y limpia el stack de navegación
  void navigateToLogin() {
    if (_router != null) {
      _router!.go('/login');
    }
  }

  /// Navega al main screen
  void navigateToMain() {
    if (_router != null) {
      _router!.go('/main');
    }
  }

  /// Retrocede en la navegación
  void goBack() {
    if (_router != null && _router!.canPop()) {
      _router!.pop();
    }
  }
}
