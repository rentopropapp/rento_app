-- Rento Database Setup for Supabase (Simplified)
-- Run this script in your Supabase SQL Editor

-- Step 1: Create Users table
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

-- Step 2: Create Properties table
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

-- Step 3: Create Bookings table
CREATE TABLE IF NOT EXISTS public.bookings (
    booking_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID REFERENCES public.users(user_id) ON DELETE CASCADE,
    property_id UUID REFERENCES public.properties(property_id) ON DELETE CASCADE,
    viewing_date TIMESTAMP WITH TIME ZONE NOT NULL,
    status VARCHAR(50) CHECK (status IN ('pending', 'confirmed', 'cancelled', 'completed')) DEFAULT 'pending',
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Step 4: Create Leads table
CREATE TABLE IF NOT EXISTS public.leads (
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

-- Step 5: Create Payments table
CREATE TABLE IF NOT EXISTS public.payments (
    payment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID,
    property_id UUID REFERENCES public.properties(property_id) ON DELETE CASCADE,
    amount DECIMAL(10,2) NOT NULL,
    payment_date DATE NOT NULL,
    payment_type VARCHAR(50) CHECK (payment_type IN ('rent', 'viewing_fee', 'deposit', 'utilities')) NOT NULL,
    status VARCHAR(50) CHECK (status IN ('completed', 'pending', 'failed')) DEFAULT 'pending',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Step 6: Create Complaints table
CREATE TABLE IF NOT EXISTS public.complaints (
    complaint_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID,
    property_id UUID REFERENCES public.properties(property_id) ON DELETE CASCADE,
    description TEXT NOT NULL,
    status VARCHAR(50) CHECK (status IN ('new', 'in_progress', 'resolved')) DEFAULT 'new',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Step 7: Enable RLS on tables
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.properties ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.leads ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.complaints ENABLE ROW LEVEL SECURITY;

-- Step 8: Create basic policies
CREATE POLICY "Users can view their own profile" ON public.users
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own profile" ON public.users
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Enable insert for authenticated users" ON public.users
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Anyone can view properties" ON public.properties
    FOR SELECT USING (true);

CREATE POLICY "Property owners can manage their properties" ON public.properties
    FOR ALL USING (auth.uid() = owner_id);

CREATE POLICY "Users can view their own bookings" ON public.bookings
    FOR SELECT USING (
        auth.uid() = tenant_id OR 
        auth.uid() IN (SELECT owner_id FROM public.properties WHERE property_id = bookings.property_id)
    );

CREATE POLICY "Tenants can create bookings" ON public.bookings
    FOR INSERT WITH CHECK (auth.uid() = tenant_id);

CREATE POLICY "Tenants can create leads" ON public.leads
    FOR INSERT WITH CHECK (auth.uid() = tenant_id);

-- Step 9: Grant permissions
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated;