#!/bin/bash

find "$1" -type d -name .git -exec dirname {} \; | while read -r repo_dir; do
  cd "$repo_dir" || continue
  echo "正在处理仓库：$repo_dir"
  git rm --cached -r .
done
