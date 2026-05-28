type FilterTab<T extends string> = { id: T; label: string };

type FilterTabsProps<T extends string> = {
  tabs: readonly FilterTab<T>[];
  value: T;
  onChange: (id: T) => void;
  ariaLabel: string;
};

export function FilterTabs<T extends string>({ tabs, value, onChange, ariaLabel }: FilterTabsProps<T>) {
  return (
    <div className="admin-filter-tabs" role="tablist" aria-label={ariaLabel}>
      {tabs.map((tab) => (
        <button
          key={tab.id}
          type="button"
          role="tab"
          aria-selected={value === tab.id}
          className={value === tab.id ? 'admin-filter-tab admin-filter-tab-active' : 'admin-filter-tab'}
          onClick={() => onChange(tab.id)}
        >
          {tab.label}
        </button>
      ))}
    </div>
  );
}
