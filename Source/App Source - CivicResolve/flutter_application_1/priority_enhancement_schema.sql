-- ========================================
-- PRIORITY ENHANCEMENT FOR REPORTS
-- ========================================

-- Add priority levels to categories table
ALTER TABLE public.categories 
ADD COLUMN IF NOT EXISTS default_priority TEXT DEFAULT 'medium' 
  CHECK (default_priority IN ('low', 'medium', 'high', 'urgent'));

-- Update existing categories with appropriate priority levels
UPDATE public.categories 
SET default_priority = CASE 
    WHEN name = 'public_safety' THEN 'urgent'
    WHEN name = 'water_sewage' THEN 'high'
    WHEN name = 'electricity_streetlights' THEN 'high'
    WHEN name = 'roads' THEN 'medium'
    WHEN name = 'waste_management' THEN 'medium'
    WHEN name = 'environmental' THEN 'medium'
    WHEN name = 'parks_recreation' THEN 'low'
    WHEN name = 'public_transport' THEN 'medium'
    WHEN name = 'noise_pollution' THEN 'low'
    ELSE 'medium'
END;

-- ========================================
-- PRIORITY ASSIGNMENT FUNCTION
-- ========================================

-- Function to automatically determine report priority
CREATE OR REPLACE FUNCTION auto_assign_priority(report_category TEXT, keywords TEXT DEFAULT '')
RETURNS TEXT AS $$
DECLARE
    base_priority TEXT;
    final_priority TEXT;
BEGIN
    -- Get base priority from category
    SELECT default_priority INTO base_priority
    FROM public.categories 
    WHERE name = report_category;
    
    -- If category not found, default to medium
    IF base_priority IS NULL THEN
        base_priority := 'medium';
    END IF;
    
    -- Check for urgent keywords in title/description
    keywords := LOWER(keywords);
    
    IF keywords ~ '(emergency|urgent|dangerous|immediate|critical|severe|accident|injury|fire|flood|gas leak|power outage|water main|blocked road|traffic accident)' THEN
        final_priority := 'urgent';
    ELSIF keywords ~ '(safety|health|hazard|damage|broken|leak|overflow|major)' THEN
        -- Escalate priority by one level
        final_priority := CASE base_priority
            WHEN 'low' THEN 'medium'
            WHEN 'medium' THEN 'high'
            WHEN 'high' THEN 'urgent'
            ELSE 'urgent'
        END;
    ELSE
        final_priority := base_priority;
    END IF;
    
    RETURN final_priority;
END;
$$ LANGUAGE plpgsql;

-- ========================================
-- ENHANCED REPORT SUBMISSION FUNCTION
-- ========================================

