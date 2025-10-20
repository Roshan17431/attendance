-- Migration script to add session_number support to existing database
-- Run this script if you already have a database with attendance data

-- Step 1: Add session_number column with default value 1
ALTER TABLE sessions 
ADD COLUMN IF NOT EXISTS session_number INTEGER NOT NULL DEFAULT 1 
CHECK (session_number >= 1 AND session_number <= 10);

-- Step 2: Drop old unique constraint
ALTER TABLE sessions 
DROP CONSTRAINT IF EXISTS sessions_session_date_subject_id_key;

-- Step 3: Add new unique constraint including session_number
ALTER TABLE sessions 
ADD CONSTRAINT sessions_session_date_subject_id_session_number_key 
UNIQUE (session_date, subject_id, session_number);

-- Verify the changes
SELECT column_name, data_type, character_maximum_length, is_nullable
FROM information_schema.columns
WHERE table_name = 'sessions'
ORDER BY ordinal_position;

-- Display existing sessions with their new session_number
SELECT session_id, session_date, subject_id, session_number, created_at
FROM sessions
ORDER BY session_date DESC, subject_id, session_number
LIMIT 20;

COMMIT;
