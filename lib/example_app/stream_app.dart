import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:getx_study/app_service/language_service.dart';
import 'package:getx_study/i18n/app_text.dart';
import 'dart:async';

import 'package:flutter/material.dart';

class StreamApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: AppText.locale,
      supportedLocales: LanguageService.supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: StreamExamplePage(),
    );
  }
}

class StreamExamplePage extends StatefulWidget {
  const StreamExamplePage({super.key});

  @override
  State<StreamExamplePage> createState() => _StreamExamplePageState();
}

class _StreamExamplePageState extends State<StreamExamplePage> {
  final _viewModel = StreamExampleViewModel();

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppText.t('example.stream')),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              AppText.t('example.counter_hint'),
            ),
            StreamBuilder<int>(
              initialData: 0,
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

class StreamExampleViewModel {
  final _controller = StreamController<int>();

  var _count = 0;

  Stream<int> get stream => _controller.stream;

  void increment() {
    ++_count;
    _controller.sink.add(_count);
  }

  void dispose() {
    _controller.close();
  }
}
