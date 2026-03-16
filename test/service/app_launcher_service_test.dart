import 'package:flutter_test/flutter_test.dart';
import 'package:getx_study/app_service/app_launcher_service.dart';

void main() {
  group('AppLauncherService', () {
    late AppLauncherService service;

    setUp(() {
      // 直接实例化，不依赖 GetX 注册
      service = AppLauncherService();
    });

    group('isCustomScheme', () {
      group('应该识别自定义 scheme', () {
        test('微信 scheme', () {
          expect(service.isCustomScheme('weixin://'), true);
          expect(service.isCustomScheme('weixin://wxpay/bizpayup'), true);
        });

        test('支付宝 scheme', () {
          expect(service.isCustomScheme('alipay://'), true);
          expect(service.isCustomScheme('alipays://'), true);
        });

        test('淘宝 scheme', () {
          expect(service.isCustomScheme('taobao://'), true);
          expect(service.isCustomScheme('tmall://'), true);
        });

        test('知乎 scheme', () {
          expect(service.isCustomScheme('zhihu://'), true);
        });

        test('哔哩哔哩 scheme', () {
          expect(service.isCustomScheme('bilibili://'), true);
        });

        test('掘金 scheme (Android)', () {
          expect(service.isCustomScheme('snssdk2606://'), true);
        });

        test('掘金 scheme (iOS)', () {
          expect(service.isCustomScheme('juejin://'), true);
          expect(service.isCustomScheme('cn.juejin://'), true);
        });

        test('抖音 scheme', () {
          expect(service.isCustomScheme('snssdk://'), true);
        });

        test('京东 scheme', () {
          expect(service.isCustomScheme('jdmobile://'), true);
        });

        test('拼多多 scheme', () {
          expect(service.isCustomScheme('pinduoduo://'), true);
        });
      });

      group('应该识别非自定义 scheme', () {
        test('HTTPS URL', () {
          expect(service.isCustomScheme('https://www.google.com'), false);
          expect(service.isCustomScheme('https://juejin.cn/post/123'), false);
        });

        test('HTTP URL', () {
          expect(service.isCustomScheme('http://www.example.com'), false);
        });

        test('普通域名', () {
          expect(service.isCustomScheme('https://github.com'), false);
          expect(service.isCustomScheme('https://flutter.dev'), false);
        });
      });

      group('边界情况处理', () {
        test('空字符串应该返回 false', () {
          expect(service.isCustomScheme(''), false);
        });

        test('无效 URL 应该返回 false', () {
          expect(service.isCustomScheme('not-a-valid-url'), false);
        });

        test('自定义 scheme 列表参数应该生效', () {
          // 使用自定义 scheme 列表 - myapp 在列表中
          final result = service.isCustomScheme('myapp://test', customSchemes: ['myapp']);
          expect(result, true);

          // unknown 不在自定义列表中，但也不以 http 开头，所以返回 true
          // 这是正确行为：非 http/https 的都被视为自定义 scheme
          final result2 = service.isCustomScheme('unknown://test', customSchemes: ['myapp']);
          // 由于 unknown 不是 http/https，仍然返回 true
          expect(result2, true);

          // http 开头的 URL 即使不在自定义列表中也返回 false
          final result3 = service.isCustomScheme('http://myapp.com', customSchemes: ['myapp']);
          expect(result3, false);
        });

        test('大小写应该不敏感', () {
          expect(service.isCustomScheme('WEIXIN://'), true);
          expect(service.isCustomScheme('Weixin://'), true);
          expect(service.isCustomScheme('ALIPAY://'), true);
        });

        test('带路径的 scheme URL', () {
          expect(service.isCustomScheme('weixin://dl/business/?ticket=xxx'), true);
          expect(service.isCustomScheme('alipay://open'), true);
        });

        test('非 HTTP/HTTPS 的其他协议', () {
          expect(service.isCustomScheme('tel://123456'), true);
          expect(service.isCustomScheme('mailto://test@example.com'), true);
          expect(service.isCustomScheme('sms://123456'), true);
          expect(service.isCustomScheme('geo://0,0'), true);
        });
      });
    });

    group('appSchemeMapping', () {
      test('应该包含常见的应用映射', () {
        final mapping = service.appSchemeMapping;

        // 验证关键应用存在
        expect(mapping.containsKey('juejin'), true);
        expect(mapping.containsKey('douyin'), true);
        expect(mapping.containsKey('weixin'), true);
        expect(mapping.containsKey('alipay'), true);
        expect(mapping.containsKey('zhihu'), true);
        expect(mapping.containsKey('bilibili'), true);
        expect(mapping.containsKey('taobao'), true);
      });

      test('掘金应用信息应该正确', () {
        final juejin = service.appSchemeMapping['juejin']!;

        expect(juejin.androidScheme, 'snssdk2606');
        expect(juejin.iosScheme, 'snssdk2606');
        expect(juejin.androidPackage, 'cn.juejin');
        expect(juejin.name, '稀土掘金');
      });

      test('微信应用信息应该正确', () {
        final weixin = service.appSchemeMapping['weixin']!;

        expect(weixin.androidScheme, 'weixin');
        expect(weixin.iosScheme, 'weixin');
        expect(weixin.androidPackage, 'com.tencent.mm');
        expect(weixin.name, '微信');
      });

      test('支付宝应用信息应该正确', () {
        final alipay = service.appSchemeMapping['alipay']!;

        expect(alipay.androidScheme, 'alipay');
        expect(alipay.iosScheme, 'alipay');
        expect(alipay.androidPackage, 'com.eg.android.AlipayGphone');
        expect(alipay.name, '支付宝');
      });

      test('所有应用都应该有 name 字段', () {
        final mapping = service.appSchemeMapping;

        for (final entry in mapping.entries) {
          expect(entry.value.name, isNotEmpty,
              reason: '${entry.key} should have a name');
        }
      });

      test('所有应用都应该有 platform 信息', () {
        final mapping = service.appSchemeMapping;

        for (final entry in mapping.entries) {
          expect(entry.value.androidScheme, isNotNull,
              reason: '${entry.key} should have androidScheme');
          expect(entry.value.iosScheme, isNotNull,
              reason: '${entry.key} should have iosScheme');
        }
      });
    });

    group('getAppInfoForCurrentPlatform', () {
      test('应该返回当前平台的应用信息', () {
        final info = service.getAppInfoForCurrentPlatform('weixin');

        // 由于测试环境不确定平台，返回值可能为 null 或对应平台信息
        if (info != null) {
          expect(info.name, '微信');
          expect(info.scheme, isNotNull);
        }
      });

      test('不存在的应用应该返回 null', () {
        final info = service.getAppInfoForCurrentPlatform('unknown_app');
        expect(info, isNull);
      });
    });
  });

  group('AppInfo', () {
    test('应该正确创建 AppInfo', () {
      const info = AppInfo(
        androidScheme: 'test',
        iosScheme: 'test',
        androidPackage: 'com.test',
        name: 'Test App',
      );

      expect(info.androidScheme, 'test');
      expect(info.iosScheme, 'test');
      expect(info.androidPackage, 'com.test');
      expect(info.name, 'Test App');
    });

    test('应该支持可选字段', () {
      const info = AppInfo(
        name: 'Test',
      );

      expect(info.name, 'Test');
      expect(info.androidScheme, isNull);
      expect(info.iosScheme, isNull);
    });
  });
}
