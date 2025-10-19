# Architecture Documentation

## Overview

The Student Attendance Management System follows a layered architecture pattern with clear separation of concerns. This document describes the structure and organization of the codebase.

## Package Structure

```
com.company/
├── models/          # Data models (POJOs)
│   ├── Student.java
│   ├── Teacher.java
│   ├── Subject.java
│   └── User.java
├── dao/             # Data Access Objects
│   ├── StudentDAO.java
│   ├── TeacherDAO.java
│   ├── SubjectDAO.java
│   └── UserDAO.java
├── db/              # Database connection management
│   └── DatabaseManager.java
├── ui/              # User Interface
│   ├── Main.java
│   └── UIConstants.java
└── utils/           # Utility classes
    ├── PasswordUtil.java
    └── ValidationUtil.java
```

## Layer Descriptions

### 1. Models Layer (`com.company.models`)

**Purpose**: Represents the data structures used throughout the application.

**Classes**:
- `Student`: Student entity with personal information
- `Teacher`: Teacher entity with contact details
- `Subject`: Subject/course information
- `User`: User authentication data

**Characteristics**:
- Plain Old Java Objects (POJOs)
- Contain only data fields, getters, and setters
- No business logic or database operations
- Immutable after construction (recommended practice)

### 2. DAO Layer (`com.company.dao`)

**Purpose**: Handles all database operations and data persistence.

**Classes**:
- `StudentDAO`: CRUD operations for students
- `TeacherDAO`: CRUD operations for teachers
- `SubjectDAO`: CRUD operations for subjects
- `UserDAO`: CRUD operations for users

**Responsibilities**:
- Execute SQL queries using prepared statements
- Map database results to model objects
- Handle SQLException exceptions
- Provide search and filter methods

**Benefits**:
- Separates data access logic from business logic
- Makes database operations testable
- Centralized SQL query management
- Easy to switch database implementations

### 3. Database Layer (`com.company.db`)

**Purpose**: Manages database connections.

**Classes**:
- `DatabaseManager`: Provides database connections

**Responsibilities**:
- Load database configuration from properties file
- Create and manage database connections
- Handle PostgreSQL driver loading

### 4. UI Layer (`com.company.ui`)

**Purpose**: User interface and presentation logic.

**Classes**:
- `Main`: Main application window and UI logic
- `UIConstants`: UI styling constants and factory methods

**Responsibilities**:
- Display data to users
- Handle user interactions
- Create and manage UI components
- Coordinate between UI and data layers

**Characteristics**:
- Uses Java Swing for UI components
- Material Design-inspired styling
- Role-based interface customization

### 5. Utils Layer (`com.company.utils`)

**Purpose**: Provides reusable utility functions.

**Classes**:
- `PasswordUtil`: Password hashing and verification
- `ValidationUtil`: Input validation utilities

**Responsibilities**:
- Common operations used across the application
- Validation logic
- Security-related operations
- String manipulation and checks

## Design Patterns

### 1. Data Access Object (DAO) Pattern

**Description**: Abstracts and encapsulates all access to the data source.

**Implementation**:
```java
// DAO provides a clean interface for data operations
StudentDAO studentDAO = new StudentDAO();
List<Student> students = studentDAO.getAllStudents();
```

**Benefits**:
- Separation of data access logic from business logic
- Easier testing with mock DAOs
- Database implementation can change without affecting UI

### 2. Model-View-Controller (MVC) Inspired

**Description**: Separates data (Models), presentation (View/UI), and logic.

**Implementation**:
- **Model**: `com.company.models` package
- **View**: `com.company.ui` package
- **Controller**: Implicit in UI event handlers and DAO coordination

### 3. Factory Pattern

**Description**: UIConstants provides factory methods for creating styled components.

**Implementation**:
```java
JButton button = UIConstants.createPrimaryButton("Save");
JTextField field = UIConstants.createStyledTextField(20);
```

**Benefits**:
- Consistent UI styling
- Easy to change global UI appearance
- Reduces code duplication

## Data Flow

### Typical Operation Flow

