import { Request, Response, NextFunction } from 'express';
import { HttpException } from '../exceptions/http.exception';
import { sendResponse } from '../utils/apihelper.util';
import { ZodError } from 'zod';

export const errorHandler = (
  error: Error,
  req: Request,
  res: Response,
  next: NextFunction
): void => {
  if (error instanceof HttpException) {
    sendResponse(res, error.status, false, error.message, null);
    return;
  }

  if (error instanceof ZodError) {
    const errorDetails = error.issues.map(err => ({
      field: err.path.join('.'),
      message: err.message,
    }));
    sendResponse(
      res,
      400,
      false,
      error.issues[0]?.message || 'Validation error',
      errorDetails
    );
    return;
  }

  console.error('[Error] Global Handler:', error);
  sendResponse(res, 500, false, error.message || 'Internal Server Error', null);
};
