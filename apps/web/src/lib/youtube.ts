export function getYoutubeVideoId(url: string | null | undefined): string | null {
  if (!url?.trim()) return null;

  try {
    const parsed = new URL(url.trim());
    const host = parsed.hostname.replace(/^www\./, "").toLowerCase();

    if (host === "youtu.be") {
      return parsed.pathname.split("/").filter(Boolean)[0] ?? null;
    }

    if (host.includes("youtube.com") || host.includes("youtube-nocookie.com")) {
      const fromQuery = parsed.searchParams.get("v");
      if (fromQuery) return fromQuery;

      const segments = parsed.pathname.split("/").filter(Boolean);
      const embedIndex = segments.indexOf("embed");
      if (embedIndex >= 0 && segments[embedIndex + 1]) {
        return segments[embedIndex + 1];
      }

      const shortsIndex = segments.indexOf("shorts");
      if (shortsIndex >= 0 && segments[shortsIndex + 1]) {
        return segments[shortsIndex + 1];
      }
    }
  } catch {
    return null;
  }

  return null;
}
