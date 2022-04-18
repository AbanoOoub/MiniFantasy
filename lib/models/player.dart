class Player {
  String name;
  String position;
  bool captain;
  bool isSelected;
  bool isPlaying;
  int price;
  int score;
  String img;

  Player(
      {required this.name,
      required this.price,
      required this.position,
      required this.img,
      required this.score,
      required this.isSelected,
      required this.captain,
      required this.isPlaying});
}
