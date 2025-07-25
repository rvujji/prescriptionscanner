# scanner

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

commands
flutter clean
rm ios/Podfile.lock pubspec.lock
flutter pub get
cd ios
rm -rf Pods
pod install

To create a **secured database in Supabase**, follow these best practices from the start:

---

### ✅ Step 1: Create Your Supabase Project

1. Go to [https://app.supabase.com](https://app.supabase.com)
2. Click **“New Project”**
3. Enter:

   - **Project name**
   - **Database password** (very important — choose a strong password)
   - Select region and organization

4. Click **“Create new project”**

This sets up a **PostgreSQL database** with Supabase.

---

### ✅ Step 2: Secure Access Using Row-Level Security (RLS)

By default, Supabase creates tables with RLS **disabled**, which means **anyone with your service key or anon key can read/write**.

**You must enable RLS to secure your tables.**

#### Enable RLS:

1. Go to **Table Editor** in your project
2. Click on a table you want to secure
3. Go to the **"Auth"** tab or "RLS"
4. Click **“Enable RLS”**
5. Create **Policies** to control who can read/write.

#### Example: Allow users to only access their own rows

```sql
-- Allow users to read their own prescriptions
CREATE POLICY "Users can read their own data"
  ON prescriptions
  FOR SELECT
  USING (user_id = auth.uid());

-- Allow users to insert data only for themselves
CREATE POLICY "Users can insert their own data"
  ON prescriptions
  FOR INSERT
  WITH CHECK (user_id = auth.uid());
```

---

### ✅ Step 3: Use Supabase Auth to Secure Users

- Enable **email/password** or **OAuth** login from the **Authentication** section.
- Supabase will manage user identities via `auth.users`
- When a user logs in, `auth.uid()` returns their ID, which you use in policies.

---

### ✅ Step 4: Use Supabase Client with Secure Key

- For frontend apps (Flutter, React, etc.), use only the **anon public key**.
- The **service role key** (admin access) should only be used on a secure backend.

```dart
final supabase = SupabaseClient(
  'https://xyzcompany.supabase.co',
  'public-anon-key', // frontend-safe
);
```

---

### ✅ Optional: Limit Storage Access

If you use Supabase Storage:

- Enable **Storage Policies** to control who can upload/download files.
- Use RLS-like rules for each bucket.

---

### 🚨 NEVER:

- Never expose `service_role` key in frontend/mobile apps.
- Never leave RLS **disabled** on sensitive tables.
- Never allow wildcard `SELECT` or `INSERT` policies.
