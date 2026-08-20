<?php
/**
 * Wrapper for Adminer login-otp plugin. It provides an environment-based
 * configuration for the plugin.
 */

require_once 'plugins/login-otp.php';

$secret = getenv('ADMINER_OTP_SECRET');
if (empty($secret)) {
  return new stdClass();
}

return new AdminerLoginOtp(base64_decode($secret));
