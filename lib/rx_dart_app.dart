import 'package:flutter/material.dart';

import 'package:rxdart/rxdart.dart';

class RxDartApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: RxDartExamplePage(),
    );
  }
}

class RxDartExamplePage extends StatefulWidget {
  const RxDartExamplePage({Key? key}) : super(key: key);

  @override
  State<RxDartExamplePage> createState() => _RxDartExamplePageState();
}

class _RxDartExamplePageState extends State<RxDartExamplePage> {
  final _relay = CounterRelay();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("RxDart编写计数器"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            StreamBuilder(
              stream: _relay.stream,
              builder: (context, AsyncSnapshot<int> snapshot) {
                if (snapshot.hasData) {
                  return Text(
                    snapshot.data.toString(),
                    style: Theme.of(context).textTheme.headlineMedium,
                  );
                } else {
                  return Container();
                }
              },
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _relay.increment,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _relay.dispose();
    super.dispose();
  }
}

class CounterRelay {
  final _subject = BehaviorSubject.seeded(0);

  ValueStream<int> get stream => _subject.stream;

  void increment() {
    _subject.add(_subject.value + 1);
  }

  void dispose() {
    _subject.close();
  }
}
