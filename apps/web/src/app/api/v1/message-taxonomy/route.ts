import { NextResponse } from 'next/server';

import { getMessageTaxonomy } from '@/lib/messages';
import { withApiTiming } from '@/lib/perf/api-timing';

export const GET = withApiTiming('GET /api/v1/message-taxonomy', async () => {
  return NextResponse.json(getMessageTaxonomy());
});
