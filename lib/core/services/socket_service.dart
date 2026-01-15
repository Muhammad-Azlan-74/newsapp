import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:newsapp/core/network/api_endpoints.dart';
import 'package:newsapp/features/user/data/models/notification_model.dart';

/// Socket Service
///
/// Manages WebSocket connection for real-time notifications
class SocketService {
  // Singleton instance
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  String? _accessToken;

  // Stream controllers for notifications
  final _notificationController = StreamController<NotificationModel>.broadcast();
  final _connectionStatusController = StreamController<bool>.broadcast();
  final _errorController = StreamController<String>.broadcast();

  // Streams
  Stream<NotificationModel> get notificationStream => _notificationController.stream;
  Stream<bool> get connectionStatusStream => _connectionStatusController.stream;
  Stream<String> get errorStream => _errorController.stream;

  // Connection status
  bool get isConnected => _socket?.connected ?? false;

  /// Initialize and connect to Socket.IO server
  Future<void> connect(String accessToken) async {
    // Disconnect if already connected
    if (_socket != null) {
      await disconnect();
    }

    _accessToken = accessToken;

    try {
      debugPrint('🔌 Connecting to Socket.IO server...');

      // Use base URL directly - Socket.IO expects full URL
      final baseUrl = ApiEndpoints.baseUrl;

      debugPrint('🔗 Socket.IO URL: $baseUrl');

      // Initialize socket with configuration (v3.x API)
      // IMPORTANT: Use polling only, disable auto-upgrade to websocket
      _socket = IO.io(
        baseUrl,
        <String, dynamic>{
          'transports': ['polling'], // Use polling only
          'upgrade': false, // CRITICAL: Disable auto-upgrade to websocket
          'autoConnect': false, // Manual connection
          'reconnection': true, // Enable reconnection
          'reconnectionAttempts': 5, // Max reconnection attempts
          'reconnectionDelay': 2000, // Delay between attempts (ms)
          'reconnectionDelayMax': 5000, // Max delay
          'timeout': 20000, // Connection timeout
          'forceNew': true, // Force new connection
          'multiplex': false, // Disable multiplexing
          'path': '/socket.io/', // Explicit Socket.IO path
        },
      );

      _setupEventListeners();

      // Manually connect
      _socket!.connect();

      debugPrint('✅ Socket.IO initialized and connecting...');
    } catch (e) {
      debugPrint('❌ Socket.IO initialization error: $e');
      _errorController.add('Failed to initialize socket connection: $e');
    }
  }

  /// Setup event listeners
  void _setupEventListeners() {
    if (_socket == null) return;

    // Connection established
    _socket!.on('connect', (_) {
      debugPrint('✅ Socket.IO connected');
      debugPrint('Socket ID: ${_socket!.id}');
      _connectionStatusController.add(true);

      // Send authentication via emit event
      if (_accessToken != null) {
        debugPrint('🔐 Sending authentication token...');
        _socket!.emit('authenticate', {'token': _accessToken});
      }
    });

    // Connection error
    _socket!.on('connect_error', (error) {
      debugPrint('❌ Socket.IO connection error: $error');
      debugPrint('Connection error type: ${error.runtimeType}');
      if (error is Map) {
        debugPrint('Error details: $error');
      }
      _errorController.add('Connection error: $error');
      _connectionStatusController.add(false);
    });

    // Disconnected
    _socket!.on('disconnect', (reason) {
      debugPrint('🔌 Socket.IO disconnected: $reason');
      _connectionStatusController.add(false);
    });

    // Authentication response
    _socket!.on('authentication', (data) {
      if (data['success'] == true) {
        debugPrint('✅ Socket.IO authenticated');
      } else {
        debugPrint('❌ Socket.IO authentication failed: ${data['message']}');
        _errorController.add('Authentication failed: ${data['message']}');
      }
    });

    // Notification received
    _socket!.on('notification', (data) {
      try {
        debugPrint('📬 Notification received: $data');

        // Parse notification - data already comes in the correct format
        final notification = NotificationModel.fromJson({
          '_id': data['notificationId'] ?? data['_id'] ?? '',
          'type': data['type'] ?? 'UNKNOWN',
          'title': data['title'] ?? '',
          'body': data['body'] ?? '',
          'data': data['data'],
          'read': false,
          'sentAt': data['sentAt'] ?? DateTime.now().toIso8601String(),
          'createdAt': data['createdAt'] ?? DateTime.now().toIso8601String(),
        });

        _notificationController.add(notification);
      } catch (e) {
        debugPrint('❌ Error parsing notification: $e');
        _errorController.add('Error parsing notification: $e');
      }
    });

    // General error
    _socket!.on('error', (error) {
      debugPrint('❌ Socket.IO error: $error');
      _errorController.add('Socket error: $error');
    });

    // Reconnection attempt
    _socket!.on('reconnect_attempt', (attemptNumber) {
      debugPrint('🔄 Reconnection attempt #$attemptNumber');
    });

    // Reconnected
    _socket!.on('reconnect', (attemptNumber) {
      debugPrint('✅ Reconnected after $attemptNumber attempts');
      _connectionStatusController.add(true);
    });

    // Reconnection error
    _socket!.on('reconnect_error', (error) {
      debugPrint('❌ Reconnection error: $error');
    });

    // Reconnection failed
    _socket!.on('reconnect_failed', (_) {
      debugPrint('❌ Reconnection failed after all attempts');
      _errorController.add('Failed to reconnect to server');
    });

    // Transport upgrade (polling → websocket)
    _socket!.on('upgrade', (transport) {
      debugPrint('⬆️ Transport upgraded to: $transport');
    });

    // Ping/pong for connection health
    _socket!.on('ping', (_) {
      debugPrint('🏓 Ping');
    });

    _socket!.on('pong', (latency) {
      debugPrint('🏓 Pong (latency: ${latency}ms)');
    });
  }

  /// Emit authentication event (if token not sent in query)
  void authenticate() {
    if (_socket == null || _accessToken == null) return;

    debugPrint('🔐 Authenticating socket...');
    _socket!.emit('authenticate', {'token': _accessToken});
  }

  /// Disconnect from Socket.IO server
  Future<void> disconnect() async {
    if (_socket == null) return;

    try {
      debugPrint('🔌 Disconnecting from Socket.IO...');
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      _accessToken = null;
      _connectionStatusController.add(false);
      debugPrint('✅ Socket.IO disconnected');
    } catch (e) {
      debugPrint('❌ Error disconnecting socket: $e');
    }
  }

  /// Reconnect with new token
  Future<void> reconnectWithToken(String newAccessToken) async {
    await disconnect();
    await connect(newAccessToken);
  }

  /// Dispose resources
  void dispose() {
    disconnect();
    _notificationController.close();
    _connectionStatusController.close();
    _errorController.close();
  }
}
