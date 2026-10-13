import '../models/completed_session.dart';
import '../models/playstation_model.dart';
import '../models/session_model.dart';

int selectHourlyPrice(PlayStationModel playstation, int playersCount) {
  switch (playersCount) {
    case 2:
      return playstation.priceForTwo;
    case 3:
      return playstation.priceForThree;
    case 4:
      return playstation.priceForFour;
    default:
      return 0;
  }
}

Duration calculateElapsedDuration({
  required DateTime startTime,
  required DateTime endTime,
}) {
  final elapsed = endTime.difference(startTime);
  return elapsed.isNegative ? Duration.zero : elapsed;
}

int calculateSessionCharge(SessionModel session, Duration actualDuration) {
  if (actualDuration <= Duration.zero) {
    return 0;
  }

  final hourlyPrice = session.hourlyPrice;
  final actualMicroseconds = actualDuration.inMicroseconds;

  const microsecondsPerHour = Duration.microsecondsPerHour;

  return (hourlyPrice * actualMicroseconds) ~/ microsecondsPerHour;
}

CompletedSession createCompletedSession({
  required SessionModel session,
  required DateTime endTime,
  required int calculatedAmount,
  required int collectedAmount,
  String? adjustmentReason,
}) {
  return CompletedSession(
    session: session,
    endTime: endTime,
    actualDuration: calculateElapsedDuration(
      startTime: session.startTime,
      endTime: endTime,
    ),
    calculatedAmount: calculatedAmount,
    collectedAmount: collectedAmount,
    adjustmentReason: adjustmentReason,
  );
}
