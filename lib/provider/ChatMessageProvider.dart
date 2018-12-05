import 'package:flutter/widgets.dart';
import 'package:shadoweet/bloc/ChatMessageBloc.dart';
import 'package:shadoweet/chat.dart';

class ChatMessageBlocProvider extends StatefulWidget {

  ChatMessageBlocProvider({Key key})
      : super(key: key);

  @override
  _ChatMessageBlocProviderState createState() => _ChatMessageBlocProviderState();

  static ChatMessageBloc of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(_ChatMessageBlocProvider) as _ChatMessageBlocProvider).bloc;

  }
}

class _ChatMessageBlocProviderState extends State<ChatMessageBlocProvider> {
  _ChatMessageBlocProvider provider;

  @override
  void initState() {
    super.initState();
    provider = _ChatMessageBlocProvider(bloc: ChatMessageBloc(), child: ChatScreen());
  }

  @override
  Widget build(BuildContext context) {
    return provider;
  }

  @override
  void dispose() {
    provider.bloc.clear();
    super.dispose();
  }
}

class _ChatMessageBlocProvider extends InheritedWidget {
  final ChatMessageBloc bloc;

  _ChatMessageBlocProvider({
    Key key,
    @required this.bloc,
    @required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(_ChatMessageBlocProvider old) => bloc != old.bloc;
}
