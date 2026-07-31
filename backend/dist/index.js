"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const dotenv_1 = __importDefault(require("dotenv"));
dotenv_1.default.config();
console.log('[boot] env loaded, importing app...');
const app_1 = __importDefault(require("./src/app"));
const db_config_1 = require("./src/configs/db.config");
const PORT = Number(process.env.PORT) || 3001;
const startServer = async () => {
    try {
        console.log('[boot] connecting to MongoDB...');
        await (0, db_config_1.connectDB)();
        console.log('[boot] starting HTTP server on 0.0.0.0:' + PORT);
        // Listen on all interfaces so physical devices on the LAN can reach the Mac backend
        app_1.default.listen(PORT, '0.0.0.0', () => {
            console.log(`Server is running on port ${PORT}`);
            console.log(`LAN: http://192.168.1.70:${PORT}/api/v1/`);
            console.log(`Local: http://127.0.0.1:${PORT}/api/v1/`);
        });
    }
    catch (error) {
        console.error('[boot] failed to start server:', error);
        process.exit(1);
    }
};
startServer();
