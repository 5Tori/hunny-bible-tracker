import { MarketingContainer } from "@/components/marketing/ui/MarketingContainer";
import { MarketingSection } from "@/components/marketing/ui/MarketingSection";

export function QuietIdeaSection() {
  return (
    <MarketingSection className="!py-16 md:!py-20">
      <MarketingContainer narrow>
        <p className="mkt-kicker">The quiet idea</p>
        <h2 className="mkt-heading-sm mt-4 max-w-2xl text-balance">
          The Bible can feel big, or hard to know where to begin.{" "}
          <span className="text-neutral-500">
            A single story is a wonderful place to start.
          </span>
        </h2>
        <p className="mkt-lead mt-6 max-w-xl">
          Hunny opens Scripture through short, approachable stories that help you
          read the next chapter, and the one after that.
        </p>
      </MarketingContainer>
    </MarketingSection>
  );
}
