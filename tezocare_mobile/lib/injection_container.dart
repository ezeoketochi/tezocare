import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'config/routes/app_router.dart';
import 'core/network/dio_client.dart';
import 'core/network/network_info.dart';
import 'core/utils/logger.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/get_current_user_usecase.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/domain/usecases/refresh_token_usecase.dart';
import 'features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'features/dashboard/domain/repositories/dashboard_repository.dart';
import 'features/dashboard/domain/usecases/get_dashboard_stats_usecase.dart';
import 'features/dashboard/domain/usecases/get_refills_due_usecase.dart';
import 'features/medication/data/datasources/medication_remote_datasource.dart';
import 'features/medication/data/repositories/medication_repository_impl.dart';
import 'features/medication/domain/repositories/medication_repository.dart';
import 'features/medication/domain/usecases/add_medication_usecase.dart';
import 'features/medication/domain/usecases/deactivate_medication_usecase.dart';
import 'features/medication/domain/usecases/get_patient_medications_usecase.dart';
import 'features/medication/domain/usecases/update_medication_usecase.dart';
import 'features/patient/data/datasources/patient_remote_datasource.dart';
import 'features/patient/data/repositories/patient_repository_impl.dart';
import 'features/patient/domain/repositories/patient_repository.dart';
import 'features/patient/domain/usecases/create_patient_usecase.dart';
import 'features/patient/domain/usecases/get_patient_detail_usecase.dart';
import 'features/patient/domain/usecases/get_patients_usecase.dart';
import 'features/patient/domain/usecases/search_patients_usecase.dart';
import 'features/patient/domain/usecases/update_patient_usecase.dart';
import 'features/visit/data/datasources/visit_remote_datasource.dart';
import 'features/visit/data/repositories/visit_repository_impl.dart';
import 'features/visit/domain/repositories/visit_repository.dart';
import 'features/visit/domain/usecases/create_visit_usecase.dart';
import 'features/visit/domain/usecases/get_patient_visits_usecase.dart';
import 'features/visit/domain/usecases/get_visit_detail_usecase.dart';

final sl = GetIt.instance;

Future<void> init() async {
  await _initExternalDependencies();
  _initCore();
  _initAuth();
  _initPatient();
  _initVisit();
  _initMedication();
  _initDashboard();
}

Future<void> _initExternalDependencies() async {
  sl.registerLazySingleton<Dio>(
    () => Dio(
      BaseOptions(
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    ),
  );

  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  sl.registerLazySingleton<InternetConnectionChecker>(
    () => InternetConnectionChecker.instance,
  );
}

void _initCore() {
  sl.registerLazySingleton<Logger>(() => Logger.instance);

  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(connectionChecker: sl()),
  );

  sl.registerLazySingleton<DioClient>(
    () => DioClient(
      dio: sl(),
      secureStorage: sl(),
      connectionChecker: sl(),
      logger: sl(),
    ),
  );

  sl.registerLazySingleton<AppRouter>(() => AppRouter(secureStorage: sl()));
  sl.registerLazySingleton<GoRouter>(() => sl<AppRouter>().router);
}

void _initAuth() {
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dioClient: sl(), secureStorage: sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );
  sl.registerFactory(() => LoginUseCase(repository: sl()));
  sl.registerFactory(() => LogoutUseCase(repository: sl()));
  sl.registerFactory(() => RefreshTokenUseCase(repository: sl()));
  sl.registerFactory(() => GetCurrentUserUseCase(repository: sl()));
}

void _initPatient() {
  sl.registerLazySingleton<PatientRemoteDataSource>(
    () => PatientRemoteDataSourceImpl(dioClient: sl()),
  );
  sl.registerLazySingleton<PatientRepository>(
    () => PatientRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );
  sl.registerFactory(() => CreatePatientUseCase(repository: sl()));
  sl.registerFactory(() => GetPatientsUseCase(repository: sl()));
  sl.registerFactory(() => GetPatientDetailUseCase(repository: sl()));
  sl.registerFactory(() => SearchPatientsUseCase(repository: sl()));
  sl.registerFactory(() => UpdatePatientUseCase(repository: sl()));
}

void _initVisit() {
  sl.registerLazySingleton<VisitRemoteDataSource>(
    () => VisitRemoteDataSourceImpl(dioClient: sl()),
  );
  sl.registerLazySingleton<VisitRepository>(
    () => VisitRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );
  sl.registerFactory(() => CreateVisitUseCase(repository: sl()));
  sl.registerFactory(() => GetPatientVisitsUseCase(repository: sl()));
  sl.registerFactory(() => GetVisitDetailUseCase(repository: sl()));
}

void _initMedication() {
  sl.registerLazySingleton<MedicationRemoteDataSource>(
    () => MedicationRemoteDataSourceImpl(dioClient: sl()),
  );
  sl.registerLazySingleton<MedicationRepository>(
    () => MedicationRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );
  sl.registerFactory(() => AddMedicationUseCase(repository: sl()));
  sl.registerFactory(() => GetPatientMedicationsUseCase(repository: sl()));
  sl.registerFactory(() => UpdateMedicationUseCase(repository: sl()));
  sl.registerFactory(() => DeactivateMedicationUseCase(repository: sl()));
}

void _initDashboard() {
  sl.registerLazySingleton<DashboardRemoteDataSource>(
    () => DashboardRemoteDataSourceImpl(dioClient: sl()),
  );
  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );
  sl.registerFactory(() => GetDashboardStatsUseCase(repository: sl()));
  sl.registerFactory(() => GetRefillsDueUseCase(repository: sl()));
}
