// lib/feature/permission/cubit/permission_state.dart

part of 'permission_cubit.dart';

abstract class PermissionState {}

class PermissionInitial extends PermissionState {}

class PermissionLoading extends PermissionState {}

class PermissionLoaded extends PermissionState {
  final DesignationModel? designation; // null = admin = full access
  PermissionLoaded(this.designation);
}