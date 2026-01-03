part of 'permission_bloc.dart';

enum AppPermissionStatus { initial, loading, granted, denied }

class PermissionState extends Equatable {
  final AppPermissionStatus status;

  const PermissionState({
    this.status = AppPermissionStatus.initial,
  });

  PermissionState copyWith({
    AppPermissionStatus? status,
  }) {
    return PermissionState(
      status: status ?? this.status,
    );
  }

  @override
  List<Object> get props => [status];
}
