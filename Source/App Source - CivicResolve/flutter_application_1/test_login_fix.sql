-- Test login with updated admin credentials
-- This file tests the updated admin login (admin/1234)

-- Test admin login
SELECT 
    id,
    email,
    full_name,
    is_admin,
    created_at
FROM users 
WHERE email = 'admin' OR email = '123@admin.com';

-- Test password verification function
SELECT verify_password('1234', '$2a$12$LQv3c1yqBwlFDtCfUq8Y0.Rg8aKv8TbmhN4u5z8Xz2Xj6rO5p7sK9') as admin_password_valid;

-- Show all users in system
SELECT 
    id,
    email,
    full_name,
    is_admin,
    phone_number,
    created_at
FROM users
ORDER BY created_at DESC;

-- Show RLS policies
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies 
WHERE tablename IN ('reports', 'notifications')
ORDER BY tablename, policyname;