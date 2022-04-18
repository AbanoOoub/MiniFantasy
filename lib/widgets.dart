import 'package:flutter/material.dart';

Widget defaultContainer({
  required height,
  required child,
}) {
  return Container(
    child: child,
    height: height,
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.white10,
      border: Border.all(color: Colors.white, width: 0.3),
      borderRadius: BorderRadius.circular(5),
    ),
  );
}

Widget defaultFormField({
  required context,
  required TextEditingController controller,
  required TextInputType type,
  required String label,
  required IconData prefix,
  bool isPassword = false,
}) =>
    Container(
      width: MediaQuery.of(context).size.width - 60,
      child: TextFormField(
        style: TextStyle(color: Colors.white, fontSize: 14),
        controller: controller,
        keyboardType: type,
        obscureText: isPassword,
        cursorColor: Colors.white,
        validator: (value) {
          if (value!.isEmpty) {
            return "this is required";
          }
        },
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(prefix, color: Colors.white),
          fillColor: Colors.white10,
          filled: true,
          labelStyle: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w300, fontSize: 14),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white, width: 0.3)),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white, width: 0.3)),
        ),
      ),
    );

Widget defaultBottom({
  required width,
  height,
  required String text,
  required onPressed,
}) {
  return Container(
    width: width,
    height: height,
    child: TextButton(
      onPressed: onPressed,
      child: defaultText(text, 14),
    ),
    decoration: BoxDecoration(
      color: Colors.white10,
      border: Border.all(color: Colors.white, width: 0.3),
      borderRadius: BorderRadius.circular(5),
    ),
  );
}

Widget defaultText(String data, double size) {
  return Text(
    data,
    style: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w300,
      fontSize: size,
    ),
  );
}

Widget defaultPlayerPrice({
  required height,
  required img,
  required playerName,
  required playerPrice,
  required playerPosition,
  required onPressed,
  required icon,
}) {
  return defaultContainer(
    height: height,
    child: Row(
      children: [
        Expanded(
            flex: 2,
            child: Center(
                child: Image.asset(img, height: height - 10, width: height))),
        Expanded(flex: 2, child: Center(child: defaultText(playerName, 18))),
        Expanded(
            flex: 1, child: Center(child: defaultText(playerPosition, 18))),
        Expanded(
            flex: 2, child: Center(child: defaultText('\$$playerPrice M', 18))),
        Expanded(
          flex: 1,
          child: Center(child: TextButton(onPressed: onPressed, child: icon)),
        ),
      ],
    ),
  );
}

Widget defaultUserStanding({
  required height,
  required teamName,
  imgStanding,
  required userScore,
}) {
  return defaultContainer(
    height: height,
    child: Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          Expanded(flex: 1, child: Center(child: defaultText(teamName, 18))),
          Expanded(
              flex: 1,
              child: Center(
                child: Image.asset(
                  imgStanding,
                  height: height - 50,
                ),
              )),
          Expanded(
              flex: 1, child: Center(child: defaultText('$userScore', 18))),
        ],
      ),
    ),
  );
}

Widget playerCard({
  required playerImg,
  required captain,
  required score,
  required playerName,
  required width,
  required height,
  required onTap,
}) {
  return InkWell(
    child: Container(
      width: width,
      height: height,
      child: Column(
        children: [
          captain
              ? Expanded(
                  flex: 4,
                  child: Row(
                    children: [
                      Expanded(
                          flex: 1, child: Image.asset('images/captain.png')),
                      Expanded(flex: 4, child: Image.asset(playerImg)),
                    ],
                  ),
                )
              : Expanded(flex: 4, child: Image.asset(playerImg)),

          //Expanded(flex: 4, child: Image.asset(playerImg)),
          Expanded(
            flex: 1,
            child: Container(
              child: Center(child: defaultText(playerName, 18)),
              color: Colors.white30,
              width: double.infinity,
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              child: Center(child: defaultText(score.toString(), 18)),
              color: Colors.white10,
              width: double.infinity,
            ),
          ),
        ],
      ),
    ),
    onTap: onTap,
  );
}

Widget defaultPlayerInTeam({
  required height,
  required img,
  required playerName,
  required playerPosition,
  required onPressed,
  required icon,
}) {
  return defaultContainer(
    height: height,
    child: Row(
      children: [
        Expanded(flex: 2, child: Center(child: Image.asset(img))),
        Expanded(flex: 2, child: Center(child: defaultText(playerName, 18))),
        Expanded(
            flex: 1, child: Center(child: defaultText(playerPosition, 18))),
        Expanded(
          flex: 1,
          child: Center(child: TextButton(onPressed: onPressed, child: icon)),
        ),
      ],
    ),
  );
}

Widget defaultPlayerAddScore({
  required height,
  required img,
  required playerName,
  required scoreController,
  required context,
}) {
  return defaultContainer(
    height: height,
    child: Row(
      children: [
        Expanded(flex: 1, child: Center(child: Image.asset(img))),
        Expanded(flex: 1, child: Center(child: defaultText(playerName, 18))),
        Expanded(
          flex: 1,
          child: Center(
            child: defaultFormField(
                context: context,
                label: 'Score',
                type: TextInputType.number,
                isPassword: false,
                prefix: Icons.assessment,
                controller: scoreController),
          ),
        ),
      ],
    ),
  );
}
