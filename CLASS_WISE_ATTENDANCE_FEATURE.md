# Class-wise Attendance Marking Feature

## Overview
This feature enables teachers to mark attendance for specific classes and divisions, making attendance management more organized and efficient.

## Feature Specifications

### Class Options
- S1, S2, S3, S4, S5, S6, S7, S8 (Semesters 1-8)

### Division Options
- A, B, C, D, E

## Changes Made

### 1. Database Schema (schema.sql)
- Added `class` column with CHECK constraint for S1-S8
- Added `division` column with CHECK constraint for A-E
- Updated sample data with class and division assignments

### 2. Student Model (com/company/models/Student.java)
- Added `studentClass` and `division` fields
- Added getter and setter methods
- Updated constructor

### 3. Student DAO (com/company/dao/StudentDAO.java)
- Updated CRUD operations to handle class and division
- Added `getStudentsByClassAndDivision()` method for filtering

### 4. User Interface (com/company/ui/Main.java)
#### Student Management Panel
- Added Class dropdown (S1-S8)
- Added Division dropdown (A-E)
- Updated student table to display class and division columns
- Form auto-populates class/division when selecting a student

#### Attendance Panel
- Added Class filter dropdown (All, S1-S8)
- Added Division filter dropdown (All, A-E)
- Added "Load Students" button to apply filters
- Attendance table displays class and division for each student
- Teachers can filter students before marking attendance

## Usage Guide

### Adding/Editing Students
1. Navigate to **Students** tab
2. Fill in student details (Name, Roll Number, Email, Phone)
3. Select **Class** (S1-S8)
4. Select **Division** (A-E)
5. Click **Add** or **Update**

### Marking Class-wise Attendance
1. Navigate to **Attendance** tab
2. Select **Subject** from dropdown
3. Select **Class** (choose specific class or "All")
4. Select **Division** (choose specific division or "All")
5. Click **Load Students** button
6. The table will show only students matching the selected class/division
7. Mark attendance status for each student (Present/Absent/Late/Excused)
8. Click **Save Attendance**

## Benefits

1. **Organized Management**: Students are organized by class and division
2. **Efficient Marking**: Teachers can mark attendance for specific classes only
3. **Better Filtering**: Easy to view and manage students by class and division
4. **Scalability**: Supports up to 8 semesters and 5 divisions per semester

## Database Migration

If you have existing data, you'll need to:
1. Update the students table with the new columns
2. Optionally assign class and division to existing students
3. Re-run the schema.sql or execute:

```sql
ALTER TABLE students ADD COLUMN class VARCHAR(10) CHECK (class IN ('S1', 'S2', 'S3', 'S4', 'S5', 'S6', 'S7', 'S8'));
ALTER TABLE students ADD COLUMN division VARCHAR(1) CHECK (division IN ('A', 'B', 'C', 'D', 'E'));
```

## Validation

- Class values are restricted to: S1, S2, S3, S4, S5, S6, S7, S8
- Division values are restricted to: A, B, C, D, E
- Both fields are optional (can be NULL)
- Database constraints ensure data integrity

## Technical Details

### Table Structure
```sql
CREATE TABLE students (
    student_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    student_roll VARCHAR(20) UNIQUE NOT NULL,
    email VARCHAR(100),
    phone VARCHAR(20),
    photo_path VARCHAR(255),
    class VARCHAR(10) CHECK (class IN ('S1', 'S2', 'S3', 'S4', 'S5', 'S6', 'S7', 'S8')),
    division VARCHAR(1) CHECK (division IN ('A', 'B', 'C', 'D', 'E')),
    user_id INTEGER REFERENCES users(user_id) ON DELETE SET NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### UI Components
- `studentClassComboBox`: Class selector in Student Management
- `studentDivisionComboBox`: Division selector in Student Management
- `attendanceClassComboBox`: Class filter in Attendance
- `attendanceDivisionComboBox`: Division filter in Attendance

## Future Enhancements

Potential improvements for this feature:
- Auto-populate class/division based on roll number pattern
- Bulk assignment of class/division
- Class-wise reports and analytics
- Timetable integration with class and division
