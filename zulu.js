import express from "express";
import bodyParser from "body-parser";
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import cors from "cors";
import { Sequelize, DataTypes } from "sequelize";
import https from "https";
import fs from "fs";

class MyApp {
  constructor() {
    this.app = express();
    this.port = 3000;
    this.setupMiddlewares();
    this.setupRoutes();
    this.setupDatabase();
    this.setupServer();
  }

  async setupMiddlewares() {
    this.app.use(bodyParser.json());
    this.app.use(cors());
  }

  setupRoutes() {
    this.app.post("/register", this.register.bind(this));
    this.app.post("/login", this.login.bind(this));
    this.app.get(
      "/protected",
      this.authenticateToken.bind(this),
      this.protected.bind(this)
    );
  }

  async setupDatabase() {
    const sequelize = new Sequelize("", "root", "Aishu", {
      host: "localhost",
      dialect: "mysql",
      logging: false,
    });

    try {
      await sequelize.authenticate();
      console.log("Connected to MySQL server");

      await sequelize.query("CREATE DATABASE IF NOT EXISTS `usersdb`");
      console.log("Database created or successfully checked.");

      await sequelize.close();
    } catch (error) {
      console.error("Error connecting to MySQL server:", error);
    }

    this.sequelize = new Sequelize("usersdb", "root", "Aishu", {
      host: "localhost",
      dialect: "mysql",
      logging: false,
    });

    this.UserName = this.sequelize.define("UserName", {
      id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true,
      },
      user: {
        type: DataTypes.STRING,
        allowNull: false,
      },
    });

    this.UserEmail = this.sequelize.define(
      "UserEmail",
      {
        email: {
          type: DataTypes.STRING,
          allowNull: false,
        },
      },
      { timestamps: false }
    );

    this.UserPassword = this.sequelize.define(
      "UserPassword",
      {
        password: {
          type: DataTypes.STRING,
          allowNull: false,
        },
      },
      { timestamps: false }
    );

    this.UserEmail.belongsTo(this.UserName, { foreignKey: "UserNameId" });
    this.UserName.hasOne(this.UserEmail, { foreignKey: "UserNameId" });

    this.UserPassword.belongsTo(this.UserName, { foreignKey: "UserNameId" });
    this.UserName.hasOne(this.UserPassword, { foreignKey: "UserNameId" });

    try {
      await this.sequelize.sync();
      console.log("Connected: Database & tables created!");
    } catch (error) {
      console.error("Error syncing database:", error);
    }
  }

  async setupServer() {
    const options = {
      key: fs.readFileSync(
        "C:/Users/Aishh B/Desktop/project/certificate/MyServer.key"
      ),
      cert: fs.readFileSync(
        "C:/Users/Aishh B/Desktop/project/certificate/MyServer.crt"
      ),
    };

    const server = https.createServer(options, this.app);

    server.listen(this.port, () => {
      console.log(`Server is running on https://localhost:${this.port}`);
    });
  }

  async register(req, res) {
    try {
      const { user, email, password } = req.headers;

      const domainRegex = /@(.+)\.com$/;

      // Extract the domain from the email address
      const [, domain] = email.match(domainRegex);

      // Check if the domain is valid
      const isValidDomain = !!domain;

      const existingEmail = await this.UserEmail.findOne({ where: { email } });

      if (existingEmail) {
        return res
          .status(400)
          .json({ error: "Email address is already in use." });
      }

      if (!isValidDomain) {
        return res.status(400).json({ error: "Invalid email domain" });
      }

      console.log(
        "Username and email available. Proceeding with registration."
      );

      const newUser = await this.UserName.create({ user });

      await this.UserEmail.create({ email, UserNameId: newUser.id });

      const hashedPassword = await bcrypt.hash(password, 10);
      await this.UserPassword.create({
        password: hashedPassword,
        UserNameId: newUser.id,
      });

      const authToken = jwt.sign({ userId: newUser.id }, "your_secret_key", {
        expiresIn: "1h",
      });
      console.log("Token generated");

      res
        .status(201)
        .json({ message: "User registered successfully", token: authToken });
    } catch (error) {
      console.error("Error registering user:", error);
      res.status(500).json({ error: "Registration failed" });
    }
  }

  async login(req, res) {
    console.log("Received login request");
    const { email, password } = req.headers;
    console.log("Received login data:");

    try {
      const existingUser = await this.UserEmail.findOne({
        where: { email },
        include: [{ model: this.UserName }],
      });

      if (!existingUser) {
        return res.status(401).json({ error: "Invalid email or password" });
      }

      const userPassword = await this.UserPassword.findOne({
        where: { UserNameId: existingUser.UserName.id },
      });

      if (!userPassword) {
        return res.status(401).json({ error: "Invalid email or password" });
      }

      const passwordMatch = await bcrypt.compare(
        password,
        userPassword.password
      );

      if (!passwordMatch) {
        return res.status(401).json({ error: "Invalid email or password" });
      }

      console.log("User authenticated successfully");
      const authToken = jwt.sign(
        { userId: existingUser.UserName.id },
        "your_secret_key",
        {
          expiresIn: "1h",
        }
      );
      console.log("Token generated:");
      res.json({ message: "Login successful", token: authToken });
    } catch (error) {
      console.error("Error logging in user:", error);
      res.status(500).json({ error: "Login failed" });
    }
  }

  async authenticateToken(req, res, next) {
    const authHeader = req.headers["authorization"];
    const token = authHeader && authHeader.split(" ")[1];
    if (token == null) {
      return res.sendStatus(401);
    }

    jwt.verify(token, "your_secret_key", (err, user) => {
      if (err) {
        return res.sendStatus(403);
      }
      req.user = user;
      next();
    });
  }

  async protected(req, res) {
    res.json({ message: "Access granted" });
  }
}

export { MyApp };