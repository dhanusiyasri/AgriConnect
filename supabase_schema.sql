-- 🚜 Smart Farm Machinery Booking Platform - Supabase Schema
-- This script sets up the full architecture for the Demo Prototype

-- 1. Users Table
CREATE TABLE IF NOT EXISTS public.users (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  aadhaar_number TEXT,
  role TEXT CHECK (role IN ('farmer', 'owner')),
  verification_status TEXT DEFAULT 'PENDING',
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Demo Aadhaar Verification Trigger
CREATE OR REPLACE FUNCTION verify_demo_aadhaar()
RETURNS TRIGGER AS $$
BEGIN
  IF length(NEW.aadhaar_number) = 12 THEN
    NEW.verification_status = 'VERIFIED_DEMO';
  ELSE
    NEW.verification_status = 'INVALID';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS demo_aadhaar_check ON public.users;
CREATE TRIGGER demo_aadhaar_check
BEFORE INSERT OR UPDATE ON public.users
FOR EACH ROW EXECUTE FUNCTION verify_demo_aadhaar();

-- 2. Equipment Table
CREATE TABLE IF NOT EXISTS public.equipment (
  equipment_id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  owner_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  equipment_name TEXT NOT NULL,
  equipment_type TEXT NOT NULL,
  hourly_price NUMERIC NOT NULL,
  driver_available BOOLEAN DEFAULT false,
  driver_price_per_hour NUMERIC DEFAULT 0,
  location_lat NUMERIC,
  location_lng NUMERIC,
  availability_status TEXT DEFAULT 'AVAILABLE',
  image_url TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 3. Bookings Table
CREATE TABLE IF NOT EXISTS public.bookings (
  booking_id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  farmer_id UUID REFERENCES public.users(id),
  equipment_id UUID REFERENCES public.equipment(equipment_id),
  owner_id UUID REFERENCES public.users(id),
  hours NUMERIC NOT NULL,
  driver_required BOOLEAN DEFAULT false,
  hourly_price NUMERIC NOT NULL,
  driver_price NUMERIC DEFAULT 0,
  total_price NUMERIC NOT NULL,
  status TEXT DEFAULT 'REQUESTED', -- REQUESTED, OWNER_ACCEPTED, REJECTED, PAYMENT_PENDING, CONFIRMED, IN_PROGRESS, COMPLETED, CANCELLED
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 4. Payments Table
CREATE TABLE IF NOT EXISTS public.payments (
  payment_id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  booking_id UUID REFERENCES public.bookings(booking_id),
  amount NUMERIC NOT NULL,
  payment_status TEXT DEFAULT 'PENDING',
  stripe_payment_intent TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 5. Tracking Table
CREATE TABLE IF NOT EXISTS public.tracking (
  tracking_id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  booking_id UUID REFERENCES public.bookings(booking_id),
  equipment_id UUID REFERENCES public.equipment(equipment_id),
  current_lat NUMERIC NOT NULL,
  current_lng NUMERIC NOT NULL,
  timestamp TIMESTAMPTZ DEFAULT now()
);

-- 6. Insurance Claims Table
CREATE TABLE IF NOT EXISTS public.insurance_claims (
  claim_id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  booking_id UUID REFERENCES public.bookings(booking_id),
  equipment_id UUID REFERENCES public.equipment(equipment_id),
  damage_description TEXT NOT NULL,
  damage_images TEXT[],
  claim_status TEXT DEFAULT 'REPORTED',
  insurance_provider TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 7. Reviews Table
CREATE TABLE IF NOT EXISTS public.reviews (
  review_id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  booking_id UUID REFERENCES public.bookings(booking_id),
  reviewer_id UUID REFERENCES public.users(id),
  reviewee_id UUID REFERENCES public.users(id),
  rating NUMERIC CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 8. Notifications Table
CREATE TABLE IF NOT EXISTS public.notifications (
  notification_id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Enable Row Level Security (RLS)
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.equipment ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tracking ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.insurance_claims ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- Setup Basic Test/Demo RLS Policies

-- Users
DROP POLICY IF EXISTS "Users can view all users" ON public.users;
CREATE POLICY "Users can view all users" ON public.users FOR SELECT USING (true);

DROP POLICY IF EXISTS "Users can update own profile" ON public.users;
CREATE POLICY "Users can update own profile" ON public.users FOR UPDATE USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users can insert own profile" ON public.users;
CREATE POLICY "Users can insert own profile" ON public.users FOR INSERT WITH CHECK (auth.uid() = id);

-- Equipment
DROP POLICY IF EXISTS "Equipment visible to everyone" ON public.equipment;
CREATE POLICY "Equipment visible to everyone" ON public.equipment FOR SELECT USING (true);

DROP POLICY IF EXISTS "Owners can insert their equipment" ON public.equipment;
CREATE POLICY "Owners can insert their equipment" ON public.equipment FOR INSERT WITH CHECK (auth.uid() = owner_id);

DROP POLICY IF EXISTS "Owners can update their equipment" ON public.equipment;
CREATE POLICY "Owners can update their equipment" ON public.equipment FOR UPDATE USING (auth.uid() = owner_id);

DROP POLICY IF EXISTS "Owners can delete their equipment" ON public.equipment;
CREATE POLICY "Owners can delete their equipment" ON public.equipment FOR DELETE USING (auth.uid() = owner_id);

-- Bookings
DROP POLICY IF EXISTS "Bookings visible to farmer and owner" ON public.bookings;
CREATE POLICY "Bookings visible to farmer and owner" ON public.bookings FOR SELECT USING (auth.uid() = farmer_id OR auth.uid() = owner_id);

DROP POLICY IF EXISTS "Farmers can create bookings" ON public.bookings;
CREATE POLICY "Farmers can create bookings" ON public.bookings FOR INSERT WITH CHECK (auth.uid() = farmer_id);

DROP POLICY IF EXISTS "Owners can update bookings" ON public.bookings;
CREATE POLICY "Owners can update bookings" ON public.bookings FOR UPDATE USING (auth.uid() = owner_id OR auth.uid() = farmer_id);

-- Turn on Realtime for tracking and bookings tables
begin;
  drop publication if exists supabase_realtime;
  create publication supabase_realtime;
commit;
alter publication supabase_realtime add table bookings;
alter publication supabase_realtime add table tracking;
alter publication supabase_realtime add table notifications;
