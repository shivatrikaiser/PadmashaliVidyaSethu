import { enquiry } from './enquiry';
import { legal } from './legal';
import { pages } from './pages';
import { site } from './site';

/** English - the source catalog. Other locales must provide the same shape (type Messages). */
export const en = { ...site, ...pages, enquiry, legal };
