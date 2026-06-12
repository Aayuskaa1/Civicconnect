import { Response } from 'express';

export interface ApiResponse<T = unknown> {
  status: number;
  success: boolean;
  message: string;
  data: T;
  meta?: Record<string, unknown>;
}

export const sendResponse = <T>(
  res: Response,
  statusCode: number,
  success: boolean,
  message: string,
  data: T,
  meta?: Record<string, unknown>
): Response => {
  const responseBody: ApiResponse<T> = {
    status: statusCode,
    success,
    message,
    data,
    ...(meta && { meta }),
  };
  return res.status(statusCode).json(responseBody);
};
