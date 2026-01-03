part of 'prayer_times_bloc.dart';

enum PrayerTimesStatus { initial, loading, loaded, error }

class PrayerTimesState extends Equatable {
  final PrayerTimesStatus status;
  final PrayerTimes? prayerTimes;
  final String locationName;
  final String? errorMessage;
  final DateTime currentTime;

  const PrayerTimesState({
    this.status = PrayerTimesStatus.initial,
    this.prayerTimes,
    this.locationName = '',
    this.errorMessage,
    required this.currentTime,
  });

  factory PrayerTimesState.initial() {
    return PrayerTimesState(currentTime: DateTime.now());
  }

  DateTime get nextPrayerTime {
    if (prayerTimes == null) return DateTime.now();
    final now = DateTime.now();
    if (now.isBefore(prayerTimes!.fajr)) return prayerTimes!.fajr;
    if (now.isBefore(prayerTimes!.dhuhr)) return prayerTimes!.dhuhr;
    if (now.isBefore(prayerTimes!.asr)) return prayerTimes!.asr;
    if (now.isBefore(prayerTimes!.maghrib)) return prayerTimes!.maghrib;
    if (now.isBefore(prayerTimes!.isha)) return prayerTimes!.isha;
    return prayerTimes!.fajr.add(const Duration(days: 1));
  }

  String get nextPrayerName {
    if (prayerTimes == null) return '';
    final now = DateTime.now();
    if (now.isBefore(prayerTimes!.fajr)) return 'Fajr';
    if (now.isBefore(prayerTimes!.dhuhr)) return 'Dhuhr';
    if (now.isBefore(prayerTimes!.asr)) return 'Asr';
    if (now.isBefore(prayerTimes!.maghrib)) return 'Maghrib';
    if (now.isBefore(prayerTimes!.isha)) return 'Isha';
    return 'Fajr';
  }

  String get remainingTime {
    final difference = nextPrayerTime.difference(currentTime);
    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;
    final seconds = difference.inSeconds % 60;
    return '$hours:$minutes:$seconds';
  }

  PrayerTimesState copyWith({
    PrayerTimesStatus? status,
    PrayerTimes? prayerTimes,
    String? locationName,
    String? errorMessage,
    DateTime? currentTime,
  }) {
    return PrayerTimesState(
      status: status ?? this.status,
      prayerTimes: prayerTimes ?? this.prayerTimes,
      locationName: locationName ?? this.locationName,
      errorMessage: errorMessage ?? this.errorMessage,
      currentTime: currentTime ?? this.currentTime,
    );
  }

  @override
  List<Object?> get props => [
        status,
        prayerTimes,
        locationName,
        errorMessage,
        currentTime,
      ];
}
