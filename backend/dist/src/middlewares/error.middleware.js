"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.errorHandler = void 0;
const http_exception_1 = require("../exceptions/http.exception");
const apihelper_util_1 = require("../utils/apihelper.util");
const zod_1 = require("zod");
const errorHandler = (error, req, res, next) => {
    if (error instanceof http_exception_1.HttpException) {
        (0, apihelper_util_1.sendResponse)(res, error.status, false, error.message, null);
        return;
    }
    if (error instanceof zod_1.ZodError) {
        const errorDetails = error.issues.map(err => ({
            field: err.path.join('.'),
            message: err.message,
        }));
        (0, apihelper_util_1.sendResponse)(res, 400, false, error.issues[0]?.message || 'Validation error', errorDetails);
        return;
    }
    console.error('[Error] Global Handler:', error);
    (0, apihelper_util_1.sendResponse)(res, 500, false, error.message || 'Internal Server Error', null);
};
exports.errorHandler = errorHandler;
