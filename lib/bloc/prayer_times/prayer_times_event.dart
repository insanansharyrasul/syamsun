part of 'prayer_times_bloc.dart';

abstract class PrayerTimesEvent extends Equatable {
  const PrayerTimesEvent();

  @override
  List<Object?> get props => [];
}

class LoadPrayerTimes extends PrayerTimesEvent {
  final CalculationMethod method;
  final Madhab madhab;

  const LoadPrayerTimes({
    required this.method,
    required this.madhab,
  });

  @override
  List<Object?> get props => [method, madhab];
}

class RefreshPrayerTimes extends PrayerTimesEvent {
  final CalculationMethod method;
  final Madhab madhab;

  const RefreshPrayerTimes({
    required this.method,
    required this.madhab,
  });

  @override
  List<Object?> get props => [method, madhab];
}

class UpdateTick extends PrayerTimesEvent {}

class ScheduleSleepNotification extends PrayerTimesEvent {
  final Duration sleepDuration;
  final CalculationMethod method;
  final Madhab madhab;

  const ScheduleSleepNotification({
    required this.sleepDuration,
    required this.method,
    required this.madhab,
  });

  @override
  List<Object?> get props => [sleepDuration, method, madhab];
}
