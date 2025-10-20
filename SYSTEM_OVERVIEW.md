# Student Attendance System - Quick System Overview

## 🎯 Purpose
This document provides a high-level overview of how the Student Attendance Management System connects all components together. For detailed explanations, see [DATABASE_AND_INTEGRATION_GUIDE.md](doc/DATABASE_AND_INTEGRATION_GUIDE.md).

---

## 🏗️ System Architecture (3-Layer)

```
┌─────────────────────────────────────────────────┐
│         PRESENTATION LAYER (Java Swing)         │
│  - Login Panel, Student Panel, Teacher Panel    │
│  - Attendance Panel, Report Panel, User Panel   │
│  - Subject Panel, Dashboard                     │
└────────────────┬────────────────────────────────┘
                 │
                 │ User Events (clicks, input)
                 ▼
┌─────────────────────────────────────────────────┐
│          BUSINESS LOGIC LAYER (DAO)             │
│  - StudentDAO, TeacherDAO, SubjectDAO           │
│  - UserDAO, DatabaseManager                     │
│  - ValidationUtil, PasswordUtil                 │
└────────────────┬────────────────────────────────┘
                 │
                 │ JDBC Calls
                 ▼
┌─────────────────────────────────────────────────┐
│      DATA LAYER (PostgreSQL Database)           │
│  - users, students, teachers, subjects          │
│  - sessions, attendance                         │
└─────────────────────────────────────────────────┘
```

---

## 🔗 How Components Connect

### 1. Database Connection (JDBC)

**DatabaseManager.java** → Centralized connection management

```java
// How it works:
1. Load db.properties (URL, username, password)
2. Load PostgreSQL JDBC driver: Class.forName("org.postgresql.Driver")
3. Create connection: DriverManager.getConnection(URL, USER, PASSWORD)
4. Return connection to DAO
```

**Connection String**: `jdbc:postgresql://localhost:5432/student_attendance_db`

---

### 2. Data Access Objects (DAO Pattern)

Each entity has a DAO class that handles all database operations:

| DAO Class    | Database Table | Operations                          |
|--------------|----------------|-------------------------------------|
| StudentDAO   | students       | CRUD, search, filter by class/div  |
| TeacherDAO   | teachers       | CRUD, search                       |
| SubjectDAO   | subjects       | CRUD                               |
| UserDAO      | users          | CRUD, authentication               |

**DAO Method Pattern**:
```java
public void addStudent(Student student) throws SQLException {
    // 1. Get connection
    Connection conn = DatabaseManager.getConnection();
    
    // 2. Prepare SQL
    String sql = "INSERT INTO students(...) VALUES(?,?,?)";
    PreparedStatement stmt = conn.prepareStatement(sql);
    
    // 3. Set parameters
    stmt.setString(1, student.getFirstName());
    stmt.setString(2, student.getLastName());
    // ...
    
    // 4. Execute
    stmt.executeUpdate();
}
```

---

### 3. UI Panel Integration

Each panel follows this flow:

```
User Action (button click)
    ↓
Event Handler (in Main.java)
    ↓
Validate Input (ValidationUtil)
    ↓
Create/Update Model Object (Student, Teacher, etc.)
    ↓
Call DAO Method (dao.addStudent(), dao.updateTeacher(), etc.)
    ↓
DAO Executes SQL Query (via JDBC)
    ↓
Database Processes Query
    ↓
DAO Returns Result
    ↓
UI Updates (refresh table, show message, clear form)
```

---

## 📋 Panel-by-Panel Summary

### 1. Login Panel
- **Purpose**: Authenticate users
- **Database**: `users` table
- **Key Flow**: Username/Password → UserDAO → Verify → Load role-based UI

### 2. Student Panel
- **Purpose**: Manage student records
- **Database**: `students` table
- **Operations**: Add, Update, Delete, Search students
- **DAO Methods**: `addStudent()`, `updateStudent()`, `deleteStudent()`, `getAllStudents()`

### 3. Teacher Panel
- **Purpose**: Manage teacher records
- **Database**: `teachers` table
- **Operations**: Add, Update, Delete teachers
- **DAO Methods**: `addTeacher()`, `updateTeacher()`, `deleteTeacher()`, `getAllTeachers()`

### 4. Subject Panel
- **Purpose**: Manage subjects/courses
- **Database**: `subjects` table
- **Operations**: Add, Delete subjects
- **DAO Methods**: `addSubject()`, `deleteSubject()`, `getAllSubjects()`

### 5. Attendance Panel
- **Purpose**: Mark attendance for class sessions
- **Database**: `sessions`, `attendance` tables
- **Key Flow**:
  1. Select subject, date, session number, class, division
  2. Load students (StudentDAO)
  3. Mark attendance status for each student
  4. Create/get session → Insert attendance records

### 6. Report Panel
- **Purpose**: Generate attendance reports
- **Database**: Complex JOIN across `attendance`, `students`, `sessions`, `subjects`
- **Features**: 
  - Filter by student, subject, status, date range
  - Export to CSV, Text, or Print
  - Calculate statistics (present %, absent %, etc.)

### 7. User Panel
- **Purpose**: Manage user accounts (Admin only)
- **Database**: `users` table
- **Operations**: Create user, Delete user
- **Security**: Passwords hashed with SHA-256

