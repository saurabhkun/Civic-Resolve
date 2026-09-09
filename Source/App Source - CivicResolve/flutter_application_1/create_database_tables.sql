-- Create the users table for authentication
CREATE TABLE IF NOT EXISTS public.users (
    id BIGSERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20),
    role VARCHAR(50) DEFAULT 'user',
    is_verified BOOLEAN DEFAULT false,
    email_verified_at TIMESTAMP WITH TIME ZONE,
    last_login TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create the reports table for user reports
CREATE TABLE IF NOT EXISTS public.reports (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES public.users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    category VARCHAR(100) NOT NULL,
    location VARCHAR(255) NOT NULL,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    image_urls TEXT[],
    contact_number VARCHAR(20),
    priority VARCHAR(20) DEFAULT 'medium',
    status VARCHAR(50) DEFAULT 'submitted',
    admin_notes TEXT,
    completion_date TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create the categories table
CREATE TABLE IF NOT EXISTS public.categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    display_name VARCHAR(255) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create the notifications table
CREATE TABLE IF NOT EXISTS public.notifications (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES public.users(id) ON DELETE CASCADE,
    report_id BIGINT REFERENCES public.reports(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50) DEFAULT 'info',
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert default admin user
INSERT INTO public.users (email, password_hash, full_name, phone_number, role, is_verified, created_at, updated_at)
VALUES ('admin', 'admin', 'System Administrator', '+1234567890', 'admin', true, NOW(), NOW())
ON CONFLICT (email) DO UPDATE SET
    password_hash = 'admin',
    full_name = 'System Administrator',
    role = 'admin',
    is_verified = true,
    updated_at = NOW();

-- Insert default categories
INSERT INTO public.categories (name, display_name, description) VALUES
('roads', 'Roads & Infrastructure', 'Issues related to roads, bridges, and infrastructure'),
('water_sewage', 'Water & Sewage', 'Water supply and sewage system issues'),
('electricity_streetlights', 'Electricity & Street Lights', 'Power outages and street lighting issues'),
('waste_management', 'Waste Management', 'Garbage collection and waste disposal issues'),
('public_safety', 'Public Safety', 'Safety concerns and security issues'),
('parks_recreation', 'Parks & Recreation', 'Parks, playgrounds, and recreational facilities'),
('public_transport', 'Public Transport', 'Bus, train, and other public transportation issues'),
('noise_pollution', 'Noise Pollution', 'Noise-related complaints and issues'),
('environmental', 'Environmental Issues', 'Environmental concerns and pollution'),
('other', 'Other Issues', 'Issues that don\'t fit in other categories')
ON CONFLICT (name) DO NOTHING;

-- Enable Row Level Security
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for users table
CREATE POLICY "Users can view their own profile" ON public.users
    FOR SELECT USING (auth.uid()::text = id::text OR EXISTS (
        SELECT 1 FROM public.users WHERE id = auth.uid()::bigint AND role = 'admin'
    ));

CREATE POLICY "Users can update their own profile" ON public.users
    FOR UPDATE USING (auth.uid()::text = id::text);

-- Create RLS policies for reports table
CREATE POLICY "Users can view their own reports" ON public.reports
    FOR SELECT USING (
        user_id = auth.uid()::bigint OR 
        EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid()::bigint AND role = 'admin')
    );

CREATE POLICY "Users can insert their own reports" ON public.reports
    FOR INSERT WITH CHECK (user_id = auth.uid()::bigint);

CREATE POLICY "Users can update their own reports" ON public.reports
    FOR UPDATE USING (
        user_id = auth.uid()::bigint OR 
        EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid()::bigint AND role = 'admin')
    );

-- Create RLS policies for notifications table
CREATE POLICY "Users can view their own notifications" ON public.notifications
    FOR SELECT USING (
        user_id = auth.uid()::bigint OR 
        EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid()::bigint AND role = 'admin')
    );

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email);
CREATE INDEX IF NOT EXISTS idx_users_role ON public.users(role);
CREATE INDEX IF NOT EXISTS idx_reports_user_id ON public.reports(user_id);
CREATE INDEX IF NOT EXISTS idx_reports_status ON public.reports(status);
CREATE INDEX IF NOT EXISTS idx_reports_category ON public.reports(category);
CREATE INDEX IF NOT EXISTS idx_reports_created_at ON public.reports(created_at);
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON public.notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON public.notifications(is_read);

-- Create a simple function to update timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers to automatically update the updated_at column
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_reports_updated_at BEFORE UPDATE ON public.reports 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Grant necessary permissions
GRANT ALL ON public.users TO authenticated;
GRANT ALL ON public.reports TO authenticated;
GRANT ALL ON public.categories TO authenticated;
GRANT ALL ON public.notifications TO authenticated;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO authenticated;