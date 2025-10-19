# Quick Start Guide

Get the Student Attendance Management System up and running in 5 minutes!

## Prerequisites Checklist

- [ ] Java JDK 11 or higher installed
- [ ] PostgreSQL 12 or higher installed
- [ ] PostgreSQL JDBC driver downloaded

## Step 1: Download JDBC Driver

Download the PostgreSQL JDBC driver:
1. Visit: https://jdbc.postgresql.org/download/
2. Download `postgresql-42.7.1.jar` (or latest version)
3. Place it in the project root directory

## Step 2: Setup Database

### Option A: Using Command Line

```bash
# Create database
createdb -U postgres student_attendance_db

# Run schema
psql -U postgres -d student_attendance_db -f schema.sql
```

### Option B: Using pgAdmin

1. Open pgAdmin
2. Create new database: `student_attendance_db`
3. Open Query Tool
4. Load and execute `schema.sql`

## Step 3: Configure Database Connection

1. Copy the example configuration:
   ```bash
   cp db.properties.example db.properties
   ```

2. Edit `db.properties` with your credentials:
   ```properties
   db.url=jdbc:postgresql://localhost:5432/student_attendance_db
   db.user=postgres
   db.password=your_password_here
   ```

## Step 4: Build and Run

### On Linux/Mac:

```bash
./build.sh    # Compile the application
./run.sh      # Run the application
```

### On Windows:

```batch
build.bat     # Compile the application
run.bat       # Run the application
```

## Step 5: Login

Use these default credentials to login:

**Admin Account:**
- Username: `admin`
- Password: `admin123`
- Role: Admin

**Teacher Account:**
- Username: `teacher1`
- Password: `teacher123`
- Role: Teacher

**Student Account:**
- Username: `student1`
- Password: `student123`
- Role: Student

## Troubleshooting

### "Database connection failed"
- Check if PostgreSQL is running: `sudo service postgresql status`
- Verify credentials in `db.properties`
- Test connection: `psql -U postgres -d student_attendance_db`

### "JDBC Driver not found"
- Ensure `postgresql-42.7.1.jar` is in the project directory
- Check if the filename matches in build scripts

### "Compilation failed"
- Verify Java version: `java -version` (must be 11+)
- Check if all `.java` files are present
- Review `build.log` for error details

### "Login failed"
- Ensure database is initialized with `schema.sql`
- Check if users table has data: `SELECT * FROM users;`
- Verify you're using correct credentials

## Next Steps

After successful login:

1. **As Admin**: 
   - Explore the Dashboard
   - Add students, teachers, and subjects
   - Create new user accounts
   - Mark attendance

2. **As Teacher**:
   - Mark attendance for your classes
   - Generate attendance reports

3. **As Student**:
   - View your attendance records
   - Export your attendance report

## Need Help?

- Check the full [README.md](README.md) for detailed documentation
- Review the database schema in `schema.sql`
- Open an issue on GitHub for bugs or questions

## Security Note

⚠️ **Important**: Change default passwords immediately after first login!

The default passwords are for demonstration only and should never be used in production.

---

**Ready to start? Run `./run.sh` (Linux/Mac) or `run.bat` (Windows)!**
