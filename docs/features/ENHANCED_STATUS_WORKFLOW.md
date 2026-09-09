# Enhanced Status Workflow System

## Overview
CivicResolve now includes a comprehensive status workflow system that allows reports to progress through multiple states with automatic notifications when status changes occur.

## Status Workflow

### Available Statuses
1. **📝 Submitted** (submitted)
   - Initial state when a report is first created
   - Color: Blue (#3498db)
   - Transitions to: under_review, rejected

2. **👁️ Under Review** (under_review)
   - Report is being evaluated by administrators
   - Color: Orange (#f39c12)
   - Transitions to: assigned, rejected, submitted

3. **👤 Assigned** (assigned)
   - Report has been assigned to a specific officer/department
   - Color: Purple (#9b59b6)
   - Transitions to: in_progress, under_review

4. **⚙️ In Progress** (in_progress)
   - Work is actively being done on the report
   - Color: Green (#2ecc71)
   - Transitions to: resolved, assigned

5. **✅ Resolved** (resolved)
   - Issue has been fixed/addressed
   - Color: Dark Green (#27ae60)
   - Transitions to: closed, in_progress

6. **🔒 Closed** (closed)
   - Report is fully completed and archived
   - Color: Dark Gray (#34495e)
   - Final state - no transitions

7. **❌ Rejected** (rejected)
   - Report was declined/invalid
   - Color: Red (#e74c3c)
   - Final state - no transitions

## Workflow Rules

### Valid Transitions
- **submitted** → under_review, rejected
- **under_review** → assigned, rejected, submitted
- **assigned** → in_progress, under_review
- **in_progress** → resolved, assigned
- **resolved** → closed, in_progress
- **closed** → (final state)
- **rejected** → (final state)

### Validation
- Status transitions are validated before allowing changes
- Invalid transitions will show error messages
- Only valid next states appear in status dropdowns
- Current status is always shown as selected

## Notification System

### Automatic Notifications
When a report status changes, the system automatically:
1. Creates a notification record
2. Includes report ID, old status, new status
3. Sends notification to the report submitter
4. Stores notification with timestamp

### Notification Features
- **Demo Mode**: Notifications stored in localStorage
- **Production Mode**: Notifications stored in Supabase database
- **User-Friendly Messages**: Clear status change descriptions
- **Icons and Colors**: Visual indicators for each status
- **Read/Unread Tracking**: Mark notifications as read

### Notification Methods
```javascript
// Send notification when status changes
await sendStatusChangeNotification(reportId, oldStatus, newStatus, userEmail);

// Get user notifications
await getUserNotifications(userEmail, limit);

// Mark notification as read
await markNotificationRead(notificationId);
```

## UI Enhancements

### Dynamic Status Dropdowns
- Show only valid transitions for current status
- Include status icons and colors
- Prevent invalid status changes

### Enhanced Status Badges
- Color-coded status indicators
- Status icons for quick recognition
- Smooth transitions and animations
- Consistent styling throughout dashboard

### Status Display Locations
1. **Dashboard Cards**: Recent reports overview
2. **Reports Table**: All reports listing
3. **Report Modal**: Detailed report view
4. **Status Dropdowns**: Admin action panels

## Database Integration

### Demo Mode Support
- Uses localStorage for persistence
- Maintains full functionality offline
- Perfect for testing and development

### Production Mode
- Integrates with Supabase PostgreSQL
- Real-time notifications
- Scalable for production use

## Usage Examples

### Updating Report Status
```javascript
// Update with validation and notifications
await updateReportStatus(reportId, newStatus, adminNotes, assignedOfficer);
```

### Getting Available Transitions
```javascript
// Get valid next states for a report
const transitions = getAvailableTransitions(currentStatus);
```

### Checking Workflow Rules
```javascript
// Get complete workflow definition
const workflow = getStatusWorkflow();
```

## Benefits

1. **Clear Process**: Defined workflow makes status progression clear
2. **User Communication**: Automatic notifications keep users informed
3. **Data Integrity**: Validation prevents invalid status changes
4. **Admin Efficiency**: Smart dropdowns show only valid options
5. **Audit Trail**: Track status changes with timestamps
6. **Visual Clarity**: Color-coded status system for quick recognition

## Testing

The system is now running at http://localhost:8000 with:
- ✅ Enhanced status workflow implemented
- ✅ Notification system functional
- ✅ UI updated with dynamic status management
- ✅ CSS styling for all 7 status types
- ✅ Validation and error handling

You can test the workflow by:
1. Logging in with admin/1234
2. Viewing existing reports
3. Changing report statuses through the workflow
4. Observing status badges and notifications
5. Testing invalid transitions (should show errors)

## Future Enhancements

1. **Email Notifications**: Send actual emails to users
2. **Status History**: Track all status changes over time
3. **Role-Based Transitions**: Different permissions for different users
4. **Bulk Status Updates**: Update multiple reports at once
5. **Custom Workflows**: Configurable workflows for different report types