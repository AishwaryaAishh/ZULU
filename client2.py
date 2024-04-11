import asyncio
import json
import aiohttp
import socketio
import ssl
from pymavlink import mavutil
from cryptography.hazmat.primitives import serialization, hashes
from cryptography.hazmat.primitives.asymmetric import padding
from cryptography.hazmat.backends import default_backend


class MAVLinkHandler:
    def __init__(self, port, server_url, baud_rate=115200):
        self.master = mavutil.mavlink_connection(port, baud=baud_rate)
        self.master.wait_heartbeat()
        self.server_url = server_url

    def receive_location_data(self):
        try:
            self.master.wait_heartbeat()
            # Request data stream from the flight control
            self.master.mav.request_data_stream_send(1, 0, mavutil.mavlink.MAV_DATA_STREAM_ALL, 4, 1)
            self.master.wait_heartbeat()

            msg = self.master.recv_match(type='GLOBAL_POSITION_INT', blocking=True)

            # Check if the received message is GLOBAL_POSITION_INT
            if msg and msg.get_type() == 'GLOBAL_POSITION_INT':
                latitude = msg.lat / 1e7
                longitude = msg.lon / 1e7
                altitude = msg.alt / 1e3
                speed = msg.vx / 100

                return {
                    "latitude": latitude,
                    "longitude": longitude,
                    "altitude": altitude,
                    "speed": speed
                }
            else:
                print("Error receiving location data: Invalid message type")
                return None

        except Exception as e:
            print(f"Error receiving location data: {e}")
            return None


class WebSocketCommunication:
    def __init__(self, server_url, clienttype, ssl_cert_path, ssl_key_path, ca_cert_path, public_key_path):
        # Set up SSL context for secure WebSocket connection
        ssl_context = ssl.SSLContext(ssl.PROTOCOL_TLS_CLIENT)
        ssl_context.load_cert_chain(ssl_cert_path, ssl_key_path)
        ssl_context.load_verify_locations(cafile=ca_cert_path)
        
        connector = aiohttp.TCPConnector(ssl=ssl_context)

        # Create AsyncClient instance for WebSocket communication
        self.sio = socketio.AsyncClient(http_session=aiohttp.ClientSession(connector=connector))
        
        self.server_url = server_url
        self.clienttype = clienttype

        self.auth_token = None
        self.token_received = False  # Flag to track authentication status

        # Load public key from PEM file
        with open(public_key_path, "rb") as key_file:
            self.public_key = serialization.load_pem_public_key(
                key_file.read(),
                backend=default_backend()
            )

        # Event handler for receiving the authentication token
        @self.sio.event
        async def auth(token):
            self.auth_token = token
            self.token_received = True  # Set the flag when the token is available

        # Event handler for handling disconnection from the server
        @self.sio.event
        async def disconnect():
            print('Disconnected from the server')
            if not self.sio.connected:  # Check if the client is not already connected
                await self.connect_websocket()

    async def connect_websocket(self):
        try:
            # Include client type in the headers
            headers = {'clienttype': self.clienttype}
            await self.sio.connect(self.server_url, headers=headers)
        except Exception as e:
            print(f"Error connecting to WebSocket: {e}")

    async def encrypt_data(self, json_data):
        if self.public_key is None:
            print("Public key not available. Cannot encrypt data.")
            return None

        encrypted_data = self.public_key.encrypt(
            json_data.encode(),
            padding.OAEP(
                mgf=padding.MGF1(algorithm=hashes.SHA256()),
                algorithm=hashes.SHA256(),
                label=None
            )
        )
        return encrypted_data

    async def send_location_data(self, mavlink_handler):
        await self.connect_websocket()

        try:
            while True:
                while not self.token_received:
                    await asyncio.sleep(1)

                location_data = mavlink_handler.receive_location_data()

                await self.sio.emit('token_for_verification', self.auth_token)
                if location_data:
                    json_data = json.dumps(location_data)
                    encrypted_data = await self.encrypt_data(json_data)
                    await self.sio.emit('data', encrypted_data)
                    print(f"Sent authenticated data to server: {encrypted_data}")

                    await asyncio.sleep(1)

        except Exception as e:
            print(f"WebSocket connection error: {e}")

        finally:
            await self.sio.disconnect()
            print("WebSocket connection closed.")


class WebHandler:
    def __init__(self, server_url, clienttype, ssl_cert_path, ssl_key_path, ca_cert_path, public_key_path):
        self.mavlink_handler = MAVLinkHandler("COM8", server_url)
        self.websocket_communication = WebSocketCommunication(server_url, clienttype, ssl_cert_path, ssl_key_path, ca_cert_path, public_key_path)

    async def send_location_data(self):
        await self.websocket_communication.send_location_data(self.mavlink_handler)


async def main():
    try:
        server_url = "https://localhost:8080"
        clienttype = "Python"
        ssl_cert_path = 'C:/Users/Aishh B/Desktop/project/certificate/MyServer.crt'
        ssl_key_path = 'C:/Users/Aishh B/Desktop/project/certificate/MyServer.key'
        public_key_path = 'C:/Users/Aishh B/Desktop/project/certificate/public_key.pem'
        ca_cert_path = "C:/Users/Aishh B/Desktop/project/certificate/MyOrg-RootCA.crt"
        
        web_handler = WebHandler(server_url, clienttype, ssl_cert_path, ssl_key_path, ca_cert_path, public_key_path)
        await web_handler.send_location_data()
    finally:
        # Close the client session
        await web_handler.websocket_communication.sio.disconnect()


if __name__ == "__main__":
    asyncio.run(main())