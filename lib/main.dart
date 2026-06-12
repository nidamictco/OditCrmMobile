import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:odit_crm_mobile/core/utils/bottom_navigation.dart';
import 'package:sizer/sizer.dart';

void main() {
    WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: Sizer( builder: (context, orientation, deviceType) {
            return CustomBottomNavScreen();
          },),
    );
  }
}

