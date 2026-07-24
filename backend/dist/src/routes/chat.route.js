"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const chat_controller_1 = require("../controllers/chat.controller");
const auth_middleware_1 = require("../middlewares/auth.middleware");
const router = (0, express_1.Router)();
const chatController = new chat_controller_1.ChatController();
// Shared CivicConnect API: POST /api/v1/ai/chat (same as CivicConnectWeb)
router.post('/chat', auth_middleware_1.authenticate, chatController.chat);
exports.default = router;
