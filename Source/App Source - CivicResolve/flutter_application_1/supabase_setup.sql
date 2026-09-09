-- Supabase Database Setup for Flutter App
-- Run this script in your Supabase SQL Editor

-- Create the reports table
CREATE TABLE IF NOT EXISTS reports (
  id BIGSERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  category TEXT NOT NULL,
  location TEXT NOT NULL,
  image_urls JSONB DEFAULT '[]'::jsonb,
  status TEXT DEFAULT 'submitted',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  user_id TEXT NOT NULL,
  coordinates JSONB,
  priority TEXT DEFAULT 'medium',
  consolidated_reports INTEGER DEFAULT 1,
  assigned_officer TEXT,
  contact_number TEXT
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_reports_user_id ON reports(user_id);
CREATE INDEX IF NOT EXISTS idx_reports_status ON reports(status);
CREATE INDEX IF NOT EXISTS idx_reports_created_at ON reports(created_at DESC);

-- Enable Row Level Security (RLS)
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Allow all operations on reports" ON reports;

-- Create a policy to allow all operations (you can refine this later)
CREATE POLICY "Allow all operations on reports" ON reports
  FOR ALL USING (true);

-- Insert some test data
INSERT INTO reports (title, description, category, location, image_urls, user_id, coordinates, priority) VALUES 
('Test Pothole Report', 'Large pothole on Main Street causing vehicle damage', 'roads', 'Main Street, Downtown', '[]'::jsonb, 'user_12345', '{"lat": 17.7513547, "lng": 75.9695465}'::jsonb, 'high'),
('Street Light Out', 'Street light not working at night', 'electricity_streetlights', 'Oak Avenue', '[]'::jsonb, 'user_12345', '{"lat": 17.7520000, "lng": 75.9700000}'::jsonb, 'medium')
ON CONFLICT DO NOTHING;