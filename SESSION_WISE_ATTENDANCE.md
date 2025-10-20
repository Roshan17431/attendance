# Session-wise Attendance Feature

## Overview
This feature enables teachers to mark attendance for multiple sessions within a single day. Each day can have up to 10 sessions, allowing for flexible scheduling and multiple class periods per subject per day.

## Feature Specifications

### Session Options
Teachers can select from:
- Session 1
- Session 2
- Session 3
- Session 4
- Session 5
- Session 6
- Session 7
- Session 8
- Session 9
- Session 10

## Changes Made

### 1. Database Schema (schema.sql)
- Added `session_number` column to the `sessions` table with CHECK constraint (1-10)
- Updated UNIQUE constraint from `(session_date, subject_id)` to `(session_date, subject_id, session_number)`
- This allows multiple sessions per day for the same subject

### 2. User Interface (com/company/ui/Main.java)
#### Attendance Panel
- Added **Session** dropdown with options "Session 1" through "Session 10"
- The dropdown appears between Subject and Class filters
- Teachers must select a session number when marking attendance

#### Attendance Marking Logic
- Updated `markAttendance()` method to include session number
- Session number is extracted from the selected dropdown value
- Session records are now uniquely identified by date, subject, and session number
- Success message now displays the session number

## Database Migration

### For Existing Databases

If you have an existing database with session data, run these migration commands:

```sql
-- Add session_number column with default value
ALTER TABLE sessions 
ADD COLUMN session_number INTEGER NOT NULL DEFAULT 1 
CHECK (session_number >= 1 AND session_number <= 10);

-- Drop old unique constraint
ALTER TABLE sessions 
DROP CONSTRAINT IF EXISTS sessions_session_date_subject_id_key;

-- Add new unique constraint including session_number
ALTER TABLE sessions 
ADD CONSTRAINT sessions_session_date_subject_id_session_number_key 
UNIQUE (session_date, subject_id, session_number);
```

### For Fresh Database Setup

For a new installation, simply run the updated `schema.sql`:

```bash
psql -U postgres -d student_attendance_db -f schema.sql
```

## Usage Guide

### Marking Session-wise Attendance

1. **Login** to the system with teacher or admin credentials

2. **Navigate** to the Attendance tab

3. **Select** your session options:
   - **Subject**: Choose the subject you're teaching
   - **Session**: Select which session (1-10) you're marking attendance for
   - **Class**: Select a specific class (S1-S8) or "All"
   - **Division**: Select a specific division (A-E) or "All"
   - **Date**: Choose the date for attendance

4. **Click** "Load Students" button
   - The table will refresh to show students matching your filters

5. **Mark** attendance for each student:
   - Select status: Present, Absent, Late, or Excused

6. **Click** "Save Attendance" to save records
   - Success message will confirm: "Attendance saved successfully for [date] - Session [X] ([subject])"

### Example Scenarios

#### Scenario 1: Morning mathematics class
```
Subject:  Mathematics
Session:  Session 1
Class:    S1
Division: A
Date:     2024-10-20
```
Result: Marks attendance for S1-A students in Mathematics Session 1

#### Scenario 2: Afternoon physics lab
```
Subject:  Physics
Session:  Session 6
Class:    S2
Division: All
Date:     2024-10-20
```
Result: Marks attendance for all S2 students in Physics Session 6

#### Scenario 3: Multiple sessions same day
Teachers can mark attendance for the same subject multiple times per day by selecting different session numbers:
- Mathematics Session 1 (Morning)
- Mathematics Session 5 (Afternoon)

## Benefits

1. **Flexible Scheduling**: Support for multiple class periods per day
2. **Clear Organization**: Each session is uniquely identified
3. **No Data Conflicts**: Database constraints prevent duplicate sessions
4. **Easy Selection**: Simple dropdown interface for session selection
5. **Scalability**: Up to 10 sessions per day per subject
6. **Detailed Tracking**: Know exactly which session attendance was marked for

## Validation

- Session number values are restricted to integers 1-10
- Database CHECK constraint ensures data integrity
- UNIQUE constraint on (session_date, subject_id, session_number) prevents duplicates
- UI validation ensures session number is always selected

## Technical Details

### Table Structure
```sql
CREATE TABLE sessions (
    session_id SERIAL PRIMARY KEY,
    session_date DATE NOT NULL,
    subject_id INTEGER NOT NULL REFERENCES subjects(subject_id) ON DELETE CASCADE,
    teacher_id INTEGER REFERENCES teachers(teacher_id) ON DELETE SET NULL,
    session_number INTEGER NOT NULL CHECK (session_number >= 1 AND session_number <= 10),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(session_date, subject_id, session_number)
);
```

### UI Components
- `sessionNumberComboBox`: Session selector in Attendance panel (Session 1 to Session 10)
- Positioned between Subject and Class filters for logical flow
- Value is required before saving attendance

### Data Flow
1. Teacher selects session number from dropdown
2. Session number is extracted from "Session X" format
3. System checks for existing session with (date, subject, session_number)
4. If exists, reuses session_id; otherwise creates new session
5. Attendance records are linked to the specific session_id

## Integration with Existing Features

### Compatible Features
- **Class-wise Attendance**: Works seamlessly with class and division filters
- **Reports**: All existing reports continue to work as they join on session_id
- **Dashboards**: Statistics and charts remain functional
- **Multiple Status Options**: Present, Absent, Late, Excused still supported

### Unaffected Components
- ReportGenerator: Uses session_id joins, no changes needed
- DashboardEnhanced: Uses session_id joins, continues to work
- Student/Teacher/Subject Management: Completely independent

## Best Practices

1. **Consistent Numbering**: Establish a school-wide session numbering scheme
   - Example: Sessions 1-4 for morning, 5-8 for afternoon, 9-10 for evening

2. **Session Planning**: Plan which session numbers correspond to which time periods
   - Document your session schedule for teachers

3. **Attendance Marking**: Mark attendance for each session separately
   - Don't skip session numbers unless necessary

4. **Verification**: Double-check the session number before saving
   - Incorrect session numbers can't be easily changed after saving

5. **Reporting**: When generating reports, be aware that one day may have multiple sessions
   - Filter by specific sessions if needed for detailed reports

## Troubleshooting

### Issue: Cannot save attendance - duplicate key error
**Solution**: 
- You've already marked attendance for this date, subject, and session number
- Either select a different session number or update the existing attendance

### Issue: Session dropdown not showing
**Solution**:
- Refresh the Attendance tab
- Restart the application if problem persists

### Issue: Confusion about which session to use
**Solution**:
- Establish a standard session schedule at your institution
- Document which time periods correspond to which session numbers
- Consider posting the session schedule in staff areas

## Future Enhancements

Potential improvements for this feature:
- Session time ranges (e.g., "Session 1: 9:00 AM - 10:00 AM")
- Session name customization (e.g., "Morning Period", "Lab Session")
- Session-specific reports and analytics
- Conflict detection (warning if marking attendance for wrong session)
- Bulk session creation for recurring schedules

## Support

For issues or questions:
1. Check the main README.md for general system information
2. Review schema.sql for database structure details
3. Contact your system administrator

---

**Note**: This feature is backward compatible. Existing attendance data without session numbers will be assigned session_number = 1 by default during migration.
