"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const dotenv_1 = __importDefault(require("dotenv"));
dotenv_1.default.config();
const app_1 = __importDefault(require("./src/app"));
const db_config_1 = require("./src/configs/db.config");
const PORT = process.env.PORT || 3000;
const startServer = async () => {
    // Connect to Database
    await (0, db_config_1.connectDB)();
    // Listen
    app_1.default.listen(PORT, () => {
        console.log(`Server is running on port ${PORT}`);
    });
};
startServer();
