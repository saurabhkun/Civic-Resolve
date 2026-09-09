-- Enhanced Supabase Database Setup for CivicResolve App
-- Run this script in your Supabase SQL Editor

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ========================================
-- USERS TABLE (Enhanced Auth Users)
-- ========================================
CREATE TABLE IF NOT EXISTS public.users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  full_name TEXT NOT NULL,
  phone_number TEXT,
  address TEXT,
  is_admin BOOLEAN DEFAULT FALSE,
  is_verified BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  last_login TIMESTAMPTZ,
  profile_image_url TEXT
);

-- ========================================
-- REPORTS TABLE (Enhanced with User Links)
-- ========================================
CREATE TABLE IF NOT EXISTS public.reports (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  category TEXT NOT NULL,
  location TEXT NOT NULL,
  latitude DECIMAL(10, 8),
  longitude DECIMAL(11, 8),
  image_urls JSONB DEFAULT '[]'::jsonb,
  status TEXT DEFAULT 'submitted' CHECK (status IN ('submitted', 'under_review', 'in_progress', 'resolved', 'rejected')),
  priority TEXT DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high', 'urgent')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  assigned_officer_id UUID REFERENCES public.users(id),
  estimated_completion_date DATE,
  completion_date TIMESTAMPTZ,
  consolidated_reports INTEGER DEFAULT 1,
  contact_number TEXT,
  admin_notes TEXT,
  citizen_feedback TEXT,
  rating INTEGER CHECK (rating >= 1 AND rating <= 5)
);

