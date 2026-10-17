/** Rules an external link must satisfy before the site renders it. */
export interface LinkPolicy {
  allowedLinkHosts: readonly string[];
  allowLocalhostLinks: boolean;
}

export interface SafeLink {
  href: string;
  /** true for a localhost link (development only) - the UI labels it. */
  development: boolean;
}

const LOCAL_HOSTS = new Set(['localhost', '127.0.0.1', '[::1]']);

/**
 * Returns the normalised link if `value` is an absolute https URL on an allowed host (or, when the policy allows it,
 * an http(s) localhost URL), otherwise null. Rejects other schemes (javascript:, data:, ...), embedded credentials
 * and anything that does not parse. Links are only ever rendered as anchors - the site never redirects automatically.
 */
export function safeExternalLink(
  value: string | null | undefined,
  policy: LinkPolicy,
): SafeLink | null {
  if (!value) return null;

  let url: URL;
  try {
    url = new URL(value.trim());
  } catch {
    return null;
  }
  if (url.username || url.password) return null;

  const host = url.hostname.toLowerCase();
  if (LOCAL_HOSTS.has(host)) {
    return policy.allowLocalhostLinks && (url.protocol === 'http:' || url.protocol === 'https:')
      ? { href: url.href, development: true }
      : null;
  }

  if (url.protocol !== 'https:') return null;
  return isAllowedHost(host, policy.allowedLinkHosts)
    ? { href: url.href, development: false }
    : null;
}

export function isAllowedHost(host: string, allowed: readonly string[]): boolean {
  return allowed.some((rule) => {
    const pattern = rule.toLowerCase();
    if (pattern.startsWith('*.')) {
      const domain = pattern.slice(2);
      return host.endsWith(`.${domain}`) && host.length > domain.length + 1;
    }
    return host === pattern;
  });
}
