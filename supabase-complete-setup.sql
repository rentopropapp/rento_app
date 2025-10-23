-- Complete Rento Database Setup for Supabase
-- This script creates all tables, relationships, and populates with mock data

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create Users table (extends Supabase auth.users)
CREATE TABLE IF NOT EXISTS public.users (
    user_id UUID PRIMARY KEY DEFAULT auth.uid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255),
    phone_number VARCHAR(20),
    profile_photo_url TEXT,
    birthday DATE,
    occupation VARCHAR(255),
    user_role VARCHAR(50) CHECK (user_role IN ('tenant', 'broker', 'property_manager')) NOT NULL,
    bio TEXT,
    rating DECIMAL(3,2) DEFAULT 5.00,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create Properties table
CREATE TABLE IF NOT EXISTS public.properties (
    property_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID REFERENCES public.users(user_id) ON DELETE CASCADE,
    property_name VARCHAR(255) NOT NULL,
    location VARCHAR(255) NOT NULL,
    property_type VARCHAR(100) NOT NULL,
    amenities TEXT[],
    description TEXT,
    viewing_fee DECIMAL(10,2),
    lease_type VARCHAR(50),
    price DECIMAL(10,2) NOT NULL,
    status VARCHAR(50) CHECK (status IN ('for_rent', 'for_sale', 'airbnb')) NOT NULL,
    photos_urls TEXT[],
    availability_calendar JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create Tenants table (for property assignments)
CREATE TABLE IF NOT EXISTS public.tenants (
    tenant_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    property_id UUID REFERENCES public.properties(property_id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.users(user_id) ON DELETE CASCADE,
    unit_number VARCHAR(50),
    move_in_date DATE,
    move_out_date DATE,
    lease_start_date DATE,
    lease_end_date DATE,
    monthly_rent DECIMAL(10,2),
    payment_due_date INTEGER DEFAULT 1, -- Day of month
    status VARCHAR(20) CHECK (status IN ('active', 'inactive')) DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create Bookings table
CREATE TABLE IF NOT EXISTS public.bookings (
    booking_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID REFERENCES public.users(user_id) ON DELETE CASCADE,
    property_id UUID REFERENCES public.properties(property_id) ON DELETE CASCADE,
    tenant_name VARCHAR(255),
    tenant_email VARCHAR(255),
    tenant_phone VARCHAR(20),
    property_name VARCHAR(255),
    property_location VARCHAR(255),
    viewing_date TIMESTAMP WITH TIME ZONE NOT NULL,
    status VARCHAR(50) CHECK (status IN ('pending', 'confirmed', 'cancelled', 'completed')) DEFAULT 'pending',
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create Payments table
CREATE TABLE IF NOT EXISTS public.payments (
    payment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID REFERENCES public.tenants(tenant_id) ON DELETE CASCADE,
    property_id UUID REFERENCES public.properties(property_id) ON DELETE CASCADE,
    amount DECIMAL(10,2) NOT NULL,
    payment_date DATE NOT NULL,
    payment_type VARCHAR(50) CHECK (payment_type IN ('rent', 'viewing_fee', 'deposit', 'utilities')) NOT NULL,
    status VARCHAR(50) CHECK (status IN ('completed', 'pending', 'failed')) DEFAULT 'pending',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create Property Expenses table
CREATE TABLE IF NOT EXISTS public.property_expenses (
    expense_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    property_id UUID REFERENCES public.properties(property_id) ON DELETE CASCADE,
    expense_name VARCHAR(255) NOT NULL,
    category VARCHAR(100) NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    expense_date DATE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create Complaints table
CREATE TABLE IF NOT EXISTS public.complaints (
    complaint_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID REFERENCES public.tenants(tenant_id) ON DELETE CASCADE,
    property_id UUID REFERENCES public.properties(property_id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    category VARCHAR(100),
    priority VARCHAR(20) CHECK (priority IN ('low', 'medium', 'high', 'urgent')) DEFAULT 'medium',
    status VARCHAR(50) CHECK (status IN ('new', 'in_progress', 'resolved', 'closed')) DEFAULT 'new',
    assigned_to UUID REFERENCES public.users(user_id),
    resolution TEXT,
    resolved_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create Messages/Notices table
CREATE TABLE IF NOT EXISTS public.notices (
    notice_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    property_id UUID REFERENCES public.properties(property_id) ON DELETE CASCADE,
    tenant_id UUID REFERENCES public.tenants(tenant_id),
    from_user_id UUID REFERENCES public.users(user_id) ON DELETE CASCADE,
    to_user_id UUID REFERENCES public.users(user_id),
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    notice_type VARCHAR(50) CHECK (notice_type IN ('general', 'maintenance', 'payment', 'lease', 'emergency')) DEFAULT 'general',
    priority VARCHAR(20) CHECK (priority IN ('low', 'medium', 'high', 'urgent')) DEFAULT 'medium',
    is_read BOOLEAN DEFAULT FALSE,
    scheduled_for TIMESTAMP WITH TIME ZONE,
    expires_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create Tenant Agreements table
CREATE TABLE IF NOT EXISTS public.tenant_agreements (
    agreement_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID REFERENCES public.tenants(tenant_id) ON DELETE CASCADE,
    property_id UUID REFERENCES public.properties(property_id) ON DELETE CASCADE,
    agreement_date DATE NOT NULL,
    lease_start_date DATE NOT NULL,
    lease_end_date DATE,
    monthly_rent DECIMAL(10,2) NOT NULL,
    security_deposit DECIMAL(10,2),
    terms_and_conditions TEXT,
    document_url TEXT,
    signed_at TIMESTAMP WITH TIME ZONE,
    status VARCHAR(50) CHECK (status IN ('draft', 'sent', 'signed', 'expired', 'terminated')) DEFAULT 'draft',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create Leads table
CREATE TABLE IF NOT EXISTS public.leads (
    lead_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID REFERENCES public.users(user_id) ON DELETE SET NULL,
    tenant_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20),
    property_type_required VARCHAR(100),
    location_preferred VARCHAR(255),
    price_range_min DECIMAL(10,2),
    price_range_max DECIMAL(10,2),
    additional_requirements TEXT,
    status VARCHAR(50) CHECK (status IN ('new', 'contacted', 'viewing', 'negotiating', 'converted', 'closed')) DEFAULT 'new',
    assigned_broker_id UUID REFERENCES public.users(user_id),
    priority VARCHAR(20) CHECK (priority IN ('low', 'medium', 'high')) DEFAULT 'medium',
    source VARCHAR(50) DEFAULT 'website',
    notes TEXT,
    converted_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create Property Ratings table for better rating management
CREATE TABLE IF NOT EXISTS public.property_ratings (
    rating_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    property_id UUID REFERENCES public.properties(property_id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.users(user_id) ON DELETE CASCADE,
    rating INTEGER CHECK (rating >= 1 AND rating <= 5) NOT NULL,
    review TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(property_id, user_id) -- One rating per user per property
);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Add updated_at triggers
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_properties_updated_at BEFORE UPDATE ON public.properties FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_complaints_updated_at BEFORE UPDATE ON public.complaints FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Enable Row Level Security
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.properties ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tenants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.property_expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.complaints ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notices ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tenant_agreements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.leads ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.property_ratings ENABLE ROW LEVEL SECURITY;

-- RLS Policies for Users
CREATE POLICY "Users can view their own profile" ON public.users
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own profile" ON public.users
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Enable insert for authenticated users" ON public.users
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- RLS Policies for Properties
CREATE POLICY "Anyone can view properties" ON public.properties
    FOR SELECT USING (true);

CREATE POLICY "Property owners can manage their properties" ON public.properties
    FOR ALL USING (auth.uid() = owner_id);

-- RLS Policies for Bookings
CREATE POLICY "Users can view their own bookings" ON public.bookings
    FOR SELECT USING (
        auth.uid() = tenant_id OR 
        auth.uid() IN (SELECT owner_id FROM public.properties WHERE property_id = bookings.property_id)
    );

CREATE POLICY "Tenants can create bookings" ON public.bookings
    FOR INSERT WITH CHECK (auth.uid() = tenant_id);

CREATE POLICY "Property owners and tenants can update bookings" ON public.bookings
    FOR UPDATE USING (
        auth.uid() = tenant_id OR 
        auth.uid() IN (SELECT owner_id FROM public.properties WHERE property_id = bookings.property_id)
    );

-- RLS Policies for Leads
CREATE POLICY "Brokers can view all leads" ON public.leads
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM public.users WHERE user_id = auth.uid() AND user_role = 'broker')
    );

CREATE POLICY "Tenants can create leads" ON public.leads
    FOR INSERT WITH CHECK (auth.uid() = tenant_id);

-- RLS Policies for Complaints
CREATE POLICY "Users can view complaints related to their properties/tenancies" ON public.complaints
    FOR SELECT USING (
        auth.uid() IN (
            SELECT user_id FROM public.tenants WHERE tenant_id = complaints.tenant_id
            UNION
            SELECT owner_id FROM public.properties WHERE property_id = complaints.property_id
        )
    );

CREATE POLICY "Tenants can create complaints" ON public.complaints
    FOR INSERT WITH CHECK (
        auth.uid() IN (SELECT user_id FROM public.tenants WHERE tenant_id = complaints.tenant_id)
    );

-- RLS Policies for Notices
CREATE POLICY "Users can view notices addressed to them" ON public.notices
    FOR SELECT USING (
        auth.uid() = to_user_id OR 
        auth.uid() = from_user_id OR
        auth.uid() IN (SELECT user_id FROM public.tenants WHERE tenant_id = notices.tenant_id)
    );

CREATE POLICY "Property managers can create notices" ON public.notices
    FOR INSERT WITH CHECK (auth.uid() = from_user_id);

-- Create storage buckets
INSERT INTO storage.buckets (id, name, public) VALUES 
    ('property-photos', 'property-photos', true),
    ('profile-photos', 'profile-photos', true),
    ('documents', 'documents', false)
ON CONFLICT (id) DO NOTHING;

-- Storage policies
CREATE POLICY "Anyone can view property photos" ON storage.objects
    FOR SELECT USING (bucket_id = 'property-photos');

CREATE POLICY "Authenticated users can upload property photos" ON storage.objects
    FOR INSERT WITH CHECK (bucket_id = 'property-photos' AND auth.role() = 'authenticated');

CREATE POLICY "Users can view profile photos" ON storage.objects
    FOR SELECT USING (bucket_id = 'profile-photos');

CREATE POLICY "Users can upload their own profile photos" ON storage.objects
    FOR INSERT WITH CHECK (bucket_id = 'profile-photos' AND auth.role() = 'authenticated');

-- Grant permissions
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated;