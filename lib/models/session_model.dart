enum SessionType { timed, open }

class SessionModel {
  final int playstationId;
  final int playersCount;
  final int hourlyPrice;
  final DateTime startTime;

  final SessionType type;
  final Duration? duration;

  const SessionModel({
    required this.playstationId,
    required this.playersCount,
    required this.hourlyPrice,
    required this.startTime,
    required this.type,
    required this.duration,
  });
}
