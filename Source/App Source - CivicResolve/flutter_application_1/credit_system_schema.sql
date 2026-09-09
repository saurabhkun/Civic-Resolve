-- Credit System Database Schema for Supabase
-- This file contains the SQL commands to set up the credit and coupon system

-- Create user_profiles table (if not exists) for storing total credits
CREATE TABLE IF NOT EXISTS user_profiles (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id TEXT UNIQUE NOT NULL,
    total_credits INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create user_credits table for credit transaction history
CREATE TABLE IF NOT EXISTS user_credits (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id TEXT NOT NULL,
    credits_earned INTEGER NOT NULL DEFAULT 0,
    earned_for TEXT NOT NULL, -- 'report_submission', 'report_resolved', 'quality_bonus', etc.
    report_id TEXT, -- Reference to the report that earned credits (optional)
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create user_coupons table for storing user's coupons
CREATE TABLE IF NOT EXISTS user_coupons (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id TEXT NOT NULL,
    coupon_code TEXT UNIQUE NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    credits_cost INTEGER NOT NULL DEFAULT 0,
    discount_percentage DECIMAL(5,2) DEFAULT 0.00, -- e.g., 15.50 for 15.5%
    max_discount_amount DECIMAL(10,2), -- Maximum discount amount in currency
    valid_until TIMESTAMP WITH TIME ZONE NOT NULL,
    is_redeemed BOOLEAN DEFAULT FALSE,
    redeemed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_user_credits_user_id ON user_credits(user_id);
CREATE INDEX IF NOT EXISTS idx_user_credits_created_at ON user_credits(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_user_coupons_user_id ON user_coupons(user_id);
CREATE INDEX IF NOT EXISTS idx_user_coupons_valid_until ON user_coupons(valid_until);
CREATE INDEX IF NOT EXISTS idx_user_coupons_is_redeemed ON user_coupons(is_redeemed);

-- Create function to update user's total credits automatically
CREATE OR REPLACE FUNCTION update_user_total_credits()
RETURNS TRIGGER AS $$
BEGIN
    -- Calculate total credits earned
    WITH credit_totals AS (
        SELECT 
            user_id,
            COALESCE(SUM(credits_earned), 0) as total_earned
        FROM user_credits 
        WHERE user_id = NEW.user_id 
        GROUP BY user_id
    ),
    coupon_totals AS (
        SELECT 
            user_id,
            COALESCE(SUM(credits_cost), 0) as total_spent
        FROM user_coupons 
        WHERE user_id = NEW.user_id 
        GROUP BY user_id
    )
    INSERT INTO user_profiles (user_id, total_credits, updated_at)
    SELECT 
        NEW.user_id,
        COALESCE(credit_totals.total_earned, 0) - COALESCE(coupon_totals.total_spent, 0),
        NOW()
    FROM credit_totals
    FULL OUTER JOIN coupon_totals ON credit_totals.user_id = coupon_totals.user_id
    ON CONFLICT (user_id) 
    DO UPDATE SET 
        total_credits = COALESCE((
            SELECT SUM(credits_earned) FROM user_credits WHERE user_id = NEW.user_id
        ), 0) - COALESCE((
            SELECT SUM(credits_cost) FROM user_coupons WHERE user_id = NEW.user_id
        ), 0),
        updated_at = NOW();
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers to automatically update total credits
DROP TRIGGER IF EXISTS trigger_update_credits_on_insert ON user_credits;
CREATE TRIGGER trigger_update_credits_on_insert
    AFTER INSERT ON user_credits
    FOR EACH ROW
    EXECUTE FUNCTION update_user_total_credits();

DROP TRIGGER IF EXISTS trigger_update_credits_on_coupon_insert ON user_coupons;
CREATE TRIGGER trigger_update_credits_on_coupon_insert
    AFTER INSERT ON user_coupons
    FOR EACH ROW
    EXECUTE FUNCTION update_user_total_credits();

-- Insert some sample credit earning templates (optional)
INSERT INTO user_credits (user_id, credits_earned, earned_for, created_at) VALUES
('mock_user_id', 10, 'report_submission', NOW() - INTERVAL '2 days'),
('mock_user_id', 10, 'report_submission', NOW() - INTERVAL '1 day'),
('mock_user_id', 5, 'report_resolved', NOW() - INTERVAL '1 hour')
ON CONFLICT DO NOTHING;

-- Create RLS (Row Level Security) policies for security
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_credits ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_coupons ENABLE ROW LEVEL SECURITY;

-- Policies for user_profiles (users can only access their own profile)
CREATE POLICY "Users can view own profile" ON user_profiles
    FOR SELECT USING (user_id = auth.uid()::text);

CREATE POLICY "Users can update own profile" ON user_profiles
    FOR UPDATE USING (user_id = auth.uid()::text);

CREATE POLICY "Users can insert own profile" ON user_profiles
    FOR INSERT WITH CHECK (user_id = auth.uid()::text);

-- Policies for user_credits (users can only access their own credits)
CREATE POLICY "Users can view own credits" ON user_credits
    FOR SELECT USING (user_id = auth.uid()::text);

CREATE POLICY "Service can insert credits" ON user_credits
    FOR INSERT WITH CHECK (true); -- Allow service to insert credits

-- Policies for user_coupons (users can only access their own coupons)
CREATE POLICY "Users can view own coupons" ON user_coupons
    FOR SELECT USING (user_id = auth.uid()::text);

CREATE POLICY "Users can update own coupons" ON user_coupons
    FOR UPDATE USING (user_id = auth.uid()::text);

CREATE POLICY "Service can insert coupons" ON user_coupons
    FOR INSERT WITH CHECK (true); -- Allow service to insert coupons

-- Comments for documentation
COMMENT ON TABLE user_profiles IS 'Stores user profile information including total credits';
COMMENT ON TABLE user_credits IS 'Stores credit earning history for each user';
COMMENT ON TABLE user_coupons IS 'Stores coupons that users have converted from credits';

COMMENT ON COLUMN user_credits.earned_for IS 'Reason for earning credits: report_submission, report_resolved, quality_bonus, etc.';
COMMENT ON COLUMN user_coupons.discount_percentage IS 'Percentage discount (e.g., 15.50 for 15.5% off)';
COMMENT ON COLUMN user_coupons.max_discount_amount IS 'Maximum discount amount in currency units';