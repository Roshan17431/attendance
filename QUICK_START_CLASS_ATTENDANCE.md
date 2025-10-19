# Quick Start: Class-wise Attendance Marking

## For Database Administrators

### Update Existing Database
If you have an existing database, run these commands:

```sql
-- Add class and division columns to students table
ALTER TABLE students 
ADD COLUMN class VARCHAR(10) CHECK (class IN ('S1', 'S2', 'S3', 'S4', 'S5', 'S6', 'S7', 'S8')),
ADD COLUMN division VARCHAR(1) CHECK (division IN ('A', 'B', 'C', 'D', 'E'));
```

### Fresh Database Setup
For a new installation, simply run the updated `schema.sql`:

```bash
psql -U postgres -d student_attendance_db -f schema.sql
```

## For Teachers

### How to Mark Class-wise Attendance

1. **Login** to the system with your teacher credentials

2. **Navigate** to the Attendance tab

3. **Select** your filtering options:
   - **Subject**: Choose the subject you're teaching
   - **Class**: Select a specific class (S1-S8) or "All" for all classes
   - **Division**: Select a specific division (A-E) or "All" for all divisions
   - **Date**: Choose the date for attendance

4. **Click** "Load Students" button
   - The table will refresh to show only students matching your filters
   - Example: Selecting Class=S1, Division=A shows only S1-A students

5. **Mark** attendance for each student:
   - Click on the Status dropdown for each student
   - Select: Present, Absent, Late, or Excused

6. **Click** "Save Attendance" to save all attendance records

### Example Scenarios

#### Scenario 1: Mark attendance for a single class
```
Subject:  Mathematics
Class:    S1
Division: All
Date:     2024-10-19
```
Result: Shows all students from S1 (all divisions A, B, C, D, E)

#### Scenario 2: Mark attendance for a specific division
```
Subject:  Physics
Class:    S2
Division: A
Date:     2024-10-19
```
Result: Shows only students from S2-A

#### Scenario 3: Mark attendance for all students
```
Subject:  English
Class:    All
Division: All
Date:     2024-10-19
```
Result: Shows all students from all classes and divisions

## For Administrators

### Adding Students with Class and Division

1. **Navigate** to the Students tab

2. **Fill in** student details:
   - First Name
   - Last Name
   - Roll Number (required, unique)
   - Email
   - Phone
   - **Class**: Select from S1-S8
   - **Division**: Select from A-E

3. **Click** "Add" to save the student

### Updating Student Class/Division

1. **Select** a student from the table (click on the row)
2. **Modify** the Class or Division dropdown
3. **Click** "Update" to save changes

### Viewing Student Organization

The student table now displays Class and Division columns, allowing you to:
- Sort students by class and division
- Quickly identify which class a student belongs to
- Verify proper class assignments

## Tips and Best Practices

1. **Always click "Load Students"** after changing class/division filters
   - This ensures you're viewing the correct student list

2. **Use specific filters** for efficiency
   - Filtering to a specific class/division reduces the student list
   - Makes attendance marking faster and less error-prone

3. **Verify the student count** before saving attendance
   - Check that the number of students shown matches your expected class size

4. **Save frequently** when marking attendance
   - Consider saving after marking each class/division

5. **Use "All" option** when needed
   - Useful for combined classes or special sessions
   - View all students across classes/divisions

## Troubleshooting

### Issue: Students not showing after clicking "Load Students"
**Solution**: 
- Verify students have been assigned a class and division
- Check that you selected the correct class/division filters
- Ensure students exist for the selected class/division combination

### Issue: Cannot save attendance
**Solution**:
- Verify you have teacher or admin role
- Ensure a subject is selected
- Check that the date is valid
- Confirm at least one student is in the table

### Issue: Class/Division dropdowns are empty
**Solution**:
- These are fixed dropdowns with S1-S8 and A-E options
- If they appear empty, try refreshing the page or restarting the application

## Database Validation

The system enforces data integrity:

- **Class values**: Only S1, S2, S3, S4, S5, S6, S7, S8 are allowed
- **Division values**: Only A, B, C, D, E are allowed
- **Null values**: Both class and division can be empty/null
- **Database constraints**: Prevent invalid values from being saved

## Support

For issues or questions:
1. Check the main README.md for general system information
2. Review CLASS_WISE_ATTENDANCE_FEATURE.md for technical details
3. Contact your system administrator
