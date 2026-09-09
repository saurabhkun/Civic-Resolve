-- Enhanced Database Schema for CivicResolve App
-- Updated to match the comprehensive report structure requirements

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ========================================
-- ENHANCED USERS TABLE
-- ========================================
DROP TABLE IF EXISTS public.users CASCADE;
CREATE TABLE public.users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  full_name TEXT NOT NULL,
  phone_number TEXT,
  aadhar_number TEXT UNIQUE, -- Added for Aadhar authentication
  address TEXT,
  profile_image_url TEXT,
  is_admin BOOLEAN DEFAULT FALSE,
  is_verified BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  last_login TIMESTAMPTZ
);

-- ========================================
-- ENHANCED REPORTS TABLE
-- ========================================
DROP TABLE IF EXISTS public.reports CASCADE;
CREATE TABLE public.reports (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  category TEXT NOT NULL,
  location TEXT NOT NULL,
  latitude DECIMAL(10, 8),
  longitude DECIMAL(11, 8),
  image_urls JSONB DEFAULT '[]'::jsonb,
  
  -- Report Status Management
  status TEXT DEFAULT 'submitted' CHECK (status IN ('submitted', 'review', 'assigned', 'progress', 'resolved')),
  priority TEXT DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high')),
  
  -- Reporter Information (from user profile)
  reporter_name TEXT, -- Copied from user.full_name at submission
  contact_number TEXT, -- From user.phone_number or manually entered
  aadhar_number TEXT, -- From user.aadhar_number at submission
  
  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  last_status_change TIMESTAMPTZ DEFAULT NOW(),
  
  -- Admin Management
  assigned_officer_id UUID REFERENCES public.users(id),
  assigned_officer_name TEXT,
  admin_notes TEXT,
  
  -- Additional Fields
  estimated_completion_date DATE,
  completion_date TIMESTAMPTZ,
  consolidated_reports INTEGER DEFAULT 1,
  citizen_feedback TEXT,
  rating INTEGER CHECK (rating >= 1 AND rating <= 5)
);

