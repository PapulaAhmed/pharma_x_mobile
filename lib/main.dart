import 'package:flutter/material.dart';
import 'package:pharma_x/view/cart_screen.dart';
import 'package:pharma_x/view/home_screen.dart';
import 'package:pharma_x/view/login_screen.dart';
import 'package:pharma_x/view/pharmacist_screen.dart';
import 'package:pharma_x/view/sign_up_screen.dart';
import 'package:pharma_x/viewmodel/auth_viewmodel.dart';
import 'package:pharma_x/viewmodel/cart_viewmodel.dart';
import 'package:pharma_x/viewmodel/chat_viewmodel.dart';
import 'package:pharma_x/viewmodel/medicine_viewmodel.dart';
import 'package:pharma_x/viewmodel/orders_viewmodel.dart';
import 'package:pharma_x/viewmodel/pharmacist_screen_viewmodel.dart';
import 'package:pharma_x/viewmodel/profile_viewmodel.dart';
import 'package:pharma_x/viewmodel/signup_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.android,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => SignupViewModel()),
        ChangeNotifierProvider(create: (_) => CartViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
        ChangeNotifierProvider(create: (_) => MedicineViewModel()),
        ChangeNotifierProvider(create: (_) => OrdersViewModel()),
        ChangeNotifierProvider(create: (_) => ChatViewModel()),
        ChangeNotifierProvider(create: (_) => PharmacistHomeViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupView(),
          '/home': (context) => const Home(),
          '/cart': (context) => const CartScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final user = authViewModel.user;
    final userRole = authViewModel.userRole;

    if (authViewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (user != null) {
      if (userRole == "customer") {
        return const Home(); // Customer home screen
      } else if (userRole == "pharmacist") {
        return PharmacistHomeScreen(); // Pharmacist home screen
      } else {
        return const Scaffold(
          body: Center(child: Text("Unknown user role")),
        );
      }
    } else {
      return const LoginScreen();
    }
  }
}
