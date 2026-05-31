-- AthletiTrack Database Schema (Supabase PostgreSQL)
-- Ensure 'uuid-ossp' extension is enabled in Supabase

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    role VARCHAR(50) CHECK (role IN ('Coach', 'Athlete')) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Teams table
CREATE TABLE teams (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    coach_id UUID REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    logo_url TEXT,
    team_code VARCHAR(10) UNIQUE NOT NULL,
    category VARCHAR(100),
    skill_level VARCHAR(50) CHECK (skill_level IN ('Beginner', 'Intermediate', 'Expert', NULL)),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Team Members (Athletes joining a Team)
CREATE TABLE team_members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    team_id UUID REFERENCES teams(id) ON DELETE CASCADE,
    athlete_id UUID REFERENCES users(id) ON DELETE CASCADE,
    status VARCHAR(50) CHECK (status IN ('Pending', 'Approved', 'Rejected')) DEFAULT 'Pending',
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(team_id, athlete_id)
);

-- Posts (Announcements and Training Sessions)
CREATE TABLE posts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    team_id UUID REFERENCES teams(id) ON DELETE CASCADE,
    type VARCHAR(50) CHECK (type IN ('Announcement', 'One-Time', 'Weekly')) NOT NULL,
    description TEXT,
    schedule_date DATE, -- For One-Time
    start_time TIME,    -- For One-Time and Weekly
    end_time TIME,      -- For Weekly
    recurring_days VARCHAR(50), -- E.g., 'M,W,F'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Training Proofs (Attendance Tracking)
CREATE TABLE training_proofs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    post_id UUID REFERENCES posts(id) ON DELETE CASCADE,
    athlete_id UUID REFERENCES users(id) ON DELETE CASCADE,
    proof_url TEXT,
    proof_type VARCHAR(50) CHECK (proof_type IN ('Image', 'Video', 'Document', NULL)),
    status VARCHAR(50) CHECK (status IN ('Pending', 'Approved', 'Rejected')) DEFAULT 'Pending',
    is_excuse BOOLEAN DEFAULT FALSE,
    message TEXT,
    coach_note TEXT,
    submitted_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(post_id, athlete_id)
);
