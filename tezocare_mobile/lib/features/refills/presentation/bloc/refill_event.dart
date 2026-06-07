import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

abstract class RefillEvent extends Equatable {
  const RefillEvent();

  @override
  List<Object?> get props => [];
}

class GetDueRefillsEvent extends RefillEvent {
  final String? filter;
  final int? days;
  final CancelToken? cancelToken;

  const GetDueRefillsEvent({this.filter, this.days, this.cancelToken});

  @override
  List<Object?> get props => [filter, days, cancelToken];
}

class MarkAsContacted extends RefillEvent {
  final String refillId;

  const MarkAsContacted({required this.refillId});

  @override
  List<Object> get props => [refillId];
}

class MarkAsRefilled extends RefillEvent {
  final String refillId;

  const MarkAsRefilled({required this.refillId});

  @override
  List<Object> get props => [refillId];
}

class CreateRefillsBatch extends RefillEvent {
  final List<Map<String, dynamic>> medications;

  const CreateRefillsBatch({required this.medications});

  @override
  List<Object> get props => [medications];
}

class ClearRefillError extends RefillEvent {
  const ClearRefillError();
}
