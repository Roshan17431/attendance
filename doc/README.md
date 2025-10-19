# Student Attendance Management System

A comprehensive Java Swing application for managing student attendance with a modern, intuitive UI featuring interactive dashboards, charts, and advanced reporting capabilities. Features include role-based access control, attendance tracking, visual analytics, and PostgreSQL database integration.

## 🌟 New Features (Latest Update)

### ✨ Enhanced Dashboards
- **Admin Dashboard**: Visual statistics with pie charts, bar charts, and activity feed
- **Teacher Dashboard**: Personal performance metrics with weekly attendance trends
- **Student Dashboard**: Subject-wise progress bars with color-coded attendance rates

### 📊 Advanced Reporting
- **Multiple Export Formats**: CSV, Text, and Print
- **Advanced Filtering**: By student, subject, status, and date range
- **Visual Summary**: Color-coded statistics with totals
- **Table View**: Professional data display with sortable columns

### 🎨 Modern UI Enhancements
- **Emoji Icons**: Better visual cues in buttons and actions
- **Improved Layouts**: Grid-based forms with optimal spacing
- **Color-Coded Elements**: Intuitive color system throughout
- **Enhanced Tables**: Optimized column widths and better styling

**See [NEW_FEATURES.md](doc/NEW_FEATURES.md) for complete details**

---

## 🌟 Core Features

### Core Functionality
- **Role-Based Dashboards**: Customized dashboards for Admin, Teacher, and Student with charts and statistics
- **Visual Analytics**: Interactive pie charts, bar charts, and progress bars
- **Student Management**: Add, update, delete, and search students with detailed information
- **Teacher Management**: Manage teacher records with email and contact information
- **Subject Management**: Create and organize subjects with codes
- **Attendance Tracking**: Mark attendance with multiple status options (Present, Absent, Late, Excused)
- **Comprehensive Reports**: Generate detailed attendance reports with statistics and multiple export formats (CSV, Text, Print)
- **Dashboard**: Visual overview of system statistics with charts for admins, teachers, and students

### Security Features
- **Password Hashing**: SHA-256 with salt for secure password storage
- **Input Validation**: Email validation, required field checks, and data integrity
- **Permission Controls**: Role-based access to different features

### Enhanced Features
- **Modern UI**: Material Design-inspired color scheme with emoji icons and improved layouts
- **Export Reports**: Save attendance reports to CSV or text files, or print directly
- **Search Functionality**: Quick search for students by name or roll number
- **Interactive Charts**: Pie charts for distribution, bar charts for trends, progress bars for subject attendance
- **Advanced Filtering**: Filter reports by subject, status, and date range
- **Real-time Statistics**: Live updates on dashboard stats and recent activity
- **Email & Phone**: Extended contact information for students and teachers
- **Subject Codes**: Organize subjects with unique codes
- **Attendance Statistics**: Percentage calculations and performance indicators

## 🚀 Getting Started

### Prerequisites
- Java Development Kit (JDK) 11 or higher
- PostgreSQL 12 or higher
- PostgreSQL JDBC Driver

### Database Setup

1. **Install PostgreSQL** and create a new database:
```sql
CREATE DATABASE student_attendance_db;
```

2. **Run the schema file** to create tables and sample data:
```bash
psql -U postgres -d student_attendance_db -f schema.sql
```

3. **Configure database connection**:
   - Copy `db.properties.example` to `db.properties`
   - Update with your PostgreSQL credentials:
```properties
db.url=jdbc:postgresql://localhost:5432/student_attendance_db
db.user=your_username
db.password=your_password
```

### Installation

1. **Clone the repository**:
```bash
git clone https://github.com/Skywalker690/Student-Attendance-Management-System-.git
cd Student-Attendance-Management-System-
```

2. **Download PostgreSQL JDBC Driver**:
   - Download from: https://jdbc.postgresql.org/download/
   - Place `postgresql-xx.x.x.jar` in your classpath

3. **Build the application**:

   **Linux/Mac**:
   ```bash
   chmod +x build.sh run.sh
   ./build.sh
   ```

   **Windows**:
   ```cmd
   build.bat
   ```

4. **Run the application**:

   **Linux/Mac**:
   ```bash
   ./run.sh
   ```

   **Windows**:
   ```cmd
   run.bat
   ```

### Default Login Credentials

The system comes with pre-configured users for testing:

| Role    | Username  | Password     |
|---------|-----------|-------------|
| Admin   | admin     | admin123    |
| Teacher | teacher1  | teacher123  |
| Student | student1  | student123  |

**⚠️ Important**: Change these default passwords immediately in production!

## 📖 User Guide

### Admin Functions
1. **Dashboard**: View system statistics with interactive charts
   - Pie chart showing attendance distribution
   - Bar chart showing subject-wise attendance
   - Recent activity feed
   - Real-time stat cards
2. **Student Management**: 
   - Add new students with complete details
   - Update existing student information
   - Delete student records
   - Search students by name or roll number
3. **Teacher Management**: Manage teacher records
4. **Subject Management**: Create and organize subjects
5. **User Management**: Create and manage system users
6. **Attendance**: Mark and track attendance
7. **Reports**: Generate comprehensive attendance reports
   - Advanced filtering options
   - Multiple export formats (CSV, Text, Print)
   - Visual summary with color-coded statistics

### Teacher Functions
1. **Dashboard**: View personal performance metrics
   - Sessions today counter
   - Average attendance rate
   - Weekly attendance trend chart
