part of 'settings_bloc.dart';

enum SettingsStatus { initial, loading, loaded, error }

class SettingsState extends Equatable {
  final SettingsStatus status;
  final CalculationMethod calculationMethod;
  final Madhab madhab;
  final String? errorMessage;

  const SettingsState({
    this.status = SettingsStatus.initial,
    this.calculationMethod = CalculationMethod.north_america,
    this.madhab = Madhab.shafi,
    this.errorMessage,
  });

  SettingsState copyWith({
    SettingsStatus? status,
    CalculationMethod? calculationMethod,
    Madhab? madhab,
    String? errorMessage,
  }) {
    return SettingsState(
      status: status ?? this.status,
      calculationMethod: calculationMethod ?? this.calculationMethod,
      madhab: madhab ?? this.madhab,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, calculationMethod, madhab, errorMessage];
}
