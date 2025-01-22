import 'package:flutter/material.dart';

class ClassLists {
  static const Map<String, List<String>> classes = {
    'IT': [
      'IE1A',
      'IE1B',
      'SE1A',
      'SK1A',
      'IE2A', //
      'IE2B', //
      'SE2A', //
      'SK2A', //
      'SK2B', //
      'IE3A',
      'IE3B',
      'SK3A',
      'IE4A',
      'IE4B',
      'WD1A',
      'WD2A',
      'WD3A',
      'KE1A',
      'KE1B',
      'KE1C',
      'KE2A',
    ],
    'GAME': [
      'GJ2A',
      'GZ2A',
      'SZ2A',
      'GJ3A',
      'GZ3A',
      'IJ3A',
      'GJ4A',
      'IJ4A',
      'CG1A',
      'CG2A',
      'GC2A',
      'CG3A',
      'GC3A',
      'GI1A',
      'GN1A',
      'GO1A',
      'GR1GA',
      'GR1GB',
      'GR1SA',
      'GR1SB',
      'GI2A',
      'GI2B',
      'GN2A',
      'GO2A',
      'GR2GA',
      'GR2GB',
      'GR2SA',
      'GR2SB',
      'GI3A',
      'GN3A',
      'GO3A',
      'GR3GA',
      'GR3GB',
      'GR3SA',
      'GR3SB',
      'GI4A',
      'GN4A',
      'GR4GA',
      'GR4GB',
      'GR4SA',
      'GR4SB',
    ],
  };

  static List<String> getClassesByCourse(String course) {
    return classes[course] ?? [];
  }
}
