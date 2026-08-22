<?php
/**
 * Logs the client IP address(es) and username for every successful Adminer
 * login. Logs both the IP the ALB saw directly and the Cloudflare-claimed
 * visitor IP (if any) rather than picking one, since telling them apart
 * requires knowing whether the request actually came through Cloudflare -
 * that's left to query time against Cloudflare's published IP ranges.
 *
 * The login() hook only runs once Adminer has already authenticated
 * successfully against the database, so this only fires on a real login, not
 * every page/form load. It always returns null so it never overrides the
 * actual authentication decision made by other plugins (e.g. login-otp,
 * login-ssl) or Adminer's own default handling.
 */
class AdminerLoginLog extends Adminer\Plugin {
  function login($login, $password) {
    // Whoever connects to the ALB directly gets appended as the last entry in
    // X-Forwarded-For; earlier entries can be forged by the client. If traffic
    // is routed through Cloudflare, this will be a Cloudflare edge IP, not the
    // real visitor.
    $forwarded_for = preg_replace('~.*, *~', '', strval($_SERVER["HTTP_X_FORWARDED_FOR"]));
    $alb_seen_ip = $forwarded_for !== "" ? $forwarded_for : strval($_SERVER["REMOTE_ADDR"]);

    // Cloudflare sets these from the actual TCP connection/edge metadata, so
    // a client can't spoof them directly - but they're only trustworthy if
    // alb_seen_ip is confirmed to be one of Cloudflare's published IP ranges
    // (https://www.cloudflare.com/ips/), since otherwise the ALB was reached
    // directly and these headers could have been set by the client itself.
    $cf_connecting_ip = strval($_SERVER["HTTP_CF_CONNECTING_IP"]);
    $cf_connecting_ipv6 = strval($_SERVER["HTTP_CF_CONNECTING_IPV6"]);
    $cf_ray = strval($_SERVER["HTTP_CF_RAY"]);
    $cf_ip_country = strval($_SERVER["HTTP_CF_IPCOUNTRY"]);

    error_log(json_encode([
      "event" => "adminer_login",
      "username" => $login,
      "alb_seen_ip" => $alb_seen_ip,
      "cf_connecting_ip" => $cf_connecting_ip,
      "cf_connecting_ipv6" => $cf_connecting_ipv6,
      "cf_ray" => $cf_ray,
      "cf_ip_country" => $cf_ip_country,
      "user_agent" => strval($_SERVER["HTTP_USER_AGENT"]),
    ]));

    return null;
  }
}

if (!getenv('ADMINER_LOGIN_LOG_ENABLED')) {
  return new stdClass();
}

return new AdminerLoginLog();
