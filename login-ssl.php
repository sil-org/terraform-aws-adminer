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

return new AdminerLoginSsl(json_decode($config, true));