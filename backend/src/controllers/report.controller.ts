import { Response, NextFunction } from 'express';
import { CreateReportSchema } from '../dtos/report.dto';
import { HttpException } from '../exceptions/http.exception';
import { ReportModel } from '../models/report.model';
import { UserModel } from '../models/user.model';
import { sendResponse } from '../utils/apihelper.util';
import { AuthenticatedRequest } from '../middlewares/auth.middleware';

const normalizeImageUrl = (req: AuthenticatedRequest, fileName?: string): string | undefined => {
  if (!fileName) return undefined;
  return `${req.protocol}://${req.get('host')}/uploads/${fileName}`;
};

export class ReportController {
  public getReports = async (
    req: AuthenticatedRequest,
    res: Response,
    next: NextFunction
  ): Promise<void> => {
    try {
      const reports = await ReportModel.find().sort({ createdAt: -1 });
      sendResponse(res, 200, true, 'Complaints fetched successfully', reports);
    } catch (error) {
      next(error);
    }
  };

  /** GET /complaints/me — same as CivicConnectWeb */
  public getMyReports = async (
    req: AuthenticatedRequest,
    res: Response,
    next: NextFunction
  ): Promise<void> => {
    try {
      const userId = req.user?.userId;
      if (!userId) {
        throw new HttpException(401, 'Authentication required');
      }

      const user = await UserModel.findById(userId).select('email');
      if (!user?.email) {
        throw new HttpException(404, 'User not found');
      }

      const reports = await ReportModel.find({ submittedBy: user.email }).sort({
        createdAt: -1,
      });
      sendResponse(res, 200, true, 'Complaints fetched successfully', reports);
    } catch (error) {
      next(error);
    }
  };

  public getReportDetail = async (
    req: AuthenticatedRequest,
    res: Response,
    next: NextFunction
  ): Promise<void> => {
    try {
      const id = req.params.id;
      const report = await ReportModel.findById(id);
      if (!report) {
        throw new HttpException(404, 'Complaint not found');
      }
      sendResponse(res, 200, true, 'Complaint fetched successfully', report);
    } catch (error) {
      next(error);
    }
  };

  public createReport = async (
    req: AuthenticatedRequest,
    res: Response,
    next: NextFunction
  ): Promise<void> => {
    try {
      const validatedBody = CreateReportSchema.parse(req.body);
      const imageUrl = normalizeImageUrl(req, req.file?.filename);

      const report = await ReportModel.create({
        ...validatedBody,
        imageUrl,
        createdAt: validatedBody.createdAt
          ? new Date(validatedBody.createdAt)
          : new Date(),
      });

      sendResponse(res, 201, true, 'Complaint created successfully', report);
    } catch (error) {
      next(error);
    }
  };

  /** PATCH /complaints/:id/admin — same as CivicConnectWeb */
  public updateReportStatus = async (
    req: AuthenticatedRequest,
    res: Response,
    next: NextFunction
  ): Promise<void> => {
    try {
      const id = req.params.id;
      const { status } = req.body as { status?: string };

      if (!status) {
        throw new HttpException(400, 'Status is required');
      }

      const report = await ReportModel.findByIdAndUpdate(
        id,
        { status },
        { new: true }
      );

      if (!report) {
        throw new HttpException(404, 'Complaint not found');
      }

      sendResponse(res, 200, true, 'Complaint updated successfully', report);
    } catch (error) {
      next(error);
    }
  };
}
