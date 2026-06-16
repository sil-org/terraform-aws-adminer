<?php
require_once 'plugins/login-otp.php';

$secret = getenv('ADMINER_OTP_SECRET');
if (empty($secret)) {
  throw new \Exception('Environment variable ADMINER_OTP_SECRET is not set');
}

return new AdminerLoginOtp(base64_decode($secret));
