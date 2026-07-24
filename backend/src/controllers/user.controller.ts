import { Request, Response, NextFunction } from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { UserModel } from '../models/user.model';
import { RegisterUserSchema, LoginUserSchema, UpdateProfileSchema } from '../dtos/user.dto';
import { HttpException } from '../exceptions/http.exception';
import { sendResponse } from '../utils/apihelper.util';
import { AuthenticatedRequest } from '../middlewares/auth.middleware';

const toPublicUser = (user: {
  _id: unknown;
  firstName: string;
  lastName: string;
  email: string;
  username: string;
  role: string;
  phoneNumber?: string;
  report?: string;
  profilePicture?: string;
  createdAt?: Date;
  updatedAt?: Date;
}) => ({
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

const normalizeProfilePictureUrl = (req: Request, fileName?: string): string | undefined => {
  if (!fileName) return undefined;
  return `${req.protocol}://${req.get('host')}/uploads/${fileName}`;
};

export class UserController {
  public register = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const validatedBody = RegisterUserSchema.parse(req.body);
      const { firstName, lastName, email, username, password, phoneNumber, report } = validatedBody;

      const existingEmail = await UserModel.findOne({ email });
      if (existingEmail) {
        throw new HttpException(400, 'Email already in use');
      }

      const existingUsername = await UserModel.findOne({ username });
      if (existingUsername) {
        throw new HttpException(400, 'Username already taken');
      }

      const salt = await bcrypt.genSalt(10);
      const hashedPassword = await bcrypt.hash(password, salt);

      const user = await UserModel.create({
        firstName,
        lastName,
        email,
        username,
        password: hashedPassword,
        role: 'user',
        phoneNumber,
        report,
      });

      sendResponse(res, 201, true, 'User registered successfully', toPublicUser(user));
    } catch (error) {
      next(error);
    }
  };

  public login = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const validatedBody = LoginUserSchema.parse(req.body);
      const { email, password } = validatedBody;

      const user = await UserModel.findOne({ email });
      if (!user) {
        throw new HttpException(400, 'Invalid email or password');
      }

      const isMatch = await bcrypt.compare(password, user.password || '');
      if (!isMatch) {
        throw new HttpException(400, 'Invalid email or password');
      }

      const jwtSecret = process.env.JWT_SECRET || 'fallback_secret_key';
      const token = jwt.sign(
        { userId: user._id, role: user.role },
        jwtSecret,
        { expiresIn: '30d' }
      );

      sendResponse(res, 200, true, 'Login successful', {
        token,
        user: toPublicUser(user),
      });
    } catch (error) {
      next(error);
    }
  };

  /** GET /auth/whoami — same as CivicConnectWeb */
  public getProfile = async (req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
      const user = await UserModel.findById(req.user?.userId).select('-password');
      if (!user) {
        throw new HttpException(404, 'User not found');
      }
      sendResponse(res, 200, true, 'User profile fetched successfully', toPublicUser(user));
    } catch (error) {
      next(error);
    }
  };

  /** PUT /auth/update — same as CivicConnectWeb (optional profileImage file) */
  public updateProfile = async (req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
      const validatedBody = UpdateProfileSchema.parse(req.body);
      const userId = req.user?.userId;

      if (validatedBody.username) {
        const existingUsername = await UserModel.findOne({
          username: validatedBody.username,
          _id: { $ne: userId },
        });
        if (existingUsername) {
          throw new HttpException(400, 'Username already taken');
        }
      }

      const updates: Record<string, unknown> = { ...validatedBody };
      if (req.file) {
        updates.profilePicture = normalizeProfilePictureUrl(req, req.file.filename);
      }

      const user = await UserModel.findByIdAndUpdate(userId, updates, {
        new: true,
        runValidators: true,
      }).select('-password');

      if (!user) {
        throw new HttpException(404, 'User not found');
      }

      sendResponse(res, 200, true, 'Profile updated successfully', toPublicUser(user));
    } catch (error) {
      next(error);
    }
  };
}
