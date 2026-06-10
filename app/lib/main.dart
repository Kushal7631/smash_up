import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'data/services/api_service.dart';
import 'ui/login/login_viewmodel.dart';
import 'ui/venue_list/venue_list_viewmodel.dart';
import 'ui/venue_detail/venue_detail_viewmodel.dart';
import 'ui/my_bookings/my_bookings_viewmodel.dart';
import 'ui/login/login_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const SmashUpApp());
}

class SmashUpApp extends StatelessWidget {
  const SmashUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginViewModel(apiService)),
        ChangeNotifierProvider(create: (_) => VenueListViewModel(apiService)),
        ChangeNotifierProvider(create: (_) => VenueDetailViewModel(apiService)),
        ChangeNotifierProvider(create: (_) => MyBookingsViewModel(apiService)),
      ],
      child: MaterialApp(
        title: 'SmashUp',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const LoginView(),
      ),
    );
  }
}
