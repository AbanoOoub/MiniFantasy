import 'package:minifantasy/models/player.dart';

class User {
  //Team team;
  int money;
  int totalScore;
  String teamName;
  String password;
  List<Player> team;

  User(this.team, this.money, this.totalScore, this.teamName, this.password);
}
