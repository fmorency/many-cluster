#!/usr/bin/env bash

file="$1"
section="$2"
key="$3"
value="$4"
temp_file="$(mktemp)"

if [[ "$section" = '' ]]; then
csplit -s -f "${temp_file}_" "${file}" "/^\[/"

(
  sed "s/^${key}.*$/${key} = ${value}/" "${temp_file}_00"
  rm "${temp_file}_00"
  cat "${temp_file}_"*
) > "$file"
elif grep -E "^\\[${section}]\$" "$file" > /dev/null; then
cp "$file" "$temp_file"
csplit -s -f "${temp_file}_" "${file}" "/\[${section}\]/"

(
  cat "${temp_file}_00"
  sed "s/^${key} .*$/${key} = ${value}/" "${temp_file}_01"
) > "$file"
else
(
  echo
  echo "[${section}]"
  echo "${key} = ${value}"
) >> "$file"
fi
