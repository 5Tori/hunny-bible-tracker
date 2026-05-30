import '../../../core/api/hunny_api_client.dart';
import '../../../core/api/hunny_api_config.dart';
import '../../../core/supabase/hunny_supabase_client.dart';
import '../../../core/supabase/remote_read_mode.dart';
import 'plan_catalog_api_client.dart';
import 'plan_catalog_supabase_client.dart';

class PlanCatalogReadClient {
  PlanCatalogReadClient({
    RemoteReadMode? mode,
    PlanCatalogApiClient? apiClient,
    PlanCatalogSupabaseClient? supabaseClient,
    HunnySupabaseClient? reachabilityClient,
    bool fallbackToApi = true,
  })  : _mode = mode ?? RemoteReadMode.fromEnvironment(),
        _apiClient = apiClient ?? PlanCatalogApiClient(),
        _supabaseClient = supabaseClient ?? PlanCatalogSupabaseClient(),
        _reachabilityClient = reachabilityClient ?? HunnySupabaseClient(),
        _fallbackToApi = fallbackToApi;

  final RemoteReadMode _mode;
  final PlanCatalogApiClient _apiClient;
  final PlanCatalogSupabaseClient _supabaseClient;
  final HunnySupabaseClient _reachabilityClient;
  final bool _fallbackToApi;

  bool get isConfigured =>
      _mode.prefersSupabaseRpc
          ? _supabaseClient.isConfigured
          : _apiClient.isConfigured;

  Future<bool> canReachRemote({bool force = false}) async {
    if (_mode.prefersSupabaseRpc && _supabaseClient.isConfigured) {
      return _reachabilityClient.canReachSupabase(force: force);
    }
    return _apiClient.isConfigured &&
        await HunnyApiReachability(
          config: HunnyApiConfig.fromEnvironment(),
        ).canReachApi(force: force);
  }

  Future<List<RemotePlanTemplate>> fetchPublishedPlans({
    String sort = 'featured',
    String? detail,
    bool forceReachability = false,
  }) async {
    if (_mode.prefersSupabaseRpc && _supabaseClient.isConfigured) {
      if (!await _reachabilityClient.canReachSupabase(force: forceReachability)) {
        throw PlanCatalogFetchFailure(
          'Cannot reach Supabase. Check your connection and try again.',
        );
      }
      try {
        return await _supabaseClient.fetchPublishedPlans(sort: sort);
      } catch (error) {
        if (!_fallbackToApi) rethrow;
        if (error is PlanCatalogFetchFailure) rethrow;
      }
    }

    return _apiClient.fetchPublishedPlans(
      sort: sort,
      detail: detail,
      forceReachability: forceReachability,
    );
  }

  Future<RemotePlanTemplate> fetchPublishedPlanByIdentifier(
    String identifier, {
    bool forceReachability = false,
  }) async {
    if (_mode.prefersSupabaseRpc && _supabaseClient.isConfigured) {
      if (!await _reachabilityClient.canReachSupabase(force: forceReachability)) {
        throw PlanCatalogFetchFailure(
          'Cannot reach Supabase. Check your connection and try again.',
        );
      }
      try {
        return await _supabaseClient.fetchPublishedPlanByIdentifier(identifier);
      } catch (error) {
        if (!_fallbackToApi) rethrow;
        if (error is PlanCatalogFetchFailure) rethrow;
      }
    }

    return _apiClient.fetchPublishedPlanByIdentifier(
      identifier,
      forceReachability: forceReachability,
    );
  }
}
