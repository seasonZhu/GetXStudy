import 'package:flutter_test/flutter_test.dart';
import 'package:getx_study/entity/base_entity.dart';
import 'package:getx_study/pages/web/repository/web_repository.dart';

void main() {
  group('WebRepository', () {
    late WebRepository repository;

    setUp(() {
      repository = WebRepository();
    });

    group('collectAction', () {
      test('收藏成功的响应应该返回 isSuccess 为 true', () {
        // 由于无法直接 Mock HttpUtils，这里展示测试结构
        // 实际项目中可以使用 mockito 或 mocktail 进行依赖注入和 Mock

        // 模拟成功的响应数据
        const successResponse = {
          'errorCode': 0,
          'errorMsg': '',
          'data': null,
        };

        // 创建实体
        final entity = BaseEntity<Object?>.fromJson(successResponse);

        // 验证实体行为
        expect(entity.isSuccess, true);
        expect(entity.errorCode, 0);
        expect(entity.errorMsg, '');
        expect(entity.data, isNull);
      });

      test('收藏失败的响应应该返回 isSuccess 为 false', () {
        // 模拟失败的响应数据
        const failureResponse = {
          'errorCode': -1,
          'errorMsg': '请先登录',
          'data': null,
        };

        final entity = BaseEntity<Object?>.fromJson(failureResponse);

        expect(entity.isSuccess, false);
        expect(entity.errorCode, -1);
        expect(entity.errorMsg, '请先登录');
      });

      test('响应数据应该正确解析', () {
        const responseWithData = {
          'errorCode': 0,
          'errorMsg': '',
          'data': {'id': 123, 'title': '测试文章'},
        };

        final entity = BaseEntity<Map<String, dynamic>>.fromJson(responseWithData);

        expect(entity.isSuccess, true);
        expect(entity.data?['id'], 123);
        expect(entity.data?['title'], '测试文章');
      });
    });

    group('unCollectAction', () {
      test('取消收藏成功的响应应该返回 isSuccess 为 true', () {
        const successResponse = {
          'errorCode': 0,
          'errorMsg': '',
          'data': null,
        };

        final entity = BaseEntity<Object?>.fromJson(successResponse);

        expect(entity.isSuccess, true);
      });

      test('取消收藏失败的响应应该返回 isSuccess 为 false', () {
        const failureResponse = {
          'errorCode': -1,
          'errorMsg': '取消收藏失败',
          'data': null,
        };

        final entity = BaseEntity<Object?>.fromJson(failureResponse);

        expect(entity.isSuccess, false);
        expect(entity.errorMsg, '取消收藏失败');
      });
    });

    group('BaseEntity 边界情况', () {
      test('空数据应该正确处理', () {
        const emptyResponse = {
          'errorCode': 0,
          'errorMsg': '',
        };

        final entity = BaseEntity<Object?>.fromJson(emptyResponse);

        expect(entity.isSuccess, true);
        expect(entity.data, isNull);
      });

      test('缺失 errorCode 应该返回 false', () {
        const missingCodeResponse = {
          'errorMsg': '',
          'data': null,
        };

        final entity = BaseEntity<Object?>.fromJson(missingCodeResponse);

        expect(entity.isSuccess, false);
      });

      test('errorCode 为 null 应该返回 false', () {
        const nullCodeResponse = {
          'errorCode': null,
          'errorMsg': '',
          'data': null,
        };

        final entity = BaseEntity<Object?>.fromJson(nullCodeResponse);

        expect(entity.isSuccess, false);
      });
    });
  });
}
