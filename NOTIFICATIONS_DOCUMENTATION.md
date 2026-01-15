# Notifications System Documentation

## Overview

The Side Line app includes a complete real-time notifications system built with Socket.IO and REST API integration. This system allows users to receive and manage notifications for events like news publications and Hall of Fame likes.

## Features

- Real-time notifications via Socket.IO WebSocket connection
- REST API for fetching notification history
- Paginated notification list
- Mark notifications as read
- In-app notification popups
- Notification badge with unread count
- Auto-reconnection on connection loss

## Architecture

### Components

```
lib/features/notifications/
├── data/
│   ├── models/
│   │   ├── notification_model.dart           # Notification data model
│   │   └── notifications_response_model.dart # API response models
│   └── repositories/
│       └── notification_repository.dart      # API calls for notifications
├── presentation/
│   └── pages/
│       └── notifications_screen.dart         # Notifications list UI
└── core/services/
    └── socket_service.dart                   # Socket.IO service
```

## Implementation Details

### 1. Socket.IO Service

**File:** `lib/core/services/socket_service.dart`

The Socket service manages WebSocket connections for real-time notifications.

**Key Features:**
- Singleton pattern for global access
- Automatic reconnection
- Event streams for notifications, connection status, and errors
- Token-based authentication

**Usage:**

```dart
// Initialize connection
final socketService = SocketService();
await socketService.connect(accessToken);

// Listen for notifications
socketService.notificationStream.listen((notification) {
  print('Received: ${notification.title}');
});

// Listen for connection status
socketService.connectionStatusStream.listen((isConnected) {
  print('Connected: $isConnected');
});

// Disconnect
await socketService.disconnect();
```

### 2. Notification Models

**File:** `lib/features/notifications/data/models/notification_model.dart`

**NotificationModel:**
```dart
NotificationModel({
  required String id,
  required String userId,
  required NotificationType type,
  required String title,
  required String body,
  NotificationData? data,
  required bool read,
  required DateTime sentAt,
  required DateTime createdAt,
  DateTime? updatedAt,
})
```

**Notification Types:**
- `NEWS_PUBLISHED` - New article published for user's favorite team
- `HOF_LIKED` - Someone liked user's Hall of Fame entry
- `UNKNOWN` - Unknown notification type

**NotificationData:**
```dart
NotificationData({
  String? newsId,     // For NEWS_PUBLISHED
  String? teamId,     // Team associated with notification
  String? hofId,      // For HOF_LIKED
  Map<String, dynamic>? extras,  // Additional data
})
```

### 3. Notification Repository

**File:** `lib/features/notifications/data/repositories/notification_repository.dart`

Handles all notification-related API calls.

**Methods:**

```dart
// Get paginated notifications
Future<NotificationsResponseModel> getNotifications({
  int page = 1,
  int limit = 20,
});

// Mark notification as read
Future<NotificationModel> markAsRead(String notificationId);

// Get unread count
Future<int> getUnreadCount();

// Delete notification
Future<void> deleteNotification(String notificationId);
```

**Usage:**

```dart
final repository = NotificationRepository();

// Fetch first page
final response = await repository.getNotifications(page: 1, limit: 20);
print('Total: ${response.pagination.totalCount}');

// Mark as read
await repository.markAsRead(notificationId);
```

### 4. Notifications Screen

**File:** `lib/features/notifications/presentation/pages/notifications_screen.dart`

Displays a paginated list of user notifications.

**Features:**
- Pull-to-refresh
- Infinite scroll pagination
- Mark as read on tap
- Visual distinction for unread notifications
- Empty state handling
- Error handling with retry

### 5. Real-time Integration

**File:** `lib/features/marketplace/presentation/pages/marketplace_screen.dart`

The marketplace screen initializes the Socket.IO connection and displays notifications.

**Implementation:**

```dart
// Initialize in initState
Future<void> _initializeSocketConnection() async {
  final accessToken = await AuthStorageService.getAccessToken();
  if (accessToken != null) {
    await _socketService.connect(accessToken);

    // Listen for notifications
    _socketService.notificationStream.listen((notification) {
      _handleIncomingNotification(notification);
    });
  }
}

// Handle incoming notification
void _handleIncomingNotification(NotificationModel notification) {
  setState(() {
    _unreadNotifications++;
  });

  // Show in-app SnackBar
  ScaffoldMessenger.of(context).showSnackBar(/* ... */);
}
```

## API Endpoints

### Socket.IO Connection

**URL:** `wss://sportsapp-server.vercel.app`

**Connection:**
```dart
// Token passed as query parameter
socket.io('https://sportsapp-server.vercel.app', {
  query: { token: accessToken }
});
```

**Events:**
- `connect` - Connection established
- `disconnect` - Connection closed
- `notification` - New notification received
- `authentication` - Authentication status
- `error` - Error occurred
- `connect_error` - Connection failed
- `reconnect` - Reconnected after disconnect
- `reconnect_failed` - Reconnection failed

### REST API

**Base URL:** `https://sportsapp-server.vercel.app/api`

#### Get Notifications

```
GET /notifications?page=1&limit=20
Authorization: Bearer <accessToken>
```

**Response:**
```json
{
  "data": [
    {
      "_id": "string",
      "userId": "string",
      "type": "NEWS_PUBLISHED",
      "title": "Lakers News",
      "body": "New article published",
      "data": {
        "newsId": "...",
        "teamId": "..."
      },
      "read": false,
      "sentAt": "2026-01-15T10:30:00Z",
      "createdAt": "2026-01-15T10:30:00Z"
    }
  ],
  "pagination": {
    "currentPage": 1,
    "totalPages": 5,
    "totalCount": 92,
    "limit": 20
  }
}
```

#### Mark as Read

