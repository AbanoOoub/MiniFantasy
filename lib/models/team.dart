import 'package:minifantasy/models/player.dart';

class Team {
  Map<Player, bool> gk;
  Map<Player, bool> pl1;
  Map<Player, bool> pl2;
  Map<Player, bool> pl3;
  Map<Player, bool> pl4;
  //List<Map<Player,bool>> team;

  //Team(this.team);

  Team(this.gk, this.pl1, this.pl2, this.pl3, this.pl4);
}
