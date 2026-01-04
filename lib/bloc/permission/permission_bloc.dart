import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

part 'permission_event.dart';
part 'permission_state.dart';

class PermissionBloc extends Bloc<PermissionEvent, PermissionState> {
  PermissionBloc() : super(const PermissionState()) {
    on<CheckPermissions>(_onCheckPermissions);
    on<RequestPermissions>(_onRequestPermissions);
  }

  Future<void> _onCheckPermissions(
    CheckPermissions event,
    Emitter<PermissionState> emit,
  ) async {
    emit(state.copyWith(status: AppPermissionStatus.loading));

    final locationStatus = await ph.Permission.locationWhenInUse.status;
    final alarmStatus = await ph.Permission.scheduleExactAlarm.status;

    if (locationStatus.isGranted && alarmStatus.isGranted) {
      emit(state.copyWith(status: AppPermissionStatus.granted));
    } else {
      add(RequestPermissions());
    }
  }

  Future<void> _onRequestPermissions(
    RequestPermissions event,
    Emitter<PermissionState> emit,
  ) async {
    emit(state.copyWith(status: AppPermissionStatus.loading));

    final locationResult = await ph.Permission.locationWhenInUse.request();
    final alarmResult = await ph.Permission.scheduleExactAlarm.request();

    if (locationResult.isGranted && alarmResult.isGranted) {
      emit(state.copyWith(status: AppPermissionStatus.granted));
    } else {
      emit(state.copyWith(status: AppPermissionStatus.denied));
    }
  }
}
