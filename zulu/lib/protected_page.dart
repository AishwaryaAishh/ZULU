import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ProtectedPage extends StatefulWidget {
  final String token;
  ProtectedPage({required this.token});

  @override
  _ProtectedPageState createState() => _ProtectedPageState();
}

class _ProtectedPageState extends State<ProtectedPage>
    with WidgetsBindingObserver {
  late IO.Socket socket;
  bool isConnected = false;
  List<dynamic> receivedData = [];
  bool _isMounted = false; // Track if the widget is mounted

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Add observer
    _isMounted = true;
    initializeSocket();
    // Set _isMounted to true
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Remove observer
    disconnectFromSocket();
    _isMounted = false; // Set _isMounted to false
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ProtectedPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.token != oldWidget.token) {
      disconnectFromSocket();
      initializeSocket();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      disconnectFromSocket();
    }
  }

  void initializeSocket() {
    socket = IO.io('https://localhost:8080', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'extraHeaders': {
        'clienttype': 'flutter',
        'Authorization': 'Bearer ${widget.token}' // Use token in extraHeaders
      },
    });

    socket.onConnect((data) {
      if (_isMounted) {
        setState(() {
          isConnected = true;
          receivedData.clear();
        });
      }
      print('Connected to server');

      // Listen for the 'client_data' event and add the received data to the list
      socket.on('client_data', (data) {
        if (_isMounted) {
          setState(() {
            receivedData.add(data);
          });
        }
        print('Received data from server: $data');
      });
    });

    socket.onDisconnect((data) {
      if (_isMounted) {
        setState(() {
          isConnected = false;
          receivedData.clear();
        });
      }
      print('Disconnected from server');

      // Remove event listeners and close the socket
      socket.off('client_data');
      socket.close();
    });
  }

  void connectToSocket() {
    // Clear receivedData before connecting to socket
    receivedData.clear();

    if (!isConnected) {
      socket.connect();
    } else {
      print('Already connected to the server');
    }

    // Navigate to the map page when connected or already connected
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapPage(
          receivedData: receivedData,
          disconnectCallback: disconnectFromSocket,
        ),
      ),
    );
  }

  void disconnectFromSocket() {
    if (isConnected) {
      // Disconnect the socket.
      socket.disconnect();
      // Close the socket
      socket.close();
      // Update the isConnected flag
      setState(() {
        isConnected = false;
      });
      // Clear the received data
      receivedData.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        disconnectFromSocket();
        return true; // Return true to allow the back button action
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Socket.IO Example'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: connectToSocket,
                child: Text('Connect'),
              ),
              SizedBox(height: 16.0),
              Text(
                isConnected
                    ? 'Connected to server'
                    : 'Disconnected from server',
                style: TextStyle(fontSize: 18.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MapPage extends StatelessWidget {
  final List<dynamic> receivedData;
  final VoidCallback disconnectCallback;

  MapPage({required this.receivedData, required this.disconnectCallback});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        disconnectCallback(); // Disconnect from the socket
        return true; // Allow navigation back
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Map View'),
          actions: [
            IconButton(
              onPressed: () {
                disconnectCallback(); // Disconnect from the socket
                Navigator.pop(context); // Navigate away from the map page
              },
              icon: Icon(Icons.close),
            ),
          ],
        ),
        body: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(0, 0),
                zoom: 2.0,
              ),
              markers: _buildMarkers(receivedData),
            ),
            Positioned(
              left: 16.0,
              bottom: 16.0,
              child: FloatingActionButton(
                onPressed: () {
                  disconnectCallback(); // Disconnect from the socket
                  Navigator.pop(context); // Navigate away from the map page
                },
                child: Icon(Icons.clear), // Use clear icon for cross mark
              ),
            ),
          ],
        ),
      ),
    );
  }

  Set<Marker> _buildMarkers(List<dynamic> receivedData) {
    Set<Marker> markers = {};
    for (int i = 0; i < receivedData.length; i++) {
      Map<String, dynamic> data = jsonDecode(receivedData[i]);
      markers.add(
        Marker(
          markerId: MarkerId('marker_$i'),
          position: LatLng(data['latitude'], data['longitude']),
          infoWindow: InfoWindow(
            title: 'Data ${i + 1}',
            snippet:
                'Latitude: ${data['latitude']}, Longitude: ${data['longitude']}',
          ),
        ),
      );
    }
    return markers;
  }
}
