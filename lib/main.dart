import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:odit_crm_mobile/core/constant/firebase_constant.dart';
import 'package:odit_crm_mobile/core/utils/notification_service.dart';
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
import 'package:app_links/app_links.dart';
import 'package:odit_crm_mobile/feature/leads/lead_details/presentation/lead_details_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await NotificationService.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService.initialize(navigatorKey: navigatorKey);
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
  final _appLinks = AppLinks();

  String? _pendingLeadId;
  bool _isAuthenticated = false;
  bool _initialCheckDone = false; // ADDED

  
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
    _addLeadCubit = AddLeadCubit();

    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    // ── 1. Cold start: app was fully closed, opened via the link ──────────
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleIncomingUri(initialUri);
      }
    } catch (e) {
      debugPrint('[DeepLink] getInitialLink error: $e');
    }

    // ── 2. App in background OR already running: stream fires on tap ──────
    _appLinks.uriLinkStream.listen(
      (uri) => _handleIncomingUri(uri),
      onError: (e) => debugPrint('[DeepLink] stream error: $e'),
    );
  }

  void _handleIncomingUri(Uri uri) {
    debugPrint('[DeepLink] Received: $uri');

    if (uri.scheme != 'oxdocrm' || uri.host != 'lead') return;

    final leadId = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '';
    if (leadId.isEmpty) return;

    if (_isAuthenticated) {
      _openLeadById(leadId);
    } else {
      // ✅ Save for after login completes
      debugPrint('[DeepLink] Not authenticated yet — queuing leadId: $leadId');
      _pendingLeadId = leadId;
    }
  }

  Future<void> _openLeadById(String leadId) async {
    final ctx = navigatorKey.currentContext;
    if (ctx == null) return;

    final lead = await _addLeadCubit.getLeadById(leadId);
    final freshCtx = navigatorKey.currentContext;
    if (lead != null && freshCtx != null) {
      // Delay slightly to ensure the home screen has finished building
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (navigatorKey.currentContext != null) {
          LeadDetailsScreen.show(navigatorKey.currentContext!, lead: lead);
        }
      });
    } else {
      debugPrint('[DeepLink] Lead not found for id: $leadId');
    }
  }

  @override
  void dispose() {
    _permissionCubit.close();
    _authCubit.close();
    _addLeadCubit.close();
    super.dispose();
  }


  // ... initState, _initDeepLinks, _handleIncomingUri, _openLeadById unchanged ...

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
            // GeneralSettingsRepository(staffId: ''),
          ),
        ),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        home: Sizer(
          builder: (context, orientation, deviceType) {
            return BlocConsumer<AuthCubit, AuthState>(
              listener: (context, state) async {
                // ADDED: mark initial session check as resolved the first
                // time we land on any non-loading/non-initial state
                if (state is Authenticated ||
                    state is AuthLoggedOut ||
                    state is AuthError ||
                    state is AuthForceLoggedOut) {
                  _initialCheckDone = true;
                }

                if (state is Authenticated) {
                  context.read<NotificationCubit>().load(state.user.id ?? '');
                  await NotificationService.registerTokenAfterLogin(state.user.id ?? ''); 
                  _isAuthenticated = true;

                  if (FirestorePath.companyId != null) {
                    _addLeadCubit.initialize();
                    _addLeadCubit.fetchLeads();
                  }

                  if (_pendingLeadId != null) {
                    final leadId = _pendingLeadId!;
                    _pendingLeadId = null;
                    Future.delayed(const Duration(milliseconds: 300), () {
                      _openLeadById(leadId);
                    });
                  }
                } else if (state is AuthForceLoggedOut) {
    _isAuthenticated = false;
     navigatorKey.currentState?.popUntil((route) => route.isFirst);
    final ctx = navigatorKey.currentContext;
    if (ctx != null) {
      showDialog(
        context: ctx,
        barrierDismissible: false,
        builder: (dialogCtx) => AlertDialog(
          title: const Text('Logged Out'),
          content: Text(state.message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  } else {
                  _isAuthenticated = false;
                }
              },
              builder: (context, state) {
                // CHANGED: only show splash loader before the initial
                // session check has ever resolved. Once resolved, further
                // AuthLoading (e.g. from a login attempt) falls through to
                // LoginScreen, which manages its own button-only spinner.
                if (!_initialCheckDone &&
                    (state is AuthInitial || state is AuthLoading)) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
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
