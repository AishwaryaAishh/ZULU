//testing
// Import required modules
import fs from "fs";
import http from "http";
import https from "https";
import { Server as SocketIOServer } from "socket.io";
import Ajv from "ajv";
import jwt from "jsonwebtoken";
import crypto from "crypto";
import { MyApp } from "./zulu.js";

const myApp = new MyApp();

// Define WebSocketServer class
class WebSocketServer {
  constructor(
    ajv,
    expectedFormat,
    io,
    server,
    yourSecretKey,
    publicKeyPath,
    privateKey
  ) {
    this.ajv = ajv;
    this.expectedFormat = expectedFormat;
    this.io = io;
    this.server = server;
    this.yourSecretKey = yourSecretKey;
    this.publicKeyPath = publicKeyPath;
    this.privateKey = privateKey;
  }

  initializeSocketIO() {
    this.io.on("connection", (socket) => this.handleConnection(socket));
  }

  handleConnection(socket) {
    console.log("A client connected");

    // Generate a unique token for each connection
    const authToken = jwt.sign({ userId: socket.id }, this.yourSecretKey);
    socket.emit("auth", authToken); // Send the authentication token to the client

    // Store the auth token in the socket object
    socket.authToken = authToken;
    socket.isAuthenticated = false;

    // Get client type from headers
    const clientType = socket.handshake.headers["clienttype"];

    socket.on("token_for_verification", (auth_token) => {
      try {
        const decoded = jwt.verify(auth_token, this.yourSecretKey);

        // Set isAuthenticated variable to true
        if (decoded.userId === socket.id) {
          socket.isAuthenticated = true;
        }
      } catch (err) {
        console.log("Authentication failed:", err.message);
        // Handle authentication failure
      }
    });

    socket.on("data", (encryptedData) => {
      this.handleData(socket, encryptedData, clientType);
    });

    socket.on("disconnect", () => {
      console.log("A client disconnected");
    });
  }

  handleData(socket, encryptedData, clientType) {
    try {
      if (socket.isAuthenticated) {
        const decryptedData = this.decryptData(encryptedData);
        if (decryptedData) {
          const data = JSON.parse(decryptedData);

          // Check the client type and perform corresponding actions
          this.io.emit("client_data", data);
          if (clientType === "flutter") {
            this.io.emit("client_data", data);
          } else if (clientType === "Python") {
            if (this.isValidFormat(data)) {
              console.log("Received data from Python client:", data);
            }
          } else {
            console.log("Unknown client type:", clientType);
          }
        } else {
          console.log("Error decrypting data");
        }
      } else {
        console.log("Unauthorized data received. Authentication required.");
        // Handle unauthorized data (e.g., disconnect the client)
      }
    } catch (error) {
      console.error("Error processing data:", error);
    }
  }

  isValidFormat(data) {
    const validate = this.ajv.compile(this.expectedFormat);
    const isValid = validate(data);

    if (!isValid) {
      console.error("Validation error:", validate.errors);
    }

    return isValid;
  }

  startServer(port) {
    this.server.listen(port, () => {
      console.log(`Server listening on port ${port}`);
    });
  }

  decryptData(encryptedData) {
    try {
      const buffer = Buffer.from(encryptedData, "base64");
      const decryptedData = crypto.privateDecrypt(
        {
          key: this.privateKey,
          padding: crypto.constants.RSA_PKCS1_OAEP_PADDING,
          oaepHash: "sha256",
        },
        buffer
      );
      return decryptedData.toString("utf8");
    } catch (error) {
      console.log("Error decrypting data:", error);
      return null;
    }
  }
}

/// Generate RSA private and public keys
const { publicKey, privateKey } = crypto.generateKeyPairSync("rsa", {
  modulusLength: 2048,
});

// Export keys to PEM format
const publicKeyPem = publicKey.export({ type: "spki", format: "pem" });
const privateKeyPem = privateKey.export({ type: "pkcs8", format: "pem" });

// Save the public key to a .pem file
fs.writeFileSync("C:/Users/Aishh B/Desktop/project/certificate/public_key.pem", publicKeyPem);
// Server setup and instantiation
const ajv = new Ajv();
const expectedFormat = loadJsonFormat("dataSchema.json");
const server = createServer(
  "https://localhost:8080",
  "C:/Users/Aishh B/Desktop/project/certificate/MyServer.crt",
  "C:/Users/Aishh B/Desktop/project/certificate/MyServer.key"
);
const io = new SocketIOServer(server);
const yourSecretKey = "zulu";

const webSocketServer = new WebSocketServer(
  ajv,
  expectedFormat,
  io,
  server,
  yourSecretKey,
  publicKeyPem, // Pass the public key directly
  privateKeyPem
);
webSocketServer.startServer(8080);
webSocketServer.initializeSocketIO();

function loadJsonFormat(jsonPath) {
  try {
    const jsonFormat = fs.readFileSync(jsonPath, "utf8");
    return JSON.parse(jsonFormat);
  } catch (error) {
    console.error(`Error loading JSON format from ${jsonPath}:`, error.message);
    return null;
  }
}

function createServer(serverUrl, sslCertPath, sslKeyPath) {
  try {
    return serverUrl.startsWith("https")
      ? https.createServer({
          key: fs.readFileSync(sslKeyPath),
          cert: fs.readFileSync(sslCertPath),
          passphrase: "zulu",
        })
      : http.createServer();
  } catch (error) {
    console.error("Error creating server:", error.message);
    return null;
  }
}