```
PUT /notifications/:id/read
Authorization: Bearer <accessToken>
```

**Response:**
```json
{
  "message": "Notification marked as read",
  "notification": { /* ... */ }
}
```

## UI Components

### Notification Bell Icon

**Location:** Top-right corner of marketplace screen

**Features:**
- Glassmorphism design
- Red badge showing unread count
- Badge disappears when notifications are viewed
- Badge shows "99+" for counts over 99

### Notification Card

**Features:**
- Icon based on notification type
- Colored background (blue for news, red for HOF)
- Title and body text
- Time ago (e.g., "2 hours ago")
- Blue dot indicator for unread notifications
- Bold text for unread, normal for read

### In-app Notification

**When received:**
- SnackBar appears at bottom
- Shows notification icon, title, and body
- "View" button navigates to notifications screen
- Auto-dismisses after 4 seconds
- Incrementsuread badge count

## User Flow

1. **User logs in**
   - Socket.IO connection established automatically
   - Access token sent for authentication

2. **Notification arrives (real-time)**
   - Socket receives notification event
   - In-app SnackBar displayed
   - Unread badge incremented
   - Notification stored on server

3. **User taps notification bell**
   - Navigate to notifications screen
   - Unread badge resets to 0
   - Fetch notifications from API (page 1)

4. **User views notification**
   - Tap on notification card
   - Mark as read API called
   - Visual state updates (bold → normal)
   - Navigate to relevant content (if applicable)

5. **User scrolls down**
   - Pagination triggered near bottom
   - Next page fetched from API
   - New notifications appended to list

## Error Handling

### Connection Errors

**Scenarios:**
- Server unreachable
- Invalid token
- Network timeout
- Reconnection failures

**Handling:**
- Automatic reconnection (5 attempts, 2-second delay)
- Error stream for monitoring
- Graceful fallback to REST API only
- User notification if persistent

### API Errors

**Status Codes:**
- `401` - Unauthorized (token invalid/expired)
- `403` - Forbidden (email not verified)
- `404` - Notification not found
- `500` - Server error

**Handling:**
- Display error message to user
- Retry button for failed requests
- Automatic token refresh on 401
- Fallback to cached data if available

## Configuration

### Socket.IO Settings

**File:** `lib/core/services/socket_service.dart`

```dart
IO.OptionBuilder()
  .setTransports(['websocket'])    // Use WebSocket only
  .enableAutoConnect()             // Auto-connect on init
  .enableReconnection()            // Enable reconnection
  .setReconnectionAttempts(5)      // Max 5 attempts
  .setReconnectionDelay(2000)      // 2 second delay
  .setQuery({'token': accessToken}) // Auth token
  .build()
```

### Pagination Settings

**File:** `lib/features/notifications/presentation/pages/notifications_screen.dart`

```dart
// Default page size
final limit = 20;

// Trigger pagination when 200px from bottom
if (scrollPosition >= maxScrollExtent - 200) {
  _loadMoreNotifications();
}
```

## Testing

### Manual Testing

1. **Real-time Notifications:**
   - Login to app
   - Trigger notification from backend/admin panel
   - Verify SnackBar appears
   - Verify badge increments

2. **Notification List:**
   - Tap bell icon
   - Verify list loads
   - Scroll to bottom for pagination
   - Pull down to refresh

3. **Mark as Read:**
   - Tap unread notification (bold)
   - Verify it changes to normal weight
   - Verify blue dot disappears

4. **Connection Loss:**
   - Disable network
   - Re-enable network
   - Verify auto-reconnection
   - Verify notifications still work

### Integration Testing

```dart
// Test notification received
test('handles incoming notification', () async {
  final socketService = SocketService();
  await socketService.connect(testToken);

  socketService.notificationStream.listen(expectAsync1((notification) {
    expect(notification.title, isNotEmpty);
    expect(notification.type, isNotNull);
  }));
});

// Test API fetch
test('fetches notifications', () async {
  final repository = NotificationRepository();
  final response = await repository.getNotifications(page: 1);

  expect(response.data, isNotEmpty);
  expect(response.pagination.currentPage, equals(1));
});
```

## Troubleshooting

### Socket not connecting

**Issue:** Socket.IO connection fails

**Solutions:**
1. Verify server URL is correct
2. Check access token is valid
3. Ensure network connectivity
4. Check server logs for errors
5. Verify firewall allows WebSocket connections

### Notifications not appearing

**Issue:** Real-time notifications not received

**Solutions:**
1. Check socket connection status
2. Verify token authentication succeeded
3. Check error stream for messages
4. Ensure notification listener is active
5. Test with REST API as fallback

### Pagination not working

**Issue:** Cannot load more notifications

**Solutions:**
1. Check network requests in debugger
2. Verify pagination.hasMore is true
3. Check for API errors
4. Verify scroll controller is attached
5. Check loading state management

## Future Enhancements

- [ ] Local notification persistence (SQLite)
- [ ] Notification categories/filtering
- [ ] Notification preferences/settings
- [ ] Sound/vibration for notifications
- [ ] Deep linking from notifications
- [ ] Bulk mark as read
- [ ] Delete all notifications
- [ ] Search notifications
- [ ] Notification grouping by type
- [ ] Rich media notifications (images, videos)

## Dependencies

```yaml
dependencies:
  socket_io_client: ^2.0.3+1  # Socket.IO client
  dio: ^5.4.0                  # HTTP client
  timeago: ^3.7.0              # Time formatting
```

## Support

For issues or questions:
- Check server logs for WebSocket errors
- Monitor Socket.IO connection status
- Use error streams for debugging
- Test REST API independently
- Review network traffic in debug mode

---

**Last Updated:** 2026-01-15
**Version:** 1.0.0
**Status:** Production Ready
