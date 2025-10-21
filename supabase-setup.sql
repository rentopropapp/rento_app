-- Rento Database Setup for Supabase
-- Copy and paste this into your Supabase SQL Editor

-- Create Users table (extends Supabase auth.users)
CREATE TABLE public.users (
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
CREATE TABLE public.properties (
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
CREATE TABLE public.tenants (
    tenant_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    property_id UUID REFERENCES public.properties(property_id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.users(user_id) ON DELETE CASCADE,
    unit_number VARCHAR(50),
    move_in_date DATE,
    move_out_date DATE,
    payment_due_date INTEGER DEFAULT 1, -- Day of month
    status VARCHAR(20) CHECK (status IN ('active', 'inactive')) DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create Bookings table
CREATE TABLE public.bookings (
    booking_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID REFERENCES public.users(user_id) ON DELETE CASCADE,
    property_id UUID REFERENCES public.properties(property_id) ON DELETE CASCADE,
    viewing_date TIMESTAMP WITH TIME ZONE NOT NULL,
    status VARCHAR(50) CHECK (status IN ('pending', 'confirmed', 'cancelled', 'completed')) DEFAULT 'pending',
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create Payments table
CREATE TABLE public.payments (
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
CREATE TABLE public.property_expenses (
    expense_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    property_id UUID REFERENCES public.properties(property_id) ON DELETE CASCADE,
    expense_name VARCHAR(255) NOT NULL,
    category VARCHAR(100) NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    expense_date DATE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create Complaints table
CREATE TABLE public.complaints (
    complaint_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID REFERENCES public.tenants(tenant_id) ON DELETE CASCADE,
    property_id UUID REFERENCES public.properties(property_id) ON DELETE CASCADE,
    description TEXT NOT NULL,
    status VARCHAR(50) CHECK (status IN ('new', 'in_progress', 'resolved')) DEFAULT 'new',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create Tenant Agreements table
CREATE TABLE public.tenant_agreements (
    agreement_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID REFERENCES public.tenants(tenant_id) ON DELETE CASCADE,
    property_id UUID REFERENCES public.properties(property_id) ON DELETE CASCADE,
    agreement_date DATE NOT NULL,
    lease_start_date DATE NOT NULL,
    lease_end_date DATE,
    terms_and_conditions TEXT,
    document_url TEXT,
    signed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create Leads table
CREATE TABLE public.leads (
    lead_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID REFERENCES public.users(user_id) ON DELETE CASCADE,
    tenant_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20),
    property_type_required VARCHAR(100),
    location_preferred VARCHAR(255),
    price_range_min DECIMAL(10,2),
    price_range_max DECIMAL(10,2),
    additional_requirements TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
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
ALTER TABLE public.tenant_agreements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.leads ENABLE ROW LEVEL SECURITY;

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

-- Insert some sample data for testing (optional)
INSERT INTO public.users (user_id, email, name, phone_number, user_role) VALUES
    ('00000000-0000-0000-0000-000000000001', 'admin@rento.com', 'Admin User', '+1234567890', 'broker');

-- Grant permissions
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated;

-- Create storage bucket for property photos (optional)
INSERT INTO storage.buckets (id, name, public) VALUES ('property-photos', 'property-photos', true);
INSERT INTO storage.buckets (id, name, public) VALUES ('profile-photos', 'profile-photos', true);

-- Storage policies
CREATE POLICY "Anyone can view property photos" ON storage.objects
    FOR SELECT USING (bucket_id = 'property-photos');

CREATE POLICY "Authenticated users can upload property photos" ON storage.objects
    FOR INSERT WITH CHECK (bucket_id = 'property-photos' AND auth.role() = 'authenticated');

CREATE POLICY "Users can view profile photos" ON storage.objects
    FOR SELECT USING (bucket_id = 'profile-photos');

CREATE POLICY "Users can upload their own profile photos" ON storage.objects
    FOR INSERT WITH CHECK (bucket_id = 'profile-photos' AND auth.role() = 'authenticated');