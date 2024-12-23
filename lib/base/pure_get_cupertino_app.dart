import 'package:flutter/cupertino.dart';

import 'package:get/get.dart';
import 'package:getx_study/base/get_cupertino_controller.dart';

class PureGetCupertinoApp extends GetCupertinoApp {
  const PureGetCupertinoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => GetBuilder<GetCupertinoController>(
        init: GetCupertinoController(),
        dispose: (d) {
          onDispose?.call();
        },
        initState: (i) {
          Get.engine.addPostFrameCallback((timeStamp) {
            onReady?.call();
          });
          if (locale != null) Get.locale = locale;

          if (fallbackLocale != null) Get.fallbackLocale = fallbackLocale;

          if (translations != null) {
            Get.addTranslations(translations!.keys);
          } else if (translationsKeys != null) {
            Get.addTranslations(translationsKeys!);
          }

          Get.customTransition = customTransition;

          initialBinding?.dependencies();
          if (getPages != null) {
            Get.addPages(getPages!);
          }

          Get.smartManagement = smartManagement;
          onInit?.call();

          Get.config(
            enableLog: enableLog ?? Get.isLogEnable,
            logWriterCallback: logWriterCallback,
            defaultTransition: defaultTransition ?? Get.defaultTransition,
            defaultOpaqueRoute: opaqueRoute ?? Get.isOpaqueRouteDefault,
            defaultPopGesture: popGesture ?? Get.isPopGestureEnable,
            defaultDurationTransition:
                transitionDuration ?? Get.defaultTransitionDuration,
          );
        },
        builder: (_) => routerDelegate != null
            ? CupertinoApp.router(
                routerDelegate: routerDelegate!,
                routeInformationParser: routeInformationParser!,
                backButtonDispatcher: backButtonDispatcher,
                routeInformationProvider: routeInformationProvider,
                key: _.unikey,
                theme: theme,
                builder: defaultBuilder,
                title: title,
                onGenerateTitle: onGenerateTitle,
                color: color,
                locale: Get.locale ?? locale,
                localizationsDelegates: localizationsDelegates,
                localeListResolutionCallback: localeListResolutionCallback,
                localeResolutionCallback: localeResolutionCallback,
                supportedLocales: supportedLocales,
                showPerformanceOverlay: showPerformanceOverlay,
                checkerboardRasterCacheImages: checkerboardRasterCacheImages,
                checkerboardOffscreenLayers: checkerboardOffscreenLayers,
                showSemanticsDebugger: showSemanticsDebugger,
                debugShowCheckedModeBanner: debugShowCheckedModeBanner,
                shortcuts: shortcuts,
                // useInheritedMediaQuery: useInheritedMediaQuery,
              )
            : CupertinoApp(
                key: _.unikey,
                theme: theme,
                navigatorKey: (navigatorKey == null
                    ? Get.key
                    : Get.addKey(navigatorKey!)),
                home: home,
                routes: routes ?? const <String, WidgetBuilder>{},
                initialRoute: initialRoute,
                onGenerateRoute:
                    (getPages != null ? generator : onGenerateRoute),
                onGenerateInitialRoutes: (getPages == null || home != null)
                    ? onGenerateInitialRoutes
                    : initialRoutesGenerate,
                onUnknownRoute: onUnknownRoute,
                navigatorObservers: (navigatorObservers == null
                    ? <NavigatorObserver>[
                        GetObserver(routingCallback, Get.routing)
                      ]
                    : <NavigatorObserver>[
                        GetObserver(routingCallback, Get.routing)
                      ]
                  ..addAll(navigatorObservers!)),
                builder: defaultBuilder,
                title: title,
                onGenerateTitle: onGenerateTitle,
                color: color,
                locale: Get.locale ?? locale,
                localizationsDelegates: localizationsDelegates,
                localeListResolutionCallback: localeListResolutionCallback,
                localeResolutionCallback: localeResolutionCallback,
                supportedLocales: supportedLocales,
                showPerformanceOverlay: showPerformanceOverlay,
                checkerboardRasterCacheImages: checkerboardRasterCacheImages,
                checkerboardOffscreenLayers: checkerboardOffscreenLayers,
                showSemanticsDebugger: showSemanticsDebugger,
                debugShowCheckedModeBanner: debugShowCheckedModeBanner,
                shortcuts: shortcuts,
                // useInheritedMediaQuery: useInheritedMediaQuery,
                //   actions: actions,
              ),
      );
}
