"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const multer_1 = __importDefault(require("multer"));
const path_1 = __importDefault(require("path"));
const user_controller_1 = require("../controllers/user.controller");
const auth_middleware_1 = require("../middlewares/auth.middleware");
const uploads_config_1 = require("../configs/uploads.config");
const storage = multer_1.default.diskStorage({
    destination: (_req, _file, cb) => {
        cb(null, uploads_config_1.uploadsPath);
    },
    filename: (_req, file, cb) => {
        const ext = path_1.default.extname(file.originalname || '');
        cb(null, `profile-${Date.now()}-${Math.round(Math.random() * 1e9)}${ext}`);
    },
});
const upload = (0, multer_1.default)({ storage });
const router = (0, express_1.Router)();
const userController = new user_controller_1.UserController();
// Shared CivicConnect API (same paths as CivicConnectWeb)
router.post('/register', userController.register);
router.post('/login', userController.login);
router.get('/whoami', auth_middleware_1.authenticate, userController.getProfile);
router.put('/update', auth_middleware_1.authenticate, upload.single('profileImage'), userController.updateProfile);
exports.default = router;
