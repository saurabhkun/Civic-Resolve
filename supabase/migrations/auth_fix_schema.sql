-- ========================================
-- USER AUTHENTICATION FIX
-- ========================================

-- Function to verify password
CREATE OR REPLACE FUNCTION verify_password(user_id UUID, input_password TEXT)
RETURNS BOOLEAN AS $$
DECLARE
    stored_hash TEXT;
BEGIN
    -- Get the stored password hash
    SELECT password_hash INTO stored_hash
    FROM public.users
    WHERE id = user_id;
    
    -- For simplicity in development, we'll do direct comparison
    -- In production, use proper password hashing
    IF stored_hash IS NULL THEN
        RETURN FALSE;
    END IF;
    
    -- Check if it's a bcrypt hash or plain text
    IF stored_hash LIKE '$2%' THEN
        -- It's a bcrypt hash, use crypt function
        RETURN stored_hash = crypt(input_password, stored_hash);
    ELSE
        -- It's plain text (for development only)
        RETURN stored_hash = input_password;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Update admin user with new credentials
UPDATE public.users 
SET email = 'admin', 
    password_hash = '1234',
    full_name = 'System Administrator'
WHERE email = '123@admin.com' OR full_name = 'System Administrator';

-- If admin user doesn't exist, create it
INSERT INTO public.users (email, password_hash, full_name, is_admin, is_verified)
VALUES ('admin', '1234', 'System Administrator', TRUE, TRUE)
ON CONFLICT (email) DO UPDATE SET
    password_hash = EXCLUDED.password_hash,
    full_name = EXCLUDED.full_name,
    is_admin = EXCLUDED.is_admin,
    is_verified = EXCLUDED.is_verified;

-- Grant permissions
GRANT EXECUTE ON FUNCTION verify_password(UUID, TEXT) TO anon, authenticated;

-- Add RLS policies to ensure users can only see their own reports
ALTER TABLE public.reports ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only see their own reports
DROP POLICY IF EXISTS "Users can view own reports" ON public.reports;
CREATE POLICY "Users can view own reports" ON public.reports
    FOR SELECT USING (auth.uid()::text = user_id::text OR 
                     EXISTS(SELECT 1 FROM public.users WHERE id = auth.uid() AND is_admin = TRUE));

-- Policy: Users can only insert their own reports  
DROP POLICY IF EXISTS "Users can insert own reports" ON public.reports;
CREATE POLICY "Users can insert own reports" ON public.reports
    FOR INSERT WITH CHECK (auth.uid()::text = user_id::text);

-- Policy: Users can only update their own reports (or admins can update any)
DROP POLICY IF EXISTS "Users can update own reports" ON public.reports;
CREATE POLICY "Users can update own reports" ON public.reports
    FOR UPDATE USING (auth.uid()::text = user_id::text OR 
                     EXISTS(SELECT 1 FROM public.users WHERE id = auth.uid() AND is_admin = TRUE));

-- Create a simple authentication context (for development)
-- Note: In production, use Supabase Auth properly
CREATE OR REPLACE FUNCTION auth.uid() RETURNS UUID AS $$
BEGIN
    -- This is a development hack - in production use proper Supabase Auth
    -- For now, we'll return the current user from a session variable
    RETURN current_setting('app.current_user_id', true)::UUID;
EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Function to set current user (for development only)
CREATE OR REPLACE FUNCTION set_current_user(user_uuid UUID)
RETURNS VOID AS $$
BEGIN
    PERFORM set_config('app.current_user_id', user_uuid::text, false);
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION set_current_user(UUID) TO anon, authenticated;