import 'package:flutter/widgets.dart';
import 'package:shadoweet/bloc/DogWatchBloc.dart';
import 'package:shadoweet/chat.dart';
import 'package:shadoweet/dog_watch.dart';

class DogWatchBlocProvider extends StatefulWidget {

  DogWatchBlocProvider({Key key})
      : super(key: key);

  @override
  _DogWatchBlocProviderState createState() => _DogWatchBlocProviderState();

  static DogWatchBloc of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(_DogWatchBlocProvider) as _DogWatchBlocProvider).bloc;

  }
}

class _DogWatchBlocProviderState extends State<DogWatchBlocProvider> {
  _DogWatchBlocProvider provider;

  @override
  void initState() {
    super.initState();
    provider = _DogWatchBlocProvider(bloc: DogWatchBloc(), child: DogWatchScreen());
  }

  @override
  Widget build(BuildContext context) {
    return provider;
  }
}

class _DogWatchBlocProvider extends InheritedWidget {
  final DogWatchBloc bloc;

  _DogWatchBlocProvider({
    Key key,
    @required this.bloc,
    @required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(_DogWatchBlocProvider old) => bloc != old.bloc;
}
