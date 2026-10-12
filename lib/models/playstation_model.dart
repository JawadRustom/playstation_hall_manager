class PlayStationModel {
  final int id;
  final String name;
  final int controllersCount;
  final int priceForTwo;
  final int priceForThree;
  final int priceForFour;
  final bool isAvailable;

  const PlayStationModel({
    required this.id,
    required this.name,
    required this.controllersCount,
    required this.priceForTwo,
    required this.priceForThree,
    required this.priceForFour,
    required this.isAvailable,
  });
}