-- ========================================
-- REPORT STATUS HISTORY TABLE
-- ========================================
DROP TABLE IF EXISTS public.report_status_history CASCADE;
CREATE TABLE public.report_status_history (
  id BIGSERIAL PRIMARY KEY,
  report_id BIGINT NOT NULL REFERENCES public.reports(id) ON DELETE CASCADE,
  old_status TEXT,
  new_status TEXT NOT NULL,
  changed_by UUID NOT NULL REFERENCES public.users(id),
  changed_by_name TEXT, -- Store name for history
  change_reason TEXT,
  admin_notes TEXT, -- Notes added with status change
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ========================================
-- ADMIN NOTES TABLE (Separate from status changes)
-- ========================================
DROP TABLE IF EXISTS public.admin_notes CASCADE;
CREATE TABLE public.admin_notes (
  id BIGSERIAL PRIMARY KEY,
  report_id BIGINT NOT NULL REFERENCES public.reports(id) ON DELETE CASCADE,
  admin_id UUID NOT NULL REFERENCES public.users(id),
  admin_name TEXT NOT NULL,
  note_text TEXT NOT NULL,
  note_type TEXT DEFAULT 'internal' CHECK (note_type IN ('internal', 'public', 'system')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ========================================
-- CATEGORIES TABLE
-- ========================================
DROP TABLE IF EXISTS public.categories CASCADE;
CREATE TABLE public.categories (
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
-- NOTIFICATIONS TABLE
-- ========================================
DROP TABLE IF EXISTS public.notifications CASCADE;
CREATE TABLE public.notifications (
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
-- INSERT DEFAULT DATA
-- ========================================

-- Insert default admin user
INSERT INTO public.users (email, password_hash, full_name, aadhar_number, is_admin, is_verified) 
VALUES ('admin', crypt('admin', gen_salt('bf')), 'System Administrator', '000000000000', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- Insert default categories with proper mapping
INSERT INTO public.categories (name, display_name, description, icon_name, color_code) VALUES
('roads_infrastructure', 'Roads & Infrastructure', 'Potholes, road damage, traffic issues', 'road', '#FF5722'),
('water_sewage', 'Water & Sewage', 'Water supply, drainage, sewage problems', 'water_drop', '#2196F3'),
('electricity_streetlights', 'Electricity & Street Lights', 'Power outages, street lighting issues', 'lightbulb', '#FFC107'),
('waste_management', 'Waste Management', 'Garbage collection, illegal dumping', 'delete', '#4CAF50'),
('public_safety', 'Public Safety', 'Crime, safety hazards, emergency situations', 'security', '#F44336'),
('parks_trees', 'Parks & Trees', 'Park maintenance, tree issues, recreational facilities', 'park', '#8BC34A'),
('public_transport', 'Public Transport', 'Bus stops, transport infrastructure', 'directions_bus', '#9C27B0'),
('noise_pollution', 'Noise Pollution', 'Excessive noise complaints', 'volume_up', '#607D8B'),
('environmental', 'Environmental Issues', 'Air quality, environmental concerns', 'eco', '#795548'),
('other', 'Other Issues', 'Miscellaneous civic issues', 'more_horiz', '#9E9E9E')
ON CONFLICT (name) DO NOTHING;

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

-- Function to update last_status_change when status changes
CREATE OR REPLACE FUNCTION update_status_change_time()
RETURNS TRIGGER AS $$
BEGIN
  IF OLD.status IS DISTINCT FROM NEW.status THEN
    NEW.last_status_change = NOW();
  END IF;
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers
CREATE TRIGGER trigger_users_updated_at
  BEFORE UPDATE ON public.users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trigger_reports_status_change
  BEFORE UPDATE ON public.reports
  FOR EACH ROW EXECUTE FUNCTION update_status_change_time();

CREATE TRIGGER trigger_admin_notes_updated_at
  BEFORE UPDATE ON public.admin_notes
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Function to create status history and notifications when report status changes
CREATE OR REPLACE FUNCTION create_status_history()
RETURNS TRIGGER AS $$
BEGIN
  IF OLD.status IS DISTINCT FROM NEW.status THEN
    -- Create status history record
    INSERT INTO public.report_status_history (
      report_id, 
      old_status, 
      new_status, 
      changed_by,
      changed_by_name,
      admin_notes
    )
    VALUES (
      NEW.id, 
      OLD.status, 
      NEW.status, 
      COALESCE(NEW.assigned_officer_id, NEW.user_id),
      COALESCE(NEW.assigned_officer_name, 'System'),
      NEW.admin_notes
    );
    
    -- Create notification for user
    INSERT INTO public.notifications (user_id, report_id, title, message, type)
    VALUES (
      NEW.user_id,
      NEW.id,
      'Report Status Updated',
      'Your report "' || NEW.title || '" status has been changed from ' || 
      COALESCE(OLD.status, 'unknown') || ' to ' || NEW.status,
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
-- ENHANCED API FUNCTIONS
-- ========================================

-- Function to authenticate user with Aadhar
CREATE OR REPLACE FUNCTION public.authenticate_user_aadhar(
  user_aadhar TEXT, 
  user_password TEXT
)
RETURNS TABLE(success BOOLEAN, user_data JSONB, message TEXT) AS $$
DECLARE
  user_record public.users%ROWTYPE;
BEGIN
  SELECT * INTO user_record 
  FROM public.users 
  WHERE aadhar_number = user_aadhar 
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
        'aadhar_number', user_record.aadhar_number,
        'is_admin', user_record.is_admin,
        'is_verified', user_record.is_verified
      ) as user_data,
      'Login successful' as message;
  ELSE
    RETURN QUERY SELECT 
      FALSE as success,
      NULL::JSONB as user_data,
      'Invalid Aadhar number or password' as message;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to submit comprehensive report
CREATE OR REPLACE FUNCTION public.submit_comprehensive_report(
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
RETURNS TABLE(success BOOLEAN, report_id BIGINT, message TEXT, priority TEXT) AS $$
DECLARE
  new_report_id BIGINT;
  report_priority TEXT := 'medium';
  user_info RECORD;
BEGIN
  -- Get user information for reporter details
  SELECT full_name, phone_number, aadhar_number 
  INTO user_info
  FROM public.users 
  WHERE id = report_user_id;
  
  -- Determine priority based on category
  IF report_category IN ('public_safety', 'water_sewage') THEN
    report_priority := 'high';
  ELSIF report_category IN ('roads_infrastructure', 'electricity_streetlights') THEN
    report_priority := 'medium';
  ELSE
    report_priority := 'low';
  END IF;
  
  -- Insert new report with comprehensive data
  INSERT INTO public.reports (
    user_id, title, description, category, location, 
    latitude, longitude, image_urls, priority, 
    contact_number, reporter_name, aadhar_number
  )
  VALUES (
    report_user_id, report_title, report_description, report_category, 
    report_location, report_latitude, report_longitude, report_image_urls, 
    report_priority, COALESCE(report_contact_number, user_info.phone_number),
    user_info.full_name, user_info.aadhar_number
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
  
  RETURN QUERY SELECT TRUE, new_report_id, 'Report submitted successfully', report_priority;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to update report status with admin notes
CREATE OR REPLACE FUNCTION public.update_report_status(
  report_id_input BIGINT,
  new_status TEXT,
  admin_id_input UUID,
  admin_note TEXT DEFAULT NULL
)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
DECLARE
  admin_info RECORD;
BEGIN
  -- Get admin information
  SELECT full_name, is_admin 
  INTO admin_info
  FROM public.users 
  WHERE id = admin_id_input;
  
  -- Check if user is admin
  IF NOT admin_info.is_admin THEN
    RETURN QUERY SELECT FALSE, 'Unauthorized: Only admins can update report status';
    RETURN;
  END IF;
  
  -- Update report status
  UPDATE public.reports 
  SET 
    status = new_status,
    assigned_officer_id = admin_id_input,
    assigned_officer_name = admin_info.full_name,
    admin_notes = COALESCE(admin_note, admin_notes)
  WHERE id = report_id_input;
  
  -- Add admin note if provided
  IF admin_note IS NOT NULL AND admin_note != '' THEN
    INSERT INTO public.admin_notes (report_id, admin_id, admin_name, note_text)
    VALUES (report_id_input, admin_id_input, admin_info.full_name, admin_note);
  END IF;
  
  RETURN QUERY SELECT TRUE, 'Report status updated successfully';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to add admin note to report
CREATE OR REPLACE FUNCTION public.add_admin_note(
  report_id_input BIGINT,
  admin_id_input UUID,
  note_text_input TEXT,
  note_type_input TEXT DEFAULT 'internal'
)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
DECLARE
  admin_info RECORD;
BEGIN
  -- Get admin information
  SELECT full_name, is_admin 
  INTO admin_info
  FROM public.users 
  WHERE id = admin_id_input;
  
  -- Check if user is admin
  IF NOT admin_info.is_admin THEN
    RETURN QUERY SELECT FALSE, 'Unauthorized: Only admins can add notes';
    RETURN;
  END IF;
  
  -- Add admin note
  INSERT INTO public.admin_notes (report_id, admin_id, admin_name, note_text, note_type)
  VALUES (report_id_input, admin_id_input, admin_info.full_name, note_text_input, note_type_input);
  
  RETURN QUERY SELECT TRUE, 'Admin note added successfully';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ========================================
-- VIEWS FOR EASY DATA ACCESS
-- ========================================

-- Comprehensive reports view with all details
CREATE OR REPLACE VIEW public.reports_comprehensive AS
SELECT 
  r.*,
  u.full_name as user_name,
  u.email as user_email,
  u.phone_number as user_phone,
  assigned_officer.full_name as assigned_officer_name,
  assigned_officer.email as assigned_officer_email,
  c.display_name as category_display_name,
  c.icon_name as category_icon,
  c.color_code as category_color,
  -- Status display mapping
  CASE r.status
    WHEN 'submitted' THEN 'Submitted'
    WHEN 'review' THEN 'Review'
    WHEN 'assigned' THEN 'Assigned'
    WHEN 'progress' THEN 'Progress'
    WHEN 'resolved' THEN 'Resolved'
    ELSE r.status
  END as status_display,
  -- Format timestamps
  TO_CHAR(r.created_at, 'DD/MM/YYYY HH24:MI') as submitted_time,
  TO_CHAR(r.updated_at, 'DD/MM/YYYY HH24:MI') as last_updated_time,
  -- GPS coordinates display
  CASE 
    WHEN r.latitude IS NOT NULL AND r.longitude IS NOT NULL THEN 
      CONCAT(r.latitude, ', ', r.longitude)
    ELSE 'GPS coordinates not available'
  END as gps_display,
  -- Count admin notes
  (SELECT COUNT(*) FROM public.admin_notes an WHERE an.report_id = r.id) as admin_notes_count
FROM public.reports r
LEFT JOIN public.users u ON r.user_id = u.id
LEFT JOIN public.users assigned_officer ON r.assigned_officer_id = assigned_officer.id
LEFT JOIN public.categories c ON r.category = c.name;

-- ========================================
-- INDEXES FOR PERFORMANCE
-- ========================================
CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email);
CREATE INDEX IF NOT EXISTS idx_users_aadhar ON public.users(aadhar_number);
CREATE INDEX IF NOT EXISTS idx_users_is_admin ON public.users(is_admin);
CREATE INDEX IF NOT EXISTS idx_reports_user_id ON public.reports(user_id);
CREATE INDEX IF NOT EXISTS idx_reports_status ON public.reports(status);
CREATE INDEX IF NOT EXISTS idx_reports_priority ON public.reports(priority);
CREATE INDEX IF NOT EXISTS idx_reports_category ON public.reports(category);
CREATE INDEX IF NOT EXISTS idx_reports_created_at ON public.reports(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_reports_location ON public.reports(latitude, longitude);
CREATE INDEX IF NOT EXISTS idx_report_status_history_report_id ON public.report_status_history(report_id);
CREATE INDEX IF NOT EXISTS idx_admin_notes_report_id ON public.admin_notes(report_id);
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON public.notifications(user_id);

-- ========================================
-- ROW LEVEL SECURITY (RLS)
-- ========================================
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.report_status_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admin_notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view own profile" ON public.users
  FOR SELECT USING (id = auth.uid());

CREATE POLICY "Users can update own profile" ON public.users
  FOR UPDATE USING (id = auth.uid());

CREATE POLICY "Public read access to reports" ON public.reports
  FOR SELECT USING (true);

CREATE POLICY "Users can create reports" ON public.reports
  FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can view own reports details" ON public.reports
  FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Admins can update any report" ON public.reports
  FOR UPDATE USING (
    EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND is_admin = true)
  );

-- Grant permissions
GRANT USAGE ON SCHEMA public TO authenticated, anon;
GRANT ALL ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO authenticated;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO authenticated, anon;