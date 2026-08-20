<?php
/**
 * Wrapper for Adminer login-ssl plugin. It provides an environment-based
 * configuration for the plugin.
 */

require_once 'plugins/login-ssl.php';

$config = getenv('ADMINER_SSL_CONFIG');
if (empty($config)) {
  return new stdClass();  
}

$decoded = json_decode($config, true);
if ($decoded === null && json_last_error() !== JSON_ERROR_NONE) {
  throw new \InvalidArgumentException('Environment variable ADMINER_SSL_CONFIG must be valid JSON: ' . json_last_error_msg());
}

return new AdminerLoginSsl($decoded);