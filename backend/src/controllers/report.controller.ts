import { Request, Response, NextFunction } from 'express';
import { CreateReportSchema } from '../dtos/report.dto';
import { HttpException } from '../exceptions/http.exception';
import { ReportModel } from '../models/report.model';
import { sendResponse } from '../utils/apihelper.util';

const normalizeImageUrl = (req: Request, fileName?: string): string | undefined => {
  if (!fileName) return undefined;
  return `${req.protocol}://${req.get('host')}/uploads/${fileName}`;
};

export class ReportController {
  public getReports = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const reports = await ReportModel.find().sort({ createdAt: -1 });
      sendResponse(res, 200, true, 'Reports fetched successfully', reports);
    } catch (error) {
      next(error);
    }
  };

  public getMyReports = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const { userId } = req.params;
      const reports = await ReportModel.find({ submittedBy: userId }).sort({ createdAt: -1 });
      sendResponse(res, 200, true, 'User reports fetched successfully', reports);
    } catch (error) {
      next(error);
    }
  };

  public getReportDetail = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const report = await ReportModel.findById(req.params.reportId);
      if (!report) {
        throw new HttpException(404, 'Report not found');
      }
      sendResponse(res, 200, true, 'Report fetched successfully', report);
    } catch (error) {
      next(error);
    }
  };

  public createReport = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const validatedBody = CreateReportSchema.parse(req.body);
      const imageUrl = normalizeImageUrl(req, req.file?.filename);

      const report = await ReportModel.create({
        ...validatedBody,
        imageUrl,
        createdAt: validatedBody.createdAt ? new Date(validatedBody.createdAt) : new Date(),
      });

      sendResponse(res, 201, true, 'Report submitted successfully', report);
    } catch (error) {
      next(error);
    }
  };

  public updateReportStatus = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const { reportId } = req.params;
      const { status } = req.body as { status?: string };

      if (!status) {
        throw new HttpException(400, 'Status is required');
      }

      const report = await ReportModel.findByIdAndUpdate(
        reportId,
        { status },
        { new: true }
      );

      if (!report) {
        throw new HttpException(404, 'Report not found');
      }

      sendResponse(res, 200, true, 'Report status updated successfully', report);
    } catch (error) {
      next(error);
    }
  };
}
