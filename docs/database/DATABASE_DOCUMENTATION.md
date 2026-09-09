# CivicResolve Database Documentation

## 📊 Complete Database Structure & API Guide

This document provides comprehensive information about the CivicResolve database structure, stored data, and API endpoints for web application development.

## 🗄️ Database Tables Overview

### 1. **USERS Table**
**Purpose**: Store user account information for authentication and profile management

| Column | Type | Description | Example |
|--------|------|-------------|---------|
| `id` | UUID | Primary key | `550e8400-e29b-41d4-a716-446655440000` |
| `email` | TEXT | User's email address (unique) | `john.doe@email.com` |
| `password_hash` | TEXT | Encrypted password | `$2b$12$hash...` |
| `full_name` | TEXT | User's full name | `John Doe` |
| `phone_number` | TEXT | Phone number (optional) | `+1-555-123-4567` |
| `address` | TEXT | User's address (optional) | `123 Main St, City, State` |
| `is_admin` | BOOLEAN | Admin privileges flag | `false` |
| `is_verified` | BOOLEAN | Email verification status | `true` |
| `created_at` | TIMESTAMPTZ | Account creation time | `2025-09-21 10:30:00+00` |
| `updated_at` | TIMESTAMPTZ | Last profile update | `2025-09-21 15:45:00+00` |
| `last_login` | TIMESTAMPTZ | Last login time | `2025-09-21 16:00:00+00` |
| `profile_image_url` | TEXT | Profile picture URL | `https://...` |

**Default Admin Account:**
- Email: `123@admin.com`
- Password: `123`
- Full Name: `System Administrator`

### 2. **REPORTS Table**
**Purpose**: Store citizen reports with full tracking and management capabilities

| Column | Type | Description | Example |
|--------|------|-------------|---------|
| `id` | BIGSERIAL | Primary key | `1001` |
| `user_id` | UUID | Reference to user who submitted | `550e8400-...` |
| `title` | TEXT | Report title | `Pothole on Main Street` |
| `description` | TEXT | Detailed description | `Large pothole causing damage...` |
| `category` | TEXT | Issue category | `roads` |
| `location` | TEXT | Human-readable location | `123 Main St, Downtown` |
| `latitude` | DECIMAL(10,8) | GPS latitude | `40.7128` |
| `longitude` | DECIMAL(11,8) | GPS longitude | `-74.0060` |
| `image_urls` | JSONB | Array of image URLs | `["https://...", "https://..."]` |
| `status` | TEXT | Current status | `submitted`, `under_review`, `in_progress`, `resolved`, `rejected` |
| `priority` | TEXT | Priority level | `low`, `medium`, `high`, `urgent` |
| `created_at` | TIMESTAMPTZ | Submission time | `2025-09-21 14:30:00+00` |
| `updated_at` | TIMESTAMPTZ | Last update time | `2025-09-21 16:00:00+00` |
| `assigned_officer_id` | UUID | Assigned staff member | `660e8400-...` |
| `estimated_completion_date` | DATE | Expected completion | `2025-09-25` |
| `completion_date` | TIMESTAMPTZ | Actual completion time | `2025-09-24 10:00:00+00` |
| `consolidated_reports` | INTEGER | Number of similar reports | `3` |
| `contact_number` | TEXT | Reporter's contact | `+1-555-123-4567` |
| `admin_notes` | TEXT | Internal admin notes | `Requires road crew...` |
| `citizen_feedback` | TEXT | Citizen feedback on resolution | `Issue resolved quickly!` |
| `rating` | INTEGER | Citizen satisfaction rating (1-5) | `5` |

### 3. **REPORT_STATUS_HISTORY Table**
**Purpose**: Track all status changes for audit trail and transparency

