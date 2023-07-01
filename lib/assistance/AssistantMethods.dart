import 'dart:math';

class AssistantMethods {
  static double generateRandomNumber(int num) {
    var randomGenerator = Random();
    int ranInt = randomGenerator.nextInt(num);
    return ranInt.toDouble();
  }
}
