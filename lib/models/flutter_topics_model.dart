import 'package:flutter/cupertino.dart';

const Color cardColor = Color(0xFF4993FA);

class FlutterTopics {
  final int id;
  final String topicName;
  final Image topicIcon;
  final Color topicColor;

  FlutterTopics({
    required this.id,
    required this.topicColor,
    required this.topicIcon,
    required this.topicName,
  });
}

final List<FlutterTopics> flutterTopicsList = [
  FlutterTopics(
    id: 0,
    topicColor: cardColor,
    topicIcon: Image.asset("assets/cow.png"),
    topicName: "Beef",
  ),
  FlutterTopics(
    id: 1,
    topicColor: cardColor,
    topicIcon: Image.asset("assets/chicken.png"),
    topicName: "Chicken",
  ),
  FlutterTopics(
    id: 2,
    topicColor: cardColor,
    topicIcon: Image.asset("assets/horse.png"),
    topicName: "Horse",
  ),
  FlutterTopics(
    id: 3,
    topicColor: cardColor,
    topicIcon: Image.asset("assets/milk-bottle.png"),
    topicName: "Milk",
  ),
];
