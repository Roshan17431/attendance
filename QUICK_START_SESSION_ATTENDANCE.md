# Quick Start: Session-wise Attendance

## What's New?

Your attendance system now supports **multiple sessions per day**! You can mark attendance up to **10 times per day** for the same subject.

## For Teachers - How to Use

### Step-by-Step Guide

1. **Open the Attendance Tab**
   - Login with your teacher credentials
   - Navigate to the "Attendance" tab

2. **Select Your Session Details**
   - **Subject**: Choose your subject (e.g., Mathematics)
   - **Session**: NEW! Select which session (Session 1 to Session 10)
   - **Class**: Choose the class (S1-S8 or All)
   - **Division**: Choose the division (A-E or All)
   - **Date**: Select the date

3. **Load Students**
   - Click the "🔄 Load Students" button
   - Students matching your filters will appear

4. **Mark Attendance**
   - Set status for each student (Present/Absent/Late/Excused)
   - Click "💾 Save Attendance"

5. **Confirmation**
   - You'll see: "Attendance saved successfully for [date] - Session [X] ([subject])"

### Example: Teaching Math Twice in One Day

**Morning Class:**
- Subject: Mathematics
- Session: Session 1
- Date: Today
- Class: S1, Division: A
- Click "Save Attendance"

**Afternoon Class:**
- Subject: Mathematics  
- Session: Session 5
- Date: Today (same day!)
- Class: S1, Division: A
- Click "Save Attendance"

✅ Both sessions are saved separately without any conflict!

## For Administrators - Database Setup

### New Installation

Simply run the updated schema:
```bash
psql -U postgres -d student_attendance_db -f schema.sql
```

### Existing Installation (Migration Required)

Run the migration script:
```bash
psql -U postgres -d student_attendance_db -f migration_add_session_number.sql
```

Or manually execute:
```sql
ALTER TABLE sessions 
ADD COLUMN session_number INTEGER NOT NULL DEFAULT 1 
CHECK (session_number >= 1 AND session_number <= 10);

ALTER TABLE sessions 
DROP CONSTRAINT IF EXISTS sessions_session_date_subject_id_key;

ALTER TABLE sessions 
ADD CONSTRAINT sessions_session_date_subject_id_session_number_key 
UNIQUE (session_date, subject_id, session_number);
```

## Session Numbering Guide

We recommend establishing a standard session schedule:

### Example School Schedule:
- **Session 1**: 08:00 - 09:00 (Period 1)
- **Session 2**: 09:00 - 10:00 (Period 2)
- **Session 3**: 10:15 - 11:15 (Period 3)
- **Session 4**: 11:15 - 12:15 (Period 4)
- **Session 5**: 13:00 - 14:00 (Period 5)
- **Session 6**: 14:00 - 15:00 (Period 6)
- **Session 7**: 15:15 - 16:15 (Period 7)
- **Session 8**: 16:15 - 17:15 (Period 8)
- **Session 9**: Evening/Extra 1
- **Session 10**: Evening/Extra 2

**Note**: Customize this schedule based on your institution's timetable.

## Reports

### Viewing Reports

Reports now include the session number!

**Report Columns:**
- Date
- Subject
- **Session** (NEW!)
- Student
- Roll No
- Status

This helps you identify exactly which session each attendance record belongs to.

### Exporting Reports

Both CSV and Text exports include the session number:
- CSV: Great for Excel analysis
- Text: Formatted for printing
- Print: Direct printing with session information

## Common Questions

### Q: Do I have to use all 10 sessions?
**A:** No! Use only the session numbers you need. If you have 6 periods, use Sessions 1-6.

### Q: What if I mark the wrong session?
**A:** Currently, you'll need to mark attendance again with the correct session number. The old record will be updated if you use the same date, subject, and session number.

### Q: Can different subjects use the same session number?
**A:** Yes! Session numbers are unique per (date, subject, session number) combination. Math Session 1 and Physics Session 1 on the same day are completely independent.

### Q: What happens to old attendance records?
**A:** After migration, all existing records will have session_number = 1. They remain valid and accessible.

### Q: Can I skip session numbers?
**A:** Yes, but it's not recommended. For consistency, use sequential numbering (1, 2, 3...).

## Benefits

### ✅ Multiple Classes Per Day
Mark attendance for morning and afternoon classes separately.

### ✅ Lab and Lecture Sessions
Differentiate between theory (Session 1) and lab (Session 2) on the same day.

### ✅ Make-up Classes
Use higher session numbers (9, 10) for extra or make-up sessions.

### ✅ Clear Records
Always know which session each attendance belongs to.

### ✅ No Conflicts
Database ensures you can't accidentally duplicate sessions.

## Troubleshooting

### "Duplicate key error" when saving
**Cause**: You've already marked attendance for this exact date, subject, and session.

**Solution**: 
- Check if you selected the correct session number
- If updating, the system will automatically update the existing record
- If marking a new session, choose a different session number

### Session dropdown doesn't show
**Solution**: 
- Refresh the Attendance tab
- Restart the application

### Students don't load
**Solution**:
- Verify students are assigned to the class/division you selected
- Try "All" for both Class and Division to see all students
- Check that subjects are configured in the system

## Technical Details

### What Changed?

1. **Database**: Added `session_number` column to sessions table
2. **UI**: Added session number dropdown with 10 options
3. **Logic**: Updated attendance marking to include session number
4. **Reports**: Enhanced to show which session each record belongs to

### Files Modified:
- `schema.sql` - Database structure
- `com/company/ui/Main.java` - Attendance UI and logic
- `com/company/ui/ReportGenerator.java` - Report display and export

### Files Added:
- `SESSION_WISE_ATTENDANCE.md` - Complete documentation
- `migration_add_session_number.sql` - Database migration
- `QUICK_START_SESSION_ATTENDANCE.md` - This file

## Getting Help

1. Read the full documentation: `SESSION_WISE_ATTENDANCE.md`
2. Check the database schema: `schema.sql`
3. Review migration steps: `migration_add_session_number.sql`
4. Contact your system administrator

## Summary

🎯 **Key Points:**
- Select a session number (1-10) when marking attendance
- Each day can have up to 10 sessions per subject
- Reports show which session each attendance record belongs to
- Existing data remains intact after migration
- No limit on how many subjects can use the same session number

**Enjoy the flexibility of session-wise attendance tracking!** 📚✅
