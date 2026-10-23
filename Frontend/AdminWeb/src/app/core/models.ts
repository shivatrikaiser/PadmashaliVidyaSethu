/** Shapes returned by the admin API (Backend/.../DTOs/AdminDtos.cs). */

export interface PagedResult<T> {
  items: T[];
  totalCount: number;
  page: number;
  pageSize: number;
}

export interface CountItem {
  label: string;
  count: number;
}

export interface LookupItem {
  id: number;
  name: string;
  code: string;
}

export interface MemberFilters {
  search?: string;
  templeId?: number | null;
  memberStatusId?: number | null;
  classId?: number | null;
  districtId?: number | null;
  ageFrom?: number | null;
  ageTo?: number | null;
  isActive?: boolean | null;
  page?: number;
  pageSize?: number;
}

export interface MemberRow {
  registrationId: string;
  fullName: string;
  age: number;
  gender: string;
  temple: string;
  memberStatus: string;
  classOrEducation: string | null;
  district: string | null;
  taluk: string | null;
  mobileNumber: string;
  isActive: boolean;
  registrationCompletedDate: string;
}

export interface LookupRef {
  id: number;
  name: string;
}

export interface Address {
  addressType: string;
  addressLine1: string;
  addressLine2: string | null;
  /** PIN code in India; outside India the postal code, if any. */
  pinCode: string | null;
  cityVillageName: string;
  /** Null for an address outside India (also district). */
  taluk: LookupRef | null;
  district: LookupRef | null;
  state: LookupRef;
  country: LookupRef;
}

export interface MemberProfile {
  registrationId: string;
  fullName: string;
  fatherName: string;
  motherName: string;
  dateOfBirth: string;
  age: number;
  gender: LookupRef;
  temple: LookupRef;
  memberStatus: LookupRef;
  memberStatusCode: string;
  class: LookupRef | null;
  highestEducationLevel: LookupRef | null;
  organisation: LookupRef;
  currentAddressSameAsPermanent: boolean;
  addresses: Address[];
  isDisabled: boolean;
  disabilityTypes: LookupRef[];
  registrationCompletedDate: string;
  /** The member's own verified mobile number, if one was added at registration. */
  mobileNumber: string | null;
  /** Email address given with a mobile number outside India. */
  email: string | null;
}

export interface MemberDetail {
  profile: MemberProfile;
  /** The account (sign-in) number the member is registered under. */
  mobileNumber: string;
  isActive: boolean;
  canSeeSensitiveData: boolean;
  consents: { consentType: string; policyVersion: string; isGranted: boolean; recordedDate: string }[];
}

export interface Summary {
  activeMembers: number;
  inactiveMembers: number;
  accounts: number;
  registeredLast30Days: number;
  byTemple: CountItem[];
  byStatus: CountItem[];
  byGender: CountItem[];
  byOrganisation: CountItem[];
  studentsByStage: CountItem[];
  byAgeGroup: CountItem[];
  byDistrict: CountItem[];
  byMonth: CountItem[];
}

export interface ListType {
  type: string;
  label: string;
}

export interface ListItem {
  id: number;
  name: string;
  code: string;
  displayOrder: number;
  isActive: boolean;
  isProtected: boolean;
}

export interface OtherValue {
  listType: string;
  listLabel: string;
  text: string;
  memberCount: number;
}

export interface AdminUser {
  accountId: number;
  mobileNumber: string;
  roles: string[];
  lastLoginDate: string | null;
  /** A portal password is set (the password itself is never sent back). */
  hasPassword: boolean;
  passwordSetDate: string | null;
}

export interface AppBranding {
  sponsorName: string | null;
  sponsorOrganisation: string | null;
  /** Up to four lines separated by a line feed. */
  sponsorAddress: string | null;
  poweredBy: string | null;
  hasSponsorLogo: boolean;
  sponsorLogoVersion: string | null;
  modifiedDate: string | null;
  /** Opened when "Powered by" is tapped in the app (the IQ Explore app on Google Play). */
  poweredByUrl: string | null;
  /** Active footer sponsors, in display order. */
  footerSponsors: { name: string; designation: string | null; companyName: string | null }[];
}

/** A footer sponsor as the admin portal manages it (active or not). */
export interface FooterSponsor {
  id: number;
  name: string;
  designation: string | null;
  companyName: string | null;
  displayOrder: number;
  isActive: boolean;
  modifiedDate: string | null;
}

export interface FooterSponsorInput {
  name: string;
  designation: string;
  companyName: string;
  displayOrder: number;
  isActive: boolean;
}

/** The editable text of [AppBranding]. */
export interface BrandingText {
  sponsorName: string;
  sponsorOrganisation: string;
  sponsorAddress: string;
  poweredBy: string;
  poweredByUrl: string;
}

export interface LocationItem {
  kind: 'District' | 'Taluk';
  id: number;
  name: string;
  parentId: number;
  parentName: string;
  source: string;
  isActive: boolean;
  addressCount: number;
  createdDate: string;
}
