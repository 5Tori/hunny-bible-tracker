import { NextResponse } from 'next/server';

import { AdminAuthError, requireAdminUser } from '@/lib/admin/auth';
import { createAdminPlan, getAdminPlans, PlanValidationError } from '@/lib/plans';

export async function GET(req: Request) {
  try {
    await requireAdminUser(req);
    const plans = await getAdminPlans();
    return NextResponse.json({ plans });
  } catch (error) {
    if (error instanceof AdminAuthError) {
      return NextResponse.json({ error: error.code, message: error.message }, { status: error.status });
    }
    if (process.env.NODE_ENV !== 'production') {
      console.error('Admin plans GET error:', error);
    }
    return NextResponse.json({ error: 'server_error' }, { status: 500 });
  }
}

export async function POST(req: Request) {
  try {
    await requireAdminUser(req);
    const body = await req.json();
    const plan = await createAdminPlan(body);
    return NextResponse.json({ plan }, { status: 201 });
  } catch (error) {
    if (error instanceof AdminAuthError) {
      return NextResponse.json({ error: error.code, message: error.message }, { status: error.status });
    }
    if (error instanceof PlanValidationError) {
      return NextResponse.json({ error: 'validation_error', message: error.message }, { status: 400 });
    }
    return NextResponse.json({ error: 'bad_request' }, { status: 400 });
  }
}
