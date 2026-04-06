-- Supabase Database Schema for Raksh Health
-- Created: 2026-04-06

-- 1. Users Table (Core account anchor)
CREATE TABLE IF NOT EXISTS public.users (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    auth_id UUID REFERENCES auth.users ON DELETE CASCADE NOT NULL,
    phone_number TEXT UNIQUE,
    raksh_id TEXT UNIQUE NOT NULL, -- Format: RK-XXXXXXXX
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own record" ON public.users
    FOR SELECT USING (auth.uid() = auth_id);

-- 2. Profiles Table (Patients/Family Members)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    raksh_id TEXT UNIQUE NOT NULL,
    full_name TEXT NOT NULL,
    date_of_birth DATE,
    blood_group TEXT,
    gender TEXT,
    health_goal TEXT,
    is_primary BOOLEAN DEFAULT FALSE,
    avatar_url TEXT,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view profiles in their account" ON public.profiles
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE users.id = profiles.user_id AND users.auth_id = auth.uid()
        )
    );

CREATE POLICY "Users can update their account profiles" ON public.profiles
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE users.id = profiles.user_id AND users.auth_id = auth.uid()
        )
    );

-- 2. Medical Documents Table
CREATE TABLE IF NOT EXISTS public.documents (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    profile_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    file_path TEXT NOT NULL,
    file_url TEXT,
    file_name TEXT,
    file_type TEXT,
    file_size_kb INTEGER,
    category TEXT DEFAULT 'Uncategorized', -- e.g., 'Lab Report', 'Prescription', 'Doctor Note'
    ocr_text TEXT,
    extraction_json JSONB,
    extraction_confidence NUMERIC DEFAULT 0.85,
    processing_status TEXT DEFAULT 'pending', -- 'pending', 'ocr_done', 'extracting', 'completed', 'failed'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE public.documents ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own documents" ON public.documents
    FOR SELECT USING (auth.uid() = profile_id);

CREATE POLICY "Users can upload their own documents" ON public.documents
    FOR INSERT WITH CHECK (auth.uid() = profile_id);

CREATE POLICY "Users can delete their own documents" ON public.documents
    FOR DELETE USING (auth.uid() = profile_id);

-- 3. Medicines Table (Extracted or Manual)
CREATE TABLE IF NOT EXISTS public.medicines (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    profile_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    document_id UUID REFERENCES public.documents(id) ON DELETE SET NULL,
    medicine_name TEXT NOT NULL,
    generic_name TEXT,
    dose TEXT,
    frequency TEXT, -- e.g., '1-0-1', 'Once daily'
    timing TEXT, -- e.g., 'Before Food', 'After Food'
    reminder_times TEXT[] DEFAULT '{}', -- e.g., ['08:00', '20:00']
    duration TEXT,
    start_date DATE DEFAULT CURRENT_DATE,
    instructions TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    is_deleted BOOLEAN DEFAULT FALSE,
    reminders_enabled BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE public.medicines ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own medicines" ON public.medicines
    FOR SELECT USING (auth.uid() = profile_id);

CREATE POLICY "Users can manage their own medicines" ON public.medicines
    FOR ALL USING (auth.uid() = profile_id);

-- 4. Lab Results Table (Extracted)
CREATE TABLE IF NOT EXISTS public.lab_results (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    profile_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    document_id UUID REFERENCES public.documents(id) ON DELETE CASCADE,
    test_name TEXT NOT NULL,
    test_value TEXT,
    value_numeric NUMERIC,
    unit TEXT,
    reference_range TEXT,
    ref_low NUMERIC,
    ref_high NUMERIC,
    flag TEXT, -- 'Normal', 'High', 'Low', 'Critical'
    is_critical BOOLEAN DEFAULT FALSE,
    report_date DATE DEFAULT CURRENT_DATE,
    test_date DATE DEFAULT CURRENT_DATE, -- For historical queries
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE public.lab_results ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own lab results" ON public.lab_results
    FOR SELECT USING (auth.uid() = profile_id);

-- Enable Realtime for key tables
ALTER PUBLICATION supabase_realtime ADD TABLE public.profiles;
ALTER PUBLICATION supabase_realtime ADD TABLE public.documents;
ALTER PUBLICATION supabase_realtime ADD TABLE public.medicines;
