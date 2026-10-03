import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'services/app_state.dart';
import 'views/main_navigation.dart';
import 'views/login/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const UniMarketApp());
}

class UniMarketApp extends StatelessWidget {
  const UniMarketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppState>(
      create: (_) => AppState(),
      child: Consumer<AppState>(
        builder: (context, state, _) {
          return MaterialApp(
            title: 'UniMarket - ตลาดนัดมหาวิทยาลัย',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: state.themeMode,
            home: state.isAuthLoading
                ? const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : (state.isAuthenticated
                    ? const MainNavigationScreen()
                    : const LoginScreen()),
          );
        },
      ),
    );
  }
}

