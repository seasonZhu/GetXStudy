# 图片资源压缩指南

## 📊 当前图片资源分析

| 文件 | 大小 | 优先级 |
|------|------|--------|
| launchImage.png | **4.9MB** | 🔴 高 |
| saber.jpg | 304KB | 🟡 中 |
| welcome_2.jpg | 288KB | 🟡 中 |
| saber_logo.jpg | 232KB | 🟡 中 |
| welcome_1.png | 156KB | 🟢 低 |
| season_ali_pay.jpg | 92KB | 🟢 低 |

**总计**: 约 **6MB** 图片资源

---

## 🎯 压缩目标

| 文件 | 当前大小 | 目标大小 | 预期节省 |
|------|----------|----------|----------|
| launchImage.png | 4.9MB | ~500KB | ⬇️ 90% |
| saber.jpg | 304KB | ~150KB | ⬇️ 50% |
| welcome_2.jpg | 288KB | ~140KB | ⬇️ 50% |
| saber_logo.jpg | 232KB | ~100KB | ⬇️ 60% |

**预期总节省**: 约 **4MB** (70%)

---

## 🛠️ 压缩方案

### 方案A: 在线工具（推荐，最简单）

#### TinyPNG - 最佳选择
1. 访问: https://tinypng.com/
2. 上传图片（支持批量，最多20张）
3. 下载压缩后的图片
4. 替换 `assets/images/` 中的文件

**优点**:
- 压缩率高（70-90%）
- 保持视觉质量
- 免费（每月最多500张）

---

### 方案B: 命令行工具

#### 安装 pngquant
```bash
# macOS
brew install pngquant

# Linux
sudo apt install pngquant

# Windows
# 下载: https://pngquant.org/pngquant-windows.zip
```

#### 批量压缩脚本
```bash
#!/bin/bash
# 压缩所有PNG图片到80-95质量

cd assets/images

for img in *.png; do
    echo "压缩: $img"
    pngquant --quality=80-95 --ext .png --force "$img"
done

echo "✅ 压缩完成！"
```

#### 安装 jpegoptim（用于JPG）
```bash
# macOS
brew install jpegoptim

# Linux
sudo apt install jpegoptim
```

#### 批量压缩JPG
```bash
#!/bin/bash
cd assets/images

for img in *.jpg *.jpeg; do
    echo "压缩: $img"
    jpegoptim --max=85 --strip-all "$img"
done
```

---

### 方案C: ImageMagick

#### 安装
```bash
# macOS
brew install imagemagick

# Linux
sudo apt install imagemagick
```

#### 批量压缩
```bash
#!/bin/bash
cd assets/images

# PNG压缩
for img in *.png; do
    magick "$img" -quality 85 -strip "${img%.png}_compressed.png"
done

# JPG压缩
for img in *.jpg *.jpeg; do
    magick "$img" -quality 85 -strip "${img%.*}_compressed.jpg"
done
```

---

### 方案D: Flutter构建优化

在 `pubspec.yaml` 中配置：
```yaml
flutter:
  assets:
    - assets/images/

  # 压缩资源配置
  uses-material-design: true

  # 启用资源压缩
  assets:
    - assets/images/

  # 在 android/app/build.gradle 中启用
  # buildTypes {
  #   release {
  #     shrinkAssets true
  #     minifyEnabled true
  #   }
  # }
```

---

## 🚀 快速执行（推荐）

### 使用在线工具（最简单）

1. **准备文件**:
```bash
cd assets/images
cp launchImage.png launchImage_backup.png
```

2. **访问 TinyPNG**: https://tinypng.com/

3. **上传并下载**:
   - 拖拽 `launchImage.png` 到网站
   - 等待压缩
   - 下载压缩后的文件
   - 替换原文件

4. **对比效果**:
```bash
ls -lh launchImage*.png
```

---

### 使用命令行（批量处理）

#### 一键安装工具
```bash
# macOS
brew install pngquant jpegoptim

# 运行压缩脚本
cd assets/images

# 压缩PNG
for f in *.png; do
    pngquant --quality=80-95 --ext .png --force "$f"
done

# 压缩JPG
for f in *.jpg *.jpeg; do
    jpegoptim --max=85 --strip-all "$f"
done
```

---

## 📋 压缩检查清单

- [ ] 备份原始图片
- [ ] 压缩 launchImage.png（最重要！）
- [ ] 压缩其他图片资源
- [ ] 验证压缩后图片质量
- [ ] 重新生成 splash 资源
- [ ] 测试应用启动效果

---

## ⚠️ 注意事项

1. **备份原始文件**
   ```bash
   cp -r assets/images assets/images_backup
   ```

2. **质量验证**
   - 压缩后在真机上测试
   - 检查是否有明显失真
   - 特别注意 splash 图

3. **重新生成资源**
   ```bash
   # 压缩launchImage.png后执行
   flutter pub run flutter_native_splash:create
   ```

---

## 📈 预期效果

| 指标 | 压缩前 | 压缩后 | 改善 |
|------|--------|--------|------|
| assets/images 大小 | ~6MB | ~2MB | ⬇️ 67% |
| APK/IPA 大小 | +6MB | +2MB | ⬇️ 4MB |
| 启动时间 | 正常 | 稍快 | ⬆️ 5-10% |

---

**建议优先级**:
1. 🔴 **立即处理**: launchImage.png (4.9MB → 0.5MB)
2. 🟡 **有时间再做**: 其他图片资源
3. 🟢 **可选**: 使用 WebP 格式（需要代码修改）

---

**文档更新**: 2025年2月6日
**工具版本**: pngquant 2.18+, jpegoptim 1.5+