-- Function to submit report with automatic priority assignment
CREATE OR REPLACE FUNCTION submit_report_with_priority(
    p_user_id UUID,
    p_title TEXT,
    p_description TEXT,
    p_category TEXT,
    p_location TEXT,
    p_latitude DECIMAL DEFAULT NULL,
    p_longitude DECIMAL DEFAULT NULL,
    p_image_urls JSONB DEFAULT '[]'::jsonb,
    p_contact_number TEXT DEFAULT NULL
)
RETURNS TABLE(
    report_id BIGINT,
    assigned_priority TEXT,
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    new_report_id BIGINT;
    calculated_priority TEXT;
    user_info RECORD;
BEGIN
    -- Get user information
    SELECT full_name, email, phone_number 
    INTO user_info
    FROM public.users 
    WHERE id = p_user_id;
    
    IF NOT FOUND THEN
        RETURN QUERY SELECT NULL::BIGINT, NULL::TEXT, FALSE, 'User not found';
        RETURN;
    END IF;
    
    -- Calculate priority based on category and content
    calculated_priority := auto_assign_priority(
        p_category, 
        p_title || ' ' || p_description
    );
    
    -- Insert the report
    INSERT INTO public.reports (
        user_id,
        title,
        description,
        category,
        location,
        latitude,
        longitude,
        image_urls,
        priority,
        contact_number,
        status,
        created_at,
        updated_at
    ) VALUES (
        p_user_id,
        p_title,
        p_description,
        p_category,
        p_location,
        p_latitude,
        p_longitude,
        p_image_urls,
        calculated_priority,
        COALESCE(p_contact_number, user_info.phone_number),
        'submitted',
        NOW(),
        NOW()
    ) RETURNING id INTO new_report_id;
    
    -- Create initial status history
    INSERT INTO public.report_status_history (
        report_id,
        old_status,
        new_status,
        changed_by,
        change_reason,
        created_at
    ) VALUES (
        new_report_id,
        NULL,
        'submitted',
        p_user_id,
        'Initial report submission',
        NOW()
    );
    
    -- Notify admins about new report
    INSERT INTO public.notifications (
        user_id,
        report_id,
        title,
        message,
        type,
        created_at
    )
    SELECT 
        u.id,
        new_report_id,
        'New ' || calculated_priority || ' Priority Report',
        'A new ' || calculated_priority || ' priority report has been submitted: ' || p_title,
        'system',
        NOW()
    FROM public.users u
    WHERE u.is_admin = TRUE;
    
    RETURN QUERY SELECT 
        new_report_id, 
        calculated_priority, 
        TRUE, 
        'Report submitted successfully with ' || calculated_priority || ' priority';
END;
$$ LANGUAGE plpgsql;

-- ========================================
-- PRIORITY STATISTICS FUNCTION
-- ========================================

-- Function to get priority statistics for external access
CREATE OR REPLACE FUNCTION get_priority_statistics(
    p_time_period TEXT DEFAULT 'all', -- 'today', 'week', 'month', 'all'
    p_category TEXT DEFAULT NULL
)
RETURNS TABLE(
    priority_level TEXT,
    total_reports INTEGER,
    submitted_count INTEGER,
    in_progress_count INTEGER,
    resolved_count INTEGER,
    avg_resolution_time_hours DECIMAL
) AS $$
DECLARE
    date_filter TIMESTAMPTZ;
BEGIN
    -- Set date filter based on period
    date_filter := CASE p_time_period
        WHEN 'today' THEN CURRENT_DATE
        WHEN 'week' THEN CURRENT_DATE - INTERVAL '7 days'
        WHEN 'month' THEN CURRENT_DATE - INTERVAL '30 days'
        ELSE '1900-01-01'::TIMESTAMPTZ
    END;
    
    RETURN QUERY
    SELECT 
        r.priority::TEXT,
        COUNT(*)::INTEGER as total_reports,
        COUNT(CASE WHEN r.status = 'submitted' THEN 1 END)::INTEGER as submitted_count,
        COUNT(CASE WHEN r.status IN ('under_review', 'in_progress') THEN 1 END)::INTEGER as in_progress_count,
        COUNT(CASE WHEN r.status = 'resolved' THEN 1 END)::INTEGER as resolved_count,
        AVG(CASE 
            WHEN r.status = 'resolved' AND r.completion_date IS NOT NULL 
            THEN EXTRACT(EPOCH FROM (r.completion_date - r.created_at)) / 3600
            ELSE NULL
        END)::DECIMAL as avg_resolution_time_hours
    FROM public.reports r
    WHERE r.created_at >= date_filter
      AND (p_category IS NULL OR r.category = p_category)
    GROUP BY r.priority
    ORDER BY 
        CASE r.priority
            WHEN 'urgent' THEN 1
            WHEN 'high' THEN 2
            WHEN 'medium' THEN 3
            WHEN 'low' THEN 4
        END;
END;
$$ LANGUAGE plpgsql;

-- ========================================
-- EXTERNAL API FUNCTIONS FOR PRIORITY ACCESS
-- ========================================

-- Function to get reports by priority (for external web application)
CREATE OR REPLACE FUNCTION get_reports_by_priority(
    p_priority TEXT DEFAULT NULL,
    p_status TEXT DEFAULT NULL,
    p_limit INTEGER DEFAULT 50,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE(
    report_id BIGINT,
    user_name TEXT,
    user_email TEXT,
    title TEXT,
    description TEXT,
    category TEXT,
    location TEXT,
    priority TEXT,
    status TEXT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    estimated_completion_date DATE,
    completion_date TIMESTAMPTZ,
    contact_number TEXT,
    admin_notes TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        r.id,
        u.full_name,
        u.email,
        r.title,
        r.description,
        r.category,
        r.location,
        r.priority,
        r.status,
        r.created_at,
        r.updated_at,
        r.estimated_completion_date,
        r.completion_date,
        r.contact_number,
        r.admin_notes
    FROM public.reports r
    JOIN public.users u ON r.user_id = u.id
    WHERE (p_priority IS NULL OR r.priority = p_priority)
      AND (p_status IS NULL OR r.status = p_status)
    ORDER BY 
        CASE r.priority
            WHEN 'urgent' THEN 1
            WHEN 'high' THEN 2
            WHEN 'medium' THEN 3
            WHEN 'low' THEN 4
        END,
        r.created_at DESC
    LIMIT p_limit
    OFFSET p_offset;
END;
$$ LANGUAGE plpgsql;

-- Function to update report priority (admin only)
CREATE OR REPLACE FUNCTION update_report_priority(
    p_report_id BIGINT,
    p_new_priority TEXT,
    p_admin_id UUID,
    p_reason TEXT DEFAULT NULL
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    old_priority TEXT;
    report_owner UUID;
BEGIN
    -- Verify admin permission
    IF NOT EXISTS (SELECT 1 FROM public.users WHERE id = p_admin_id AND is_admin = TRUE) THEN
        RETURN QUERY SELECT FALSE, 'Unauthorized: Admin access required';
        RETURN;
    END IF;
    
    -- Get current priority and report owner
    SELECT priority, user_id INTO old_priority, report_owner
    FROM public.reports
    WHERE id = p_report_id;
    
    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, 'Report not found';
        RETURN;
    END IF;
    
    -- Update priority
    UPDATE public.reports 
    SET priority = p_new_priority, updated_at = NOW()
    WHERE id = p_report_id;
    
    -- Log admin action
    INSERT INTO public.admin_actions (
        admin_id,
        action_type,
        target_type,
        target_id,
        details,
        created_at
    ) VALUES (
        p_admin_id,
        'priority_change',
        'report',
        p_report_id::TEXT,
        jsonb_build_object(
            'old_priority', old_priority,
            'new_priority', p_new_priority,
            'reason', p_reason
        ),
        NOW()
    );
    
    -- Notify report owner
    INSERT INTO public.notifications (
        user_id,
        report_id,
        title,
        message,
        type,
        created_at
    ) VALUES (
        report_owner,
        p_report_id,
        'Report Priority Updated',
        'Your report priority has been changed from ' || old_priority || ' to ' || p_new_priority ||
        CASE WHEN p_reason IS NOT NULL THEN '. Reason: ' || p_reason ELSE '' END,
        'priority_update',
        NOW()
    );
    
    RETURN QUERY SELECT TRUE, 'Priority updated successfully from ' || old_priority || ' to ' || p_new_priority;
END;
$$ LANGUAGE plpgsql;

-- ========================================
-- PRIORITY DASHBOARD FUNCTION
-- ========================================

-- Function for external dashboard to get comprehensive priority overview
CREATE OR REPLACE FUNCTION get_priority_dashboard()
RETURNS TABLE(
    urgent_reports INTEGER,
    high_reports INTEGER,
    medium_reports INTEGER,
    low_reports INTEGER,
    urgent_pending INTEGER,
    high_pending INTEGER,
    medium_pending INTEGER,
    low_pending INTEGER,
    priority_distribution JSONB,
    avg_resolution_by_priority JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(CASE WHEN priority = 'urgent' THEN 1 END)::INTEGER as urgent_reports,
        COUNT(CASE WHEN priority = 'high' THEN 1 END)::INTEGER as high_reports,
        COUNT(CASE WHEN priority = 'medium' THEN 1 END)::INTEGER as medium_reports,
        COUNT(CASE WHEN priority = 'low' THEN 1 END)::INTEGER as low_reports,
        
        COUNT(CASE WHEN priority = 'urgent' AND status NOT IN ('resolved', 'rejected') THEN 1 END)::INTEGER as urgent_pending,
        COUNT(CASE WHEN priority = 'high' AND status NOT IN ('resolved', 'rejected') THEN 1 END)::INTEGER as high_pending,
        COUNT(CASE WHEN priority = 'medium' AND status NOT IN ('resolved', 'rejected') THEN 1 END)::INTEGER as medium_pending,
        COUNT(CASE WHEN priority = 'low' AND status NOT IN ('resolved', 'rejected') THEN 1 END)::INTEGER as low_pending,
        
        jsonb_build_object(
            'urgent', COUNT(CASE WHEN priority = 'urgent' THEN 1 END),
            'high', COUNT(CASE WHEN priority = 'high' THEN 1 END),
            'medium', COUNT(CASE WHEN priority = 'medium' THEN 1 END),
            'low', COUNT(CASE WHEN priority = 'low' THEN 1 END)
        ) as priority_distribution,
        
        jsonb_build_object(
            'urgent_avg_hours', AVG(CASE WHEN priority = 'urgent' AND completion_date IS NOT NULL 
                THEN EXTRACT(EPOCH FROM (completion_date - created_at)) / 3600 END),
            'high_avg_hours', AVG(CASE WHEN priority = 'high' AND completion_date IS NOT NULL 
                THEN EXTRACT(EPOCH FROM (completion_date - created_at)) / 3600 END),
            'medium_avg_hours', AVG(CASE WHEN priority = 'medium' AND completion_date IS NOT NULL 
                THEN EXTRACT(EPOCH FROM (completion_date - created_at)) / 3600 END),
            'low_avg_hours', AVG(CASE WHEN priority = 'low' AND completion_date IS NOT NULL 
                THEN EXTRACT(EPOCH FROM (completion_date - created_at)) / 3600 END)
        ) as avg_resolution_by_priority
    FROM public.reports;
END;
$$ LANGUAGE plpgsql;

-- ========================================
-- GRANTS FOR EXTERNAL ACCESS
-- ========================================

-- Grant execute permissions for external API access
GRANT EXECUTE ON FUNCTION auto_assign_priority(TEXT, TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION submit_report_with_priority(UUID, TEXT, TEXT, TEXT, TEXT, DECIMAL, DECIMAL, JSONB, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION get_priority_statistics(TEXT, TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION get_reports_by_priority(TEXT, TEXT, INTEGER, INTEGER) TO authenticated;
GRANT EXECUTE ON FUNCTION update_report_priority(BIGINT, TEXT, UUID, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION get_priority_dashboard() TO anon, authenticated;

-- ========================================
-- PRIORITY INDEXES FOR PERFORMANCE
-- ========================================

-- Create indexes for priority-based queries
CREATE INDEX IF NOT EXISTS idx_reports_priority ON public.reports(priority);
CREATE INDEX IF NOT EXISTS idx_reports_priority_status ON public.reports(priority, status);
CREATE INDEX IF NOT EXISTS idx_reports_priority_created ON public.reports(priority, created_at);
CREATE INDEX IF NOT EXISTS idx_categories_priority ON public.categories(default_priority);

-- ========================================
-- COMMENTS FOR DOCUMENTATION
-- ========================================

COMMENT ON FUNCTION auto_assign_priority(TEXT, TEXT) IS 'Automatically determines report priority based on category and content keywords';
COMMENT ON FUNCTION submit_report_with_priority(UUID, TEXT, TEXT, TEXT, TEXT, DECIMAL, DECIMAL, JSONB, TEXT) IS 'Submits a new report with automatic priority assignment';
COMMENT ON FUNCTION get_priority_statistics(TEXT, TEXT) IS 'Returns priority-based statistics for dashboard analytics';
COMMENT ON FUNCTION get_reports_by_priority(TEXT, TEXT, INTEGER, INTEGER) IS 'Retrieves reports filtered by priority for external applications';
COMMENT ON FUNCTION update_report_priority(BIGINT, TEXT, UUID, TEXT) IS 'Updates report priority with admin authorization and audit trail';
COMMENT ON FUNCTION get_priority_dashboard() IS 'Comprehensive priority overview for external dashboard applications';

COMMENT ON COLUMN public.categories.default_priority IS 'Default priority level assigned to reports in this category';
COMMENT ON COLUMN public.reports.priority IS 'Priority level: urgent, high, medium, low - determines processing order';