1. **User Action** → User clicks a button in the UI
2. **Event Handler** → UI component captures the event
3. **Validation** → ValidationUtil validates user input
4. **DAO Call** → UI calls appropriate DAO method
5. **Database Operation** → DAO executes SQL query
6. **Model Creation** → DAO maps ResultSet to Model object
7. **UI Update** → UI displays the result to user

### Example: Adding a Student

```java
// 1. UI captures user input
String firstName = firstNameField.getText();
String lastName = lastNameField.getText();

// 2. Validation
if (!ValidationUtil.areFieldsFilled(firstName, lastName)) {
    showError("Required fields missing");
    return;
}

// 3. Create model
Student student = new Student();
student.setFirstName(firstName);
student.setLastName(lastName);

// 4. Call DAO
StudentDAO dao = new StudentDAO();
dao.addStudent(student);

// 5. Refresh UI
loadStudents();
```

## Database Schema Integration

### Tables and DAO Mapping

| Table      | DAO Class      | Model Class |
|------------|----------------|-------------|
| students   | StudentDAO     | Student     |
| teachers   | TeacherDAO     | Teacher     |
| subjects   | SubjectDAO     | Subject     |
| users      | UserDAO        | User        |
| sessions   | (In Main.java) | -           |
| attendance | (In Main.java) | -           |

**Note**: Sessions and attendance operations are currently in Main.java. Consider extracting to dedicated DAOs for better organization.

## Security Considerations

### Password Security
- Passwords are hashed using SHA-256 with salt
- Plain text passwords are never stored
- Password verification is constant-time to prevent timing attacks

### SQL Injection Prevention
- All database queries use PreparedStatement
- User input is parameterized, never concatenated
- No dynamic SQL query construction

### Input Validation
- All user inputs are validated before processing
- Email format validation using regex
- Required field checks
- Role-based access control

## Best Practices Implemented

1. **Try-with-resources**: Automatic resource management for database connections
2. **Prepared Statements**: All SQL queries use PreparedStatement
3. **Exception Handling**: Proper exception handling with user-friendly messages
4. **Code Reusability**: Shared utility classes and UI components
5. **Package Organization**: Clear separation of concerns
6. **Naming Conventions**: Consistent naming across the codebase

## Future Improvements

### Recommended Enhancements

1. **Service Layer**: Add a service layer between UI and DAO
   ```
   UI → Service → DAO → Database
   ```
   Benefits: Business logic separation, transaction management

2. **Attendance DAO**: Extract attendance operations from Main.java
   ```java
   AttendanceDAO.java
   SessionDAO.java
   ```

3. **Interface-based DAOs**: Define interfaces for DAOs
   ```java
   interface IStudentDAO {
       List<Student> getAllStudents();
       void addStudent(Student student);
   }
   ```

4. **Dependency Injection**: Use a DI framework or pattern
   - Makes code more testable
   - Reduces coupling between components

5. **Unit Tests**: Add comprehensive unit tests
   ```java
   StudentDAOTest.java
   ValidationUtilTest.java
   ```

## Migration from Old Structure

### What Changed

**Before**:
```
.
├── Main.java (1523 lines - everything in one file)
├── Attendance.java (unused)
├── DatabaseManager.java
├── PasswordUtil.java
└── UIConstants.java
```

**After**:
```
com.company/
├── models/        (NEW - 4 model classes)
├── dao/           (NEW - 4 DAO classes)
├── db/            (DatabaseManager moved here)
├── ui/            (Main.java and UIConstants moved here)
└── utils/         (PasswordUtil moved here + ValidationUtil)
```

### Benefits of Refactoring

1. **Maintainability**: Smaller, focused files are easier to understand
2. **Testability**: Each component can be tested independently
3. **Reusability**: DAOs can be reused across different UI components
4. **Scalability**: Easy to add new features without modifying existing code
5. **Team Development**: Multiple developers can work on different layers

### Backward Compatibility

- All existing functionality is preserved
- Database schema unchanged
- Build and run scripts updated for new structure
- No API changes for end users

## Conclusion

The refactored architecture provides a solid foundation for future development. The clear separation of concerns makes the codebase more maintainable, testable, and scalable. Each layer has a well-defined responsibility, making it easier to understand and modify the system.
