import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { HttpException } from '../exceptions/http.exception';

export interface AuthPayload {
  userId: string;
  role: 'admin' | 'user';
}

export interface AuthenticatedRequest extends Request {
  user?: AuthPayload;
}

export const authenticate = (req: AuthenticatedRequest, _res: Response, next: NextFunction): void => {
  try {
    const header = req.headers.authorization;
    if (!header || !header.startsWith('Bearer ')) {
      throw new HttpException(401, 'Authentication required');
    }

    const token = header.slice(7);
    const jwtSecret = process.env.JWT_SECRET || 'fallback_secret_key';
    const decoded = jwt.verify(token, jwtSecret) as AuthPayload;

    if (!decoded?.userId) {
      throw new HttpException(401, 'Invalid token');
    }

    req.user = {
      userId: String(decoded.userId),
      role: decoded.role === 'admin' ? 'admin' : 'user',
    };
    next();
  } catch (error) {
    if (error instanceof HttpException) {
      next(error);
      return;
    }
    next(new HttpException(401, 'Invalid or expired token'));
  }
};

export const requireAdmin = (req: AuthenticatedRequest, _res: Response, next: NextFunction): void => {
  if (!req.user) {
    next(new HttpException(401, 'Authentication required'));
    return;
  }
  if (req.user.role !== 'admin') {
    next(new HttpException(403, 'Admin access required'));
    return;
  }
  next();
};
