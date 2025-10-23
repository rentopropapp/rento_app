-- Additional Supabase Functions for Rento Application
-- Run this after the main setup scripts

-- Function to calculate owner average rating
CREATE OR REPLACE FUNCTION calculate_owner_average_rating(owner_id UUID)
RETURNS DECIMAL(3,2) AS $$
DECLARE
    avg_rating DECIMAL(3,2);
BEGIN
    SELECT AVG(pr.rating)::DECIMAL(3,2)
    INTO avg_rating
    FROM property_ratings pr
    JOIN properties p ON pr.property_id = p.property_id
    WHERE p.owner_id = calculate_owner_average_rating.owner_id;
    
    RETURN COALESCE(avg_rating, 5.00);
END;
$$ LANGUAGE plpgsql;

-- Function to get property statistics
CREATE OR REPLACE FUNCTION get_property_stats(prop_id UUID)
RETURNS JSON AS $$
DECLARE
    result JSON;
BEGIN
    SELECT json_build_object(
        'total_bookings', (
            SELECT COUNT(*) FROM bookings WHERE property_id = prop_id
        ),
        'confirmed_bookings', (
            SELECT COUNT(*) FROM bookings WHERE property_id = prop_id AND status = 'confirmed'
        ),
        'average_rating', (
            SELECT AVG(rating)::DECIMAL(3,2) FROM property_ratings WHERE property_id = prop_id
        ),
        'total_ratings', (
            SELECT COUNT(*) FROM property_ratings WHERE property_id = prop_id
        ),
        'active_complaints', (
            SELECT COUNT(*) FROM complaints WHERE property_id = prop_id AND status IN ('new', 'in_progress')
        ),
        'resolved_complaints', (
            SELECT COUNT(*) FROM complaints WHERE property_id = prop_id AND status = 'resolved'
        ),
        'unread_notices', (
            SELECT COUNT(*) FROM notices WHERE property_id = prop_id AND is_read = false
        )
    ) INTO result;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- Function to get user dashboard stats
CREATE OR REPLACE FUNCTION get_user_dashboard_stats(user_id UUID)
RETURNS JSON AS $$
DECLARE
    result JSON;
    user_role TEXT;
BEGIN
    -- Get user role first
    SELECT users.user_role INTO user_role FROM users WHERE users.user_id = get_user_dashboard_stats.user_id;
    
    IF user_role = 'tenant' THEN
        SELECT json_build_object(
            'active_rentals', (
                SELECT COUNT(*) FROM tenants WHERE tenants.user_id = get_user_dashboard_stats.user_id AND status = 'active'
            ),
            'pending_bookings', (
                SELECT COUNT(*) FROM bookings WHERE tenant_id = get_user_dashboard_stats.user_id AND status = 'pending'
            ),
            'confirmed_bookings', (
                SELECT COUNT(*) FROM bookings WHERE tenant_id = get_user_dashboard_stats.user_id AND status = 'confirmed'
            ),
            'active_complaints', (
                SELECT COUNT(*) FROM complaints c
                JOIN tenants t ON c.tenant_id = t.tenant_id
                WHERE t.user_id = get_user_dashboard_stats.user_id AND c.status IN ('new', 'in_progress')
            ),
            'unread_notices', (
                SELECT COUNT(*) FROM notices WHERE to_user_id = get_user_dashboard_stats.user_id AND is_read = false
            )
        ) INTO result;
    
    ELSIF user_role = 'property_manager' THEN
        SELECT json_build_object(
            'total_properties', (
                SELECT COUNT(*) FROM properties WHERE owner_id = get_user_dashboard_stats.user_id
            ),
            'occupied_properties', (
                SELECT COUNT(DISTINCT property_id) FROM tenants t
                JOIN properties p ON t.property_id = p.property_id
                WHERE p.owner_id = get_user_dashboard_stats.user_id AND t.status = 'active'
            ),
            'pending_bookings', (
                SELECT COUNT(*) FROM bookings b
                JOIN properties p ON b.property_id = p.property_id
                WHERE p.owner_id = get_user_dashboard_stats.user_id AND b.status = 'pending'
            ),
            'active_complaints', (
                SELECT COUNT(*) FROM complaints c
                JOIN properties p ON c.property_id = p.property_id
                WHERE p.owner_id = get_user_dashboard_stats.user_id AND c.status IN ('new', 'in_progress')
            ),
            'monthly_revenue', (
                SELECT COALESCE(SUM(monthly_rent), 0) FROM tenants t
                JOIN properties p ON t.property_id = p.property_id
                WHERE p.owner_id = get_user_dashboard_stats.user_id AND t.status = 'active'
            )
        ) INTO result;
    
    ELSIF user_role = 'broker' THEN
        SELECT json_build_object(
            'total_leads', (
                SELECT COUNT(*) FROM leads WHERE assigned_broker_id = get_user_dashboard_stats.user_id
            ),
            'new_leads', (
                SELECT COUNT(*) FROM leads WHERE assigned_broker_id = get_user_dashboard_stats.user_id AND status = 'new'
            ),
            'active_leads', (
                SELECT COUNT(*) FROM leads WHERE assigned_broker_id = get_user_dashboard_stats.user_id AND status IN ('contacted', 'viewing', 'negotiating')
            ),
            'converted_leads', (
                SELECT COUNT(*) FROM leads WHERE assigned_broker_id = get_user_dashboard_stats.user_id AND status = 'converted'
            ),
            'total_properties', (
                SELECT COUNT(*) FROM properties WHERE owner_id = get_user_dashboard_stats.user_id
            )
        ) INTO result;
    
    ELSE
        result := '{}'::JSON;
    END IF;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- Function to get recent activity for a user