| Column | Type | Description | Example |
|--------|------|-------------|---------|
| `id` | BIGSERIAL | Primary key | `5001` |
| `report_id` | BIGINT | Reference to report | `1001` |
| `old_status` | TEXT | Previous status | `submitted` |
| `new_status` | TEXT | New status | `under_review` |
| `changed_by` | UUID | User who made the change | `660e8400-...` |
| `change_reason` | TEXT | Reason for status change | `Assigned to road maintenance team` |
| `created_at` | TIMESTAMPTZ | When change occurred | `2025-09-21 15:00:00+00` |

### 4. **NOTIFICATIONS Table**
**Purpose**: Manage push notifications and real-time updates

| Column | Type | Description | Example |
|--------|------|-------------|---------|
| `id` | BIGSERIAL | Primary key | `7001` |
| `user_id` | UUID | Target user | `550e8400-...` |
| `report_id` | BIGINT | Related report (optional) | `1001` |
| `title` | TEXT | Notification title | `Report Status Updated` |
| `message` | TEXT | Notification message | `Your report has been assigned...` |
| `type` | TEXT | Notification type | `status_update`, `system`, `reminder`, `admin_message` |
| `is_read` | BOOLEAN | Read status | `false` |
| `created_at` | TIMESTAMPTZ | Creation time | `2025-09-21 15:30:00+00` |
| `scheduled_for` | TIMESTAMPTZ | Scheduled delivery time | `2025-09-21 16:00:00+00` |
| `delivered_at` | TIMESTAMPTZ | Actual delivery time | `2025-09-21 16:01:00+00` |

### 5. **ADMIN_ACTIONS Table**
**Purpose**: Audit trail for all administrative actions

| Column | Type | Description | Example |
|--------|------|-------------|---------|
| `id` | BIGSERIAL | Primary key | `9001` |
| `admin_id` | UUID | Admin who performed action | `660e8400-...` |
| `action_type` | TEXT | Type of action | `status_change`, `assignment`, `user_management` |
| `target_type` | TEXT | What was affected | `report`, `user`, `notification` |
| `target_id` | TEXT | ID of affected item | `1001` |
| `details` | JSONB | Additional action details | `{"old_status": "submitted", "new_status": "in_progress"}` |
| `created_at` | TIMESTAMPTZ | Action timestamp | `2025-09-21 15:45:00+00` |

### 6. **CATEGORIES Table**
**Purpose**: Define available report categories with metadata

| Column | Type | Description | Example |
|--------|------|-------------|---------|
| `id` | SERIAL | Primary key | `1` |
| `name` | TEXT | Internal category name | `roads` |
| `display_name` | TEXT | User-friendly name | `Roads & Infrastructure` |
| `description` | TEXT | Category description | `Potholes, road damage, traffic issues` |
| `icon_name` | TEXT | Icon identifier | `road` |
| `color_code` | TEXT | UI color code | `#FF5722` |
| `is_active` | BOOLEAN | Category availability | `true` |
| `created_at` | TIMESTAMPTZ | Creation time | `2025-09-21 10:00:00+00` |

## 🔧 Database Views & Functions

### Views for Easy Data Access

#### 1. **reports_with_user** View
Combines report data with user information for easy querying:
```sql
SELECT * FROM reports_with_user WHERE status = 'submitted';
```

#### 2. **dashboard_stats** View  
Provides real-time statistics for dashboards:
```sql
SELECT * FROM dashboard_stats;
```

### API Functions

#### 1. **authenticate_user(email, password)**
```sql
SELECT * FROM authenticate_user('user@email.com', 'password123');
```
Returns: `{success: boolean, user_data: json, message: string}`

#### 2. **create_user_account(email, password, full_name, phone)**
```sql
SELECT * FROM create_user_account('new@email.com', 'pass123', 'John Doe', '+1234567890');
```
Returns: `{success: boolean, user_id: uuid, message: string}`

#### 3. **submit_report(...)**
```sql
SELECT * FROM submit_report(user_id, title, description, category, location, lat, lng, images, phone);
```
Returns: `{success: boolean, report_id: bigint, message: string}`

## 📱 Mobile App Data Storage

### What Gets Stored When You Submit a Report:

1. **User Information**:
   - Your name (from user account)
   - Email address (from user account)
   - Phone number (optional, from form or profile)

2. **Report Details**:
   - Report title and description
   - Category (roads, water, electricity, etc.)
   - Location (address and GPS coordinates)
   - Photos/images
   - Submission timestamp

3. **Tracking Information**:
   - Unique report ID
   - Current status
   - Priority level (auto-assigned based on category)
   - Status change history

4. **Administrative Data**:
   - Assigned officer (when available)
   - Internal notes from staff
   - Estimated completion date
   - Actual completion date

## 🌐 Web Application API Endpoints

### Authentication Endpoints

#### POST `/auth/login`
```json
{
  "email": "user@email.com",
  "password": "password123"
}
```

#### POST `/auth/register`
```json
{
  "email": "new@email.com",
  "password": "password123",
  "full_name": "John Doe",
  "phone_number": "+1234567890"
}
```

### Report Management Endpoints

#### GET `/reports`
Query parameters:
- `status`: Filter by status
- `category`: Filter by category
- `user_id`: Filter by user
- `limit`: Number of results
- `offset`: Pagination offset

#### PUT `/reports/{id}/status`
```json
{
  "status": "in_progress",
  "reason": "Assigned to maintenance team",
  "estimated_completion": "2025-09-25"
}
```

#### POST `/reports/{id}/notify`
```json
{
  "title": "Work Started",
  "message": "Maintenance work has begun on your reported issue.",
  "type": "status_update"
}
```

### Statistics Endpoints

#### GET `/stats/dashboard`
Returns real-time statistics for admin dashboard

#### GET `/stats/reports-by-category`
Returns report counts grouped by category

#### GET `/stats/resolution-times`
Returns average resolution times by category

## 🔄 Real-Time Status Updates

### Automatic Triggers:

1. **Status Change Notifications**: When report status changes, automatic notification sent to user
2. **Admin Notifications**: When new reports submitted, all admins notified
3. **Reminder System**: Automated reminders for overdue reports

### Manual Notifications:

Admins can trigger custom notifications via web application:
```sql
INSERT INTO notifications (user_id, report_id, title, message, type) 
VALUES ('user-id', 1001, 'Update Title', 'Custom message', 'admin_message');
```

## 🛡️ Security & Permissions

### Row Level Security (RLS):
- Users can only view/edit their own profile
- Users can view all reports but only edit their own
- Admins can update any report
- Users can only view their own notifications

### Password Security:
- Passwords hashed using bcrypt
- Minimum requirements: 8 chars, uppercase, lowercase, number, special char

## 📊 Data Analytics Capabilities

### Available Analytics:

1. **Report Volume Trends**: Daily/weekly/monthly submission counts
2. **Category Analysis**: Most common issue types
3. **Resolution Performance**: Average time to resolution by category
4. **Geographic Hotspots**: Map of most reported areas
5. **User Engagement**: Registration and activity metrics
6. **Staff Performance**: Resolution rates by assigned officers

### Sample Analytics Queries:

```sql
-- Reports by month
SELECT DATE_TRUNC('month', created_at) as month, COUNT(*) 
FROM reports 
GROUP BY month 
ORDER BY month;

-- Average resolution time by category
SELECT category, AVG(completion_date - created_at) as avg_resolution_time
FROM reports 
WHERE status = 'resolved' 
GROUP BY category;

-- Top reported locations
SELECT location, COUNT(*) as report_count
FROM reports 
GROUP BY location 
ORDER BY report_count DESC 
LIMIT 10;
```

## 🚀 Getting Started with Web Development

### 1. **Database Setup**:
Run the `database_schema.sql` file in your Supabase SQL editor

### 2. **API Integration**:
Use Supabase REST API or create custom endpoints

### 3. **Real-time Updates**:
Implement Supabase real-time subscriptions for live updates

### 4. **Authentication**:
Integrate with existing user system using provided functions

---

**Note**: This database structure supports a complete civic management system with user authentication, report tracking, real-time notifications, and comprehensive analytics. The system is designed to scale and can be extended with additional features as needed.

---

## 🚨 PRIORITY MANAGEMENT SYSTEM

### Priority Management Functions

#### 1. **auto_assign_priority(category, keywords)**
Automatically determines report priority based on category and content analysis.

**Parameters:**
- `category` (TEXT): Report category name
- `keywords` (TEXT): Combined title and description for keyword analysis

**Returns:** Priority level (urgent, high, medium, low)

**Usage:**
```sql
SELECT auto_assign_priority('public_safety', 'emergency gas leak dangerous');
-- Returns: 'urgent'
```

#### 2. **submit_report_with_priority(...)**
Enhanced report submission with automatic priority assignment.

**Parameters:**
- `p_user_id` (UUID): User ID submitting the report
- `p_title` (TEXT): Report title
- `p_description` (TEXT): Report description
- `p_category` (TEXT): Report category
- `p_location` (TEXT): Location description
- `p_latitude` (DECIMAL): Optional latitude
- `p_longitude` (DECIMAL): Optional longitude
- `p_image_urls` (JSONB): Optional image URLs array
- `p_contact_number` (TEXT): Optional contact number

**Returns:** Table with report_id, assigned_priority, success, message

**Example:**
```sql
SELECT * FROM submit_report_with_priority(
    'user-uuid-here',
    'Emergency: Water main break',
    'Major water pipe burst causing flooding',
    'water_sewage',
    'Main Street intersection',
    40.7128,
    -74.0060,
    '[]'::jsonb,
    '+1-555-0123'
);
```

#### 3. **get_priority_statistics(time_period, category)**
Retrieves priority-based statistics for analytics.

**Parameters:**
- `time_period` (TEXT): 'today', 'week', 'month', 'all'
- `category` (TEXT): Optional category filter

**Returns:** Priority breakdown with counts and resolution times

**Example:**
```sql
SELECT * FROM get_priority_statistics('week', 'roads');
```

#### 4. **get_reports_by_priority(priority, status, limit, offset)**
External API function to retrieve reports filtered by priority.

**Parameters:**
- `priority` (TEXT): Priority level to filter by
- `status` (TEXT): Optional status filter
- `limit` (INTEGER): Maximum results (default 50)
- `offset` (INTEGER): Pagination offset (default 0)

**Returns:** Detailed report data with user information

**Example:**
```sql
SELECT * FROM get_reports_by_priority('urgent', 'submitted', 10, 0);
```

#### 5. **update_report_priority(report_id, new_priority, admin_id, reason)**
Admin function to update report priority with audit trail.

**Parameters:**
- `report_id` (BIGINT): Report ID to update
- `new_priority` (TEXT): New priority level
- `admin_id` (UUID): Admin user ID
- `reason` (TEXT): Optional reason for change

**Returns:** Success status and message

**Example:**
```sql
SELECT * FROM update_report_priority(
    123,
    'urgent',
    'admin-uuid-here',
    'Escalated due to safety concerns'
);
```

#### 6. **get_priority_dashboard()**
Comprehensive priority overview for external dashboards.

**Returns:** Complete priority statistics, distributions, and resolution times

**Example:**
```sql
SELECT * FROM get_priority_dashboard();
```

### Priority Levels

The system uses four priority levels with automatic assignment:

1. **URGENT** 🔴
   - Public safety issues
   - Emergency keywords detected
   - Immediate action required

2. **HIGH** 🟠
   - Water/sewage problems
   - Electrical issues
   - Safety hazards

3. **MEDIUM** 🟡
   - Road maintenance
   - Public transport issues
   - Standard infrastructure

4. **LOW** 🟢
   - Noise complaints
   - Parks/recreation
   - Non-critical issues

### Priority Assignment Logic

The system automatically assigns priorities based on:

1. **Category Default**: Each category has a default priority level
2. **Keyword Analysis**: Content is scanned for urgent keywords
3. **Escalation Rules**: Keywords can escalate priority levels

**Urgent Keywords:**
- emergency, urgent, dangerous, immediate, critical
- severe, accident, injury, fire, flood, gas leak
- power outage, water main, blocked road, traffic accident

**High Priority Keywords:**
- safety, health, hazard, damage, broken
- leak, overflow, major

### External Web Application Integration

#### Priority-Based Endpoints

**1. Get All Urgent Reports**
```javascript
// REST API equivalent
GET /api/reports?priority=urgent&status=submitted

// Direct SQL function
SELECT * FROM get_reports_by_priority('urgent', 'submitted', 20, 0);
```

**2. Priority Dashboard Data**
```javascript
// Get comprehensive priority overview
GET /api/dashboard/priority

// Direct SQL function
SELECT * FROM get_priority_dashboard();
```

**3. Update Priority (Admin)**
```javascript
// Update report priority
PUT /api/reports/123/priority
{
  "new_priority": "urgent",
  "reason": "Safety escalation"
}

// Direct SQL function
SELECT * FROM update_report_priority(123, 'urgent', 'admin-id', 'Safety escalation');
```

**4. Priority Statistics**
```javascript
// Get priority analytics
GET /api/analytics/priority?period=week&category=roads

// Direct SQL function
SELECT * FROM get_priority_statistics('week', 'roads');
```

### Sample Priority Data Access

#### Get High Priority Reports with User Data
```sql
SELECT 
    r.id,
    r.title,
    r.priority,
    r.status,
    u.full_name,
    u.email,
    r.created_at
FROM reports r
JOIN users u ON r.user_id = u.id
WHERE r.priority = 'high'
  AND r.status IN ('submitted', 'in_progress')
ORDER BY r.created_at DESC;
```

#### Priority Resolution Time Analysis
```sql
SELECT 
    priority,
    COUNT(*) as total_reports,
    AVG(EXTRACT(EPOCH FROM (completion_date - created_at)) / 3600) as avg_hours,
    MIN(EXTRACT(EPOCH FROM (completion_date - created_at)) / 3600) as min_hours,
    MAX(EXTRACT(EPOCH FROM (completion_date - created_at)) / 3600) as max_hours
FROM reports 
WHERE status = 'resolved' 
  AND completion_date IS NOT NULL
GROUP BY priority
ORDER BY 
  CASE priority
    WHEN 'urgent' THEN 1
    WHEN 'high' THEN 2
    WHEN 'medium' THEN 3
    WHEN 'low' THEN 4
  END;
```

#### Category Priority Distribution
```sql
SELECT 
    r.category,
    c.display_name,
    r.priority,
    COUNT(*) as count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY r.category), 2) as percentage
FROM reports r
JOIN categories c ON r.category = c.name
GROUP BY r.category, c.display_name, r.priority
ORDER BY r.category, 
  CASE r.priority
    WHEN 'urgent' THEN 1
    WHEN 'high' THEN 2
    WHEN 'medium' THEN 3
    WHEN 'low' THEN 4
  END;
```

---

## 🎯 PRIORITY SYSTEM SUMMARY

Your enhanced civic reporting system now includes:

✅ **Automatic Priority Assignment** - Reports automatically get priority based on category and content  
✅ **External Priority Access** - Web applications can access all priority data  
✅ **Priority Analytics** - Comprehensive statistics and dashboard data  
✅ **Admin Priority Management** - Update priorities with audit trail  
✅ **Real-time Priority Updates** - Changes instantly reflected across systems  
✅ **User Data Integration** - All priority reports linked to user name/email  

**Ready for External Integration**: Your web application can now access, analyze, and manage report priorities through the comprehensive API functions provided.