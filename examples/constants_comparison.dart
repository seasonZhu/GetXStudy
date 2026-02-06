import 'package:flutter/material.dart';
import 'package:getx_study/resource/app_resources.dart';

/// ❌ 迁移前的代码（硬编码）
class BeforeMigration extends StatelessWidget {
  const BeforeMigration({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("首页"), // 硬编码
        backgroundColor: const Color(0xFF2196F3), // 硬编码
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // 硬编码
        child: Column(
          children: [
            const Text(
              "加载中...", // 硬编码
              style: TextStyle(fontSize: 14), // 硬编码
            ),
            const SizedBox(height: 8), // 硬编码
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50), // 硬编码
                padding: const EdgeInsets.symmetric( // 硬编码
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
              ),
              child: const Text("确定"), // 硬编码
            ),
            const SizedBox(height: 16), // 硬编码
            if (false)
              const Text("网络连接失败，请检查网络设置"), // 硬编码
          ],
        ),
      ),
    );
  }
}

/// ✅ 迁移后的代码（使用配置文件）

class AfterMigration extends StatelessWidget {
  const AfterMigration({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.homeTitle), // ✅ 从配置读取
        backgroundColor: AppColors.primary, // ✅ 从配置读取
      ),
      body: Padding(
        padding: EdgeInsets.all(AppDimens.paddingMedium), // ✅ 从配置读取
        child: Column(
          children: [
            Text(
              AppStrings.loading, // ✅ 从配置读取
              style: TextStyle(fontSize: AppDimens.fontSizeMedium), // ✅ 从配置读取
            ),
            SizedBox(height: AppDimens.paddingSmall), // ✅ 从配置读取
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success, // ✅ 从配置读取
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimens.paddingLarge, // ✅ 从配置读取
                  vertical: AppDimens.paddingMedium, // ✅ 从配置读取
                ),
              ),
              child: Text(AppStrings.confirm), // ✅ 从配置读取
            ),
            SizedBox(height: AppDimens.paddingMedium), // ✅ 从配置读取
            if (false)
              Text(AppStrings.networkErrorConnection), // ✅ 从配置读取
          ],
        ),
      ),
    );
  }
}

/// 迁移对比总结
class MigrationSummary {
  static const before = '''
硬编码:
  - "首页"
  - Color(0xFF2196F3)
  - 16.0
  - EdgeInsets.all(16.0)
  ''';

  static const after = '''
配置文件:
  - AppStrings.homeTitle
  - AppColors.primary
  - AppDimens.paddingMedium
  - AppColors.success
  ''';

  static const advantages = '''
优势:
  ✅ 集中管理，修改方便
  ✅ 类型安全，自动补全
  ✅ 支持国际化
  ✅ 类似Android的res文件夹
  ✅ 配置文件可热更新
  ''';
}