CREATE OR REPLACE FUNCTION get_recent_activity(user_id UUID, limit_count INTEGER DEFAULT 10)
RETURNS JSON AS $$
DECLARE
    result JSON;
BEGIN
    WITH activities AS (
        -- Bookings
        SELECT 
            'booking' as activity_type,
            'Viewing scheduled for ' || property_name as description,
            viewing_date as activity_date,
            status
        FROM bookings 
        WHERE tenant_id = get_recent_activity.user_id
        
        UNION ALL
        
        -- Complaints
        SELECT 
            'complaint' as activity_type,
            'Complaint: ' || title as description,
            created_at as activity_date,
            status
        FROM complaints c
        JOIN tenants t ON c.tenant_id = t.tenant_id
        WHERE t.user_id = get_recent_activity.user_id
        
        UNION ALL
        
        -- Notices
        SELECT 
            'notice' as activity_type,
            'Notice: ' || title as description,
            created_at as activity_date,
            CASE WHEN is_read THEN 'read' ELSE 'unread' END as status
        FROM notices
        WHERE to_user_id = get_recent_activity.user_id
        
        UNION ALL
        
        -- Payments
        SELECT 
            'payment' as activity_type,
            'Payment of $' || amount::TEXT || ' - ' || payment_type as description,
            created_at as activity_date,
            status
        FROM payments p
        JOIN tenants t ON p.tenant_id = t.tenant_id
        WHERE t.user_id = get_recent_activity.user_id
    )
    SELECT json_agg(
        json_build_object(
            'type', activity_type,
            'description', description,
            'date', activity_date,
            'status', status
        ) ORDER BY activity_date DESC
    )
    INTO result
    FROM (
        SELECT * FROM activities 
        ORDER BY activity_date DESC 
        LIMIT get_recent_activity.limit_count
    ) limited_activities;
    
    RETURN COALESCE(result, '[]'::JSON);
END;
$$ LANGUAGE plpgsql;

-- Trigger function to automatically update property owner ratings when a new rating is added
CREATE OR REPLACE FUNCTION update_owner_rating_trigger()
RETURNS TRIGGER AS $$
BEGIN
    -- Update the property owner's average rating
    UPDATE users 
    SET rating = calculate_owner_average_rating(
        (SELECT owner_id FROM properties WHERE property_id = NEW.property_id)
    ),
    updated_at = NOW()
    WHERE user_id = (SELECT owner_id FROM properties WHERE property_id = NEW.property_id);
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for automatic rating updates
DROP TRIGGER IF EXISTS trigger_update_owner_rating ON property_ratings;
CREATE TRIGGER trigger_update_owner_rating
    AFTER INSERT OR UPDATE ON property_ratings
    FOR EACH ROW
    EXECUTE FUNCTION update_owner_rating_trigger();

-- Function to get property availability for calendar
CREATE OR REPLACE FUNCTION get_property_availability(prop_id UUID, start_date DATE, end_date DATE)
RETURNS JSON AS $$
DECLARE
    result JSON;
BEGIN
    WITH date_series AS (
        SELECT generate_series(start_date, end_date, '1 day'::interval)::date as date
    ),
    booked_dates AS (
        SELECT viewing_date::date as date
        FROM bookings 
        WHERE property_id = prop_id 
        AND status IN ('confirmed', 'pending')
        AND viewing_date::date BETWEEN start_date AND end_date
    )
    SELECT json_agg(
        json_build_object(
            'date', ds.date,
            'available', CASE WHEN bd.date IS NULL THEN true ELSE false END,
            'status', CASE 
                WHEN bd.date IS NOT NULL THEN 'booked'
                ELSE 'available'
            END
        ) ORDER BY ds.date
    )
    INTO result
    FROM date_series ds
    LEFT JOIN booked_dates bd ON ds.date = bd.date;
    
    RETURN COALESCE(result, '[]'::JSON);
END;
$$ LANGUAGE plpgsql;

-- Grant execute permissions on functions
GRANT EXECUTE ON FUNCTION calculate_owner_average_rating(UUID) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION get_property_stats(UUID) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION get_user_dashboard_stats(UUID) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION get_recent_activity(UUID, INTEGER) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION get_property_availability(UUID, DATE, DATE) TO anon, authenticated;