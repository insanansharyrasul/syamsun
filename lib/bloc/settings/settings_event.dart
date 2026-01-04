part of 'settings_bloc.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object> get props => [];
}

class LoadSettings extends SettingsEvent {}

class UpdateCalculationMethod extends SettingsEvent {
  final CalculationMethod method;

  const UpdateCalculationMethod(this.method);

  @override
  List<Object> get props => [method];
}

class UpdateMadhab extends SettingsEvent {
  final Madhab madhab;

  const UpdateMadhab(this.madhab);

  @override
  List<Object> get props => [madhab];
}
