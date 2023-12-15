#!/bin/bash

# 获取脚本所在的目录
START_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# 遍历目录寻找pubspec.yaml文件，并执行flutter clean
find "$START_DIR" -name 'pubspec.yaml' | while read -r file; do
    # 获取Flutter项目的目录路径
    project_dir=$(dirname "$file")
    echo "Found Flutter project at $project_dir"
    # 进入项目目录
    cd "$project_dir" || exit
    # 执行flutter clean
    flutter clean
    # 返回到脚本开始的目录，以继续搜索
    cd "$START_DIR" || exit
done

echo "All Flutter projects cleaned."
