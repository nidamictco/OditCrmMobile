import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:odit_crm_mobile/feature/lead_details/data/activity_repo.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/models/activity_model.dart';

abstract class ActivityState {}

class ActivityInitial extends ActivityState {}

class ActivityLoading extends ActivityState {}

class ActivityLoaded extends ActivityState {
  final List<ActivityModel> activities;
  ActivityLoaded(this.activities);
}

class ActivityError extends ActivityState {
  final String errorMessage;
  ActivityError(this.errorMessage);
}

class ActivityCubit extends Cubit<ActivityState> {
  final ActivityRepository _repository;

  ActivityCubit(this._repository) : super(ActivityInitial());

  Future<void> fetchActivities(String leadId) async {
    emit(ActivityLoading());
    try {
      final activities = await _repository.getActivities(leadId);
      emit(ActivityLoaded(activities));
    } catch (e) {
      emit(ActivityError(e.toString()));
    }
  }

  void clearActivities() {
    emit(ActivityInitial());
  }
}
