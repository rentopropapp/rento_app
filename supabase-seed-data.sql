-- Rento Application - Mock Data Seeding Script
-- Run this after running supabase-complete-setup.sql

-- Insert sample users (Property Managers, Brokers, and Tenants)
INSERT INTO public.users (user_id, email, name, phone_number, user_role, bio, rating, profile_photo_url) VALUES 
    -- Property Managers
    ('11111111-1111-1111-1111-111111111111', 'john.smith@propertymgmt.com', 'John Smith', '+1-234-567-8901', 'property_manager', 'Professional property manager with 10+ years of experience. Committed to providing excellent service and maintaining high-quality properties.', 4.8, 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face&auto=format&q=80'),
    ('22222222-2222-2222-2222-222222222222', 'sarah.johnson@realestate.com', 'Sarah Johnson', '+1-234-567-8902', 'property_manager', 'Friendly and responsive property manager who cares about tenant satisfaction. Always available for maintenance requests and questions.', 4.6, 'https://images.unsplash.com/photo-1494790108755-2616b2e1a2b4?w=150&h=150&fit=crop&crop=face&auto=format&q=80'),
    
    -- Brokers
    ('33333333-3333-3333-3333-333333333333', 'mike.broker@realty.com', 'Mike Thompson', '+1-234-567-8903', 'broker', 'Expert real estate broker specializing in residential properties. Helping families find their perfect home for over 8 years.', 4.7, 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face&auto=format&q=80'),
    ('44444444-4444-4444-4444-444444444444', 'lisa.broker@homes.com', 'Lisa Williams', '+1-234-567-8904', 'broker', 'Professional broker with deep market knowledge. Specializing in luxury properties and commercial real estate.', 4.9, 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150&h=150&fit=crop&crop=face&auto=format&q=80'),
    
    -- Tenants
    ('55555555-5555-5555-5555-555555555555', 'john.tenant@email.com', 'John Tenant', '+1-234-567-8905', 'tenant', 'Young professional looking for modern apartment close to downtown.', 5.0, 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&h=150&fit=crop&crop=face&auto=format&q=80'),
    ('66666666-6666-6666-6666-666666666666', 'maria.tenant@email.com', 'Maria Rodriguez', '+1-234-567-8906', 'tenant', 'Graduate student seeking affordable accommodation near university campus.', 4.5, 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&h=150&fit=crop&crop=face&auto=format&q=80'),
    ('77777777-7777-7777-7777-777777777777', 'david.tenant@email.com', 'David Chen', '+1-234-567-8907', 'tenant', 'Family man looking for spacious home with good schools nearby.', 4.8, 'https://images.unsplash.com/photo-1507591064344-4c6ce005b128?w=150&h=150&fit=crop&crop=face&auto=format&q=80'),
    ('88888888-8888-8888-8888-888888888888', 'emma.tenant@email.com', 'Emma Davis', '+1-234-567-8908', 'tenant', 'First-time renter, young professional in finance sector.', 5.0, 'https://images.unsplash.com/photo-1494790108755-2616b2e1a2b4?w=150&h=150&fit=crop&crop=face&auto=format&q=80')
ON CONFLICT (user_id) DO NOTHING;

-- Insert sample properties
INSERT INTO public.properties (property_id, owner_id, property_name, location, property_type, amenities, description, viewing_fee, lease_type, price, status, photos_urls, availability_calendar) VALUES 
    (
        'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
        '11111111-1111-1111-1111-111111111111',
        'Modern Downtown Apartment',
        'Downtown, City Center',
        'apartment',
        ARRAY['WiFi', 'Gym', 'Pool', 'Parking', 'Air Conditioning', 'Laundry', 'Security', 'Elevator'],
        'Experience luxury living in this stunning modern apartment located in the heart of downtown. This beautifully designed space features floor-to-ceiling windows with breathtaking city views, high-end finishes throughout, and access to world-class amenities.',
        25.00,
        'monthly',
        1500.00,
        'for_rent',
        ARRAY['https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800', 'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800', 'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800'],
        '{"available_dates": ["2024-11-15", "2024-11-16", "2024-11-20"], "selected_dates": ["2024-11-18", "2024-11-19"]}'::jsonb
    ),
    (
        'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
        '22222222-2222-2222-2222-222222222222',
        'Cozy Studio Loft',
        'Midtown, Arts District',
        'studio',
        ARRAY['WiFi', 'Laundry', 'Pet-friendly', 'Heating', 'Kitchen', 'Furnished'],
        'Perfect studio apartment for young professionals or students. This cozy space is optimally designed to maximize comfort and functionality. Located just minutes from public transportation.',
        null,
        'monthly',
        1200.00,
        'for_rent',
        ARRAY['https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800', 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800'],
        '{"available_dates": ["2024-11-14", "2024-11-17", "2024-11-21"], "selected_dates": ["2024-11-16", "2024-11-18"]}'::jsonb
    ),
    (
        'cccccccc-cccc-cccc-cccc-cccccccccccc',
        '11111111-1111-1111-1111-111111111111',
        'Suburban Family Home',
        'Oak Hills, Family Neighborhood',
        'house',
        ARRAY['WiFi', 'Parking', 'Garden', 'Pet-friendly', 'Security', 'Storage'],
        'Beautiful family home in quiet residential neighborhood. Features spacious rooms, private garden, and excellent school district. Perfect for families with children.',
        50.00,
        'monthly',
        2200.00,
        'for_rent',
        ARRAY['https://images.unsplash.com/photo-1568605114967-8130f3a36994?w=800', 'https://images.unsplash.com/photo-1493809842364-78817add7ffb?w=800'],
        '{"available_dates": ["2024-11-12", "2024-11-15", "2024-11-22"], "selected_dates": ["2024-11-20", "2024-11-21"]}'::jsonb
    ),
    (
        'dddddddd-dddd-dddd-dddd-dddddddddddd',
        '33333333-3333-3333-3333-333333333333',
        'Luxury Penthouse Suite',
        'Upper East Side, Manhattan',
        'apartment',
        ARRAY['WiFi', 'Gym', 'Pool', 'Parking', 'Concierge', 'Rooftop', 'Security', 'Elevator'],
        'Exclusive penthouse with panoramic city views. Premium finishes, private terrace, and access to 5-star amenities. The epitome of luxury urban living.',
        100.00,
        'monthly',
        3500.00,
        'for_rent',
        ARRAY['https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=800', 'https://images.unsplash.com/photo-1484154218962-a197022b5858?w=800'],
        '{"available_dates": ["2024-11-25", "2024-11-26", "2024-11-28"], "selected_dates": ["2024-11-27", "2024-11-29"]}'::jsonb
    ),
    (
        'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee',
        '22222222-2222-2222-2222-222222222222',
        'Waterfront Condo',
        'Marina Bay, Waterfront District',
        'apartment',
        ARRAY['WiFi', 'Gym', 'Pool', 'Parking', 'Marina Access', 'Security', 'Elevator'],
        'Stunning waterfront condominium with direct marina access. Floor-to-ceiling windows showcase breathtaking water views. Modern amenities and prime location.',
        75.00,
        'monthly',
        2800.00,
        'for_rent',
        ARRAY['https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=800', 'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800'],
        '{"available_dates": ["2024-11-30", "2024-12-01", "2024-12-03"], "selected_dates": ["2024-12-02", "2024-12-04"]}'::jsonb
    )
ON CONFLICT (property_id) DO NOTHING;

-- Insert tenants (property assignments)
INSERT INTO public.tenants (tenant_id, property_id, user_id, unit_number, move_in_date, lease_start_date, lease_end_date, monthly_rent, status) VALUES 
    ('t1111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '55555555-5555-5555-5555-555555555555', 'A101', '2024-01-01', '2024-01-01', '2024-12-31', 1500.00, 'active'),
    ('t2222222-2222-2222-2222-222222222222', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '66666666-6666-6666-6666-666666666666', 'Studio 2B', '2023-06-15', '2023-06-15', '2025-06-14', 1200.00, 'active'),
    ('t3333333-3333-3333-3333-333333333333', 'cccccccc-cccc-cccc-cccc-cccccccccccc', '77777777-7777-7777-7777-777777777777', 'Main House', '2023-09-01', '2023-09-01', '2025-08-31', 2200.00, 'active'),
    ('t4444444-4444-4444-4444-444444444444', 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', '88888888-8888-8888-8888-888888888888', 'Penthouse', '2024-05-15', '2024-05-15', '2025-05-14', 2800.00, 'active')
ON CONFLICT (tenant_id) DO NOTHING;

-- Insert sample bookings
INSERT INTO public.bookings (booking_id, tenant_id, property_id, tenant_name, tenant_email, tenant_phone, property_name, property_location, viewing_date, status, notes) VALUES 
    ('b1111111-1111-1111-1111-111111111111', '55555555-5555-5555-5555-555555555555', 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'John Tenant', 'john.tenant@email.com', '+1-234-567-8905', 'Luxury Penthouse Suite', 'Upper East Side, Manhattan', '2024-11-25 14:00:00+00', 'confirmed', 'Interested in long-term lease'),
    ('b2222222-2222-2222-2222-222222222222', '66666666-6666-6666-6666-666666666666', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Maria Rodriguez', 'maria.tenant@email.com', '+1-234-567-8906', 'Modern Downtown Apartment', 'Downtown, City Center', '2024-11-28 16:30:00+00', 'pending', 'Graduate student, needs furnished option'),
    ('b3333333-3333-3333-3333-333333333333', '77777777-7777-7777-7777-777777777777', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'David Chen', 'david.tenant@email.com', '+1-234-567-8907', 'Cozy Studio Loft', 'Midtown, Arts District', '2024-11-30 11:00:00+00', 'confirmed', 'Family looking for temporary accommodation')
ON CONFLICT (booking_id) DO NOTHING;

-- Insert sample leads
INSERT INTO public.leads (lead_id, tenant_id, tenant_name, email, phone_number, property_type_required, location_preferred, price_range_min, price_range_max, additional_requirements, status, priority, assigned_broker_id) VALUES 
    ('l1111111-1111-1111-1111-111111111111', '55555555-5555-5555-5555-555555555555', 'John Tenant', 'john.tenant@email.com', '+1-234-567-8905', 'apartment', 'Downtown, Financial District', 1400.00, 2000.00, 'Looking for modern apartment with gym and parking. Pet-friendly preferred.', 'new', 'high', '33333333-3333-3333-3333-333333333333'),
    ('l2222222-2222-2222-2222-222222222222', '66666666-6666-6666-6666-666666666666', 'Maria Rodriguez', 'maria.tenant@email.com', '+1-234-567-8906', 'studio', 'University District, Near Campus', 800.00, 1200.00, 'Graduate student needs affordable studio near university. Good internet essential.', 'contacted', 'medium', '44444444-4444-4444-4444-444444444444'),
    ('l3333333-3333-3333-3333-333333333333', '77777777-7777-7777-7777-777777777777', 'David Chen', 'david.tenant@email.com', '+1-234-567-8907', 'house', 'Suburban Area, Good Schools', 2500.00, 3500.00, 'Family with two children. Need 3+ bedrooms, safe neighborhood, good school district.', 'viewing', 'high', '33333333-3333-3333-3333-333333333333')
ON CONFLICT (lead_id) DO NOTHING;

-- Insert sample complaints
INSERT INTO public.complaints (complaint_id, tenant_id, property_id, title, description, category, priority, status, assigned_to) VALUES 
    ('c1111111-1111-1111-1111-111111111111', 't1111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Heating System Not Working', 'The heating system in my apartment has not been working for the past 3 days. The temperature is getting quite cold, especially at night.', 'maintenance', 'high', 'in_progress', '11111111-1111-1111-1111-111111111111'),
    ('c2222222-2222-2222-2222-222222222222', 't2222222-2222-2222-2222-222222222222', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'Noisy Neighbors', 'The upstairs neighbors are consistently loud late at night, playing music and having parties on weekdays. This is affecting my sleep and studies.', 'noise', 'medium', 'new', '22222222-2222-2222-2222-222222222222'),
    ('c3333333-3333-3333-3333-333333333333', 't3333333-3333-3333-3333-333333333333', 'cccccccc-cccc-cccc-cccc-cccccccccccc', 'Water Pressure Issues', 'Low water pressure in both bathroom and kitchen. Makes it difficult to shower and wash dishes effectively.', 'plumbing', 'medium', 'resolved', '11111111-1111-1111-1111-111111111111')
ON CONFLICT (complaint_id) DO NOTHING;

-- Insert sample notices/messages
INSERT INTO public.notices (notice_id, property_id, tenant_id, from_user_id, to_user_id, title, message, notice_type, priority, is_read) VALUES 
    ('n1111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 't1111111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111111', '55555555-5555-5555-5555-555555555555', 'Monthly Rent Reminder', 'This is a friendly reminder that your monthly rent payment of $1,500 is due on the 1st of each month. Please ensure payment is made on time to avoid late fees.', 'payment', 'medium', false),
    ('n2222222-2222-2222-2222-222222222222', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 't2222222-2222-2222-2222-222222222222', '22222222-2222-2222-2222-222222222222', '66666666-6666-6666-6666-666666666666', 'Maintenance Scheduled', 'We have scheduled maintenance work for the building heating system on November 30th from 9 AM to 3 PM. There may be temporary heating disruption.', 'maintenance', 'high', false),
    ('n3333333-3333-3333-3333-333333333333', 'cccccccc-cccc-cccc-cccc-cccccccccccc', 't3333333-3333-3333-3333-333333333333', '11111111-1111-1111-1111-111111111111', '77777777-7777-7777-7777-777777777777', 'Lease Renewal Available', 'Your current lease expires on August 31st, 2025. We would like to offer you a lease renewal with updated terms. Please contact us to discuss.', 'lease', 'medium', true),
    ('n4444444-4444-4444-4444-444444444444', 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 't4444444-4444-4444-4444-444444444444', '22222222-2222-2222-2222-222222222222', '88888888-8888-8888-8888-888888888888', 'Pool Closure Notice', 'The building pool will be closed for cleaning and maintenance from December 1st to December 5th. We apologize for any inconvenience.', 'general', 'low', false)
ON CONFLICT (notice_id) DO NOTHING;

-- Insert sample payments
INSERT INTO public.payments (payment_id, tenant_id, property_id, amount, payment_date, payment_type, status) VALUES 
    ('p1111111-1111-1111-1111-111111111111', 't1111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 1500.00, '2024-11-01', 'rent', 'completed'),
    ('p2222222-2222-2222-2222-222222222222', 't2222222-2222-2222-2222-222222222222', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 1200.00, '2024-11-01', 'rent', 'completed'),
    ('p3333333-3333-3333-3333-333333333333', 't3333333-3333-3333-3333-333333333333', 'cccccccc-cccc-cccc-cccc-cccccccccccc', 2200.00, '2024-11-01', 'rent', 'completed'),
    ('p4444444-4444-4444-4444-444444444444', 't4444444-4444-4444-4444-444444444444', 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 2800.00, '2024-11-01', 'rent', 'completed'),
    ('p5555555-5555-5555-5555-555555555555', 't1111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 25.00, '2024-10-15', 'viewing_fee', 'completed')
ON CONFLICT (payment_id) DO NOTHING;

-- Insert sample property expenses
INSERT INTO public.property_expenses (expense_id, property_id, expense_name, category, amount, expense_date) VALUES 
    ('e1111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Heating System Repair', 'maintenance', 350.50, '2024-10-15'),
    ('e2222222-2222-2222-2222-222222222222', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'Plumbing Fix - Kitchen', 'maintenance', 125.00, '2024-10-20'),
    ('e3333333-3333-3333-3333-333333333333', 'cccccccc-cccc-cccc-cccc-cccccccccccc', 'Landscaping Services', 'maintenance', 200.00, '2024-10-25'),
    ('e4444444-4444-4444-4444-444444444444', 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'Pool Maintenance', 'utilities', 150.00, '2024-10-30'),
    ('e5555555-5555-5555-5555-555555555555', 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 'Security System Upgrade', 'security', 800.00, '2024-11-01')
ON CONFLICT (expense_id) DO NOTHING;

-- Insert sample tenant agreements
INSERT INTO public.tenant_agreements (agreement_id, tenant_id, property_id, agreement_date, lease_start_date, lease_end_date, monthly_rent, security_deposit, terms_and_conditions, status) VALUES 
    ('a1111111-1111-1111-1111-111111111111', 't1111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '2023-12-15', '2024-01-01', '2024-12-31', 1500.00, 3000.00, 'Standard residential lease agreement with monthly payment due on 1st of each month. No pets allowed. Tenant responsible for utilities.', 'signed'),
    ('a2222222-2222-2222-2222-222222222222', 't2222222-2222-2222-2222-222222222222', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '2023-05-20', '2023-06-15', '2025-06-14', 1200.00, 2400.00, 'Two-year lease agreement for furnished studio apartment. Pet-friendly property. Utilities included except electricity.', 'signed'),
    ('a3333333-3333-3333-3333-333333333333', 't3333333-3333-3333-3333-333333333333', 'cccccccc-cccc-cccc-cccc-cccccccccccc', '2023-08-10', '2023-09-01', '2025-08-31', 2200.00, 4400.00, 'Family home lease with garden maintenance included. Tenant responsible for all utilities. Early termination clause available.', 'signed'),
    ('a4444444-4444-4444-4444-444444444444', 't4444444-4444-4444-4444-444444444444', 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', '2024-04-20', '2024-05-15', '2025-05-14', 2800.00, 5600.00, 'Luxury waterfront condo lease with marina access privileges. All utilities and amenities included. No subletting allowed.', 'signed')
ON CONFLICT (agreement_id) DO NOTHING;

-- Insert sample property ratings
INSERT INTO public.property_ratings (rating_id, property_id, user_id, rating, review) VALUES 
    ('r1111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '55555555-5555-5555-5555-555555555555', 5, 'Excellent apartment with great amenities. The location is perfect for work commute and the building management is very responsive.'),
    ('r2222222-2222-2222-2222-222222222222', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '66666666-6666-6666-6666-666666666666', 4, 'Nice studio apartment, perfect for a student. The area is vibrant with lots of cafes and shops nearby.'),
    ('r3333333-3333-3333-3333-333333333333', 'cccccccc-cccc-cccc-cccc-cccccccccccc', '77777777-7777-7777-7777-777777777777', 5, 'Perfect family home with a beautiful garden. The neighborhood is quiet and safe, great schools nearby.'),
    ('r4444444-4444-4444-4444-444444444444', 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', '88888888-8888-8888-8888-888888888888', 5, 'Stunning waterfront views and luxury amenities. The marina access is a huge plus. Highly recommend!')
ON CONFLICT (rating_id) DO NOTHING;

-- Update user ratings based on property ratings
UPDATE public.users SET rating = (
    SELECT AVG(pr.rating)::DECIMAL(3,2)
    FROM public.property_ratings pr
    JOIN public.properties p ON pr.property_id = p.property_id
    WHERE p.owner_id = users.user_id
    GROUP BY p.owner_id
) WHERE user_role IN ('property_manager', 'broker') AND user_id IN (
    SELECT DISTINCT p.owner_id 
    FROM public.properties p 
    JOIN public.property_ratings pr ON p.property_id = pr.property_id
);