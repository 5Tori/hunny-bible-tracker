import type { MetadataRoute } from "next";
import { siteConfig } from "@/lib/site-config";

export default function sitemap(): MetadataRoute.Sitemap {
  const lastModified = new Date();
  const routes = [
    { path: "", priority: 1 },
    { path: "/today", priority: 0.9 },
    { path: "/discover", priority: 0.9 },
    { path: "/privacy", priority: 0.6 },
    { path: "/support", priority: 0.6 },
    { path: "/terms", priority: 0.6 },
  ];

  return routes.map((route) => ({
    url: `${siteConfig.url}${route.path}`,
    lastModified,
    changeFrequency: "monthly",
    priority: route.priority,
  }));
}
