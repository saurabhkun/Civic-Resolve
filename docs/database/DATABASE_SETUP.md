# 🗄️ CivicResolve Database Setup Guide

## Current Status: Demo Mode ✅

Your CivicResolve dashboard is currently running in **Demo Mode** with sample data. This allows you to explore all features without needing a database connection.

## Option 1: Continue with Demo Mode (Recommended for Testing)

✅ **Already Working!** Your dashboard includes:
- Sample reports with realistic data
- All CRUD operations (simulated)
- Full dashboard functionality
- Performance optimizations
- No setup required

### Demo Data Includes:
- 25+ sample civic reports
- Multiple user accounts
- Various categories (Roads, Lighting, Water Supply, etc.)
- Different status levels (Submitted, Under Review, Resolved)
- Mock statistics and analytics

## Option 2: Set Up Real Supabase Database

If you want to connect to a real database, follow these steps:

### 1. Create Supabase Account
1. Go to [supabase.com](https://supabase.com)
2. Sign up for a free account
3. Create a new project

### 2. Set Up Database Tables

Run these SQL commands in your Supabase SQL editor:

```sql
-- Create reports table
CREATE TABLE reports (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(100),
    status VARCHAR(50) DEFAULT 'submitted',
    priority VARCHAR(20) DEFAULT 'medium',
    location TEXT,
    user_id INTEGER,
    contact_number VARCHAR(20),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Create users table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(255),
    email VARCHAR(255) UNIQUE,
    phone_number VARCHAR(20),
    role VARCHAR(50) DEFAULT 'citizen',
    created_at TIMESTAMP DEFAULT NOW()
);

-- Create categories table
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE,
    display_name VARCHAR(255),
    description TEXT
);

-- Insert sample categories
INSERT INTO categories (name, display_name) VALUES
('roads', 'Roads & Infrastructure'),
('lighting', 'Street Lighting'),
('cleanliness', 'Cleanliness & Sanitation'),
('water_supply', 'Water Supply'),
('other', 'Other Issues');

-- Set up Row Level Security (RLS)
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

-- Create policies for public access (adjust as needed)
CREATE POLICY "Public access" ON reports FOR ALL USING (true);
CREATE POLICY "Public access" ON users FOR ALL USING (true);
CREATE POLICY "Public access" ON categories FOR ALL USING (true);
```

### 3. Update Database Configuration

Edit `js/database.js` and replace these values:

```javascript
this.supabaseUrl = 'YOUR_SUPABASE_URL';
this.supabaseKey = 'YOUR_SUPABASE_ANON_KEY';
```

### 4. Get Your Credentials

In your Supabase dashboard:
1. Go to Settings → API
2. Copy your "Project URL" (supabaseUrl)
3. Copy your "anon public" key (supabaseKey)

## Features Working in Demo Mode

### ✅ Fully Functional:
- Login/Logout (admin/1234)
- Dashboard navigation
- Reports listing with pagination
- Search and filtering
- Status updates
- Analytics and charts
- User management interface
- Performance optimizations

### 📊 Sample Data:
- 25+ realistic civic reports
- Multiple user accounts
- Various report categories
- Different priority levels
- Time-based data for charts

## Troubleshooting

### "Database connection failed" message?
This is normal if you haven't set up Supabase. The app automatically switches to demo mode with full functionality.

### Want to test with real data?
Follow Option 2 above to set up Supabase, or keep using demo mode for development and testing.

### Performance optimizations not working?
All optimizations work in both demo and real database modes:
- Pagination (10 items per page)
- Caching (5-minute expiration)
- Optimized queries
- Lazy loading

## Next Steps

1. **Demo Mode**: Continue exploring features with sample data
2. **Real Database**: Follow the Supabase setup guide above
3. **Custom Backend**: Modify `database.js` to connect to your preferred backend

---

🎯 **Quick Start**: Your dashboard is ready to use at http://localhost:8080
👤 **Login**: admin / 1234
📧 **Support**: Check console logs for detailed information