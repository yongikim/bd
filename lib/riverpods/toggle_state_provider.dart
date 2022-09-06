import 'package:flutter_riverpod/flutter_riverpod.dart';

final showAllRecurringProvider = StateProvider<bool>((ref) {
  return false;
});

final showAllTemporaryProvider = StateProvider<bool>((ref) {
  return false;
});
