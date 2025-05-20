// lib/models/challenge.dart

import 'package:flutter/material.dart';

class Challenge {
  final String   id;
  final String   title;
  final String   frequency; // «Ежедневно», «Еженедельно» и т.д.
  final String   unit;      // «стаканов», «шагов», «ч»
  final int      target;    // первоначальная цель
  final IconData icon;      // иконка

  const Challenge({
    required this.id,
    required this.title,
    required this.frequency,
    required this.unit,
    required this.target,
    required this.icon,
  });
}