2. **Attendance**: Mark daily attendance for classes
2. **Reports**: View and export attendance reports for any student
   - CSV export for data analysis
   - Text export for documentation
   - Direct printing capability

### Student Functions
1. **Dashboard**: View personal attendance overview
   - Overall attendance percentage
   - Present/absent day counters
   - Subject-wise progress bars with color coding
2. **My Attendance**: View personal attendance reports
3. **Export**: Save attendance reports for records (CSV, Text, or Print)

## 🎨 UI Features

### Dashboard Visualizations
- **Interactive Charts**: Pie charts for distribution, bar charts for trends
- **Progress Bars**: Color-coded subject-wise attendance tracking
- **Stat Cards**: Quick metrics with emoji icons
- **Recent Activity Feed**: Latest sessions and attendance counts

### Modern Design Elements

### Technology Stack
- **Language**: Java 11+
- **UI Framework**: Java Swing
- **Database**: PostgreSQL
- **Security**: SHA-256 password hashing
- **Architecture**: Layered architecture with DAO pattern

### Design Patterns
- **DAO Pattern**: Separates data access logic from business logic
- **MVC-inspired**: Models, Views (UI), and Controllers (event handlers)
- **Factory Pattern**: UI component creation through UIConstants
- **Singleton**: DatabaseManager for connection management

For detailed architecture documentation, see [ARCHITECTURE.md](ARCHITECTURE.md)

### Project Structure
```
.
├── com/company/
│   ├── models/              # Data models (Student, Teacher, Subject, User)
│   ├── dao/                 # Data Access Objects for database operations
│   ├── db/                  # Database connection management
│   ├── ui/                  # User Interface (Main, UIConstants)
│   └── utils/               # Utility classes (PasswordUtil, ValidationUtil)
├── schema.sql              # PostgreSQL database schema
├── db.properties.example   # Database configuration template
├── build.sh / build.bat    # Build scripts
├── run.sh / run.bat        # Run scripts
├── README.md               # This file
└── ARCHITECTURE.md         # Detailed architecture documentation
```

### Database Schema
- **users**: User authentication and roles
- **students**: Student information and details
- **teachers**: Teacher records
- **subjects**: Course subjects
- **sessions**: Class sessions
- **attendance**: Attendance records

## 🎨 UI Features

### Modern Design Elements
- Material Design-inspired color palette
- Professional card-based layouts with emoji icons
- Styled buttons with hover effects and color coding
- Enhanced table views with alternating row colors and optimized widths
- Responsive form layouts with improved spacing
- Clear visual hierarchy with section titles

### Button Icons
- ➕ Add/Create new records
- ✏️ Update/Edit existing records
- 🗑️ Delete records (with confirmation)
- 🔍 Search and filter data
- 🔄 Refresh data display
- 💾 Save changes

### Color Scheme
- Primary: Indigo (#3F51B5)
- Success: Green (#4CAF50)
- Warning: Orange (#FF9800)
- Error: Red (#F44336)
- Accent: Pink (#FF4081)

## 📊 Database Migration

### From MySQL to PostgreSQL

Key changes made for PostgreSQL compatibility:
1. **Auto-increment**: `AUTO_INCREMENT` → `SERIAL`
2. **Upsert syntax**: `ON DUPLICATE KEY UPDATE` → `ON CONFLICT ... DO UPDATE`
3. **Case-insensitive search**: `LIKE` → `ILIKE`
4. **Data types**: Adjusted for PostgreSQL standards
5. **Constraints**: Added proper CHECK constraints

## 🔒 Security Considerations

1. **Password Storage**: All passwords are hashed using SHA-256 with salt
2. **SQL Injection Protection**: Prepared statements used throughout
3. **Input Validation**: Client-side and server-side validation
4. **Session Management**: Proper user authentication and role checking
5. **Database Configuration**: Externalized in properties file

## 🛠️ Development

### Building from Source

**Using Build Scripts** (Recommended):
```bash
# Linux/Mac
./build.sh

# Windows
build.bat
```

**Manual Build**:
```bash
# Create output directory
mkdir -p out

# Compile all Java files
find com -name "*.java" -print0 | xargs -0 javac -d out -cp .:postgresql-xx.x.x.jar

# Run the application
java -cp out:postgresql-xx.x.x.jar com.company.ui.Main
```

### IDE Setup (IntelliJ IDEA)
1. Open project in IntelliJ IDEA
2. Add PostgreSQL JDBC driver to project libraries
3. Configure run configuration for Main class
4. Ensure db.properties is in the classpath

## 📝 Future Enhancements

- [ ] Biometric attendance integration
- [ ] Mobile application
- [ ] Email notifications for low attendance
- [ ] Advanced analytics and charts
- [ ] Bulk import/export (CSV, Excel)
- [ ] REST API for third-party integrations
- [ ] Multi-language support
- [ ] Dark mode theme
- [ ] PDF report generation

## 🐛 Troubleshooting

### Common Issues

**Database Connection Error**
```
Solution: Verify PostgreSQL is running and credentials in db.properties are correct
```

**JDBC Driver Not Found**
```
Solution: Add postgresql-xx.x.x.jar to your classpath
```

**Login Issues**
```
Solution: Ensure database is initialized with schema.sql
```

## 📄 License

This project is open source and available under the MIT License.

## 👥 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📧 Support

For support, please open an issue in the GitHub repository.

## 🙏 Acknowledgments

- Material Design for UI inspiration
- PostgreSQL community for excellent documentation
- Java Swing documentation and tutorials

---

**Made with ❤️ for educational purposes**
