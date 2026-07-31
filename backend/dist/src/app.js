"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const cors_1 = __importDefault(require("cors"));
const user_route_1 = __importDefault(require("./routes/user.route"));
const report_route_1 = __importDefault(require("./routes/report.route"));
const chat_route_1 = __importDefault(require("./routes/chat.route"));
const error_middleware_1 = require("./middlewares/error.middleware");
const uploads_config_1 = require("./configs/uploads.config");
const app = (0, express_1.default)();
// Middlewares
app.use((0, cors_1.default)());
app.use(express_1.default.json());
// Shared CivicConnect API paths (same contract as CivicConnectWeb)
app.use('/api/v1/auth', user_route_1.default);
app.use('/api/v1/complaints', report_route_1.default);
app.use('/api/v1/ai', chat_route_1.default);
app.use('/uploads', express_1.default.static(uploads_config_1.uploadsPath));
// Global Error Handler
app.use(error_middleware_1.errorHandler);
exports.default = app;
