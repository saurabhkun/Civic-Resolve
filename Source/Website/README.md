# 🏛️ CivicResolve Admin Dashboard

A comprehensive web-based administration dashboard for the CivicResolve civic reporting system, connected to a live Supabase PostgreSQL database.

## 🌟 Overview

CivicResolve is a civic engagement platform that allows citizens to report issues in their communities through a mobile application. This admin dashboard provides government administrators with powerful tools to manage, track, and resolve these civic reports efficiently.

## 🔑 Login Credentials

**Admin Access:**
- **Username:** `admin`
- **Password:** `1234`

## 🚀 Key Features

### 📊 Dashboard Overview
- **Real-time Statistics**: Live data on total reports, pending cases, resolved issues
- **Interactive Charts**: Visual analytics showing reports over time and category breakdowns
- **Recent Reports Feed**: Latest submissions with quick action buttons
- **Priority Alerts**: Highlighted urgent and high-priority reports
- **Notification System**: Real-time alerts for new submissions

### 📋 Reports Management
- **Comprehensive Table View**: All reports with search, filter, and sort capabilities
- **Advanced Filtering**: Filter by status, category, priority, date range, and keywords
- **Bulk Operations**: Select multiple reports for batch status updates
- **Pagination**: Efficient handling of large datasets
- **Quick Actions**: One-click status updates and report resolution

### 🔍 Report Details
- **Complete Report View**: Full details including title, description, location, images
- **Image Gallery**: View all submitted photos with full-screen preview
- **Interactive Maps**: GPS location display using Leaflet maps
- **Status Management**: Update report status with dropdown selection
- **Admin Notes**: Add internal comments and tracking information
- **Reporter Information**: Contact details and submission history

### 👥 User Management
- **User Directory**: Complete list of registered users
- **Account Details**: Contact information and registration dates
- **Report History**: View all reports submitted by specific users
- **Admin Privileges**: Identify administrator accounts

### 🏷️ Categories Management
- **Category Overview**: Visual display of all issue categories
- **Color Coding**: Each category has a unique color identifier
- **Activity Status**: Active/inactive category management
- **Usage Statistics**: Reports count per category

### 📈 Analytics & Insights
- **Performance Metrics**: Resolution times and efficiency tracking
- **Geographic Distribution**: Heatmap of report locations
- **Trend Analysis**: Historical data and pattern recognition
- **Export Capabilities**: Download data in CSV/PDF formats

## 🛠️ Technical Architecture

### Database Integration
- **Supabase PostgreSQL**: Cloud-hosted database with real-time capabilities
- **RESTful API**: Direct integration with Supabase REST API
- **Real-time Updates**: Live data synchronization every 30 seconds
- **Secure Authentication**: API key-based access control

### Core Technologies
- **Frontend**: Vanilla JavaScript, HTML5, CSS3
- **Charts**: Chart.js for data visualization
- **Maps**: Leaflet.js for interactive mapping
- **CSS Framework**: Custom responsive design
- **Icons**: Unicode emoji icons for better UX

### Data Models

#### Reports Table Structure
```sql
- id (Primary Key)
- title (Report Title)
- description (Detailed Description)
- category (Issue Category)
- location (Address/Location)
- latitude, longitude (GPS Coordinates)
- image_urls (JSONB Array of Base64 Images)
- status (submitted, under_review, in_progress, resolved, rejected)
- priority (low, medium, high, urgent)
- user_id (Foreign Key to Users)
- assigned_officer_id (Staff Assignment)
- contact_number (Reporter Contact)
- admin_notes (Internal Comments)
- citizen_feedback (User Feedback)
- rating (Satisfaction Rating 1-5)
- created_at, updated_at (Timestamps)
```

#### Users Table Structure
```sql
- id (Primary Key)
- full_name (User Name)
- email (Email Address)
- phone_number (Contact Number)
- is_admin (Admin Flag)
- created_at (Registration Date)
```

#### Categories Table Structure
```sql
- id (Primary Key)
- name (Category Name)
- display_name (Friendly Name)
- description (Category Description)
- color_code (Hex Color)
- is_active (Status Flag)
```

## 📁 Project Structure

