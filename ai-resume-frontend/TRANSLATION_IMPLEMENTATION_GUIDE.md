# Translation Implementation Guide

## ✅ Completed
1. **Translation Keys Added** - All 3 language files (en, hi, or) now have comprehensive login keys
2. **Imports Added** - Login screen now imports AppLocalizations and LanguageSelectorWidget

## 🔧 Manual Updates Required

### Login Screen (`lib/screens/auth/login_screen.dart`)

The login screen needs the following updates in the `build` method:

#### 1. Add localization variable at start of build method (line ~313):
```dart
@override
Widget build(BuildContext context) {
  final loc = AppLocalizations.of(context);
  
  return Scaffold(
```

#### 2. Update Welcome Title with Language Selector (line ~358):
Replace:
```dart
const Text(
  'Welcome\nBack!',
  style: TextStyle(...),
),
```

With:
```dart
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Expanded(
      child: Text(
        loc?.translate('login_title') ?? 'Welcome\nBack!',
        style: const TextStyle(...),
      ),
    ),
    const LanguageSelectorWidget(),
  ],
),
```

#### 3. Update Subtitle (line ~370):
```dart
Text(
  loc?.translate('login_subtitle') ?? 'Sign in to continue your journey',
  style: TextStyle(...),
),
```

#### 4. Update "Choose your role" (line ~389):
```dart
Text(
  loc?.translate('login_choose_role') ?? 'Choose your role',
  style: TextStyle(...),
),
```

#### 5. Update Role Buttons (line ~399-412):
```dart
_buildAnimatedRoleButton(
  icon: Icons.person_outline_rounded,
  label: loc?.translate('login_user') ?? 'User',
  isSelected: _selectedRole == 'User',
  onTap: () => setState(() => _selectedRole = 'User'),
),
const SizedBox(width: 16),
_buildAnimatedRoleButton(
  icon: Icons.business_rounded,
  label: loc?.translate('login_organization') ?? 'Organization',
  isSelected: _selectedRole == 'Organization',
  onTap: () => setState(() => _selectedRole = 'Organization'),
),
```

#### 6. Update Phone Field (line ~448):
```dart
TextFormField(
  controller: _phoneController,
  decoration: InputDecoration(
    labelText: loc?.translate('login_phone') ?? 'Phone number',
    prefixIcon: Icon(Icons.phone_outlined),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
  ),
  keyboardType: TextInputType.phone,
  validator: (value) {
    if (_selectedRole == 'User' && (value == null || value.trim().length < 10)) {
      return loc?.translate('login_phone_error') ?? 'Please enter a valid 10-digit number';
    }
    return null;
  },
),
```

#### 7. Update Email Field (line ~473):
```dart
TextFormField(
  controller: _emailController,
  decoration: InputDecoration(
    labelText: loc?.translate('login_email') ?? "Organization's Email",
    prefixIcon: Icon(Icons.email_outlined),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
  ),
  keyboardType: TextInputType.emailAddress,
  validator: (value) {
    if (_selectedRole == 'Organization') {
      if (value == null || value.trim().isEmpty)
        return loc?.translate('login_email_required') ?? 'Please enter email';
      if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value))
        return loc?.translate('login_email_invalid') ?? 'Enter valid email';
    }
    return null;
  },
),
```

#### 8. Update Password Field (line ~497):
```dart
TextFormField(
  controller: _passwordController,
  decoration: InputDecoration(
    labelText: loc?.translate('login_password') ?? 'Password',
    prefixIcon: Icon(Icons.lock_outline_rounded),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
  ),
  obscureText: true,
  validator: (value) {
    if (value == null || value.trim().length < 6) {
      return loc?.translate('login_password_error') ?? 'Password must be at least 6 characters';
    }
    return null;
  },
),
```

#### 9. Update Forgot Password (line ~528):
```dart
child: Text(
  loc?.translate('login_forgot_password') ?? 'Forgot password?',
  style: TextStyle(
    color: _currentPrimaryColor,
    fontWeight: FontWeight.w600,
  ),
),
```

#### 10. Update Guest Account Button (line ~550):
```dart
child: Text(
  loc?.translate('login_guest_account') ?? 'Create Guest Account?',
  style: TextStyle(
    color: _currentPrimaryColor,
    fontWeight: FontWeight.bold,
    fontSize: 16,
    decoration: TextDecoration.underline,
  ),
),
```

#### 11. Update LOGIN Button (line ~598):
```dart
: Text(
    (loc?.translate('login_button') ?? 'LOGIN').toUpperCase(),
    style: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.white,
      letterSpacing: 1,
    ),
  ),
```

#### 12. Update "Don't have an account?" (line ~614):
```dart
Text(
  loc?.translate('login_no_account') ?? "Don't have an account? ",
  style: TextStyle(
    color: Colors.grey.shade600,
    fontSize: 15,
  ),
),
```

#### 13. Update Register Button (line ~646):
```dart
child: Text(
  loc?.translate('login_register') ?? 'Register',
  style: TextStyle(
    fontWeight: FontWeight.bold,
    color: _currentPrimaryColor,
    fontSize: 15,
  ),
),
```

## 📝 Registration Screens

Similar updates needed for:
- `lib/screens/auth/registration_screen.dart` (User registration)
- `lib/screens/auth/org_registration_screen.dart` (Organization registration)
- `lib/screens/auth/forgot_password_screen.dart`

## 🎯 Profile Edit Screens

Add language selector to:
- `lib/profile/edit_profile_screen.dart` (User)
- `lib/profile/org_edit_profile_screen.dart` (Organization)

Add to AppBar:
```dart
appBar: AppBar(
  title: Text(loc?.translate('edit_profile_title') ?? 'Edit Profile'),
  actions: const [
    LanguageSelectorWidget(),
    SizedBox(width: 8),
  ],
),
```

## 🚀 Quick Implementation

Run this command to see all files that need translation updates:
```bash
grep -r "const Text(" lib/screens/auth/ lib/profile/ --include="*.dart"
```

All hardcoded English text should be replaced with:
```dart
loc?.translate('key_name') ?? 'Fallback Text'
```
