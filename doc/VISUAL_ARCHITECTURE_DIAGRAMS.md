# Visual Architecture Diagrams

This document contains detailed ASCII diagrams showing the architecture and data flow of the Student Attendance Management System.

---

## Table of Contents
1. [System Architecture Overview](#system-architecture-overview)
2. [JDBC Connection Flow](#jdbc-connection-flow)
3. [Request-Response Cycle](#request-response-cycle)
4. [Panel Integration Diagrams](#panel-integration-diagrams)
5. [Database Entity Relationships](#database-entity-relationships)

---

## System Architecture Overview

### Complete System Layout

```
┌────────────────────────────────────────────────────────────────────────────┐
│                        STUDENT ATTENDANCE SYSTEM                            │
│                                                                              │
│  ┌────────────────────────────────────────────────────────────────────┐   │
│  │                    PRESENTATION LAYER                               │   │
│  │                    (Java Swing GUI)                                 │   │
│  ├────────────────────────────────────────────────────────────────────┤   │
│  │                                                                      │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐          │   │
│  │  │  Login   │  │ Student  │  │ Teacher  │  │ Subject  │          │   │
│  │  │  Panel   │  │  Panel   │  │  Panel   │  │  Panel   │  ...     │   │
│  │  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘          │   │
│  │       │             │             │             │                  │   │
│  │       └─────────────┴─────────────┴─────────────┘                  │   │
│  │                          │                                          │   │
│  │                          │ Event Handlers                          │   │
│  │                          │ (ActionListener, etc.)                  │   │
│  └──────────────────────────┼─────────────────────────────────────────┘   │
│                              │                                              │
│                              ▼                                              │
│  ┌────────────────────────────────────────────────────────────────────┐   │
│  │                      MODEL LAYER                                    │   │
│  │                    (POJOs / Entities)                               │   │
│  ├────────────────────────────────────────────────────────────────────┤   │
│  │                                                                      │   │
│  │  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐              │   │
│  │  │ Student │  │ Teacher │  │ Subject │  │  User   │              │   │
│  │  │  Model  │  │  Model  │  │  Model  │  │  Model  │              │   │
│  │  └─────────┘  └─────────┘  └─────────┘  └─────────┘              │   │
│  │                                                                      │   │
│  └──────────────────────────────────────────────────────────────────────   │
│                              │                                              │
│                              ▼                                              │
│  ┌────────────────────────────────────────────────────────────────────┐   │
│  │                   DATA ACCESS LAYER                                 │   │
│  │                   (DAO Pattern)                                     │   │
│  ├────────────────────────────────────────────────────────────────────┤   │
│  │                                                                      │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐          │   │
│  │  │ Student  │  │ Teacher  │  │ Subject  │  │   User   │          │   │
│  │  │   DAO    │  │   DAO    │  │   DAO    │  │   DAO    │  ...     │   │
│  │  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘          │   │
│  │       │             │             │             │                  │   │
│  │       └─────────────┴─────────────┴─────────────┘                  │   │
│  │                          │                                          │   │
│  └──────────────────────────┼─────────────────────────────────────────┘   │
│                              │                                              │
│                              ▼                                              │
│  ┌────────────────────────────────────────────────────────────────────┐   │
│  │                 CONNECTION MANAGEMENT                               │   │
│  │                 (DatabaseManager)                                   │   │
│  ├────────────────────────────────────────────────────────────────────┤   │
│  │                                                                      │   │
│  │  • Load JDBC Driver                                                 │   │
│  │  • Manage db.properties                                             │   │
│  │  • Create JDBC Connections                                          │   │
│  │  • Return Connection objects                                        │   │
│  │                                                                      │   │
│  └──────────────────────────────────────────────────────────────────────   │
│                              │                                              │
│                              │ JDBC                                         │
│                              ▼                                              │
│  ┌────────────────────────────────────────────────────────────────────┐   │
│  │                    JDBC DRIVER                                      │   │
│  │              (org.postgresql.Driver)                                │   │
│  ├────────────────────────────────────────────────────────────────────┤   │
│  │                                                                      │   │
│  │  • Translate Java to PostgreSQL protocol                            │   │
│  │  • Handle network communication                                     │   │
│  │  • Parse result sets                                                │   │
│  │                                                                      │   │
│  └──────────────────────────────────────────────────────────────────────   │
│                              │                                              │
│                              │ TCP/IP (PostgreSQL Wire Protocol)           │
│                              ▼                                              │
│  ┌────────────────────────────────────────────────────────────────────┐   │
│  │                   DATABASE SERVER                                   │   │
│  │                   (PostgreSQL)                                      │   │
│  ├────────────────────────────────────────────────────────────────────┤   │
│  │                                                                      │   │
│  │  Tables: users, students, teachers, subjects,                       │   │
│  │          sessions, attendance                                       │   │
│  │                                                                      │   │
│  └──────────────────────────────────────────────────────────────────────   │
└────────────────────────────────────────────────────────────────────────────┘
```

---

## JDBC Connection Flow

### Detailed Connection Establishment

```
┌─────────────────────────────────────────────────────────────────┐
│                     APPLICATION STARTUP                          │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
         ┌───────────────────────────────┐
         │  DatabaseManager Static Block │
         ├───────────────────────────────┤
         │  1. Load db.properties        │
         │  2. Read configuration:       │
         │     - db.url                  │
         │     - db.user                 │
         │     - db.password             │
         │  3. Set defaults if missing   │
         └──────────────┬────────────────┘
                        │
                        ▼
         ┌───────────────────────────────────────────────┐
         │         Configuration Loaded                   │
         │  URL = "jdbc:postgresql://localhost:5432/     │
         │         student_attendance_db"                 │
         │  USER = "postgres"                             │
         │  PASSWORD = "your_password"                    │
         └───────────────────────────────────────────────┘
                        │
                        │ Application runs...
                        │
        ┌───────────────┴────────────────┐
        │   DAO needs database access    │
        └───────────────┬────────────────┘
                        │
                        ▼
         ┌──────────────────────────────────┐
         │  DatabaseManager.getConnection() │
         └──────────────┬───────────────────┘
                        │
                        ▼
         ┌─────────────────────────────────┐
         │  Step 1: Load JDBC Driver       │
         ├─────────────────────────────────┤
         │  Class.forName(                 │
         │    "org.postgresql.Driver"      │
         │  );                              │
         └──────────────┬──────────────────┘
                        │
                        │ Driver class loaded
                        ▼
         ┌─────────────────────────────────────────┐
         │  PostgreSQL Driver Registered with      │
         │  DriverManager                          │
         └──────────────┬──────────────────────────┘
                        │
                        ▼
         ┌──────────────────────────────────┐
         │  Step 2: Request Connection      │
         ├──────────────────────────────────┤
         │  DriverManager.getConnection(    │
         │    URL,    // Connection string  │
         │    USER,   // Username           │
         │    PASSWORD // Password          │
         │  );                               │
         └──────────────┬───────────────────┘
                        │
                        │ TCP connection established
                        ▼
         ┌────────────────────────────────────────┐
         │     Network Socket Created             │
         │  localhost:5432 ← → Application       │
         └────────────┬───────────────────────────┘
                      │
                      ▼
         ┌────────────────────────────────────────┐
         │  PostgreSQL Server Authenticates       │
         ├────────────────────────────────────────┤
         │  1. Verify username/password           │
         │  2. Check database exists              │
         │  3. Grant session                      │
         └────────────┬───────────────────────────┘
                      │
                      │ Authentication successful
                      ▼
         ┌────────────────────────────────────────┐
         │     Connection Object Created          │
         │  (java.sql.Connection instance)        │
         └────────────┬───────────────────────────┘
                      │
                      ▼
         ┌────────────────────────────────────────┐
         │  Connection Returned to DAO            │
         └────────────────────────────────────────┘
                      │
                      │ DAO can now execute queries
                      ▼
         ┌────────────────────────────────────────┐
         │  DAO uses Connection for:              │
         │  - Creating PreparedStatements         │
         │  - Executing queries                   │
         │  - Managing transactions               │
         └────────────────────────────────────────┘
```

---

## Request-Response Cycle

### Complete Cycle from UI to Database and Back

```
┌──────────────────────────────────────────────────────────────────────┐
│                      USER ACTION (Example: Add Student)               │
└────────────────────────────┬─────────────────────────────────────────┘
                             │
                             ▼
              ┌──────────────────────────────┐
              │   1. UI EVENT TRIGGERED      │
              ├──────────────────────────────┤
              │  User clicks "Add Student"   │
              │  button                      │
              └──────────────┬───────────────┘
                             │
                             ▼
              ┌──────────────────────────────────────┐
              │   2. EVENT HANDLER EXECUTES          │
              ├──────────────────────────────────────┤
              │  addStudentBtn.addActionListener()  │
              │  called                              │
              └──────────────┬───────────────────────┘
                             │
                             ▼
              ┌─────────────────────────────────────────┐
              │   3. EXTRACT DATA FROM UI               │
              ├─────────────────────────────────────────┤
              │  String firstName =                     │
              │      firstNameField.getText();          │
              │  String lastName =                      │
              │      lastNameField.getText();           │
              │  String roll = rollField.getText();     │
              │  // ... collect all fields              │
              └──────────────┬──────────────────────────┘
                             │
                             ▼
              ┌─────────────────────────────────────────┐
              │   4. VALIDATE INPUT                     │
              ├─────────────────────────────────────────┤
              │  if (!ValidationUtil.areFieldsFilled()) │
              │    showError();                         │
              │    return;                              │
              │  if (!ValidationUtil.isValidEmail())    │
              │    showError();                         │
              │    return;                              │
              └──────────────┬──────────────────────────┘
                             │
                             │ Validation passed
                             ▼
              ┌─────────────────────────────────────────┐
              │   5. CREATE MODEL OBJECT                │
              ├─────────────────────────────────────────┤
              │  Student student = new Student();       │
              │  student.setFirstName(firstName);       │
              │  student.setLastName(lastName);         │
              │  student.setStudentRoll(roll);          │
              │  // ... set all properties              │
              └──────────────┬──────────────────────────┘
                             │
                             ▼
              ┌─────────────────────────────────────────┐
              │   6. INVOKE DAO METHOD                  │
              ├─────────────────────────────────────────┤
              │  StudentDAO dao = new StudentDAO();     │
              │  dao.addStudent(student);               │
              └──────────────┬──────────────────────────┘
                             │
                             │ Control transferred to DAO
                             ▼
    ┌────────────────────────────────────────────────────────────┐
    │                  DAO PROCESSING                             │
    └────────────────────────────────────────────────────────────┘
                             │
                             ▼
              ┌─────────────────────────────────────────┐
              │   7. GET DATABASE CONNECTION            │
              ├─────────────────────────────────────────┤
              │  Connection conn =                      │
              │    DatabaseManager.getConnection();     │
              └──────────────┬──────────────────────────┘
                             │
                             ▼
              ┌──────────────────────────────────────────┐
              │   8. PREPARE SQL STATEMENT               │
              ├──────────────────────────────────────────┤
              │  String sql =                            │
              │    "INSERT INTO students                 │
              │     (first_name, last_name,              │
              │      student_roll, email, ...)           │
              │     VALUES(?, ?, ?, ?, ...)";            │
              │                                          │
              │  PreparedStatement stmt =                │
              │    conn.prepareStatement(sql);           │
              └──────────────┬───────────────────────────┘
                             │
                             ▼
              ┌──────────────────────────────────────────┐
              │   9. SET PARAMETERS                      │
              ├──────────────────────────────────────────┤
              │  stmt.setString(1, student.getFirstName());│
              │  stmt.setString(2, student.getLastName()); │
              │  stmt.setString(3, student.getStudentRoll());│
              │  stmt.setString(4, student.getEmail());    │
              │  // ... set all parameters               │
              └──────────────┬───────────────────────────┘
                             │
                             ▼
              ┌──────────────────────────────────────────┐
              │   10. EXECUTE SQL                        │
              ├──────────────────────────────────────────┤
              │  int rowsAffected =                      │
              │      stmt.executeUpdate();               │
              └──────────────┬───────────────────────────┘
                             │
                             │ SQL sent over JDBC
                             ▼
    ┌────────────────────────────────────────────────────────────┐
    │                  DATABASE PROCESSING                        │
    └────────────────────────────────────────────────────────────┘
                             │
                             ▼
              ┌──────────────────────────────────────────┐
              │   11. POSTGRESQL RECEIVES QUERY          │
              ├──────────────────────────────────────────┤
              │  - Parse SQL                             │
              │  - Check syntax                          │
              │  - Plan execution                        │
              └──────────────┬───────────────────────────┘
                             │
                             ▼
              ┌──────────────────────────────────────────┐
              │   12. VALIDATE CONSTRAINTS               │
              ├──────────────────────────────────────────┤
              │  - Check UNIQUE student_roll             │
              │  - Validate foreign keys                 │
              │  - Check data types                      │
              └──────────────┬───────────────────────────┘
                             │
                             │ Constraints satisfied
                             ▼
              ┌──────────────────────────────────────────┐
              │   13. EXECUTE INSERT                     │
              ├──────────────────────────────────────────┤
              │  - Generate student_id (SERIAL)          │
              │  - Insert row into students table        │
              │  - Update indexes                        │
              └──────────────┬───────────────────────────┘
                             │
                             ▼
              ┌──────────────────────────────────────────┐
              │   14. COMMIT TRANSACTION                 │
              ├──────────────────────────────────────────┤
              │  - Write to disk                         │
              │  - Update transaction log                │
              └──────────────┬───────────────────────────┘
                             │
                             │ Return success status
                             ▼
    ┌────────────────────────────────────────────────────────────┐
    │                  RETURN TO APPLICATION                      │
    └────────────────────────────────────────────────────────────┘
                             │
                             ▼
              ┌──────────────────────────────────────────┐
              │   15. DAO RECEIVES RESULT                │
              ├──────────────────────────────────────────┤
              │  rowsAffected = 1 (success)              │
              │  OR SQLException thrown                  │
              └──────────────┬───────────────────────────┘
                             │
                             ▼
              ┌──────────────────────────────────────────┐
              │   16. CLOSE RESOURCES                    │
              ├──────────────────────────────────────────┤
              │  try-with-resources automatically:       │
              │  - Closes PreparedStatement              │
              │  - Closes Connection                     │
              └──────────────┬───────────────────────────┘
                             │
                             │ Control returns to UI
                             ▼
    ┌────────────────────────────────────────────────────────────┐
    │                     UI UPDATE                               │
    └────────────────────────────────────────────────────────────┘
                             │
                             ▼
              ┌──────────────────────────────────────────┐
              │   17. SHOW SUCCESS MESSAGE               │
              ├──────────────────────────────────────────┤
              │  JOptionPane.showMessageDialog(          │
              │    "Student added successfully"          │
              │  );                                       │
              └──────────────┬───────────────────────────┘
                             │
                             ▼
              ┌──────────────────────────────────────────┐
              │   18. REFRESH TABLE                      │
              ├──────────────────────────────────────────┤
              │  loadStudents();                         │
              │  - Calls StudentDAO.getAllStudents()     │
              │  - Populates JTable with updated data    │
              └──────────────┬───────────────────────────┘
                             │
                             ▼
              ┌──────────────────────────────────────────┐
              │   19. CLEAR FORM                         │
              ├──────────────────────────────────────────┤
              │  clearStudentFields();                   │
              │  - Reset all text fields                 │
              │  - Reset combo boxes                     │
              └──────────────┬───────────────────────────┘
                             │
                             ▼
              ┌──────────────────────────────────────────┐
              │   20. USER SEES RESULT                   │
              ├──────────────────────────────────────────┤
              │  - Success message displayed             │
              │  - Table shows new student               │
              │  - Form is cleared                       │
              └──────────────────────────────────────────┘
```

---

## Panel Integration Diagrams

### Login Panel Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                        LOGIN PANEL                               │
└──────────────────────────┬──────────────────────────────────────┘
                           │
         ┌─────────────────┴─────────────────┐
         │                                     │
         ▼                                     ▼
   ┌──────────┐                         ┌──────────┐
   │ Username │                         │ Password │
   │  Field   │                         │  Field   │
   └──────────┘                         └──────────┘
         │                                     │
         │                                     │
         └─────────────────┬─────────────────┘
                           │
                           │ + Role Selection
                           │
                           ▼
                   ┌──────────────┐
                   │ Login Button │
                   └───────┬──────┘
                           │
                           │ Click
                           ▼
          ┌────────────────────────────────────┐
          │  Validate Credentials              │
          ├────────────────────────────────────┤
          │  SQL: SELECT * FROM users          │
          │       WHERE username = ?           │
          │       AND role = ?                 │
          └────────────┬───────────────────────┘
                       │
        ┌──────────────┴──────────────┐
        │                             │
        ▼                             ▼
   ┌─────────┐                  ┌──────────┐
   │  Found  │                  │   Not    │
   │         │                  │  Found   │
   └────┬────┘                  └────┬─────┘
        │                            │
        ▼                            ▼
   Verify Password              Show Error
        │                       "Invalid credentials"
        │
    ┌───┴────┐
    │        │
    ▼        ▼
 Match   No Match
    │        │
    │        └─→ Show Error
    │
    ▼
 Success!
    │
    ├─→ Set currentUser
    ├─→ Set currentRole
    ├─→ Set currentUserId
    │
    ▼
 Load Main UI
    │
    ├─→ Create tabs based on role
    │   ├─ Admin: All tabs
    │   ├─ Teacher: Attendance, Reports
    │   └─ Student: My Attendance
    │
    └─→ Show Dashboard
```

### Attendance Marking Flow

```
┌────────────────────────────────────────────────────────────────────┐
│                      ATTENDANCE PANEL                               │
└─────────────────────────────┬──────────────────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
        ▼                     ▼                     ▼
  ┌──────────┐         ┌──────────┐         ┌──────────┐
  │ Subject  │         │  Class   │         │ Division │
  │ Selector │         │ Selector │         │ Selector │
  └────┬─────┘         └────┬─────┘         └────┬─────┘
       │                    │                     │
       │                    │                     │
       └────────────────────┴─────────────────────┘
                            │
                            │ + Date + Session Number
                            │
                            ▼
                  ┌──────────────────┐
                  │  Load Students   │
                  └────────┬─────────┘
                           │
                           │ StudentDAO.getStudentsByClassAndDivision()
                           │
                           ▼
              ┌────────────────────────┐
              │  Display Students in   │
              │  Attendance Table      │
              └────────┬───────────────┘
                       │
                       │ Each row has:
                       │ - Student ID
                       │ - Name
                       │ - Roll
                       │ - Status dropdown
                       │
                       ▼
         ┌─────────────────────────────────┐
         │  Teacher marks status:          │
         │  Present / Absent / Late /      │
         │  Excused                        │
         └─────────────┬───────────────────┘
                       │
                       │ Click "Mark Attendance"
                       ▼
         ┌──────────────────────────────────┐
         │  Step 1: Get/Create Session      │
         ├──────────────────────────────────┤
         │  Check if session exists:        │
         │  SELECT session_id FROM sessions │
         │  WHERE date=? AND subject_id=?   │
         │  AND session_number=?            │
         │                                  │
         │  If not exists, INSERT new       │
         │  session                         │
         └─────────────┬────────────────────┘
                       │
                       │ session_id obtained
                       ▼
         ┌──────────────────────────────────┐
         │  Step 2: Mark Each Student       │
         ├──────────────────────────────────┤
         │  For each row in table:          │
         │                                  │
         │  INSERT INTO attendance          │
         │  (student_id, session_id, status)│
         │  VALUES(?, ?, ?)                 │
         │  ON CONFLICT DO UPDATE           │
         │  SET status=?                    │
         └─────────────┬────────────────────┘
                       │
                       │ All students marked
                       ▼
         ┌──────────────────────────────────┐
         │  Show Success                    │
         │  "Attendance marked for N        │
         │   students"                      │
         └──────────────────────────────────┘
```

---

## Database Entity Relationships

### Complete ERD

```
┌────────────────────────────────────────────────────────────────────┐
│                    DATABASE SCHEMA ERD                              │
└────────────────────────────────────────────────────────────────────┘

┌─────────────────────┐
│       users         │
├─────────────────────┤
│ PK user_id          │
│    username         │
│    password (hash)  │
│    role             │
│    created_at       │
└──────────┬──────────┘
           │
           │ 1
           │
           ├──────────────────┐
           │                  │
           │ 0..1             │ 0..1
           │                  │
           ▼                  ▼
┌─────────────────────┐  ┌─────────────────────┐
│     students        │  │     teachers        │
├─────────────────────┤  ├─────────────────────┤
│ PK student_id       │  │ PK teacher_id       │
│    first_name       │  │    first_name       │
│    last_name        │  │    last_name        │
│    student_roll (UQ)│  │    email (UQ)       │
│    email            │  │    phone            │
│    phone            │  │ FK user_id          │
│    class            │  │    created_at       │
│    division         │  └──────────┬──────────┘
│ FK user_id          │             │
│    created_at       │             │ 0..*
└──────────┬──────────┘             │
           │                        │
           │ 1..*                   │
           │                        │
           │            ┌───────────┴────────────┐
           │            │                        │
           │            │                        │
           │            │              ┌─────────────────────┐
           │            │              │      subjects       │
           │            │              ├─────────────────────┤
           │            │              │ PK subject_id       │
           │            │              │    subject_name (UQ)│
           │            │              │    subject_code     │
           │            │              │    description      │
           │            │              │    created_at       │
           │            │              └──────────┬──────────┘
           │            │                         │
           │            │                         │ 1
           │            │                         │
           │            │              ┌──────────┴──────────┐
           │            │              │                     │
           │            │              │ 1..*                │
           │            │              │                     │
           │            │              ▼                     │
           │            │  ┌─────────────────────┐          │
           │            │  │      sessions       │          │
           │            │  ├─────────────────────┤          │
           │            │  │ PK session_id       │          │
           │            │  │    session_date     │          │
           │            └─►│ FK subject_id       │          │
           │               │ FK teacher_id       │◄─────────┘
           │               │    session_number   │
           │               │    created_at       │
           │               └──────────┬──────────┘
           │                          │
           │                          │ 1
           │                          │
           │                          │ 1..*
           │                          │
           │                          ▼
           │              ┌─────────────────────┐
           │              │     attendance      │
           │              ├─────────────────────┤
           │              │ PK attendance_id    │
           └─────────────►│ FK student_id       │
                          │ FK session_id       │
                          │    status           │
                          │    marked_at        │
                          │    UQ(student_id,   │
                          │       session_id)   │
                          └─────────────────────┘

Legend:
PK = Primary Key
FK = Foreign Key
UQ = Unique Constraint
1..* = One to many
0..* = Zero to many
0..1 = Zero to one
```

### Key Relationships

1. **users → students** (0..1): A user can be linked to one student
2. **users → teachers** (0..1): A user can be linked to one teacher
3. **subjects → sessions** (1..*): Each subject has many sessions
4. **teachers → sessions** (0..*): Each teacher conducts many sessions
5. **sessions → attendance** (1..*): Each session has many attendance records
6. **students → attendance** (1..*): Each student has many attendance records

---

## Component Interaction Matrix

```
┌────────────────────────────────────────────────────────────────────────┐
│                  COMPONENT INTERACTION MATRIX                           │
├──────────────┬──────────┬──────────┬──────────┬──────────┬────────────┤
│  Component   │   UI     │  DAO     │  Model   │ Database │ DBManager  │
├──────────────┼──────────┼──────────┼──────────┼──────────┼────────────┤
│ UI           │    -     │  Calls   │  Creates │    -     │     -      │
│              │          │          │   Uses   │          │            │
├──────────────┼──────────┼──────────┼──────────┼──────────┼────────────┤
│ DAO          │  Returns │    -     │  Creates │  Queries │   Calls    │
│              │   to     │          │   Maps   │          │            │
├──────────────┼──────────┼──────────┼──────────┼──────────┼────────────┤
│ Model        │  Used by │  Used by │    -     │    -     │     -      │
│              │          │          │          │          │            │
├──────────────┼──────────┼──────────┼──────────┼──────────┼────────────┤
│ Database     │    -     │  Returns │    -     │    -     │     -      │
│              │          │   data   │          │          │            │
├──────────────┼──────────┼──────────┼──────────┼──────────┼────────────┤
│ DBManager    │    -     │  Provides│    -     │ Connects │     -      │
│              │          │   conn   │          │    to    │            │
└──────────────┴──────────┴──────────┴──────────┴──────────┴────────────┘
```

---

## Summary

These diagrams illustrate:

1. **System Architecture**: 3-layer design with clear boundaries
2. **JDBC Connection**: Step-by-step connection establishment
3. **Request-Response**: Complete cycle from user action to database and back
4. **Panel Integration**: How each UI panel interacts with backend
5. **Database ERD**: Table relationships and foreign keys
6. **Component Interaction**: How different parts of the system communicate

For detailed code examples and explanations, see the [DATABASE_AND_INTEGRATION_GUIDE.md](DATABASE_AND_INTEGRATION_GUIDE.md).

