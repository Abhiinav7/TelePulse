-- Run this in your Supabase SQL Editor

CREATE TABLE IF NOT EXISTS channels (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  logo_url TEXT,
  stream_url TEXT NOT NULL,
  category TEXT,
  language TEXT,
  is_enabled BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- For the initial setup, we will allow anyone to insert and read channels.
-- (In a production app, you would lock down the INSERT policy to only admins)
ALTER TABLE channels ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read-only access" ON channels
  FOR SELECT USING (true);

CREATE POLICY "Allow public insert (temporary for setup)" ON channels
  FOR INSERT WITH CHECK (true);
