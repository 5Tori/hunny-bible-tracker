# Plan cover images

Web-optimized covers for the public `/plans` list (offline mock and local previews).

| File | Source | Plan `template_key` |
| --- | --- | --- |
| `bible.webp` | `bible.png` | `bible_in_a_year` |
| `ot.webp` | `ot.png` | `old_testament` |
| `nt.webp` | `nt.png` | `new_testament` |

Specs: WebP, quality 82, **4:5** crop (center), output **512×640**.

Regenerate (place `bible.png`, `ot.png`, `nt.png` in `apps/web/public/` or set `SRC`):

```bash
SRC=apps/web/public  # or path to masters
OUT=apps/web/public/plans/covers
TMP=$(mktemp -d)
for name in bible ot nt; do
  sips -c 1358 1086 "$SRC/${name}.png" --out "$TMP/${name}.png"
  cwebp -q 82 -resize 512 640 "$TMP/${name}.png" -o "$OUT/${name}.webp"
done
rm -rf "$TMP"
```

Keep source art outside `public/` if you need full-resolution masters; only commit the `.webp` files here.
