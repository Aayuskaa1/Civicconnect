"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.requireAdmin = exports.authenticate = void 0;
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
const http_exception_1 = require("../exceptions/http.exception");
const authenticate = (req, _res, next) => {
    try {
        const header = req.headers.authorization;
        if (!header || !header.startsWith('Bearer ')) {
            throw new http_exception_1.HttpException(401, 'Authentication required');
        }
        const token = header.slice(7);
        const jwtSecret = process.env.JWT_SECRET || 'fallback_secret_key';
        const decoded = jsonwebtoken_1.default.verify(token, jwtSecret);
        if (!decoded?.userId) {
            throw new http_exception_1.HttpException(401, 'Invalid token');
        }
        req.user = {
            userId: String(decoded.userId),
            role: decoded.role === 'admin' ? 'admin' : 'user',
        };
        next();
    }
    catch (error) {
        if (error instanceof http_exception_1.HttpException) {
            next(error);
            return;
        }
        next(new http_exception_1.HttpException(401, 'Invalid or expired token'));
    }
};
exports.authenticate = authenticate;
const requireAdmin = (req, _res, next) => {
    if (!req.user) {
        next(new http_exception_1.HttpException(401, 'Authentication required'));
        return;
    }
    if (req.user.role !== 'admin') {
        next(new http_exception_1.HttpException(403, 'Admin access required'));
        return;
    }
    next();
};
exports.requireAdmin = requireAdmin;
