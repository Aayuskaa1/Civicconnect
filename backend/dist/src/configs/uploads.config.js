"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.uploadsPath = exports.uploadsDir = void 0;
const fs_1 = __importDefault(require("fs"));
const path_1 = __importDefault(require("path"));
exports.uploadsDir = process.env.UPLOADS_DIR || '/tmp/civicconnect_uploads';
fs_1.default.mkdirSync(exports.uploadsDir, { recursive: true });
exports.uploadsPath = path_1.default.resolve(exports.uploadsDir);
