import 'package:adhan/adhan.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:syamsun/utils/saving_configuration.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(const SettingsState()) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateCalculationMethod>(_onUpdateCalculationMethod);
    on<UpdateMadhab>(_onUpdateMadhab);
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(status: SettingsStatus.loading));

    try {
      final savedMethod = await SavingPreferences.getConfigurationMethod();
      final savedMadhab = await SavingPreferences.getConfigurationMadhab();

      final calculationMethod = savedMethod != null
          ? CalculationMethod.values.firstWhere(
              (method) => method.toString() == savedMethod,
              orElse: () => CalculationMethod.north_america,
            )
          : CalculationMethod.north_america;

      final madhab = savedMadhab != null
          ? Madhab.values.firstWhere(
              (m) => m.toString() == savedMadhab,
              orElse: () => Madhab.shafi,
            )
          : Madhab.shafi;

      emit(state.copyWith(
        status: SettingsStatus.loaded,
        calculationMethod: calculationMethod,
        madhab: madhab,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SettingsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateCalculationMethod(
    UpdateCalculationMethod event,
    Emitter<SettingsState> emit,
  ) async {
    await SavingPreferences.saveConfigurationMethod(event.method.toString());
    emit(state.copyWith(calculationMethod: event.method));
  }

  Future<void> _onUpdateMadhab(
    UpdateMadhab event,
    Emitter<SettingsState> emit,
  ) async {
    await SavingPreferences.saveConfigurationMadhab(event.madhab.toString());
    emit(state.copyWith(madhab: event.madhab));
  }
}
