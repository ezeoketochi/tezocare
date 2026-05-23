import 'package:equatable/equatable.dart';

abstract class RefillEvent extends Equatable {
  const RefillEvent();

  @override
  List<Object?> get props => [];
}

class GetDueRefillsEvent extends RefillEvent {
  final int? days;

  const GetDueRefillsEvent({this.days});

  @override
  List<Object?> get props => [days];
}
