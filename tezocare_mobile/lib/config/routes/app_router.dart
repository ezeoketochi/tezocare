import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/api_constants.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/medication/presentation/pages/add_medication_page.dart';
import '../../features/medication/presentation/pages/medications_page.dart';
import '../../features/patient/presentation/pages/create_patient_page.dart';
import '../../features/patient/presentation/pages/edit_patient_page.dart';
import '../../features/patient/presentation/pages/patient_detail_page.dart';
import '../../features/patient/presentation/pages/patients_page.dart';
import '../../features/profile/presentation/pages/change_password_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/visit/presentation/pages/create_visit_page.dart';
import '../../features/visit/presentation/pages/visit_detail_page.dart';
import 'not_found_page.dart';
import 'route_names.dart';

class AppRouter {
  final FlutterSecureStorage secureStorage;

  late final GoRouter router = GoRouter(
    initialLocation: RouteNames.splash,
    redirect: _redirectLogic,
    errorBuilder: (context, state) => const NotFoundPage(),
    routes: [
      GoRoute(
        path: RouteNames.splash,
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: RouteNames.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: RouteNames.dashboard,
        name: 'dashboard',
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: RouteNames.patients,
        name: 'patients',
        builder: (context, state) => const PatientsPage(),
        routes: [
          GoRoute(
            path: 'create',
            name: 'createPatient',
            builder: (context, state) => const CreatePatientPage(),
          ),
          GoRoute(
            path: ':id',
            name: 'patientDetail',
            builder: (context, state) => PatientDetailPage(
              patientId: state.pathParameters['id']!,
            ),
            routes: [
              GoRoute(
                path: 'edit',
                name: 'editPatient',
                builder: (context, state) => EditPatientPage(
                  patientId: state.pathParameters['id']!,
                ),
              ),
              GoRoute(
                path: 'visits/:visitId',
                name: 'visitDetail',
                builder: (context, state) => VisitDetailPage(
                  visitId: state.pathParameters['visitId']!,
                ),
              ),
              GoRoute(
                path: 'medications',
                name: 'medications',
                builder: (context, state) => MedicationsPage(
                  patientId: state.pathParameters['id'],
                ),
                routes: [
                  GoRoute(
                    path: 'add',
                    name: 'addMedication',
                    builder: (context, state) =>
                        AddMedicationPage(
                          patientId: state.pathParameters['id'],
                        ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: RouteNames.createVisit,
        name: 'createVisit',
        builder: (context, state) => const CreateVisitPage(),
      ),
      GoRoute(
        path: RouteNames.profile,
        name: 'profile',
        builder: (context, state) => const ProfilePage(),
        routes: [
          GoRoute(
            path: 'change-password',
            name: 'changePassword',
            builder: (context, state) => const ChangePasswordPage(),
          ),
        ],
      ),
    ],
  );

  AppRouter({required this.secureStorage});

  Future<String?> _redirectLogic(
    BuildContext context,
    GoRouterState state,
  ) async {
    final isAuthenticated =
        await secureStorage.read(key: ApiConstants.accessTokenKey) != null;
    final location = state.matchedLocation;

    if (!isAuthenticated &&
        location != RouteNames.login &&
        location != RouteNames.splash) {
      return RouteNames.login;
    }

    if (isAuthenticated && location == RouteNames.login) {
      return RouteNames.dashboard;
    }

    if (isAuthenticated && location == RouteNames.splash) {
      return RouteNames.dashboard;
    }

    return null;
  }
}
