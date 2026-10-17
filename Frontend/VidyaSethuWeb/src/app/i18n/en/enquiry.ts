/** Enquiry / contact form. */
export const enquiry = {
  categoryLabel: 'What is your enquiry about?',
  categories: {
    organization: 'Bringing my organization to VidyaSethu / demo',
    general: 'General question',
    partnership: 'Partnership',
    feedback: 'Feedback about this website',
    privacy: 'Privacy or personal data request',
  },
  nameLabel: 'Your name',
  organizationLabel: 'Organization name (optional)',
  emailLabel: 'Email',
  phoneLabel: 'Phone',
  contactHint: 'Give an email address, a phone number, or both.',
  messageLabel: 'Message',
  consentLabel:
    'I agree that VidyaSethu may use these details to reply to my enquiry, as described in the',
  privacyLink: 'Privacy notice',
  privacyNote:
    'We use the details you send only to reply to your enquiry. Please do not include student records, documents, ' +
    'Aadhaar numbers or other sensitive personal information.',
  honeypotLabel: 'Leave this field empty',
  submit: 'Send enquiry',
  sending: 'Sending…',
  errors: {
    required: 'This field is required.',
    name: 'Please enter your name (2 to 100 characters).',
    email: 'Please enter a valid email address.',
    phone: 'Please enter a valid phone number (digits, spaces, + and - only).',
    emailOrPhone: 'Please give an email address or a phone number.',
    message: (min: number, max: number) => `Please write between ${min} and ${max} characters.`,
    consent: 'Please confirm that we may use your details to reply.',
    summary: 'Please correct the highlighted fields.',
  },
  status: {
    notEnabledTitle: 'Online enquiries are not open yet',
    notEnabled:
      'This form cannot send messages yet, so nothing you type here will be sent. Online enquiries will be ' +
      'switched on before VidyaSethu goes live.',
    notEnabledEmail: (email: string) => `In the meantime, please email us at ${email}.`,
    success:
      'Thank you - your enquiry has been sent. We will reply using the contact details you gave.',
    error: 'Your enquiry could not be sent. Please check your connection and try again later.',
    tooFast: 'Please take a moment to check your details, then send again.',
  },
};
