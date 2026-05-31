-- AthletiTrack Supabase Schema
-- Run this in your Supabase SQL Editor

-- 1. Users Table
CREATE TABLE users (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    full_name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    role TEXT CHECK (role IN ('Coach', 'Athlete')) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Teams Table
CREATE TABLE teams (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    code TEXT UNIQUE NOT NULL, -- 6 character join code
    name TEXT NOT NULL,
    description TEXT,
    category TEXT,
    skill_level TEXT,
    coach_id UUID REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Team Members (Join Requests & Approved Athletes)
CREATE TABLE team_members (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    team_id UUID REFERENCES teams(id) ON DELETE CASCADE,
    athlete_id UUID REFERENCES users(id) ON DELETE CASCADE,
    status TEXT CHECK (status IN ('pending', 'approved')) DEFAULT 'pending',
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(team_id, athlete_id)
);

-- 4. Posts (Announcements and Training Sessions)
CREATE TABLE posts (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    team_id UUID REFERENCES teams(id) ON DELETE CASCADE,
    type TEXT CHECK (type IN ('announcement', 'training')) NOT NULL,
    title TEXT NOT NULL,
    content TEXT,
    session_date DATE, -- Null for weekly
    session_time TEXT, -- E.g., '15:00 - 17:00'
    is_weekly BOOLEAN DEFAULT FALSE,
    days_of_week TEXT, -- E.g., 'Mon,Wed,Fri'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. Training Proofs
CREATE TABLE proofs (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    post_id UUID REFERENCES posts(id) ON DELETE CASCADE,
    athlete_id UUID REFERENCES users(id) ON DELETE CASCADE,
    file_url TEXT NOT NULL,
    status TEXT CHECK (status IN ('pending', 'approved', 'rejected')) DEFAULT 'pending',
    is_excuse BOOLEAN DEFAULT FALSE,
    comment TEXT,
    coach_note TEXT,
    submitted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create a storage bucket for proofs (Run this manually or via UI if needed)
-- INSERT INTO storage.buckets (id, name, public) VALUES ('proofs', 'proofs', true);

-- Enable RLS and create policies for the storage bucket so images can be uploaded
-- Allow public uploads to the proofs bucket
CREATE POLICY "Allow public uploads to proofs"
ON storage.objects FOR INSERT
WITH CHECK (bucket_id = 'proofs');

-- Allow public to read objects from proofs
CREATE POLICY "Allow public read from proofs"
ON storage.objects FOR SELECT
USING (bucket_id = 'proofs');

-- 6. OTP Requests (Temporary storage for registration verifications)
CREATE TABLE otp_requests (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    full_name TEXT NOT NULL,
    password_hash TEXT NOT NULL,
    role TEXT NOT NULL,
    otp_code TEXT NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
