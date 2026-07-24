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
const toPublicUser = (user) => ({
    _id: user._id,
    firstName: user.firstName,
    lastName: user.lastName,
    email: user.email,
    username: user.username,
    role: user.role,
    phoneNumber: user.phoneNumber,
    report: user.report,
    profilePicture: user.profilePicture,
    createdAt: user.createdAt,
    updatedAt: user.updatedAt,
});
const normalizeProfilePictureUrl = (req, fileName) => {
    if (!fileName)
        return undefined;
    return `${req.protocol}://${req.get('host')}/uploads/${fileName}`;
};
class UserController {
    register = async (req, res, next) => {
        try {
            const validatedBody = user_dto_1.RegisterUserSchema.parse(req.body);
            const { firstName, lastName, email, username, password, phoneNumber, report } = validatedBody;
            const existingEmail = await user_model_1.UserModel.findOne({ email });
            if (existingEmail) {
                throw new http_exception_1.HttpException(400, 'Email already in use');
            }
            const existingUsername = await user_model_1.UserModel.findOne({ username });
            if (existingUsername) {
                throw new http_exception_1.HttpException(400, 'Username already taken');
            }
            const salt = await bcryptjs_1.default.genSalt(10);
            const hashedPassword = await bcryptjs_1.default.hash(password, salt);
            const user = await user_model_1.UserModel.create({
                firstName,
                lastName,
                email,
                username,
                password: hashedPassword,
                role: 'user',
                phoneNumber,
                report,
            });
            (0, apihelper_util_1.sendResponse)(res, 201, true, 'User registered successfully', toPublicUser(user));
        }
        catch (error) {
            next(error);
        }
    };
    login = async (req, res, next) => {
        try {
            const validatedBody = user_dto_1.LoginUserSchema.parse(req.body);
            const { email, password } = validatedBody;
            const user = await user_model_1.UserModel.findOne({ email });
            if (!user) {
                throw new http_exception_1.HttpException(400, 'Invalid email or password');
            }
            const isMatch = await bcryptjs_1.default.compare(password, user.password || '');
            if (!isMatch) {
                throw new http_exception_1.HttpException(400, 'Invalid email or password');
            }
            const jwtSecret = process.env.JWT_SECRET || 'fallback_secret_key';
            const token = jsonwebtoken_1.default.sign({ userId: user._id, role: user.role }, jwtSecret, { expiresIn: '30d' });
            (0, apihelper_util_1.sendResponse)(res, 200, true, 'Login successful', {
                token,
                user: toPublicUser(user),
            });
        }
        catch (error) {
            next(error);
        }
    };
    /** GET /auth/whoami — same as CivicConnectWeb */
    getProfile = async (req, res, next) => {
        try {
            const user = await user_model_1.UserModel.findById(req.user?.userId).select('-password');
            if (!user) {
                throw new http_exception_1.HttpException(404, 'User not found');
            }
            (0, apihelper_util_1.sendResponse)(res, 200, true, 'User profile fetched successfully', toPublicUser(user));
        }
        catch (error) {
            next(error);
        }
    };
    /** PUT /auth/update — same as CivicConnectWeb (optional profileImage file) */
    updateProfile = async (req, res, next) => {
        try {
            const validatedBody = user_dto_1.UpdateProfileSchema.parse(req.body);
            const userId = req.user?.userId;
            if (validatedBody.username) {
                const existingUsername = await user_model_1.UserModel.findOne({
                    username: validatedBody.username,
                    _id: { $ne: userId },
                });
                if (existingUsername) {
                    throw new http_exception_1.HttpException(400, 'Username already taken');
                }
            }
            const updates = { ...validatedBody };
            if (req.file) {
                updates.profilePicture = normalizeProfilePictureUrl(req, req.file.filename);
            }
            const user = await user_model_1.UserModel.findByIdAndUpdate(userId, updates, {
                new: true,
                runValidators: true,
            }).select('-password');
            if (!user) {
                throw new http_exception_1.HttpException(404, 'User not found');
            }
            (0, apihelper_util_1.sendResponse)(res, 200, true, 'Profile updated successfully', toPublicUser(user));
        }
        catch (error) {
            next(error);
        }
    };
}
exports.UserController = UserController;
