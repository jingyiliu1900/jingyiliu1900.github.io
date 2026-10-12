#!/usr/bin/env bash
# Copies every image, video and PDF the site still loads from jingyiliu.net
# into media/ and rewrites the HTML to use the local copies.
# Files that can't be downloaded are skipped and keep their old link.
# Safe to re-run: files already in media/ are not downloaded again.
set -uo pipefail
cd "$(dirname "$0")"

PREFIX="https://jingyiliu.net/wp-content/uploads/"
urls=$(grep -ohE "${PREFIX}[^\"' )<]+" ./*.html | sort -u)
failed=()

for url in $urls; do
  rel="${url#$PREFIX}"              # e.g. 2024/10/wave.mov
  dest="media/$rel"
  mkdir -p "$(dirname "$dest")"
  if [ ! -s "$dest" ]; then
    echo "Downloading $rel"
    if ! curl -fsSL "$url" -o "$dest.part"; then
      rm -f "$dest.part"
      failed+=("$rel")
      continue
    fi
    mv "$dest.part" "$dest"
  fi
  size=$(wc -c < "$dest" | tr -d ' ')
  if [ "$size" -gt 100000000 ]; then
    echo "WARNING: $dest is over 100 MB; GitHub will reject it. Compress it or host it elsewhere." >&2
  fi
  # Point the pages at the local copy (works with GNU and BSD sed).
  for f in ./*.html; do
    sed -i.bak "s#${url}#${dest}#g" "$f" && rm -f "$f.bak"
  done
done

# Remove empty folders left by failed downloads.
find media -type d -empty -delete 2>/dev/null

echo
if [ ${#failed[@]} -gt 0 ]; then
  echo "Could not download (links left unchanged):"
  printf '  %s\n' "${failed[@]}"
else
  echo "All media downloaded."
fi
