import '../../../core/supabase/hunny_supabase_client.dart';
import 'plan_catalog_api_client.dart';

class PlanCatalogSupabaseClient {
  PlanCatalogSupabaseClient({
    HunnySupabaseClient? supabaseClient,
  }) : _supabaseClient = supabaseClient ?? HunnySupabaseClient();

  final HunnySupabaseClient _supabaseClient;

  bool get isConfigured => _supabaseClient.isConfigured;

  Future<List<RemotePlanTemplate>> fetchPublishedPlans({
    String sort = 'featured',
  }) async {
    final payload = await _supabaseClient.rpc(
      'mobile_plan_catalog',
      params: {'p_sort': sort},
    );
    if (payload == null) return const [];
    if (payload is! List) {
      throw PlanCatalogFetchFailure('Invalid mobile_plan_catalog response');
    }

    return payload
        .whereType<Map<String, dynamic>>()
        .map(
          (plan) => RemotePlanTemplate.fromJson({
            ...plan,
            'sections': plan['sections'] ?? const [],
            'tags': plan['tags'] ?? const [],
          }),
        )
        .toList();
  }

  Future<RemotePlanTemplate> fetchPublishedPlanByIdentifier(
    String identifier,
  ) async {
    final payload = await _supabaseClient.rpc(
      'mobile_plan_detail',
      params: {'p_identifier': identifier},
    );
    if (payload == null) {
      throw PlanCatalogFetchFailure('This plan is no longer available.');
    }
    if (payload is! Map<String, dynamic>) {
      throw PlanCatalogFetchFailure('Invalid mobile_plan_detail response');
    }
    return RemotePlanTemplate.fromJson(payload);
  }
}
