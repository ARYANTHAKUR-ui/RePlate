
import 'package:flutter/foundation.dart';

import 'food_item.dart';

class FoodStore {
  FoodStore._();

  static final List<FoodItem> items = [];

  // Notifies screens whenever the donation list changes.
  static final ValueNotifier<int> changes = ValueNotifier<int>(0);

  static void addFood(FoodItem food) {
    items.insert(0, food);
    changes.value++;
  }

  static void removeFood(String id) {
    items.removeWhere((food) => food.id == id);
    changes.value++;
  }

  static List<FoodItem> get availableFoods {
    return items.where((food) => !food.isExpired).toList();
  }
}
