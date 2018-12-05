
import 'package:flutter/widgets.dart';
import 'package:shadoweet/bloc/ChatMessageBloc.dart';
import 'package:shadoweet/chat.dart';
import 'package:shadoweet/provider/ChatMessageProvider.dart';
import 'package:shadoweet/provider/DogWatchProvider.dart';

class BlocProviderUtil {
  static Widget buildChatScreen() {
    return ChatMessageBlocProvider();
  }
  static Widget buildDogWatchScreen() {
    return DogWatchBlocProvider();
  }
}
