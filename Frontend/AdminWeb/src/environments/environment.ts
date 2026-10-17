/**
 * Production build, served at https://pvs.vidyasethu.co.in. The API has its own host, so it must list
 * https://pvs.vidyasethu.co.in in Cors:AllowedOrigins. If the API host changes, also update the CSP in
 * public/staticwebapp.config.json and public/web.config.
 */
export const environment = {
  production: true,
  apiBaseUrl: 'https://api.pvs.vidyasethu.co.in',
};
