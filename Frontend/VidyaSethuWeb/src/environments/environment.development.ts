import type { SiteConfig } from '../app/core/site-config';
import { shared } from './shared';

/**
 * `ng serve` / `npm run build:dev`. Never used for a deployed site. Same as production (shared.ts) except the data
 * sources below.
 */
export const environment: SiteConfig = {
  ...shared,
  environmentName: 'development',
  siteUrl: 'http://localhost:4300',
  allowLocalhostLinks: true,

  // Development fallback: the PVS Flutter app run as a web app on this PC -
  //   cd Frontend/padmashali_vidya_setu
  //   flutter run -d chrome --web-port 8080 --dart-define-from-file=config/development.json
  // The organization page marks it as a development link.
  organizationLinks: {
    pvs: { application: 'http://localhost:8080/' },
  },

  // The API run on this PC (dotnet run) - enquiries are acknowledged but not emailed in Development.
  enquiryEndpoint: 'http://localhost:5274/api/v1/enquiries',
};