-- ========================================
-- REPORT STATUS HISTORY TABLE
-- ========================================
CREATE TABLE IF NOT EXISTS public.report_status_history (
  id BIGSERIAL PRIMARY KEY,
  report_id BIGINT NOT NULL REFERENCES public.reports(id) ON DELETE CASCADE,
  old_status TEXT,
  new_status TEXT NOT NULL,
  changed_by UUID NOT NULL REFERENCES public.users(id),
  change_reason TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ========================================
-- NOTIFICATIONS TABLE
-- ========================================
CREATE TABLE IF NOT EXISTS public.notifications (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  report_id BIGINT REFERENCES public.reports(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('status_update', 'system', 'reminder', 'admin_message')),
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  scheduled_for TIMESTAMPTZ,
  delivered_at TIMESTAMPTZ
);

-- ========================================
-- ADMIN ACTIONS TABLE (Audit Trail)
-- ========================================
CREATE TABLE IF NOT EXISTS public.admin_actions (
  id BIGSERIAL PRIMARY KEY,
  admin_id UUID NOT NULL REFERENCES public.users(id),
  action_type TEXT NOT NULL,
  target_type TEXT NOT NULL, -- 'report', 'user', 'notification'
  target_id TEXT NOT NULL,
  details JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ========================================
-- CATEGORIES TABLE (For Dynamic Categories)
-- ========================================
CREATE TABLE IF NOT EXISTS public.categories (
  id SERIAL PRIMARY KEY,
  name TEXT UNIQUE NOT NULL,
  display_name TEXT NOT NULL,
  description TEXT,
  icon_name TEXT,
  color_code TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ========================================
-- INSERT DEFAULT DATA
-- ========================================

-- Insert default admin user (admin / 1234)
-- Note: In production, use proper password hashing
INSERT INTO public.users (email, password_hash, full_name, is_admin, is_verified) 
VALUES ('admin', crypt('1234', gen_salt('bf')), 'System Administrator', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- Insert default categories
INSERT INTO public.categories (name, display_name, description, icon_name, color_code) VALUES
('roads', 'Roads & Infrastructure', 'Potholes, road damage, traffic issues', 'road', '#FF5722'),
('water_sewage', 'Water & Sewage', 'Water supply, drainage, sewage problems', 'water_drop', '#2196F3'),
('electricity_streetlights', 'Electricity & Street Lights', 'Power outages, street lighting issues', 'lightbulb', '#FFC107'),
('waste_management', 'Waste Management', 'Garbage collection, illegal dumping', 'delete', '#4CAF50'),
('public_safety', 'Public Safety', 'Crime, safety hazards, emergency situations', 'security', '#F44336'),
('parks_recreation', 'Parks & Recreation', 'Park maintenance, recreational facilities', 'park', '#8BC34A'),
('public_transport', 'Public Transport', 'Bus stops, transport infrastructure', 'directions_bus', '#9C27B0'),
('noise_pollution', 'Noise Pollution', 'Excessive noise complaints', 'volume_up', '#607D8B'),
('environmental', 'Environmental Issues', 'Air quality, environmental concerns', 'eco', '#795548'),
('other', 'Other Issues', 'Miscellaneous civic issues', 'more_horiz', '#9E9E9E')
ON CONFLICT (name) DO NOTHING;

-- ========================================
-- CREATE INDEXES FOR PERFORMANCE
-- ========================================
CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email);
CREATE INDEX IF NOT EXISTS idx_users_is_admin ON public.users(is_admin);
CREATE INDEX IF NOT EXISTS idx_reports_user_id ON public.reports(user_id);
CREATE INDEX IF NOT EXISTS idx_reports_status ON public.reports(status);
CREATE INDEX IF NOT EXISTS idx_reports_priority ON public.reports(priority);
CREATE INDEX IF NOT EXISTS idx_reports_created_at ON public.reports(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_reports_location ON public.reports(latitude, longitude);
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON public.notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON public.notifications(is_read);
CREATE INDEX IF NOT EXISTS idx_report_status_history_report_id ON public.report_status_history(report_id);

-- ========================================
-- ENABLE ROW LEVEL SECURITY
-- ========================================
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.report_status_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admin_actions ENABLE ROW LEVEL SECURITY;

-- ========================================
-- RLS POLICIES
-- ========================================

-- Users can view and update their own profile
CREATE POLICY "Users can view own profile" ON public.users
  FOR SELECT USING (id = auth.uid() OR auth.jwt() ->> 'email' = email);

CREATE POLICY "Users can update own profile" ON public.users
  FOR UPDATE USING (id = auth.uid() OR auth.jwt() ->> 'email' = email);

-- Reports policies
CREATE POLICY "Users can view all reports" ON public.reports
  FOR SELECT USING (true);

CREATE POLICY "Users can create reports" ON public.reports
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Users can update own reports" ON public.reports
  FOR UPDATE USING (user_id = auth.uid());

CREATE POLICY "Admins can update any report" ON public.reports
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM public.users 
      WHERE id = auth.uid() AND is_admin = true
    )
  );

-- Notifications policies
CREATE POLICY "Users can view own notifications" ON public.notifications
  FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "System can create notifications" ON public.notifications
  FOR INSERT WITH CHECK (true);

-- ========================================
-- FUNCTIONS AND TRIGGERS
-- ========================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers for updated_at
CREATE TRIGGER trigger_users_updated_at
  BEFORE UPDATE ON public.users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trigger_reports_updated_at
  BEFORE UPDATE ON public.reports
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Function to create status history when report status changes
CREATE OR REPLACE FUNCTION create_status_history()
RETURNS TRIGGER AS $$
BEGIN
  IF OLD.status IS DISTINCT FROM NEW.status THEN
    INSERT INTO public.report_status_history (report_id, old_status, new_status, changed_by)
    VALUES (NEW.id, OLD.status, NEW.status, NEW.user_id);
    
    -- Create notification for status change
    INSERT INTO public.notifications (user_id, report_id, title, message, type)
    VALUES (
      NEW.user_id,
      NEW.id,
      'Report Status Updated',
      'Your report "' || NEW.title || '" status has been changed to ' || NEW.status,
      'status_update'
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for status history
CREATE TRIGGER trigger_report_status_history
  AFTER UPDATE ON public.reports
  FOR EACH ROW EXECUTE FUNCTION create_status_history();

-- ========================================
-- VIEWS FOR EASY DATA ACCESS
-- ========================================

-- View for reports with user information
CREATE OR REPLACE VIEW public.reports_with_user AS
SELECT 
  r.*,
  u.full_name as user_name,
  u.email as user_email,
  u.phone_number as user_phone,
  assigned_officer.full_name as assigned_officer_name,
  assigned_officer.email as assigned_officer_email,
  c.display_name as category_display_name,
  c.icon_name as category_icon,
  c.color_code as category_color
FROM public.reports r
LEFT JOIN public.users u ON r.user_id = u.id
LEFT JOIN public.users assigned_officer ON r.assigned_officer_id = assigned_officer.id
LEFT JOIN public.categories c ON r.category = c.name;

-- View for dashboard statistics
CREATE OR REPLACE VIEW public.dashboard_stats AS
SELECT 
  COUNT(*) as total_reports,
  COUNT(*) FILTER (WHERE status = 'submitted') as submitted_reports,
  COUNT(*) FILTER (WHERE status = 'under_review') as under_review_reports,
  COUNT(*) FILTER (WHERE status = 'in_progress') as in_progress_reports,
  COUNT(*) FILTER (WHERE status = 'resolved') as resolved_reports,
  COUNT(*) FILTER (WHERE status = 'rejected') as rejected_reports,
  COUNT(*) FILTER (WHERE priority = 'urgent') as urgent_reports,
  COUNT(*) FILTER (WHERE priority = 'high') as high_priority_reports,
  COUNT(*) FILTER (WHERE created_at >= CURRENT_DATE - INTERVAL '7 days') as reports_this_week,
  COUNT(*) FILTER (WHERE created_at >= CURRENT_DATE - INTERVAL '30 days') as reports_this_month
FROM public.reports;

-- ========================================
-- API FUNCTIONS FOR MOBILE APP
-- ========================================

-- Function to authenticate user
CREATE OR REPLACE FUNCTION public.authenticate_user(user_email TEXT, user_password TEXT)
RETURNS TABLE(success BOOLEAN, user_data JSONB, message TEXT) AS $$
DECLARE
  user_record public.users%ROWTYPE;
BEGIN
  SELECT * INTO user_record 
  FROM public.users 
  WHERE email = user_email 
  AND password_hash = crypt(user_password, password_hash);
  
  IF FOUND THEN
    -- Update last login
    UPDATE public.users SET last_login = NOW() WHERE id = user_record.id;
    
    RETURN QUERY SELECT 
      TRUE as success,
      jsonb_build_object(
        'id', user_record.id,
        'email', user_record.email,
        'full_name', user_record.full_name,
        'phone_number', user_record.phone_number,
        'is_admin', user_record.is_admin,
        'is_verified', user_record.is_verified
      ) as user_data,
      'Login successful' as message;
  ELSE
    RETURN QUERY SELECT 
      FALSE as success,
      NULL::JSONB as user_data,
      'Invalid email or password' as message;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to create new user account
CREATE OR REPLACE FUNCTION public.create_user_account(
  user_email TEXT,
  user_password TEXT,
  user_full_name TEXT,
  user_phone TEXT DEFAULT NULL
)
RETURNS TABLE(success BOOLEAN, user_id UUID, message TEXT) AS $$
DECLARE
  new_user_id UUID;
BEGIN
  -- Check if email already exists
  IF EXISTS (SELECT 1 FROM public.users WHERE email = user_email) THEN
    RETURN QUERY SELECT FALSE, NULL::UUID, 'Email already exists';
    RETURN;
  END IF;
  
  -- Create new user
  INSERT INTO public.users (email, password_hash, full_name, phone_number)
  VALUES (user_email, crypt(user_password, gen_salt('bf')), user_full_name, user_phone)
  RETURNING id INTO new_user_id;
  
  RETURN QUERY SELECT TRUE, new_user_id, 'Account created successfully';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to submit report
CREATE OR REPLACE FUNCTION public.submit_report(
  report_user_id UUID,
  report_title TEXT,
  report_description TEXT,
  report_category TEXT,
  report_location TEXT,
  report_latitude DECIMAL DEFAULT NULL,
  report_longitude DECIMAL DEFAULT NULL,
  report_image_urls JSONB DEFAULT '[]'::jsonb,
  report_contact_number TEXT DEFAULT NULL
)
RETURNS TABLE(success BOOLEAN, report_id BIGINT, message TEXT) AS $$
DECLARE
  new_report_id BIGINT;
  report_priority TEXT := 'medium';
BEGIN
  -- Determine priority based on category
  IF report_category IN ('public_safety', 'water_sewage') THEN
    report_priority := 'high';
  ELSIF report_category IN ('roads', 'electricity_streetlights') THEN
    report_priority := 'medium';
  ELSE
    report_priority := 'low';
  END IF;
  
  -- Insert new report
  INSERT INTO public.reports (
    user_id, title, description, category, location, 
    latitude, longitude, image_urls, priority, contact_number
  )
  VALUES (
    report_user_id, report_title, report_description, report_category, 
    report_location, report_latitude, report_longitude, report_image_urls, 
    report_priority, report_contact_number
  )
  RETURNING id INTO new_report_id;
  
  -- Create notification for admins
  INSERT INTO public.notifications (user_id, report_id, title, message, type)
  SELECT 
    u.id,
    new_report_id,
    'New Report Submitted',
    'A new ' || report_category || ' report has been submitted: ' || report_title,
    'system'
  FROM public.users u
  WHERE u.is_admin = TRUE;
  
  RETURN QUERY SELECT TRUE, new_report_id, 'Report submitted successfully';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO authenticated, anon;
GRANT ALL ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO authenticated;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO authenticated, anon;