"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.sendResponse = void 0;
const sendResponse = (res, statusCode, success, message, data, meta) => {
    const responseBody = {
        status: statusCode,
        success,
        message,
        data,
        ...(meta && { meta }),
    };
    return res.status(statusCode).json(responseBody);
};
exports.sendResponse = sendResponse;
