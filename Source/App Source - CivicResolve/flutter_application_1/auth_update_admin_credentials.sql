-- Update admin credentials to admin/admin
UPDATE users 
SET 
    email = 'admin',
    password_hash = 'admin',
    full_name = 'System Administrator',
    role = 'admin',
    updated_at = NOW()
WHERE email = 'admin' OR email = '123@admin.com';

-- If admin doesn't exist, create it
INSERT INTO users (email, password_hash, full_name, phone_number, role, is_verified, created_at, updated_at)
SELECT 'admin', 'admin', 'System Administrator', '+1234567890', 'admin', true, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'admin');

-- Update verify_password function to handle simple admin password
CREATE OR REPLACE FUNCTION verify_password(user_id INTEGER, input_password TEXT)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    stored_password TEXT;
    user_email TEXT;
BEGIN
    -- Get the stored password and email for the user
    SELECT password_hash, email INTO stored_password, user_email
    FROM users
    WHERE id = user_id;
    
    -- Special case for admin with simple password
    IF user_email = 'admin' AND input_password = 'admin' THEN
        RETURN TRUE;
    END IF;
    
    -- For other users, do simple password comparison
    -- In production, you would use proper password hashing
    RETURN stored_password = input_password;
END;
$$;