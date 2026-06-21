class Constants {
  static const String EMPTY = "";
  static const int ZERO = 0;

  static const int USER_ROLE_ADMIN = 0;
  static const int USER_ROLE_PARTNER = 1;
  static const int USER_ROLE_CLIENT = 2;

  static const int UNAUTHORIZED_CODE = 401;
  static const int UNPROCESSABLE_ENTITY_CODE = 422;
  static const int INTERNAL_SERVER_ERROR_CODE = 500;
  static const int CONNECTION_ERROR = 100;
  static const int TIMEOUT_ERROR = 101;
  static const int BAD_CERTIFICATE = -4;
  static const int REQUEST_CANCELLED = -2;
  static const int UNKNOWN_ERROR = -3;
  static const int LOCAL_ERROR = -1;

  static const String SECURE_STORAGE_TOKEN_ID_KEY = "token_id";
  static const String SECURE_STORAGE_ACCESS_TOKEN_KEY = "access_token";
  static const String SECURE_STORAGE_REFRESH_TOKEN_KEY = "refresh_token";
  static const String SECURE_STORAGE_REMEMBER_ME_KEY = "remember_me";
  static const String SECURE_STORAGE_USER_KEY = "user";

  static const String PREFS_ENV_CONFIG_URLS_KEY = "environment_config_urls";
  static const String PREFS_ENV_CONFIG_DEV_ENV_KEY = "dev_env";
  static const String PREFS_ENV_CONFIG_CLIENT_TEST_ENV_KEY = "cient_test_env";
  static const String PREFS_ENV_CONFIG_ENABLE_HTTP_TRAFFIC_LOG_KEY = "enable_http_traffic_log";
  static const String PREFS_ENV_CONFIG_ENABLE_APP_CENTER_KEY = "enable_app_center_key";
  static const String PREFS_ENV_CONFIG_TEST_TOKEN_KEY = "test_token";
  static const String PREFS_ENV_CONFIG_VALID_TOKEN_KEY = "valid_token";
  static const String PREFS_ENV_CONFIG_EXPIRED_TOKEN_KEY = "expired_token";
  static const String PREFS_IS_GET_STARTED_COMPLETED = "is_get_started_completed";
  static const String PREFS_NOTIFICATIONS_ENABLED_KEY = "push_notifications";
  static const String PREFS_USER_ROLE = "user_role";
  static const String PREFS_GET_STARTED = "get_started";

  static const String ARG_LOGIN_SCREEN_ERROR = "error";
}