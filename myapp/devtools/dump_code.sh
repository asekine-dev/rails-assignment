#!/bin/bash

ROOT_DIR="/rails-assignment/myapp"

LIST_FILE="$1"

if [ ! -f "$LIST_FILE" ]; then
  echo "ファイルリストが見つかりません: $LIST_FILE" >&2
  exit 1
fi

while read -r path; do
  # CR(\r)と前後空白を除去（Windows改行・コピペ汚れ対策）
  path="${path%%$'\r'}"
  path="${path#"${path%%[![:space:]]*}"}"  # 左trim
  path="${path%"${path##*[![:space:]]}"}"  # 右trim

  # 空行・コメント行を無視
  [[ -z "$path" || "$path" =~ ^# ]] && continue

  FULL_PATH="$ROOT_DIR/$path"
  echo "$ROOT_DIR/$path"

  # ディレクトリの場合
  if [ -d "$FULL_PATH" ]; then
    find "$FULL_PATH" -type f | sort | while read -r file; do
      # 表示用はリポジトリ相対パスに戻す
      REL_PATH="${file#$ROOT_DIR/}"

      echo "\`\`\`[$REL_PATH]"
      cat "$file"
      echo "\`\`\`"
      echo
    done

  # ファイルの場合
  elif [ -f "$FULL_PATH" ]; then
    echo "\`\`\`[$path]"
    cat "$FULL_PATH"
    echo "\`\`\`"
    echo

  else
    echo "⚠️ ファイルまたはディレクトリが存在しません: $path" >&2
  fi
done < "$LIST_FILE"