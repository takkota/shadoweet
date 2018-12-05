import 'dart:collection';

import 'package:shadoweet/enum/item.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SharedPreferencesHelper {

  static Future<bool> isFirstConversation() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool("isFirstConversation") ?? true;
  }

  static Future setFirstConversation(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("isFirstConversation", value);
  }

  static Future<int> getAffection() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt("affection") ?? 0;
  }

  static Future setAffection(int value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt("affection", value);
  }

  static Future<int> countUpAffection(int upCount) async {
    final affection = await getAffection();
    final newAffection = affection + upCount;
    await setAffection(newAffection);
    return newAffection;
  }

  static Future<int> getMoney() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt("money") ?? 0;
  }

  static Future setMoney(int value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt("money", value);
  }

  static Future<int> countUpMoney(int upCount) async {
    final money = await getMoney();
    final newMoney = money + upCount;
    await setMoney(newMoney);
    return newMoney;
  }

  static Future<String> getDogName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("dog_name") ?? "";
  }

  static Future setDogName(String name) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("dog_name", name);
  }
}
