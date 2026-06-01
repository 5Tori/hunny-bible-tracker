# Message composite images

Pre-rendered message cards (background + verse text baked in).

- Path: `/messages/composites/{slug}.webp`
- Add one file per message when ready; until then the app uses the base `cover_image_url`.

Example seed:

```ts
compositeImageUrl: '/messages/composites/john-1-1-3.webp',
compositeImagePublicId: 'messages/composites/john-1-1-3',
```
