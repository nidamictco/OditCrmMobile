import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:odit_crm_mobile/core/shared_prefference/session_service.dart';
import 'package:odit_crm_mobile/core/utils/bottom_navigation.dart';
import 'package:odit_crm_mobile/feature/auth/cubit/auth_cubit.dart';
import 'package:odit_crm_mobile/feature/auth/data/auth_data.dart';
import 'package:odit_crm_mobile/feature/auth/login_screen.dart';
import 'package:odit_crm_mobile/feature/designation/cubit/permission_cubit.dart';
import 'package:odit_crm_mobile/feature/general_settings/data/general_setting_repo.dart';
import 'package:odit_crm_mobile/feature/notification/cubit/notification_cubit.dart';
import 'package:odit_crm_mobile/feature/notification/data/notification_repo.dart';
import 'package:odit_crm_mobile/firebase_options.dart';
import 'package:sizer/sizer.dart';

import 'package:odit_crm_mobile/feature/leads/lead_managment/cubit/lead_cubit/lead_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final FirebaseAuthService _authService;
  late final SessionService _sessionService;
  late final PermissionCubit _permissionCubit;
  late final AuthCubit _authCubit;
  late final AddLeadCubit _addLeadCubit;

  @override
  void initState() {
    super.initState();
    _authService = FirebaseAuthService();
    _sessionService = SessionService();
    _permissionCubit = PermissionCubit();
    _authCubit = AuthCubit(
      authService: _authService,
      sessionService: _sessionService,
    )..checkSession(permissionCubit: _permissionCubit);
    _addLeadCubit = AddLeadCubit()..initialize()..fetchLeads();
  }

  @override
  void dispose() {
    _permissionCubit.close();
    _authCubit.close();
    _addLeadCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PermissionCubit>.value(value: _permissionCubit),
        BlocProvider<AuthCubit>.value(value: _authCubit),
        BlocProvider<AddLeadCubit>.value(value: _addLeadCubit),
         BlocProvider<NotificationCubit>(
      create: (_) => NotificationCubit(
        NotificationRepo(),
        GeneralSettingsRepository(staffId: ''), // updated via initSettings later
      ),
    ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        home: Sizer(
          builder: (context, orientation, deviceType) {
            return BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) {
                if (state is AuthInitial || state is AuthLoading) {
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                if (state is Authenticated) {
                  return const CustomBottomNavScreen();
                }
                return const LoginScreen();
              },
            );
          },
        ),
      ),
    );
  }
}

