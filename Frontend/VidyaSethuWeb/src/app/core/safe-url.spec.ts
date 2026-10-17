import { isAllowedHost, safeExternalLink } from './safe-url';

const production = {
  allowedLinkHosts: ['vidyasethu.co.in', '*.vidyasethu.co.in'],
  allowLocalhostLinks: false,
};
const development = { ...production, allowLocalhostLinks: true };

describe('safeExternalLink', () => {
  it('accepts https links on allowed hosts', () => {
    expect(safeExternalLink('https://pvs.vidyasethu.co.in/', production)).toEqual({
      href: 'https://pvs.vidyasethu.co.in/',
      development: false,
    });
    expect(safeExternalLink('https://vidyasethu.co.in/x', production)?.href).toBe(
      'https://vidyasethu.co.in/x',
    );
  });

  it.each([
    ['empty', ''],
    ['null', null],
    ['not a URL', 'pvs.vidyasethu.co.in'],
    ['plain http', 'http://pvs.vidyasethu.co.in/'],
    ['javascript scheme', 'javascript:alert(1)'],
    ['data scheme', 'data:text/html,<script>alert(1)</script>'],
    ['other host', 'https://evil.example/'],
    ['look-alike host', 'https://vidyasethu.co.in.evil.example/'],
    ['suffix trick', 'https://evilvidyasethu.co.in/'],
    ['credentials', 'https://user:pass@pvs.vidyasethu.co.in/'],
    ['localhost in production', 'http://localhost:8080/'],
    ['https localhost in production', 'https://localhost/'],
  ])('rejects %s', (_label, value) => {
    expect(safeExternalLink(value, production)).toBeNull();
  });

  it('accepts localhost only when the policy allows it, and marks it as a development link', () => {
    expect(safeExternalLink('http://localhost:8080/', development)).toEqual({
      href: 'http://localhost:8080/',
      development: true,
    });
    expect(safeExternalLink('http://127.0.0.1:8080/', development)?.development).toBe(true);
    expect(safeExternalLink('ftp://localhost/', development)).toBeNull();
  });
});

describe('isAllowedHost', () => {
  it('matches exact hosts and subdomain wildcards, but not the bare domain for a wildcard', () => {
    expect(isAllowedHost('a.example.org', ['*.example.org'])).toBe(true);
    expect(isAllowedHost('example.org', ['*.example.org'])).toBe(false);
    expect(isAllowedHost('example.org', ['example.org'])).toBe(true);
  });
});
