import { jsonWithPublicCache } from '@/lib/http/public-cache';
import { getMessageTaxonomy } from '@/lib/messages';
import { withApiTiming } from '@/lib/perf/api-timing';

export const GET = withApiTiming('GET /api/v1/message-taxonomy', async () => {
  return jsonWithPublicCache(getMessageTaxonomy());
});
