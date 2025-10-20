# Database Connections and Frontend-Backend Integration Guide

## Table of Contents
1. [Overview](#overview)
2. [Database Architecture](#database-architecture)
3. [JDBC Connection Management](#jdbc-connection-management)
4. [Frontend-Backend Integration](#frontend-backend-integration)
5. [Panel-by-Panel Integration](#panel-by-panel-integration)
6. [Data Flow Diagrams](#data-flow-diagrams)
7. [Complete Flow Examples](#complete-flow-examples)

---

## Overview

This Student Attendance Management System is built using:
- **Frontend**: Java Swing (GUI)
- **Backend Logic**: Java DAO Pattern
- **Database**: PostgreSQL
- **Connector**: JDBC (PostgreSQL JDBC Driver)

The application follows a layered architecture pattern with clear separation between presentation (UI), business logic (DAOs), and data persistence (Database).

---

## Database Architecture

### Database Schema

The system uses PostgreSQL with the following tables:

```
┌─────────────────────────────────────────────────────────────┐
│                    DATABASE SCHEMA                           │
│                  (student_attendance_db)                     │
└─────────────────────────────────────────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
   ┌────▼────┐          ┌────▼────┐          ┌────▼────┐
   │  users  │          │teachers │          │students │
   └────┬────┘          └────┬────┘          └────┬────┘
        │                    │                     │
        │                    │                     │
        └────────┬───────────┴──────────┬──────────┘
                 │                      │
            ┌────▼────┐            ┌───▼──────┐
            │subjects │            │sessions  │
            └────┬────┘            └────┬─────┘
                 │                      │
                 └──────────┬───────────┘
                            │
                       ┌────▼─────┐
                       │attendance│
                       └──────────┘
```

### Table Relationships

1. **users** → Primary authentication table
   - Columns: user_id, username, password, role, created_at
   - Roles: Admin, Teacher, Student

2. **students** → Student information
   - Foreign Key: user_id → users(user_id)
   - Columns: student_id, first_name, last_name, student_roll, email, phone, class, division

3. **teachers** → Teacher information
   - Foreign Key: user_id → users(user_id)
   - Columns: teacher_id, first_name, last_name, email, phone

4. **subjects** → Course/subject data
   - Columns: subject_id, subject_name, subject_code, description

5. **sessions** → Class sessions
   - Foreign Keys: subject_id → subjects(subject_id), teacher_id → teachers(teacher_id)
   - Columns: session_id, session_date, session_number

6. **attendance** → Attendance records
   - Foreign Keys: student_id → students(student_id), session_id → sessions(session_id)
   - Columns: attendance_id, status (Present/Absent/Late/Excused), marked_at

---

## JDBC Connection Management

### DatabaseManager Class

The `DatabaseManager.java` class provides centralized database connection management:

```java
// Location: com/company/db/DatabaseManager.java

┌──────────────────────────────────────────────────────┐
│              DatabaseManager.java                     │
├──────────────────────────────────────────────────────┤
│  Static Configuration:                                │
│  - URL: jdbc:postgresql://localhost:5432/db_name     │
│  - USER: Database username                            │
│  - PASSWORD: Database password                        │
│                                                        │
│  Static Block:                                        │
│  - Loads db.properties file                           │
│  - Overrides defaults if file exists                  │
│                                                        │
│  getConnection() Method:                              │
│  1. Load PostgreSQL JDBC Driver                       │
│  2. Create connection using DriverManager             │
│  3. Return Connection object                          │
│  4. Throw SQLException on failure                     │
└──────────────────────────────────────────────────────┘
```

### Connection Flow

```
Application Startup
       │
       ▼
┌─────────────────┐
│ Static Block    │ → Load db.properties
│ Initialization  │ → Set URL, USER, PASSWORD
└────────┬────────┘
         │
         ▼
┌─────────────────────────────────────────────┐
│  When DAO needs database access:            │
│                                              │
│  Connection conn =                           │
│      DatabaseManager.getConnection();       │
└────────┬────────────────────────────────────┘
         │
         ▼
┌─────────────────┐
│ Class.forName() │ → Load org.postgresql.Driver
└────────┬────────┘
         │
         ▼
┌─────────────────────────────┐
│ DriverManager.getConnection │ → Create JDBC Connection
│   (URL, USER, PASSWORD)     │
└────────┬────────────────────┘
         │
         ▼
┌─────────────────┐
│ Return Connection│ → DAO uses this connection
└─────────────────┘
```

### Connection Properties

Configuration file: `db.properties`

```properties
db.url=jdbc:postgresql://localhost:5432/student_attendance_db
db.user=postgres
db.password=your_password
```

### JDBC Driver Loading

```java
try {
    // Step 1: Load PostgreSQL JDBC Driver class
    Class.forName("org.postgresql.Driver");
    
    // Step 2: Establish connection
    Connection conn = DriverManager.getConnection(URL, USER, PASSWORD);
    
    // Step 3: Connection ready for use
    return conn;
    
} catch (ClassNotFoundException e) {
    // Driver not in classpath
    throw new SQLException("PostgreSQL JDBC Driver not found");
}
```

---

## Frontend-Backend Integration

### Three-Layer Architecture

```
┌───────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                      │
│                   (Java Swing UI)                          │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐        │
│  │ Login   │ │Student  │ │Teacher  │ │Attendance│  ...   │
│  │ Panel   │ │ Panel   │ │ Panel   │ │  Panel   │        │
│  └────┬────┘ └────┬────┘ └────┬────┘ └────┬─────┘        │
└───────┼──────────┼──────────┼──────────┼─────────────────┘
        │          │          │          │
        │   Event Handlers & UI Logic   │
        │          │          │          │
┌───────▼──────────▼──────────▼──────────▼─────────────────┐
│                    BUSINESS LAYER                          │
│                   (DAO Classes)                            │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐        │
│  │UserDAO  │ │StudentDAO│ │TeacherDAO│ │SubjectDAO│       │
│  └────┬────┘ └────┬────┘ └────┬────┘ └────┬─────┘        │
└───────┼──────────┼──────────┼──────────┼─────────────────┘
        │          │          │          │
        │   SQL Queries & PreparedStatements
        │          │          │          │
┌───────▼──────────▼──────────▼──────────▼─────────────────┐
│                 PERSISTENCE LAYER                          │
│              (PostgreSQL Database)                         │
│  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐            │
│  │ users  │ │students│ │teachers│ │subjects│  ...        │
│  │ table  │ │ table  │ │ table  │ │ table  │            │
│  └────────┘ └────────┘ └────────┘ └────────┘            │
└───────────────────────────────────────────────────────────┘
```

### DAO Pattern Implementation

Each DAO class encapsulates database operations for a specific entity:

```
┌─────────────────────────────────────────────┐
│            DAO Pattern Structure             │
├─────────────────────────────────────────────┤
│                                              │
│  UI Component                                │
│       │                                      │
│       │ calls method                         │
│       ▼                                      │
│  DAO Method (e.g., addStudent)              │
│       │                                      │
│       │ 1. Get Connection                    │
│       │    DatabaseManager.getConnection()  │
│       │                                      │
│       │ 2. Create PreparedStatement         │
│       │    conn.prepareStatement(SQL)       │
│       │                                      │
│       │ 3. Set Parameters                    │
│       │    stmt.setString(1, value)         │
│       │                                      │
│       │ 4. Execute Query                     │
│       │    stmt.executeUpdate()             │
│       │    OR stmt.executeQuery()           │
│       │                                      │
│       │ 5. Process ResultSet (if SELECT)    │
│       │    while(rs.next()) {...}           │
│       │                                      │
│       │ 6. Map to Model Object              │
│       │    mapResultSetToStudent(rs)        │
│       │                                      │
│       │ 7. Close Resources                   │
│       │    (try-with-resources)             │
│       │                                      │
│       ▼                                      │
│  Return Result to UI                         │
└─────────────────────────────────────────────┘
```

---

## Panel-by-Panel Integration

### 1. Login Panel Integration

**Purpose**: Authenticate users and determine their role

```
┌────────────────────────────────────────────────────────────┐
│                    LOGIN PANEL FLOW                         │
└────────────────────────────────────────────────────────────┘

User enters credentials
       │
       ▼
┌──────────────────┐
│  usernameField   │ ──┐
│  passwordField   │   │ UI Components
│  roleComboBox    │   │ (Java Swing)
└──────┬───────────┘ ──┘
       │
       │ User clicks Login button
       ▼
┌──────────────────────────────────┐
│  login() method in Main.java     │
├──────────────────────────────────┤
│  1. Validate input fields         │
│  2. Get database connection      │
│  3. Create SQL query             │
└──────┬───────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────────┐
│  SQL Query Execution                         │
├─────────────────────────────────────────────┤
│  String sql = "SELECT * FROM users          │
│                WHERE username = ?           │
│                AND role = ?";               │
│                                              │
│  PreparedStatement stmt =                   │
│      conn.prepareStatement(sql);           │
│  stmt.setString(1, username);              │
│  stmt.setString(2, role);                  │
│  ResultSet rs = stmt.executeQuery();       │
└─────┬───────────────────────────────────────┘
      │
      ▼
┌─────────────────────────────┐
│  Database Query              │
│  PostgreSQL processes query │
│  Returns matching user      │
└─────┬───────────────────────┘
      │
      ▼
┌────────────────────────────────────┐
│  Password Verification              │
├────────────────────────────────────┤
│  if (rs.next()) {                  │
│    String storedPassword =         │
│        rs.getString("password");   │
│    boolean match =                 │
│        PasswordUtil.verifyPassword │
│        (password, storedPassword); │
│  }                                  │
└────┬───────────────────────────────┘
     │
     ▼
┌──────────────────────────────┐
│  Success: Load Main UI        │
│  - Store currentUser          │
│  - Store currentRole          │
│  - Store currentUserId        │
│  - Create role-based tabs     │
└──────────────────────────────┘
```

**Code Implementation**:
```java
// File: com/company/ui/Main.java

private void login() {
    String username = usernameField.getText().trim();
    String password = new String(passwordField.getPassword());
    String role = (String) roleComboBox.getSelectedItem();

    try (Connection conn = DatabaseManager.getConnection()) {
        String sql = "SELECT * FROM users WHERE username = ? AND role = ?";
        PreparedStatement stmt = conn.prepareStatement(sql);
        stmt.setString(1, username);
        stmt.setString(2, role);

        ResultSet rs = stmt.executeQuery();
        if (rs.next()) {
            String storedPassword = rs.getString("password");
            
            if (PasswordUtil.verifyPassword(password, storedPassword)) {
                currentUser = username;
                currentRole = rs.getString("role");
                currentUserId = rs.getInt("user_id");

                // Load main application UI
                remove(loginPanel);
                createMainUI();
                revalidate();
                repaint();
            }
        }
    } catch (SQLException e) {
        JOptionPane.showMessageDialog(this, "Login failed: " + e.getMessage());
    }
}
```

### 2. Student Panel Integration

**Purpose**: Manage student CRUD operations

```
┌────────────────────────────────────────────────────────────┐
│                  STUDENT PANEL FLOW                         │
└────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────┐
│  UI Components (Java Swing)                          │
├──────────────────────────────────────────────────────┤
│  - firstNameField, lastNameField                     │
│  - rollField, emailField, phoneField                 │
│  - studentClassComboBox, studentDivisionComboBox     │
│  - addStudentBtn, updateStudentBtn, deleteStudentBtn │
│  - studentTable (JTable)                             │
└──────┬───────────────────────────────────────────────┘
       │
       │ User action (e.g., Click "Add Student")
       ▼
┌──────────────────────────────────────┐
│  Event Handler in Main.java          │
├──────────────────────────────────────┤
│  addStudentBtn.addActionListener     │
└──────┬───────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────┐
│  Collect and Validate Data              │
├─────────────────────────────────────────┤
│  String firstName =                     │
│      firstNameField.getText();         │
│  String lastName =                      │
│      lastNameField.getText();          │
│  // ... collect other fields            │
│                                          │
│  ValidationUtil.areFieldsFilled(...)   │
│  ValidationUtil.isValidEmail(...)      │
└─────┬───────────────────────────────────┘
      │
      ▼
┌──────────────────────────────────────┐
│  Create Model Object                  │
├──────────────────────────────────────┤
│  Student student = new Student();    │
│  student.setFirstName(firstName);    │
│  student.setLastName(lastName);      │
│  student.setStudentRoll(roll);       │
│  // ... set other properties          │
└──────┬───────────────────────────────┘
       │
       ▼
┌──────────────────────────────────────┐
│  Call DAO Method                      │
├──────────────────────────────────────┤
│  StudentDAO dao = new StudentDAO();  │
│  dao.addStudent(student);            │
└──────┬───────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────────────┐
│  StudentDAO.addStudent() Implementation         │
├─────────────────────────────────────────────────┤
│  1. Get Connection                               │
│     Connection conn =                            │
│         DatabaseManager.getConnection();        │
│                                                  │
│  2. Prepare SQL Statement                       │
│     String sql = "INSERT INTO students          │
│         (first_name, last_name, student_roll,   │
│          email, phone, class, division)         │
│         VALUES(?, ?, ?, ?, ?, ?, ?)";           │
│                                                  │
│  3. Set Parameters                              │
│     PreparedStatement stmt =                    │
│         conn.prepareStatement(sql);            │
│     stmt.setString(1, student.getFirstName()); │
│     stmt.setString(2, student.getLastName());  │
│     // ... set other parameters                 │
│                                                  │
│  4. Execute Update                              │
│     stmt.executeUpdate();                      │
└─────┬───────────────────────────────────────────┘
      │
      ▼
┌──────────────────────────┐
│  PostgreSQL Database     │
├──────────────────────────┤
│  INSERT INTO students    │
│  - New row created       │
│  - student_id generated  │
│  - Constraints checked   │
└──────┬───────────────────┘
       │
       ▼
┌──────────────────────────────┐
│  Return to UI                 │
├──────────────────────────────┤
│  - Show success message      │
│  - Refresh studentTable      │
│  - Clear input fields        │
└──────────────────────────────┘
```

**Code Implementation**:
```java
// File: com/company/ui/Main.java (UI Layer)

addStudentBtn.addActionListener(e -> {
    String firstName = firstNameField.getText().trim();
    String lastName = lastNameField.getText().trim();
    String roll = rollField.getText().trim();
    String email = studentEmailField.getText().trim();
    String phone = studentPhoneField.getText().trim();
    String studentClass = (String) studentClassComboBox.getSelectedItem();
    String division = (String) studentDivisionComboBox.getSelectedItem();

    if (!ValidationUtil.areFieldsFilled(firstName, lastName, roll)) {
        JOptionPane.showMessageDialog(this, "Please fill required fields");
        return;
    }

    try {
        StudentDAO dao = new StudentDAO();
        Student student = new Student();
        student.setFirstName(firstName);
        student.setLastName(lastName);
        student.setStudentRoll(roll);
        student.setEmail(email);
        student.setPhone(phone);
        student.setStudentClass(studentClass);
        student.setDivision(division);

        dao.addStudent(student);
        
        JOptionPane.showMessageDialog(this, "Student added successfully");
        loadStudents(); // Refresh table
        clearStudentFields();
    } catch (SQLException ex) {
        JOptionPane.showMessageDialog(this, "Error: " + ex.getMessage());
    }
});

// File: com/company/dao/StudentDAO.java (DAO Layer)

public void addStudent(Student student) throws SQLException {
    String sql = "INSERT INTO students(first_name, last_name, student_roll, " +
                 "email, phone, class, division) VALUES(?, ?, ?, ?, ?, ?, ?)";
    
    try (Connection conn = DatabaseManager.getConnection();
         PreparedStatement stmt = conn.prepareStatement(sql)) {
        
        stmt.setString(1, student.getFirstName());
        stmt.setString(2, student.getLastName());
        stmt.setString(3, student.getStudentRoll());
        stmt.setString(4, student.getEmail());
        stmt.setString(5, student.getPhone());
        stmt.setString(6, student.getStudentClass());
        stmt.setString(7, student.getDivision());
        stmt.executeUpdate();
    }
}
```

### 3. Teacher Panel Integration

**Purpose**: Manage teacher records

```
┌────────────────────────────────────────────────────────────┐
│                  TEACHER PANEL FLOW                         │
└────────────────────────────────────────────────────────────┘

Similar to Student Panel:
  UI Components → Event Handler → Validation → 
  Create Model → TeacherDAO → Database → Update UI

Key DAO Methods:
  - getAllTeachers()     → SELECT * FROM teachers
  - addTeacher()         → INSERT INTO teachers
  - updateTeacher()      → UPDATE teachers SET ... WHERE teacher_id=?
  - deleteTeacher()      → DELETE FROM teachers WHERE teacher_id=?
  - getTeacherById()     → SELECT * FROM teachers WHERE teacher_id=?
```

### 4. Subject Panel Integration

**Purpose**: Manage subjects/courses

```
┌────────────────────────────────────────────────────────────┐
│                  SUBJECT PANEL FLOW                         │
└────────────────────────────────────────────────────────────┘

UI Components:
  - subjectNameField
  - subjectCodeField
  - subjectTable

Key DAO Methods (SubjectDAO):
  - getAllSubjects()     → SELECT * FROM subjects
  - addSubject()         → INSERT INTO subjects
  - deleteSubject()      → DELETE FROM subjects WHERE subject_id=?
  - getSubjectById()     → SELECT * FROM subjects WHERE subject_id=?
```

### 5. Attendance Panel Integration

**Purpose**: Mark and track attendance for sessions

```
┌────────────────────────────────────────────────────────────┐
│                ATTENDANCE PANEL FLOW                        │
└────────────────────────────────────────────────────────────┘

Step 1: Load Session Configuration
       │
       ▼
┌──────────────────────────────────────┐
│  UI Components                        │
├──────────────────────────────────────┤
│  - subjectComboBox                   │
│  - attendanceClassComboBox           │
│  - attendanceDivisionComboBox        │
│  - sessionNumberComboBox (1-10)      │
│  - dateSpinner                       │
│  - attendanceTable                   │
└──────┬───────────────────────────────┘
       │
       │ Load subjects from database
       ▼
┌─────────────────────────────────────┐
│  SubjectDAO.getAllSubjects()        │
│  → Populates subjectComboBox        │
└─────┬───────────────────────────────┘
      │
      │ User selects subject, class, division
      ▼
Step 2: Load Students
       │
       ▼
┌─────────────────────────────────────────────┐
│  StudentDAO.getStudentsByClassAndDivision() │
│  → Loads students into attendanceTable      │
└─────┬───────────────────────────────────────┘
      │
      │ User marks attendance (Present/Absent/Late/Excused)
      ▼
Step 3: Mark Attendance
       │
       ▼
┌──────────────────────────────────────┐
│  markAttendanceBtn clicked            │
└──────┬───────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────────────────┐
│  Create or Get Session                               │
├─────────────────────────────────────────────────────┤
│  1. Check if session exists:                        │
│     SELECT session_id FROM sessions                 │
│     WHERE session_date=? AND subject_id=?           │
│     AND session_number=?                            │
│                                                      │
│  2. If not exists, create session:                  │
│     INSERT INTO sessions                            │
│     (session_date, subject_id, teacher_id,          │
│      session_number)                                │
│     VALUES(?, ?, ?, ?)                              │
└─────┬───────────────────────────────────────────────┘
      │
      ▼
┌─────────────────────────────────────────────────────┐
│  Mark Attendance for Each Student                   │
├─────────────────────────────────────────────────────┤
│  For each row in attendanceTable:                   │
│    1. Get student_id and status                     │
│    2. Execute SQL:                                  │
│       INSERT INTO attendance                        │
│       (student_id, session_id, status)              │
│       VALUES(?, ?, ?)                               │
│       ON CONFLICT (student_id, session_id)          │
│       DO UPDATE SET status=?                        │
└─────┬───────────────────────────────────────────────┘
      │
      ▼
┌──────────────────────────┐
│  Database Updates        │
├──────────────────────────┤
│  - sessions table        │
│  - attendance table      │
└──────┬───────────────────┘
       │
       ▼
┌──────────────────────────────┐
│  Show Success Message         │
│  Attendance marked for X      │
│  students                     │
└──────────────────────────────┘
```

**Code Implementation**:
```java
// File: com/company/ui/Main.java

markAttendanceBtn.addActionListener(e -> {
    try {
        // Get session details
        Date date = (Date) dateSpinner.getValue();
        String subjectName = (String) subjectComboBox.getSelectedItem();
        int sessionNumber = Integer.parseInt(
            (String) sessionNumberComboBox.getSelectedItem()
        );

        // Get or create session
        int sessionId = getOrCreateSession(date, subjectName, sessionNumber);

        // Mark attendance for each student
        int markedCount = 0;
        for (int i = 0; i < attendanceTableModel.getRowCount(); i++) {
            int studentId = (int) attendanceTableModel.getValueAt(i, 0);
            String status = (String) attendanceTableModel.getValueAt(i, 4);
            
            markAttendanceForStudent(sessionId, studentId, status);
            markedCount++;
        }

        JOptionPane.showMessageDialog(this, 
            "Attendance marked for " + markedCount + " students");
    } catch (SQLException ex) {
        JOptionPane.showMessageDialog(this, "Error: " + ex.getMessage());
    }
});

private int getOrCreateSession(Date date, String subjectName, int sessionNumber) 
        throws SQLException {
    Connection conn = DatabaseManager.getConnection();
    
    // Get subject_id
    String getSubjectSql = "SELECT subject_id FROM subjects WHERE subject_name=?";
    PreparedStatement stmt = conn.prepareStatement(getSubjectSql);
    stmt.setString(1, subjectName);
    ResultSet rs = stmt.executeQuery();
    
    int subjectId = 0;
    if (rs.next()) {
        subjectId = rs.getInt("subject_id");
    }

    // Check if session exists
    String checkSessionSql = "SELECT session_id FROM sessions " +
                            "WHERE session_date=? AND subject_id=? " +
                            "AND session_number=?";
    stmt = conn.prepareStatement(checkSessionSql);
    stmt.setDate(1, new java.sql.Date(date.getTime()));
    stmt.setInt(2, subjectId);
    stmt.setInt(3, sessionNumber);
    rs = stmt.executeQuery();

    if (rs.next()) {
        return rs.getInt("session_id");
    }

    // Create new session
    String insertSessionSql = "INSERT INTO sessions " +
                             "(session_date, subject_id, teacher_id, session_number) " +
                             "VALUES(?, ?, ?, ?) RETURNING session_id";
    stmt = conn.prepareStatement(insertSessionSql);
    stmt.setDate(1, new java.sql.Date(date.getTime()));
    stmt.setInt(2, subjectId);
    stmt.setInt(3, currentUserId); // teacher_id
    stmt.setInt(4, sessionNumber);
    rs = stmt.executeQuery();
    
    if (rs.next()) {
        return rs.getInt("session_id");
    }
    
    throw new SQLException("Failed to create session");
}

private void markAttendanceForStudent(int sessionId, int studentId, String status) 
        throws SQLException {
    String sql = "INSERT INTO attendance (student_id, session_id, status) " +
                 "VALUES(?, ?, ?) " +
                 "ON CONFLICT (student_id, session_id) " +
                 "DO UPDATE SET status=?";
    
    try (Connection conn = DatabaseManager.getConnection();
         PreparedStatement stmt = conn.prepareStatement(sql)) {
        
        stmt.setInt(1, studentId);
        stmt.setInt(2, sessionId);
        stmt.setString(3, status);
        stmt.setString(4, status);
        stmt.executeUpdate();
    }
}
```

### 6. Report Panel Integration

**Purpose**: Generate and export attendance reports

```
┌────────────────────────────────────────────────────────────┐
│                  REPORT PANEL FLOW                          │
└────────────────────────────────────────────────────────────┘

Step 1: Configure Report Parameters
       │
       ▼
┌──────────────────────────────────────┐
│  UI Components (ReportGenerator)      │
├──────────────────────────────────────┤
│  - studentFilterCombo                │
│  - subjectFilterCombo                │
│  - statusFilterCombo                 │
│  - startDateSpinner                  │
│  - endDateSpinner                    │
│  - reportTable                       │
└──────┬───────────────────────────────┘
       │
       │ User clicks "Generate Report"
       ▼
Step 2: Build Dynamic SQL Query
       │
       ▼
┌─────────────────────────────────────────────────────┐
│  Build SQL with Filters                              │
├─────────────────────────────────────────────────────┤
│  StringBuilder sql = new StringBuilder(             │
│    "SELECT s.student_roll, s.first_name,            │
│     s.last_name, sub.subject_name,                  │
│     ses.session_date, a.status                      │
│     FROM attendance a                               │
│     JOIN students s ON a.student_id=s.student_id    │
│     JOIN sessions ses ON a.session_id=ses.session_id│
│     JOIN subjects sub ON ses.subject_id=sub.subject_id│
│     WHERE 1=1"                                       │
│  );                                                  │
│                                                      │
│  if (studentFilter != "All") {                      │
│    sql.append(" AND s.student_roll=?");             │
│  }                                                   │
│  if (subjectFilter != "All") {                      │
│    sql.append(" AND sub.subject_name=?");           │
│  }                                                   │
│  if (statusFilter != "All") {                       │
│    sql.append(" AND a.status=?");                   │
│  }                                                   │
│  sql.append(" AND ses.session_date BETWEEN ? AND ?");│
└─────┬───────────────────────────────────────────────┘
      │
      ▼
Step 3: Execute Query
       │
       ▼
┌─────────────────────────────────────────────────────┐
│  Execute Query with Parameters                       │
├─────────────────────────────────────────────────────┤
│  Connection conn = DatabaseManager.getConnection(); │
│  PreparedStatement stmt = conn.prepareStatement(sql);│
│                                                      │
│  int paramIndex = 1;                                │
│  if (studentFilter != "All")                        │
│    stmt.setString(paramIndex++, studentFilter);    │
│  if (subjectFilter != "All")                        │
│    stmt.setString(paramIndex++, subjectFilter);    │
│  // ... set other parameters                        │
│                                                      │
│  ResultSet rs = stmt.executeQuery();                │
└─────┬───────────────────────────────────────────────┘
      │
      ▼
Step 4: Process Results
       │
       ▼
┌─────────────────────────────────────────────────────┐
│  Populate Report Table                               │
├─────────────────────────────────────────────────────┤
│  DefaultTableModel model = new DefaultTableModel(); │
│  model.setColumnIdentifiers(columns);               │
│                                                      │
│  while (rs.next()) {                                │
│    Object[] row = {                                 │
│      rs.getString("student_roll"),                  │
│      rs.getString("first_name"),                    │
│      rs.getString("last_name"),                     │
│      rs.getString("subject_name"),                  │
│      rs.getDate("session_date"),                    │
│      rs.getString("status")                         │
│    };                                                │
│    model.addRow(row);                               │
│  }                                                   │
│                                                      │
│  reportTable.setModel(model);                       │
└─────┬───────────────────────────────────────────────┘
      │
      ▼
Step 5: Calculate Statistics
       │
       ▼
┌─────────────────────────────────────────────────────┐
│  Calculate Attendance Stats                         │
├─────────────────────────────────────────────────────┤
│  int totalRecords = 0;                              │
│  int presentCount = 0;                              │
│  int absentCount = 0;                               │
│  int lateCount = 0;                                 │
│  int excusedCount = 0;                              │
│                                                      │
│  for each row in model:                             │
│    totalRecords++;                                  │
│    String status = row[5];                          │
│    switch(status) {                                 │
│      case "Present": presentCount++; break;         │
│      case "Absent": absentCount++; break;           │
│      case "Late": lateCount++; break;               │
│      case "Excused": excusedCount++; break;         │
│    }                                                 │
│                                                      │
│  double percentage =                                │
│    (presentCount * 100.0) / totalRecords;           │
└─────┬───────────────────────────────────────────────┘
      │
      ▼
┌──────────────────────────────────┐
│  Display Report & Statistics      │
│  - Show in table                 │
│  - Display summary stats         │
│  - Enable export options         │
└──────────────────────────────────┘
```

### 7. User Panel Integration

**Purpose**: Manage user accounts (Admin only)

```
┌────────────────────────────────────────────────────────────┐
│                    USER PANEL FLOW                          │
└────────────────────────────────────────────────────────────┘

UI Components:
  - newUsernameField
  - newPasswordField
  - userRoleComboBox (Admin/Teacher/Student)
  - userTable

Key DAO Methods (UserDAO):
  - getAllUsers()       → SELECT * FROM users
  - createUser()        → INSERT INTO users
  - deleteUser()        → DELETE FROM users WHERE user_id=?
  - getUserByUsername() → SELECT * FROM users WHERE username=?

Password Security:
  - Passwords hashed using PasswordUtil.hashPassword()
  - SHA-256 with salt
  - Stored hashed in database
```

---

## Data Flow Diagrams

### Complete System Data Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    COMPLETE SYSTEM DATA FLOW                     │
└─────────────────────────────────────────────────────────────────┘

User Interaction
       │
       ▼
┌──────────────────────────────────────────────────────────┐
│  PRESENTATION LAYER (Java Swing UI)                      │
│  ────────────────────────────────────────────────────    │
│  Components:                                              │
│  - JFrame, JPanel, JTable, JTextField, JButton, etc.     │
│  - Event Listeners (ActionListener, MouseListener, etc.) │
│  - UI Logic (validation, formatting, display)            │
└──────┬───────────────────────────────────────────────────┘
       │
       │ Event triggered (button click, table select, etc.)
       │
       ▼
┌──────────────────────────────────────────────────────────┐
│  EVENT HANDLER                                            │
│  ────────────────────────────────────────────────────    │
│  1. Capture event                                        │
│  2. Extract data from UI components                      │
│  3. Validate input (ValidationUtil)                      │
│  4. Create/prepare data                                  │
└──────┬───────────────────────────────────────────────────┘
       │
       │ Call DAO method
       │
       ▼
┌──────────────────────────────────────────────────────────┐
│  MODEL LAYER                                              │
│  ────────────────────────────────────────────────────    │
│  Create or populate model objects:                       │
│  - Student, Teacher, Subject, User                       │
│  - POJOs with getters/setters                            │
│  - No business logic                                     │
└──────┬───────────────────────────────────────────────────┘
       │
       │ Pass model to DAO
       │
       ▼
┌──────────────────────────────────────────────────────────┐
│  DATA ACCESS LAYER (DAO Classes)                         │
│  ────────────────────────────────────────────────────    │
│  1. Get Connection                                       │
│     Connection conn =                                    │
│         DatabaseManager.getConnection();                │
│                                                           │
│  2. Prepare SQL Statement                               │
│     String sql = "...";                                  │
│     PreparedStatement stmt =                            │
│         conn.prepareStatement(sql);                     │
│                                                           │
│  3. Set Parameters                                       │
│     stmt.setString(1, value);                           │
│     stmt.setInt(2, id);                                 │
│                                                           │
│  4. Execute Query/Update                                │
│     ResultSet rs = stmt.executeQuery();                 │
│     OR                                                   │
│     int rowsAffected = stmt.executeUpdate();            │
└──────┬───────────────────────────────────────────────────┘
       │
       │ JDBC sends SQL
       │
       ▼
┌──────────────────────────────────────────────────────────┐
│  DATABASE CONNECTION LAYER                               │
│  ────────────────────────────────────────────────────    │
│  DatabaseManager:                                        │
│  1. Load PostgreSQL JDBC Driver                         │
│     Class.forName("org.postgresql.Driver");             │
│                                                           │
│  2. Create Connection                                    │
│     DriverManager.getConnection(URL, USER, PASSWORD);   │
│                                                           │
│  3. Return Connection object                             │
└──────┬───────────────────────────────────────────────────┘
       │
       │ TCP/IP connection
       │
       ▼
┌──────────────────────────────────────────────────────────┐
│  JDBC DRIVER                                              │
│  ────────────────────────────────────────────────────    │
│  PostgreSQL JDBC Driver:                                 │
│  - Translates Java calls to PostgreSQL protocol         │
│  - Manages network communication                         │
│  - Handles result set parsing                            │
└──────┬───────────────────────────────────────────────────┘
       │
       │ PostgreSQL wire protocol
       │
       ▼
┌──────────────────────────────────────────────────────────┐
│  DATABASE SERVER (PostgreSQL)                            │
│  ────────────────────────────────────────────────────    │
│  1. Parse SQL query                                      │
│  2. Execute query plan                                   │
│  3. Access tables (students, teachers, etc.)            │
│  4. Apply constraints and triggers                       │
│  5. Return results or confirmation                       │
└──────┬───────────────────────────────────────────────────┘
       │
       │ Return ResultSet or update count
       │
       ▼
┌──────────────────────────────────────────────────────────┐
│  DAO PROCESSES RESULTS                                    │
│  ────────────────────────────────────────────────────    │
│  For SELECT queries:                                     │
│    while (rs.next()) {                                   │
│      Model obj = new Model();                            │
│      obj.setField(rs.getString("column"));              │
│      list.add(obj);                                      │
│    }                                                      │
│    return list;                                          │
│                                                           │
│  For INSERT/UPDATE/DELETE:                              │
│    return success/failure                                │
└──────┬───────────────────────────────────────────────────┘
       │
       │ Return data/status
       │
       ▼
┌──────────────────────────────────────────────────────────┐
│  UI UPDATES                                               │
│  ────────────────────────────────────────────────────    │
│  1. Receive results from DAO                             │
│  2. Update table model (for JTable)                     │
│  3. Refresh display                                      │
│  4. Show success/error messages                          │
│  5. Clear/reset form fields                              │
└──────────────────────────────────────────────────────────┘
       │
       ▼
User sees updated data
```

### Read Operation Flow (SELECT)

```
┌─────────────────────────────────────────────────────────┐
│           READ OPERATION (Load Students Example)         │
└─────────────────────────────────────────────────────────┘

User opens Student Panel
       │
       ▼
loadStudents() method called
       │
       ▼
┌──────────────────────────────┐
│  StudentDAO dao =            │
│    new StudentDAO();         │
│  List<Student> students =    │
│    dao.getAllStudents();     │
└──────┬───────────────────────┘
       │
       ▼
┌────────────────────────────────────────────┐
│  StudentDAO.getAllStudents()               │
├────────────────────────────────────────────┤
│  Connection conn =                         │
│    DatabaseManager.getConnection();       │
│                                            │
│  String sql = "SELECT * FROM students      │
│                ORDER BY student_id";       │
│                                            │
│  PreparedStatement stmt =                  │
│    conn.prepareStatement(sql);            │
│                                            │
│  ResultSet rs = stmt.executeQuery();      │
└────────┬───────────────────────────────────┘
         │
         ▼
┌────────────────────────────────────────────┐
│  PostgreSQL executes:                      │
│  SELECT * FROM students ORDER BY student_id│
└────────┬───────────────────────────────────┘
         │
         │ Returns ResultSet
         ▼
┌────────────────────────────────────────────┐
│  Process ResultSet                         │
├────────────────────────────────────────────┤
│  List<Student> students =                  │
│    new ArrayList<>();                      │
│                                            │
│  while (rs.next()) {                       │
│    Student s = new Student();              │
│    s.setStudentId(                         │
│      rs.getInt("student_id"));             │
│    s.setFirstName(                         │
│      rs.getString("first_name"));          │
│    s.setLastName(                          │
│      rs.getString("last_name"));           │
│    // ... map all fields                   │
│    students.add(s);                        │
│  }                                          │
│                                            │
│  return students;                          │
└────────┬───────────────────────────────────┘
         │
         ▼
┌────────────────────────────────────────────┐
│  Update UI Table                           │
├────────────────────────────────────────────┤
│  studentTableModel.setRowCount(0);         │
│                                            │
│  for (Student s : students) {              │
│    Object[] row = {                        │
│      s.getStudentId(),                     │
│      s.getFirstName(),                     │
│      s.getLastName(),                      │
│      s.getStudentRoll(),                   │
│      s.getEmail(),                         │
│      s.getStudentClass(),                  │
│      s.getDivision()                       │
│    };                                       │
│    studentTableModel.addRow(row);          │
│  }                                          │
└────────────────────────────────────────────┘
         │
         ▼
Table displays student data
```

### Write Operation Flow (INSERT/UPDATE/DELETE)

```
┌─────────────────────────────────────────────────────────┐
│      WRITE OPERATION (Add Student Example)              │
└─────────────────────────────────────────────────────────┘

User fills form and clicks "Add"
       │
       ▼
┌──────────────────────────────┐
│  Collect form data            │
│  Validate inputs             │
│  Create Student object       │
└──────┬───────────────────────┘
       │
       ▼
┌──────────────────────────────┐
│  StudentDAO dao =            │
│    new StudentDAO();         │
│  dao.addStudent(student);    │
└──────┬───────────────────────┘
       │
       ▼
┌────────────────────────────────────────────┐
│  StudentDAO.addStudent()                   │
├────────────────────────────────────────────┤
│  String sql =                              │
│    "INSERT INTO students                   │
│    (first_name, last_name, student_roll,   │
│     email, phone, class, division)         │
│    VALUES(?, ?, ?, ?, ?, ?, ?)";           │
│                                            │
│  Connection conn =                         │
│    DatabaseManager.getConnection();       │
│                                            │
│  PreparedStatement stmt =                  │
│    conn.prepareStatement(sql);            │
│                                            │
│  stmt.setString(1, student.getFirstName());│
│  stmt.setString(2, student.getLastName()); │
│  stmt.setString(3, student.getStudentRoll());│
│  stmt.setString(4, student.getEmail());    │
│  stmt.setString(5, student.getPhone());    │
│  stmt.setString(6, student.getStudentClass());│
│  stmt.setString(7, student.getDivision()); │
│                                            │
│  int rowsAffected = stmt.executeUpdate(); │
└────────┬───────────────────────────────────┘
         │
         ▼
┌────────────────────────────────────────────┐
│  PostgreSQL executes:                      │
│  INSERT INTO students ...                  │
│  - Validates constraints (UNIQUE, etc.)    │
│  - Generates student_id (SERIAL)           │
│  - Inserts row                             │
└────────┬───────────────────────────────────┘
         │
         │ Returns rowsAffected = 1
         ▼
┌────────────────────────────────────────────┐
│  DAO returns to UI                         │
└────────┬───────────────────────────────────┘
         │
         ▼
┌────────────────────────────────────────────┐
│  UI shows success message                  │
│  Calls loadStudents() to refresh table    │
│  Clears form fields                        │
└────────────────────────────────────────────┘
```

---

## Complete Flow Examples

### Example 1: User Login Flow

**Step-by-Step Process:**

1. **User Input**: User enters username "admin", password "admin123", selects role "Admin"

2. **UI Capture**: `login()` method extracts values from text fields

3. **Database Query**:
   ```java
   Connection conn = DatabaseManager.getConnection();
   String sql = "SELECT * FROM users WHERE username = ? AND role = ?";
   PreparedStatement stmt = conn.prepareStatement(sql);
   stmt.setString(1, "admin");
   stmt.setString(2, "Admin");
   ResultSet rs = stmt.executeQuery();
   ```

4. **JDBC Processing**: Driver sends query to PostgreSQL

5. **Database Execution**: PostgreSQL executes:
   ```sql
   SELECT * FROM users WHERE username = 'admin' AND role = 'Admin'
   ```

6. **Result Return**: Database returns matching user record

7. **Password Verification**:
   ```java
   String storedPassword = rs.getString("password");
   boolean match = PasswordUtil.verifyPassword("admin123", storedPassword);
   ```

8. **Session Creation**: If match, store currentUser, currentRole, currentUserId

9. **UI Update**: Remove login panel, create main UI with role-based tabs

### Example 2: Adding a Student

**Step-by-Step Process:**

1. **User Input**: Admin fills student form:
   - First Name: "John"
   - Last Name: "Doe"
   - Roll: "STU021"
   - Email: "john.doe@student.edu"
   - Class: "S1"
   - Division: "A"

2. **UI Validation**:
   ```java
   if (!ValidationUtil.areFieldsFilled(firstName, lastName, roll)) {
       showError("Required fields missing");
       return;
   }
   if (!ValidationUtil.isValidEmail(email)) {
       showError("Invalid email");
       return;
   }
   ```

3. **Model Creation**:
   ```java
   Student student = new Student();
   student.setFirstName("John");
   student.setLastName("Doe");
   student.setStudentRoll("STU021");
   student.setEmail("john.doe@student.edu");
   student.setStudentClass("S1");
   student.setDivision("A");
   ```

4. **DAO Call**:
   ```java
   StudentDAO dao = new StudentDAO();
   dao.addStudent(student);
   ```

5. **Database Connection**: DatabaseManager provides connection

6. **SQL Execution**:
   ```java
   String sql = "INSERT INTO students (first_name, last_name, student_roll, 
                 email, phone, class, division) VALUES(?, ?, ?, ?, ?, ?, ?)";
   PreparedStatement stmt = conn.prepareStatement(sql);
   // Set parameters...
   stmt.executeUpdate();
   ```

7. **PostgreSQL Processing**:
   - Validates UNIQUE constraint on student_roll
   - Generates student_id (e.g., 21)
   - Inserts row into students table

8. **Success Return**: executeUpdate() returns 1 (row affected)

9. **UI Update**:
   ```java
   JOptionPane.showMessageDialog(this, "Student added successfully");
   loadStudents(); // Refresh table
   clearStudentFields(); // Clear form
   ```

10. **Table Refresh**: StudentDAO.getAllStudents() called, table updated with new student

### Example 3: Marking Attendance

**Step-by-Step Process:**

1. **Setup**: Teacher selects:
   - Subject: "Mathematics"
   - Date: "2024-01-15"
   - Session Number: 1
   - Class: "S1"
   - Division: "A"

2. **Load Students**:
   ```java
   StudentDAO dao = new StudentDAO();
   List<Student> students = dao.getStudentsByClassAndDivision("S1", "A");
   // Populate attendance table with students
   ```

3. **Mark Attendance**: Teacher selects status for each student in table

4. **Click "Mark Attendance"**: System processes:

   a. **Get or Create Session**:
   ```java
   // Get subject_id
   SELECT subject_id FROM subjects WHERE subject_name='Mathematics'
   // Returns: 1
   
   // Check if session exists
   SELECT session_id FROM sessions 
   WHERE session_date='2024-01-15' 
   AND subject_id=1 
   AND session_number=1
   
   // If not exists, create:
   INSERT INTO sessions (session_date, subject_id, teacher_id, session_number)
   VALUES('2024-01-15', 1, 2, 1) RETURNING session_id
   // Returns: session_id = 42
   ```

   b. **Mark Attendance for Each Student**:
   ```java
   // For student_id=1, status="Present"
   INSERT INTO attendance (student_id, session_id, status) 
   VALUES(1, 42, 'Present')
   ON CONFLICT (student_id, session_id) 
   DO UPDATE SET status='Present'
   
   // For student_id=2, status="Absent"
   INSERT INTO attendance (student_id, session_id, status) 
   VALUES(2, 42, 'Absent')
   ON CONFLICT (student_id, session_id) 
   DO UPDATE SET status='Absent'
   
   // ... repeat for all students
   ```

5. **Database Updates**:
   - sessions table: 1 new row (or existing row)
   - attendance table: N new/updated rows (N = number of students)

6. **Success Message**: "Attendance marked for 20 students"

### Example 4: Generating Attendance Report

**Step-by-Step Process:**

1. **Open Report Panel**: Admin/Teacher opens ReportGenerator

2. **Set Filters**:
   - Student: "All"
   - Subject: "Mathematics"
   - Status: "All"
   - Date Range: "2024-01-01" to "2024-01-31"

3. **Click "Generate Report"**: System builds dynamic query:

   ```java
   StringBuilder sql = new StringBuilder(
       "SELECT s.student_roll, s.first_name, s.last_name, " +
       "sub.subject_name, ses.session_date, a.status " +
       "FROM attendance a " +
       "JOIN students s ON a.student_id = s.student_id " +
       "JOIN sessions ses ON a.session_id = ses.session_id " +
       "JOIN subjects sub ON ses.subject_id = sub.subject_id " +
       "WHERE 1=1"
   );
   
   // Add subject filter
   sql.append(" AND sub.subject_name = ?");
   
   // Add date range filter
   sql.append(" AND ses.session_date BETWEEN ? AND ?");
   
   sql.append(" ORDER BY ses.session_date, s.student_roll");
   ```

4. **Execute Query**:
   ```java
   PreparedStatement stmt = conn.prepareStatement(sql.toString());
   stmt.setString(1, "Mathematics");
   stmt.setDate(2, startDate);
   stmt.setDate(3, endDate);
   ResultSet rs = stmt.executeQuery();
   ```

5. **PostgreSQL Processing**: Executes complex JOIN query across 4 tables

6. **Process Results**:
   ```java
   DefaultTableModel model = new DefaultTableModel();
   while (rs.next()) {
       Object[] row = {
           rs.getString("student_roll"),
           rs.getString("first_name"),
           rs.getString("last_name"),
           rs.getString("subject_name"),
           rs.getDate("session_date"),
           rs.getString("status")
       };
       model.addRow(row);
   }
   reportTable.setModel(model);
   ```

7. **Calculate Statistics**:
   ```java
   int totalRecords = model.getRowCount();
   int presentCount = 0;
   int absentCount = 0;
   
   for (int i = 0; i < totalRecords; i++) {
       String status = (String) model.getValueAt(i, 5);
       if ("Present".equals(status)) presentCount++;
       else if ("Absent".equals(status)) absentCount++;
   }
   
   double percentage = (presentCount * 100.0) / totalRecords;
   ```

8. **Display Report**: Show table with data and statistics panel

9. **Export Options**:
   - CSV: Write table data to CSV file
   - Text: Format as text file
   - Print: Send to printer

---

## Key Concepts Summary

### JDBC Connection Lifecycle

```
1. Load Driver      → Class.forName("org.postgresql.Driver")
2. Get Connection   → DriverManager.getConnection(URL, USER, PASSWORD)
3. Create Statement → conn.prepareStatement(sql)
4. Set Parameters   → stmt.setString(1, value)
5. Execute Query    → stmt.executeQuery() OR stmt.executeUpdate()
6. Process Results  → while (rs.next()) { ... }
7. Close Resources  → try-with-resources handles this
```

### PreparedStatement Benefits

1. **SQL Injection Prevention**: Parameters are properly escaped
2. **Performance**: Query is pre-compiled, can be reused
3. **Type Safety**: Automatic type conversion and validation
4. **Readability**: Clear separation of SQL structure and data

### DAO Pattern Benefits

1. **Separation of Concerns**: UI doesn't know about SQL
2. **Reusability**: Same DAO can be used by multiple UI components
3. **Testability**: DAOs can be tested independently
4. **Maintainability**: Database changes don't affect UI
5. **Flexibility**: Easy to switch database implementations

### Try-With-Resources

All database operations use try-with-resources for automatic cleanup:

```java
try (Connection conn = DatabaseManager.getConnection();
     PreparedStatement stmt = conn.prepareStatement(sql);
     ResultSet rs = stmt.executeQuery()) {
    
    // Use connection, statement, and result set
    
} // Automatically closes rs, stmt, and conn
catch (SQLException e) {
    // Handle exception
}
```

This ensures resources are always closed, even if an exception occurs.

---

## Troubleshooting Common Issues

### Connection Issues

**Problem**: "Database driver not found"
- **Cause**: PostgreSQL JDBC driver not in classpath
- **Solution**: Add postgresql-xx.x.x.jar to classpath

**Problem**: "Connection refused"
- **Cause**: PostgreSQL not running or wrong connection details
- **Solution**: Verify PostgreSQL is running and db.properties is correct

### Query Issues

**Problem**: "Syntax error at or near..."
- **Cause**: Invalid SQL syntax
- **Solution**: Check SQL query syntax, ensure compatibility with PostgreSQL

**Problem**: "Column not found"
- **Cause**: Trying to access non-existent column
- **Solution**: Verify column name matches database schema

### Data Issues

**Problem**: "Unique constraint violation"
- **Cause**: Trying to insert duplicate value in UNIQUE column
- **Solution**: Check if record already exists before inserting

**Problem**: "Foreign key constraint violation"
- **Cause**: Referenced record doesn't exist
- **Solution**: Ensure parent record exists before creating child record

---

## Conclusion

This Student Attendance Management System demonstrates a well-structured Java application with:

1. **Clear Architecture**: Layered design with separation of concerns
2. **JDBC Integration**: Proper use of PostgreSQL JDBC driver for database connectivity
3. **DAO Pattern**: Clean abstraction of database operations
4. **Security**: Password hashing and SQL injection prevention
5. **User Experience**: Modern Swing UI with role-based access
6. **Data Integrity**: Proper use of foreign keys and constraints

The system provides a comprehensive example of how Java Swing applications can effectively integrate with PostgreSQL databases using JDBC, following industry best practices for maintainability, security, and scalability.