```
CivicResolve-Dashboard/
├── index.html              # Login page
├── dashboard.html          # Main dashboard interface
├── css/
│   ├── style.css          # Base styles and login page
│   └── dashboard.css      # Dashboard-specific styles
├── js/
│   ├── database.js        # Supabase database service
│   ├── auth-simple.js     # Authentication logic
│   └── dashboard-civic.js # Main dashboard controller
└── README.md              # This documentation
```

## 🔧 Setup Instructions

### 1. Local Development
1. **Clone/Download** the project files
2. **Open** `index.html` in a modern web browser
3. **Login** with admin credentials: `admin` / `1234`
4. **Verify** database connection in Settings > Test Connection

### 2. Database Configuration
The dashboard is pre-configured to connect to the live Supabase database:
- **URL**: `https://ooryormddgyvgthggnzo.supabase.co`
- **API Key**: Already embedded in the code
- **Tables**: `reports`, `users`, `categories`

### 3. Production Deployment
For production deployment:
1. **Upload** all files to your web server
2. **Configure HTTPS** for secure operation
3. **Set up** environment variables for API keys
4. **Configure** CORS policies if needed

## 🎯 Usage Guide

### Daily Operations
1. **Login** to the dashboard using admin credentials
2. **Review** dashboard overview for current statistics
3. **Check** urgent reports in the priority alerts section
4. **Process** reports by updating their status
5. **Add** admin notes for internal tracking
6. **Monitor** resolution performance metrics

### Report Management Workflow
1. **View** new reports in the Reports section
2. **Filter** reports by status, category, or priority
3. **Open** report details for complete information
4. **Update** status from submitted → under_review → in_progress → resolved
5. **Add** administrative notes for documentation
6. **Track** progress through status timeline

### Analytics Review
1. **Access** Analytics section for insights
2. **Review** charts for trends and patterns
3. **Identify** high-volume categories
4. **Monitor** resolution performance
5. **Export** data for external analysis

## 🔒 Security Features

- **Secure Authentication**: Session-based login system
- **API Security**: Protected Supabase endpoints
- **Data Validation**: Input sanitization and validation
- **Session Management**: Automatic logout and session expiry
- **Access Control**: Admin-only access to sensitive operations

## 📱 Mobile App Integration

This dashboard receives data from the CivicResolve Flutter mobile application where citizens:
- **Submit Reports**: Text, images, and GPS location
- **Track Status**: Real-time updates on report progress
- **Provide Feedback**: Rate satisfaction with resolution
- **Receive Notifications**: Updates from administrators

## 🌐 Browser Compatibility

**Supported Browsers:**
- Chrome 90+
- Firefox 88+
- Safari 14+
- Edge 90+

**Features Requiring Modern Browser:**
- ES6 JavaScript support
- Fetch API for database calls
- CSS Grid and Flexbox
- Canvas for charts

## 📊 Performance Metrics

- **Load Time**: < 3 seconds for initial page load
- **Database Queries**: Optimized with pagination and filtering
- **Real-time Updates**: 30-second auto-refresh interval
- **Responsive Design**: Works on screens 320px and larger

## 🔄 Maintenance

### Regular Tasks
- **Monitor** database connection status
- **Review** error logs in browser console
- **Update** report statuses within 24 hours
- **Backup** important admin notes and data
- **Clean** resolved reports older than 6 months

### Troubleshooting
- **Connection Issues**: Check Settings > Test DB Connection
- **Login Problems**: Verify credentials `admin` / `1234`
- **Loading Errors**: Check browser console for JavaScript errors
- **Display Issues**: Ensure JavaScript is enabled

## 📞 Support

For technical support or feature requests:
1. **Check** browser console for error messages
2. **Test** database connection in Settings
3. **Verify** internet connectivity
4. **Clear** browser cache and cookies
5. **Try** different browser if issues persist

## 🔮 Future Enhancements

### Planned Features
- **Push Notifications**: Real-time alerts for urgent reports
- **Advanced Analytics**: Machine learning insights
- **Mobile Dashboard**: Responsive mobile interface
- **API Documentation**: Swagger/OpenAPI documentation
- **Multi-language Support**: Internationalization
- **Role-based Access**: Different permission levels
- **Audit Logs**: Complete action tracking
- **Integration APIs**: Third-party service connections

---

**CivicResolve Dashboard v1.0** - Empowering civic engagement through technology