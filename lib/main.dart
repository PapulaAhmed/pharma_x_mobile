import 'package:flutter/material.dart';
import 'package:pharma_x/view/cart_screen.dart';
import 'package:pharma_x/view/home_screen.dart';
import 'package:pharma_x/view/login_screen.dart';
import 'package:pharma_x/view/notification_screen.dart';
import 'package:pharma_x/view/order_screen.dart';
import 'package:pharma_x/view/pharmacist_home_screen.dart';
import 'package:pharma_x/view/sign_up_screen.dart';
import 'package:pharma_x/viewmodel/auth_viewmodel.dart';
import 'package:pharma_x/viewmodel/cart_viewmodel.dart';
import 'package:pharma_x/viewmodel/chat_viewmodel.dart';
import 'package:pharma_x/viewmodel/customer_conversation_viewmodel.dart';
import 'package:pharma_x/viewmodel/medicine_viewmodel.dart';
import 'package:pharma_x/viewmodel/notification_viewmodel.dart';
import 'package:pharma_x/viewmodel/orders_viewmodel.dart';
import 'package:pharma_x/viewmodel/pharmacist_screen_viewmodel.dart';
import 'package:pharma_x/viewmodel/profile_viewmodel.dart';
import 'package:pharma_x/viewmodel/signup_viewmodel.dart';
import 'package:pharma_x/viewmodel/user_viewmodel.dart';
import 'package:pharma_x/viewmodel/pharmacist_order_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
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
        ChangeNotifierProxyProvider<AuthViewModel, NotificationViewModel>(
          create: (_) => NotificationViewModel(),
          update: (_, auth, notifications) {
            if (auth.user != null) {
              notifications?.refreshNotifications();
            }
            return notifications ?? NotificationViewModel();
          },
        ),
        ChangeNotifierProvider(create: (_) => UserViewModel()),
        ChangeNotifierProvider(create: (_) => SignupViewModel()),
        ChangeNotifierProvider(create: (_) => CartViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
        ChangeNotifierProvider(create: (_) => MedicineViewModel()),
        ChangeNotifierProvider(create: (_) => OrdersViewModel()),
        ChangeNotifierProvider(create: (_) => ChatViewModel()),
        ChangeNotifierProvider(create: (_) => PharmacistHomeViewModel()),
        ChangeNotifierProvider(create: (_) => PharmacistOrderViewModel()),
        ChangeNotifierProvider(create: (_) => CustomerConversationViewModel()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        home: const AuthWrapper(),
        routes: {
          '/signup': (context) => const SignupView(),
          '/cart': (context) => const CartScreen(),
          '/orders': (context) => const OrdersScreen(),
          '/notifications': (context) => const NotificationScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, _) {
        if (authViewModel.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = authViewModel.user;
        final userRole = authViewModel.userRole;

        if (user == null) {
          _clearAllStates(context);
          return const LoginScreen();
        }

        switch (userRole) {
          case "customer":
            return const Home();
          case "pharmacist":
            return const PharmacistHomeScreen();
          default:
            return const Scaffold(
              body: Center(child: Text("Unknown user role")),
            );
        }
      },
    );
  }

  void _clearAllStates(BuildContext context) {
    // Clear in reverse dependency order
    Provider.of<ChatViewModel>(context, listen: false).clearState();
    Provider.of<UserViewModel>(context, listen: false).clearState();
    Provider.of<CustomerConversationViewModel>(context, listen: false)
        .clearConversations();
  }
}
