import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:tezocare_mobile/features/dashboard/data/models/dashboard_stats_model.dart';
import 'package:tezocare_mobile/features/dashboard/domain/entities/dashboard_stats.dart';

void main() {
  final testJson = {
    'total_patients': 150,
    'active_visits': 12,
    'today_appointments': 8,
    'pending_refills': 5,
    'total_staff': 10,
    'medications_active': 45,
  };
  final testModel = DashboardStatsModel(
    totalPatients: 150,
    activeVisits: 12,
    todayAppointments: 8,
    pendingRefills: 5,
    totalStaff: 10,
    medicationsActive: 45,
  );

  group('DashboardStatsModel', () {
    test('fromJson creates model correctly', () {
      final model = DashboardStatsModel.fromJson(testJson);
      expect(model.totalPatients, 150);
      expect(model.activeVisits, 12);
      expect(model.todayAppointments, 8);
      expect(model.pendingRefills, 5);
      expect(model.totalStaff, 10);
      expect(model.medicationsActive, 45);
    });

    test('fromJson defaults missing fields to 0', () {
      final model = DashboardStatsModel.fromJson({});
      expect(model.totalPatients, 0);
      expect(model.activeVisits, 0);
      expect(model.todayAppointments, 0);
      expect(model.pendingRefills, 0);
      expect(model.totalStaff, 0);
      expect(model.medicationsActive, 0);
    });

    test('toJson produces correct map', () {
      final json = testModel.toJson();
      expect(json, testJson);
    });

    test('json round-trip produces equal model', () {
      final jsonString = jsonEncode(testModel.toJson());
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      final recreated = DashboardStatsModel.fromJson(decoded);
      expect(recreated, testModel);
    });

    test('DashboardStatsModel is a DashboardStats entity', () {
      expect(testModel, isA<DashboardStats>());
    });
  });
}
