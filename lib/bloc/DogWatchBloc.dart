import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:shadoweet/urility/SharedPreferencesHelper.dart';

class DogWatchBloc {

  final StreamController<int> _affectionStreamController = StreamController<int>();
  // input entry point
  Sink<int> get affectionSink => _affectionStreamController.sink;
  // BehaviorSubjectを使う事で最後に追加したアイテムがstreamにaddした後のタイミングでも取得できる
  final BehaviorSubject<int> _affection = BehaviorSubject<int>();
  // output entry point
  Stream get affectionStream => _affection.stream;

  final StreamController<int> _moneyStreamController = StreamController<int>();
  // input entry point
  Sink<int> get moneySink => _moneyStreamController.sink;
  final BehaviorSubject<int> _money = BehaviorSubject<int>();
  // output entry point
  Stream get moneyStream => _money.stream;

  DogWatchBloc() {
    refresh();

    _affectionStreamController.stream.listen((affection) {
      _affection.add(affection);
    });
    _moneyStreamController.stream.listen((affection) {
      _money.add(affection);
    });
  }

  void refresh() async {
    final affection = await SharedPreferencesHelper.getAffection();
    final money = await SharedPreferencesHelper.getMoney();
    affectionSink.add(affection);
    moneySink.add(money);
  }

  void addAffection(int upCount) async {
    final affection = await SharedPreferencesHelper.countUpAffection(upCount);
    affectionSink.add(affection);
  }

  void addMoney(int upCount) async {
    final money = await SharedPreferencesHelper.countUpMoney(upCount);
    moneySink.add(money);
  }
}