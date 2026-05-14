import { NextResponse } from 'next/server';

import { AdminAuthError, requireAdminUser } from '@/lib/admin/auth';
import {
  deleteAdminPlan,
  getAdminPlanById,
  patchAdminPlanCatalog,
  PlanValidationError,
  updateAdminPlan,
} from '@/lib/plans';

export async function GET(req: Request, context: { params: Promise<{ id: string }> }) {
  try {
    await requireAdminUser(req);
    const { id } = await context.params;
    const plan = await getAdminPlanById(id);

    if (!plan) {
      return NextResponse.json({ error: 'not_found' }, { status: 404 });
    }

    return NextResponse.json({ plan });
  } catch (error) {
    if (error instanceof AdminAuthError) {
      return NextResponse.json({ error: error.code, message: error.message }, { status: error.status });
    }
    return NextResponse.json({ error: 'server_error' }, { status: 500 });
  }
}

export async function PUT(req: Request, context: { params: Promise<{ id: string }> }) {
  try {
    await requireAdminUser(req);
    const { id } = await context.params;
    const body = await req.json();
    const updatedPlan = await updateAdminPlan(id, body);

    if (!updatedPlan) {
      return NextResponse.json({ error: 'not_found' }, { status: 404 });
    }

    return NextResponse.json({ plan: updatedPlan });
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

export async function PATCH(req: Request, context: { params: Promise<{ id: string }> }) {
  try {
    await requireAdminUser(req);
    const { id } = await context.params;
    const body = (await req.json()) as { is_published?: boolean; is_archived?: boolean };
    const updated = await patchAdminPlanCatalog(id, body);

    if (!updated) {
      return NextResponse.json({ error: 'not_found' }, { status: 404 });
    }

    return NextResponse.json({ plan: updated });
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

export async function DELETE(req: Request, context: { params: Promise<{ id: string }> }) {
  try {
    await requireAdminUser(req);
    const { id } = await context.params;
    const ok = await deleteAdminPlan(id);

    if (!ok) {
      return NextResponse.json({ error: 'not_found' }, { status: 404 });
    }

    return NextResponse.json({ ok: true });
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
