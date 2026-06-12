import { Request, Response, NextFunction } from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { UserModel } from '../models/user.model';
import { RegisterUserSchema, LoginUserSchema } from '../dtos/user.dto';
import { HttpException } from '../exceptions/http.exception';
import { sendResponse } from '../utils/apihelper.util';

export class UserController {
  public register = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const validatedBody = RegisterUserSchema.parse(req.body);
      const { firstName, lastName, email, username, password, phoneNumber, report } = validatedBody;

      // Check if email already exists
      const existingEmail = await UserModel.findOne({ email });
      if (existingEmail) {
        throw new HttpException(400, 'Email already in use');
      }

      // Check if username already exists
      const existingUsername = await UserModel.findOne({ username });
      if (existingUsername) {
        throw new HttpException(400, 'Username already taken');
      }

      // Hash password
      const salt = await bcrypt.genSalt(10);
      const hashedPassword = await bcrypt.hash(password, salt);

      // Create user
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

      const responseData = {
        _id: user._id,
        firstName: user.firstName,
        lastName: user.lastName,
        email: user.email,
        username: user.username,
        role: user.role,
        phoneNumber: user.phoneNumber,
        report: user.report,
        createdAt: user.createdAt,
        updatedAt: user.updatedAt,
      };

      sendResponse(res, 201, true, 'User registered successfully', responseData);
    } catch (error) {
      next(error);
    }
  };

  public login = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const validatedBody = LoginUserSchema.parse(req.body);
      const { email, password } = validatedBody;

      // Check user existence
      const user = await UserModel.findOne({ email });
      if (!user) {
        throw new HttpException(400, 'Invalid email or password');
      }

      // Verify password
      const isMatch = await bcrypt.compare(password, user.password || '');
      if (!isMatch) {
        throw new HttpException(400, 'Invalid email or password');
      }

      // Generate token
      const jwtSecret = process.env.JWT_SECRET || 'fallback_secret_key';
      const token = jwt.sign(
        { userId: user._id, role: user.role },
        jwtSecret,
        { expiresIn: '30d' }
      );

      const responseData = {
        token,
        user: {
          _id: user._id,
          firstName: user.firstName,
          lastName: user.lastName,
          email: user.email,
          username: user.username,
          role: user.role,
          phoneNumber: user.phoneNumber,
          report: user.report,
        },
      };

      sendResponse(res, 200, true, 'Login successful', responseData);
    } catch (error) {
      next(error);
    }
  };
}
