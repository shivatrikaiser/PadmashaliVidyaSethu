# Registration Flow

Screenshots of every step: `Docs/ui/screenshots/` (captured from the automated end-to-end test).

```
Welcome → Mobile Number → Phone Number Verification Code → [account signed in]
   → 1 Personal Details → 2 Current Status → 3 Temple & Organisation → 4 Address → 5 Disability Information
   → Registration Complete (Student ID / Registration ID) → Home (profile completion)
```

The term **"OTP" is never used**; the UI says *Phone Number Verification Code* (4 digits). A unit test fails if
"OTP" appears in any UI string.

## Sign-in
1. **Mobile Number** — 10-digit Indian number (+91 shown as prefix). Note explains a parent may register children.
2. **Phone Number Verification** — four boxes, auto-submits on the 4th digit, supports paste/SMS autofill;
   "Resend Code" after a countdown; "Change Mobile Number". Wrong code shows remaining attempts.
3. New number ⇒ account created. Existing account with members ⇒ Home; without members ⇒ registration.

## Wizard (each step validated before *Next*; server re-validates everything)

| Step | Fields | Rules |
|------|--------|-------|
| 1 Personal Details | Full Name, Father Name, Mother Name, Date of Birth (picker, shows **"Age: N years"**, recalculated on change), Gender (chips) | Letters (any script) / space / `.'-`; age ≥ 5 |
| 2 Current Status | Student / Working / Unemployed (**default Student**); **Class Studying** (Student) *or* **Highest Education** (Working, Unemployed) | Class never shown for Working/Unemployed; switching status clears the irrelevant field |
| 3 Temple & Organisation | Temple (16, from master), "Are you linked to any Padmashali Organisation?" | — |
| 4 Address | Permanent: house/street, area (optional), **PIN** → City/Village options, Country (India), State, District auto-filled, **Taluk dropdown filtered by district** (suggested from PIN), "My taluk is not listed" → free text. ☐ *Current address is same as Permanent Address* — unticked shows a second address form | PIN lookup failure never blocks: State/District can be chosen manually |
| 5 Disability Information | Is Disabled? **No (default)** / Yes → Type of Disability (multi-select) → "Other" → *Please Specify*; Privacy Policy consent; parent/guardian consent (under 18 only) | Types hidden for No; description required for Other |

On submit, server field errors are shown on the matching fields and the wizard jumps to the first step with an error.

## Completion
Shows "Registration Successful!", the **Student ID** (or **Registration ID** for non-students) `PVS-TT-NNNN`,
"Welcome to Padmashali Vidya Setu. Your basic profile has been created." and **Continue to My Profile** → Home.

## Family members
Home → menu or Quick Links → **Add Family Member** runs the same wizard under the same mobile number (max 10).
A member switcher appears in the app bar when an account has several members.
