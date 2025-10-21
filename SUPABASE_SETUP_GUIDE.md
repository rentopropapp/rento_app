# 🚀 Supabase Setup Guide for Rento

Follow these simple steps to set up your Supabase database for the Rento application.

## Step 1: Access Your Supabase Project

1. Go to [https://alsmzgubmgjcibezlpbs.supabase.co](https://alsmzgubmgjcibezlpbs.supabase.co)
2. Sign in to your Supabase account
3. You should see your Rento project dashboard

## Step 2: Open SQL Editor

1. In your Supabase dashboard, look for the sidebar on the left
2. Click on **"SQL Editor"** (it has a SQL icon)
3. You'll see a code editor where you can run SQL commands

## Step 3: Create the Database Tables

**IMPORTANT:** Use the simplified version to avoid permission errors!

1. Open the file called `supabase-setup-simple.sql` in your rento-app folder
2. **Select All** the contents of that file (Ctrl+A)
3. **Copy** everything (Ctrl+C)
4. Go back to your Supabase SQL Editor
5. **Paste** the SQL code into the editor (Ctrl+V)
6. Click the **"Run"** button (usually a play icon ▶️)

**Note:** This simplified version removes problematic commands that require admin privileges.

## Step 4: Verify Tables Were Created

1. In the Supabase sidebar, click on **"Table Editor"**
2. You should now see these tables:
   - users
   - properties
   - bookings
   - payments
   - property_expenses
   - complaints
   - tenant_agreements
   - leads
   - tenants

## Step 5: Set Up Storage (Optional)

1. In the Supabase sidebar, click on **"Storage"**
2. You should see two buckets created:
   - property-photos
   - profile-photos

If they weren't created automatically, you can create them manually:
1. Click **"New bucket"**
2. Name: `property-photos`, make it **Public**
3. Click **"New bucket"** again
4. Name: `profile-photos`, make it **Public**

## Step 6: Test Your Setup

1. Open your `index.html` file in a web browser
2. Try to create a new account
3. If you can sign up successfully, your database is working!

## 🆘 Troubleshooting

### If you get permission errors:

**For "permission denied to set parameter" error:**
1. Use `supabase-setup-simple.sql` instead of `supabase-setup.sql`
2. This removes admin-only commands that cause permission errors

**For authentication setup:**
1. Go to **"Authentication"** in Supabase
2. Click on **"Settings"**
3. Make sure **"Enable email confirmations"** is turned **OFF** for testing
4. Make sure **"Enable phone confirmations"** is turned **OFF** for testing

### If tables don't appear:
1. Try running the SQL script in smaller chunks
2. Make sure you're signed in as the project owner
3. Check the **"Logs"** section for error messages

### If you need help:
1. Check the browser console for error messages (F12 → Console tab)
2. Look at the Supabase logs for more details
3. Make sure your internet connection is stable

## 📝 What the SQL Script Does

The script creates:
- **8 main tables** for storing all your app data
- **Security policies** so users can only see their own data
- **Triggers** to automatically update timestamps
- **Sample data** for testing
- **Storage buckets** for photos

## 🎉 You're All Set!

Once the tables are created, your Rento app will be fully functional. You can:

1. Create tenant, broker, and property manager accounts
2. Add properties
3. Book viewings
4. Track payments
5. Manage leads

**Important:** The `.env` file is already created with your credentials, so the app should connect automatically to your database.

---

**Need More Help?** The database is already configured with your exact URL and API key, so everything should work once the tables are created!