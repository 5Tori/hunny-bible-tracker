import Link from "next/link";

const filters = [
  { key: "all", label: "All" },
  { key: "video", label: "Videos" },
  { key: "essay", label: "Articles" },
  { key: "cartoon", label: "Cartoons" },
] as const;

export type DiscoverTypeFilter = (typeof filters)[number]["key"];

export function DiscoverFilters({ active }: { active: DiscoverTypeFilter }) {
  return (
    <div className="flex flex-wrap gap-2">
      {filters.map((filter) => {
        const href = filter.key === "all" ? "/discover" : `/discover?type=${filter.key}`;
        const isActive = active === filter.key;

        return (
          <Link
            key={filter.key}
            href={href}
            className={`rounded-full border px-3.5 py-1.5 text-sm font-medium transition ${
              isActive
                ? "border-neutral-900 bg-neutral-900 text-white"
                : "border-neutral-200 bg-white text-neutral-600 hover:border-neutral-300 hover:text-neutral-900"
            }`}
          >
            {filter.label}
          </Link>
        );
      })}
    </div>
  );
}

export function parseDiscoverType(
  value: string | string[] | undefined,
): DiscoverTypeFilter {
  const raw = Array.isArray(value) ? value[0] : value;
  if (raw === "video" || raw === "essay" || raw === "cartoon") {
    return raw;
  }
  return "all";
}