---

## 🔄 Complete Data Flow Example

### Example: Adding a Student

```
1. USER ACTION
   Admin fills form: "John Doe", roll="STU021", class="S1", division="A"
   Clicks "Add Student" button
   ↓
2. UI LAYER (Main.java)
   addStudentBtn.addActionListener() triggered
   Collect data from text fields
   Validate using ValidationUtil
   ↓
3. MODEL LAYER
   Create Student object:
   Student student = new Student();
   student.setFirstName("John");
   student.setLastName("Doe");
   student.setStudentRoll("STU021");
   // ... set other fields
   ↓
4. DAO LAYER (StudentDAO.java)
   StudentDAO dao = new StudentDAO();
   dao.addStudent(student);
   ↓
5. DATABASE CONNECTION
   Connection conn = DatabaseManager.getConnection();
   - Loads PostgreSQL driver
   - Creates JDBC connection
   ↓
6. SQL EXECUTION
   PreparedStatement stmt = conn.prepareStatement(
     "INSERT INTO students (first_name, last_name, student_roll, ...) 
      VALUES (?, ?, ?, ...)"
   );
   stmt.setString(1, "John");
   stmt.setString(2, "Doe");
   stmt.setString(3, "STU021");
   stmt.executeUpdate();
   ↓
7. POSTGRESQL DATABASE
   - Validates constraints (UNIQUE student_roll)
   - Generates student_id (e.g., 21)
   - Inserts row into students table
   - Returns success
   ↓
8. UI UPDATE
   - Show success message: "Student added successfully"
   - Call loadStudents() to refresh table
   - Clear form fields
   - User sees new student in table
```

---

## 🗃️ Database Schema

### Tables and Relationships

```
users (authentication)
  ↓ (user_id FK)
  ├─→ students (student info)
  └─→ teachers (teacher info)

subjects (course info)
  ↓ (subject_id FK)
  sessions (class sessions)
    ↓ (session_id FK)
    attendance (attendance records)
      ↑ (student_id FK)
    students
```

### Key Tables

1. **users**: user_id, username, password (hashed), role
2. **students**: student_id, first_name, last_name, student_roll, email, class, division
3. **teachers**: teacher_id, first_name, last_name, email
4. **subjects**: subject_id, subject_name, subject_code
5. **sessions**: session_id, session_date, subject_id, teacher_id, session_number
6. **attendance**: attendance_id, student_id, session_id, status (Present/Absent/Late/Excused)

---

## 🔐 Security Features

1. **Password Security**:
   - SHA-256 hashing with salt (PasswordUtil.java)
   - Plain text passwords never stored

2. **SQL Injection Prevention**:
   - All queries use PreparedStatement
   - Parameters never concatenated into SQL

3. **Input Validation**:
   - ValidationUtil validates emails, required fields
   - Client-side and server-side checks

4. **Role-Based Access**:
   - Admin: Full access to all panels
   - Teacher: Attendance marking and reports
   - Student: View own attendance only

---

## 🛠️ Key Technologies

- **Frontend**: Java Swing (JFrame, JPanel, JTable, JButton, etc.)
- **Backend**: Java SE (DAO pattern, JDBC)
- **Database**: PostgreSQL 12+
- **Driver**: PostgreSQL JDBC Driver
- **Security**: SHA-256 password hashing
- **Architecture**: 3-Layer (Presentation, Business Logic, Data)

---

## 📊 Data Flow Types

### READ Operations (SELECT)
```
UI → DAO.getAll() → DatabaseManager.getConnection() → 
PreparedStatement → executeQuery() → ResultSet → 
Map to Model → Return List → Update UI Table
```

### WRITE Operations (INSERT/UPDATE/DELETE)
```
UI Form → Validate → Create Model → DAO.add/update/delete() →
DatabaseManager.getConnection() → PreparedStatement →
Set Parameters → executeUpdate() → Database Modifies Table →
Return Success → Refresh UI
```

---

## 📚 Documentation

For detailed explanations, code examples, and diagrams:
- **Comprehensive Guide**: [doc/DATABASE_AND_INTEGRATION_GUIDE.md](doc/DATABASE_AND_INTEGRATION_GUIDE.md)
- **Architecture**: [doc/ARCHITECTURE.md](doc/ARCHITECTURE.md)
- **Features**: [doc/NEW_FEATURES.md](doc/NEW_FEATURES.md)

---

## 🎯 Quick Reference

| Need to...                    | Look at...                           |
|-------------------------------|--------------------------------------|
| Understand database connection| DatabaseManager.java                 |
| See how to query database     | Any DAO class (StudentDAO, etc.)    |
| Understand UI event handling  | Main.java event listeners            |
| Learn about data models       | com/company/models/ package          |
| See database schema           | schema.sql                           |
| Configure database            | db.properties                        |

---

## ✅ Summary

The Student Attendance System is a **3-layer Java Swing application** that uses:
- **JDBC** to connect to **PostgreSQL** database
- **DAO pattern** to separate database logic from UI
- **PreparedStatements** for secure SQL execution
- **Model objects** to represent database entities
- **Event-driven UI** for user interactions

All components are connected through well-defined interfaces, making the system maintainable, secure, and scalable.

