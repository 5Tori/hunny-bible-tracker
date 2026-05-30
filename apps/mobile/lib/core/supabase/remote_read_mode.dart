enum RemoteReadMode {
  api,
  supabaseRpc;

  static const envKey = 'HUNNY_REMOTE_READ_MODE';

  static RemoteReadMode fromEnvironment() {
    const raw = String.fromEnvironment(envKey, defaultValue: 'api');
    switch (raw.trim().toLowerCase()) {
      case 'supabase_rpc':
      case 'supabase-rpc':
      case 'rpc':
        return RemoteReadMode.supabaseRpc;
      case 'api':
      default:
        return RemoteReadMode.api;
    }
  }

  bool get prefersSupabaseRpc => this == RemoteReadMode.supabaseRpc;
}
