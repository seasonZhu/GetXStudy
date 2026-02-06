import 'package:flutter/material.dart';
import 'package:getx_study/resource/app_resources.dart';

/// 常量管理使用示例
///
/// 本文件演示如何使用JSON配置文件管理常量
class ConstantsExample extends StatelessWidget {
  const ConstantsExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.homeTitle), // ✅ 使用配置文件
        backgroundColor: AppColors.primary, // ✅ 使用配置文件
      ),
      body: Padding(
        padding: EdgeInsets.all(AppDimens.paddingMedium), // ✅ 使用配置文件
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStringsExample(),
            SizedBox(height: AppDimens.paddingLarge),
            _buildColorsExample(),
            SizedBox(height: AppDimens.paddingLarge),
            _buildDimensExample(),
            SizedBox(height: AppDimens.paddingLarge),
            _buildErrorHandlingExample(),
          ],
        ),
      ),
    );
  }

  /// 1. 字符串资源示例
  Widget _buildStringsExample() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppDimens.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '字符串资源示例',
              style: TextStyle(
                fontSize: AppDimens.fontSizeLarge,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppDimens.paddingMedium),
            Text('应用名称: ${AppStrings.appName}'),
            SizedBox(height: AppDimens.paddingSmall),
            Text('加载提示: ${AppStrings.loading}'),
            SizedBox(height: AppDimens.paddingSmall),
            Text('成功提示: ${AppStrings.success}'),
            SizedBox(height: AppDimens.paddingSmall),
            Text('登录标题: ${AppStrings.loginTitle}'),
            SizedBox(height: AppDimens.paddingSmall),
            ElevatedButton(
              onPressed: () {},
              child: Text(AppStrings.confirm),
            ),
          ],
        ),
      ),
    );
  }

  /// 2. 颜色资源示例
  Widget _buildColorsExample() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppDimens.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '颜色资源示例',
              style: TextStyle(
                fontSize: AppDimens.fontSizeLarge,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppDimens.paddingMedium),
            _buildColorRow('主色', AppColors.primary),
            _buildColorRow('次要色', AppColors.secondary),
            _buildColorRow('成功', AppColors.success),
            _buildColorRow('警告', AppColors.warning),
            _buildColorRow('错误', AppColors.error),
          ],
        ),
      ),
    );
  }

  Widget _buildColorRow(String label, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppDimens.paddingSmall),
      child: Row(
        children: [
          Container(
            width: AppDimens.iconLarge,
            height: AppDimens.iconLarge,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
            ),
          ),
          SizedBox(width: AppDimens.paddingMedium),
          Text(label),
        ],
      ),
    );
  }

  /// 3. 尺寸资源示例
  Widget _buildDimensExample() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppDimens.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '尺寸资源示例',
              style: TextStyle(
                fontSize: AppDimens.fontSizeLarge,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppDimens.paddingMedium),
            Text('间距:'),
            Text('  Tiny: ${AppDimens.paddingTiny}px'),
            Text('  Small: ${AppDimens.paddingSmall}px'),
            Text('  Medium: ${AppDimens.paddingMedium}px'),
            Text('  Large: ${AppDimens.paddingLarge}px'),
            SizedBox(height: AppDimens.paddingMedium),
            Text('字体大小:'),
            Text('  Tiny: ${AppDimens.fontSizeTiny}px'),
            Text('  Small: ${AppDimens.fontSizeSmall}px'),
            Text('  Medium: ${AppDimens.fontSizeMedium}px'),
            Text('  Large: ${AppDimens.fontSizeLarge}px'),
            SizedBox(height: AppDimens.paddingMedium),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                minimumSize: Size.fromHeight(AppDimens.buttonHeight),
              ),
              child: Text('按钮 (${AppDimens.buttonHeight}px)'),
            ),
          ],
        ),
      ),
    );
  }

  /// 4. 错误处理示例
  Widget _buildErrorHandlingExample() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppDimens.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '错误信息示例',
              style: TextStyle(
                fontSize: AppDimens.fontSizeLarge,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppDimens.paddingMedium),
            _buildErrorButton('网络超时', AppStrings.networkErrorTimeout),
            _buildErrorButton('连接失败', AppStrings.networkErrorConnection),
            _buildErrorButton('服务器错误', AppStrings.networkErrorServer),
            _buildErrorButton('登录过期', AppStrings.networkError401),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorButton(String label, String message) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppDimens.paddingSmall),
      child: Builder(
        builder: (ctx) => SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(content: Text(message)),
              );
            },
            child: Text(label),
          ),
        ),
      ),
    );
  }
}
