#!/usr/bin/env python3
"""
Splash图片增强工具
基于现有launchImage.png生成更高分辨率的splash图片资源
"""

from PIL import Image
import os
from pathlib import Path

# 源图片路径
SOURCE_IMAGE = Path(__file__).parent.parent / "assets" / "images" / "launchImage.png"

# Android DPI对应的目标尺寸（基于现代高分辨率设备）
DPI_SIZES = {
    "mdpi": (480, 854),      # 基准: 放大1.55倍
    "hdpi": (720, 1280),     # 1.5x mdpi
    "xhdpi": (960, 1707),    # 2x mdpi
    "xxhdpi": (1440, 2560),  # 3x mdpi - 支持2K屏幕
    "xxxhdpi": (1920, 3413), # 4x mdpi - 支持4K屏幕
}

# 输出目录
OUTPUT_BASE = Path(__file__).parent.parent / "android" / "app" / "src" / "main" / "res"


def upscale_image(input_path: Path, target_size: tuple, output_path: Path) -> bool:
    """
    使用高质量Lanczos算法放大图片

    Args:
        input_path: 输入图片路径
        target_size: 目标尺寸 (width, height)
        output_path: 输出图片路径

    Returns:
        是否成功
    """
    try:
        # 打开图片
        img = Image.open(input_path)

        # 确保输出目录存在
        output_path.parent.mkdir(parents=True, exist_ok=True)

        # 使用Lanczos重采样算法进行高质量放大
        resized = img.resize(target_size, Image.Resampling.LANCZOS)

        # 保存为PNG，保持透明度和质量
        resized.save(output_path, "PNG", optimize=True)

        print(f"✓ 生成: {output_path.name} ({target_size[0]}x{target_size[1]})")
        return True

    except Exception as e:
        print(f"✗ 错误: {output_path} - {e}")
        return False


def main():
    """主处理函数"""
    print("=" * 50)
    print("Splash图片增强工具")
    print("=" * 50)

    # 检查源图片
    if not SOURCE_IMAGE.exists():
        print(f"✗ 错误: 源图片不存在 - {SOURCE_IMAGE}")
        return 1

    # 显示源图片信息
    with Image.open(SOURCE_IMAGE) as img:
        print(f"\n源图片: {SOURCE_IMAGE.name}")
        print(f"原始尺寸: {img.size[0]} x {img.size[1]} 像素")
        print(f"原始比例: {img.size[0] / img.size[1]:.2f}\n")

    print("开始生成各分辨率splash图片...\n")

    success_count = 0

    # 为每个DPI生成对应尺寸的图片
    for dpi, size in DPI_SIZES.items():
        output_dir = OUTPUT_BASE / f"drawable-{dpi}"
        output_path = output_dir / "splash.png"

        if upscale_image(SOURCE_IMAGE, size, output_path):
            success_count += 1

    print("\n" + "=" * 50)
    print(f"完成! 成功生成 {success_count}/{len(DPI_SIZES)} 个分辨率版本")
    print("=" * 50)

    return 0


if __name__ == "__main__":
    exit(main())
