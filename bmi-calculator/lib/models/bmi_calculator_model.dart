import 'dart:math';

class BMICalculatorModel {
  final double height;
  final double weight;
  final bool isMetric;

  BMICalculatorModel({
    required this.height,
    required this.weight,
    this.isMetric = true,
  });

  double calculateBMI() {
    if (height == 0) return 0.0;

    if (isMetric) {
      double heightInMeters = height / 100;
      return weight / pow(heightInMeters, 2);
    } else {
      return (weight / pow(height, 2)) * 703;
    }
  }

  String getResult(double bmi) {
    if (bmi >= 25) {
      return 'Overweight';
    } else if (bmi > 18.5) {
      return 'Normal';
    } else {
      return 'Underweight';
    }
  }

  String getInterpretation(double bmi) {
    if (bmi >= 25) {
      return 'Your BMI is above the ideal range.';
    } else if (bmi > 18.5) {
      return 'Your BMI is within the ideal range.';
    } else {
      return 'Your BMI is below the ideal range.';
    }
  }
}
