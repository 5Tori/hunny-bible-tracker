import { runWithDbTiming, getDbTimingSnapshot } from '@/lib/perf/db-timing';

export type ApiPerfLog = {
  type: 'api_perf';
  route: string;
  method: string;
  status: number;
  totalMs: number;
  dbMs: number;
  dbQueryCount: number;
  handlerMs: number;
  responseBytes: number | null;
  slowestDbQueryMs: number | null;
  slowestDbQuery: string | null;
  error?: string;
};

export function isApiPerfLogEnabled(): boolean {
  if (process.env.API_PERF_LOG === '0') return false;
  if (process.env.API_PERF_LOG === '1') return true;
  return process.env.NODE_ENV === 'development';
}

function roundMs(value: number): number {
  return Math.round(value * 10) / 10;
}

function buildPerfLog(input: {
  route: string;
  method: string;
  status: number;
  totalMs: number;
  responseBytes: number | null;
  error?: string;
}): ApiPerfLog {
  const db = getDbTimingSnapshot();
  const slowest = db.queries.reduce<DbQueryStatLike | null>((current, query) => {
    if (!current || query.durationMs > current.durationMs) return query;
    return current;
  }, null);

  return {
    type: 'api_perf',
    route: input.route,
    method: input.method,
    status: input.status,
    totalMs: roundMs(input.totalMs),
    dbMs: roundMs(db.totalMs),
    dbQueryCount: db.queries.length,
    handlerMs: roundMs(Math.max(0, input.totalMs - db.totalMs)),
    responseBytes: input.responseBytes,
    slowestDbQueryMs: slowest ? roundMs(slowest.durationMs) : null,
    slowestDbQuery: slowest?.sqlPreview ?? null,
    ...(input.error ? { error: input.error } : {}),
  };
}

type DbQueryStatLike = {
  durationMs: number;
  sqlPreview: string;
};

async function measureResponse(response: Response): Promise<{
  response: Response;
  responseBytes: number | null;
}> {
  const contentType = response.headers.get('content-type') ?? '';
  if (!contentType.includes('json') && !contentType.includes('text')) {
    return { response, responseBytes: null };
  }

  const bodyText = await response.text();
  return {
    response: new Response(bodyText, {
      status: response.status,
      statusText: response.statusText,
      headers: response.headers,
    }),
    responseBytes: new TextEncoder().encode(bodyText).byteLength,
  };
}

function logPerf(entry: ApiPerfLog) {
  console.info(JSON.stringify(entry));
}

export function withApiTiming<T extends unknown[]>(
  route: string,
  handler: (...args: T) => Promise<Response>,
) {
  return async (...args: T): Promise<Response> => {
    if (!isApiPerfLogEnabled()) {
      return handler(...args);
    }

    const method =
      args[0] instanceof Request ? args[0].method : 'GET';
    const routeStarted = performance.now();

    return runWithDbTiming(async () => {
      try {
        const response = await handler(...args);
        const measured = await measureResponse(response);
        const totalMs = performance.now() - routeStarted;
        logPerf(
          buildPerfLog({
            route,
            method,
            status: measured.response.status,
            totalMs,
            responseBytes: measured.responseBytes,
          }),
        );
        return measured.response;
      } catch (error) {
        const totalMs = performance.now() - routeStarted;
        logPerf(
          buildPerfLog({
            route,
            method,
            status: 500,
            totalMs,
            responseBytes: null,
            error: error instanceof Error ? error.message : 'unknown_error',
          }),
        );
        throw error;
      }
    });
  };
}
