"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.UserController = void 0;
const bcryptjs_1 = __importDefault(require("bcryptjs"));
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
const user_model_1 = require("../models/user.model");
const user_dto_1 = require("../dtos/user.dto");
const http_exception_1 = require("../exceptions/http.exception");
const apihelper_util_1 = require("../utils/apihelper.util");
class UserController {
    register = async (req, res, next) => {
        try {
            const validatedBody = user_dto_1.RegisterUserSchema.parse(req.body);
            const { firstName, lastName, email, username, password } = validatedBody;
            // Check if email already exists
            const existingEmail = await user_model_1.UserModel.findOne({ email });
            if (existingEmail) {
                throw new http_exception_1.HttpException(400, 'Email already in use');
            }
            // Check if username already exists
            const existingUsername = await user_model_1.UserModel.findOne({ username });
            if (existingUsername) {
                throw new http_exception_1.HttpException(400, 'Username already taken');
            }
            // Hash password
            const salt = await bcryptjs_1.default.genSalt(10);
            const hashedPassword = await bcryptjs_1.default.hash(password, salt);
            // Create user
            const user = await user_model_1.UserModel.create({
                firstName,
                lastName,
                email,
                username,
                password: hashedPassword,
                role: 'user',
            });
            const responseData = {
                _id: user._id,
                firstName: user.firstName,
                lastName: user.lastName,
                email: user.email,
                username: user.username,
                role: user.role,
                createdAt: user.createdAt,
                updatedAt: user.updatedAt,
            };
            (0, apihelper_util_1.sendResponse)(res, 201, true, 'User registered successfully', responseData);
        }
        catch (error) {
            next(error);
        }
    };
    login = async (req, res, next) => {
        try {
            const validatedBody = user_dto_1.LoginUserSchema.parse(req.body);
            const { email, password } = validatedBody;
            // Check user existence
            const user = await user_model_1.UserModel.findOne({ email });
            if (!user) {
                throw new http_exception_1.HttpException(400, 'Invalid email or password');
            }
            // Verify password
            const isMatch = await bcryptjs_1.default.compare(password, user.password || '');
            if (!isMatch) {
                throw new http_exception_1.HttpException(400, 'Invalid email or password');
            }
            // Generate token
            const jwtSecret = process.env.JWT_SECRET || 'fallback_secret_key';
            const token = jsonwebtoken_1.default.sign({ userId: user._id, role: user.role }, jwtSecret, { expiresIn: '30d' });
            const responseData = {
                token,
                user: {
                    _id: user._id,
                    firstName: user.firstName,
                    lastName: user.lastName,
                    email: user.email,
                    username: user.username,
                    role: user.role,
                },
            };
            (0, apihelper_util_1.sendResponse)(res, 200, true, 'Login successful', responseData);
        }
        catch (error) {
            next(error);
        }
    };
}
exports.UserController = UserController;
