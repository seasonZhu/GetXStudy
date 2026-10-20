import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:getx_study/app_service/language_service.dart';
import 'package:getx_study/i18n/app_text.dart';
import 'dart:async';

import 'package:flutter/material.dart';

import 'package:rxdart/rxdart.dart';

class RxDartApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: AppText.locale,
      supportedLocales: LanguageService.supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: RxDartExamplePage(),
    );
  }
}

class RxDartExamplePage extends StatefulWidget {
  const RxDartExamplePage({super.key});

  @override
  State<RxDartExamplePage> createState() => _RxDartExamplePageState();
}

class _RxDartExamplePageState extends State<RxDartExamplePage> {
  final _viewModel = RxDartExampleViewModel();

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppText.t('example.rxdart')),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              AppText.t('example.counter_hint'),
            ),
            StreamBuilder<int>(
              stream: _viewModel.stream,
              builder: (context, snapshot) {
                return Text(
                  AppText.number(snapshot.data),
                  //_viewModel.stream.value.toString(),
                  style: Theme.of(context).textTheme.headlineMedium,
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _viewModel.increment,
        tooltip: AppText.t('example.increment'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class RxDartExampleViewModel {
  final _subject = BehaviorSubject.seeded(0);

  ValueStream<int> get stream => _subject.stream;

  void increment() {
    _subject.add(_subject.value + 1);
  }

  void dispose() {
    _subject.close();
  }
}

/// 尝试使用了PublishSubject,但是感觉和BehaviorSubject差不多
class RxDartExampleViewModel2 {
  final _subject = PublishSubject<int>();

  var _count = 0;

  Stream<int> get stream => _subject.stream;

  StreamSink<int> get sink => _subject.sink;

  RxDartExampleViewModel2() {
    _subject.startWith(_count);
  }

  void increment() {
    ++_count;
    _subject.add(_count);
  }

  void dispose() {
    _subject.close();
  }
}
