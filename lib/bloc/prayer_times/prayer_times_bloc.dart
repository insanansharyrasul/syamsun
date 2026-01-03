import 'dart:async';

import 'package:adhan/adhan.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:syamsun/utils/homewidget_configuration.dart';
import 'package:syamsun/utils/location_configuration.dart';
import 'package:syamsun/utils/notification_configuration.dart';
import 'package:syamsun/utils/schedule_configuration.dart';

part 'prayer_times_event.dart';
part 'prayer_times_state.dart';

class PrayerTimesBloc extends Bloc<PrayerTimesEvent, PrayerTimesState> {
  Timer? _timer;

  PrayerTimesBloc() : super(PrayerTimesState.initial()) {
    on<LoadPrayerTimes>(_onLoadPrayerTimes);
    on<RefreshPrayerTimes>(_onRefreshPrayerTimes);
    on<UpdateTick>(_onUpdateTick);
    on<ScheduleSleepNotification>(_onScheduleSleepNotification);

    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      add(UpdateTick());
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }

  Future<void> _onLoadPrayerTimes(
    LoadPrayerTimes event,
    Emitter<PrayerTimesState> emit,
  ) async {
    emit(state.copyWith(status: PrayerTimesStatus.loading));

    try {
      final position = await LocationConfiguration.getCurrentLocation();
      final coordinates = Coordinates(position.latitude, position.longitude);

      // Get location name
      final locationName = await _getLocationName(
        position.latitude,
        position.longitude,
      );

      final params = event.method.getParameters();
      params.madhab = event.madhab;
      final prayerTimes = PrayerTimes.today(coordinates, params);

      // Schedule notifications
      ScheduleConfiguration.schedulePrayerNotification(prayerTimes);

      // Update home widget
      HomeWidgetConfiguration.updateWidget(prayerTimes);

      emit(state.copyWith(
        status: PrayerTimesStatus.loaded,
        prayerTimes: prayerTimes,
        locationName: locationName,
      ));
    } catch (e) {
      debugPrint('Error loading prayer times: $e');
      emit(state.copyWith(
        status: PrayerTimesStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onRefreshPrayerTimes(
    RefreshPrayerTimes event,
    Emitter<PrayerTimesState> emit,
  ) async {
    try {
      final position = await LocationConfiguration.getCurrentLocation();
      final coordinates = Coordinates(position.latitude, position.longitude);

      final params = event.method.getParameters();
      params.madhab = event.madhab;
      final prayerTimes = PrayerTimes.today(coordinates, params);

      // Schedule notifications
      ScheduleConfiguration.schedulePrayerNotification(prayerTimes);

      // Update home widget
      HomeWidgetConfiguration.updateWidget(prayerTimes);

      emit(state.copyWith(
        prayerTimes: prayerTimes,
      ));
    } catch (e) {
      debugPrint('Error refreshing prayer times: $e');
    }
  }

  void _onUpdateTick(
    UpdateTick event,
    Emitter<PrayerTimesState> emit,
  ) {
    emit(state.copyWith(currentTime: DateTime.now()));
  }

  Future<void> _onScheduleSleepNotification(
    ScheduleSleepNotification event,
    Emitter<PrayerTimesState> emit,
  ) async {
    try {
      final position = await LocationConfiguration.getCurrentLocation();
      final coordinates = Coordinates(position.latitude, position.longitude);
      final params = event.method.getParameters();
      params.madhab = event.madhab;

      final now = DateTime.now();
      final prayerTimes = PrayerTimes.today(coordinates, params);
      final nextFajr = prayerTimes.fajr.isAfter(now)
          ? prayerTimes.fajr
          : PrayerTimes(coordinates, DateComponents.from(now.add(const Duration(days: 1))), params)
              .fajr;

      final alarmTime = nextFajr.subtract(event.sleepDuration);
      debugPrint('Alarm time: $alarmTime');

      await LocalNotifications.scheduledSleeepNotification(
        id: 'Sleep',
        setTime: alarmTime,
      );
    } catch (e) {
      debugPrint('Error scheduling sleep notification: $e');
      rethrow;
    }
  }

  Future<String> _getLocationName(double latitude, double longitude) async {
    try {
      final timezone = DateTime.now().timeZoneName;
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      Placemark place = placemarks[0];
      return '${place.country}, ${place.locality} ($timezone)';
    } catch (e) {
      return 'Location not found';
    }
  }
}
