import 'package:flutter/material.dart';

// Map of emotions to Material icons
final Map<String, IconData> emotionIcons = {
  'very_satisfied': Icons.sentiment_very_satisfied,
  'satisfied': Icons.sentiment_satisfied,
  'neutral': Icons.sentiment_neutral,
  'dissatisfied': Icons.sentiment_dissatisfied,
  'very_dissatisfied': Icons.sentiment_very_dissatisfied,
};

// Define the feelings and their display order
final List<String> feelingsOrder = [
  'very_satisfied',
  'satisfied',
  'neutral',
  'dissatisfied',
  'very_dissatisfied',
];
