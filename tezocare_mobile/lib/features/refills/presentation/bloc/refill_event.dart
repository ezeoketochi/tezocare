import 'package:equatable/equatable.dart';

abstract class RefillEvent extends Equatable {
  const RefillEvent();

  @override
  List<Object?> get props => [];
}

class GetDueRefillsEvent extends RefillEvent {
  final String? filter;

  const GetDueRefillsEvent({this.filter});

  @override
  List<Object?> get props => [filter];
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
