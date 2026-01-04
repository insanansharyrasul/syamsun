part of 'permission_bloc.dart';

abstract class PermissionEvent extends Equatable {
  const PermissionEvent();

  @override
  List<Object> get props => [];
}

class CheckPermissions extends PermissionEvent {}

class RequestPermissions extends PermissionEvent {}
