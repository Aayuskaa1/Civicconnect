"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.ReportController = void 0;
const report_dto_1 = require("../dtos/report.dto");
const http_exception_1 = require("../exceptions/http.exception");
const report_model_1 = require("../models/report.model");
const user_model_1 = require("../models/user.model");
const apihelper_util_1 = require("../utils/apihelper.util");
const normalizeImageUrl = (req, fileName) => {
    if (!fileName)
        return undefined;
    return `${req.protocol}://${req.get('host')}/uploads/${fileName}`;
};
class ReportController {
    getReports = async (req, res, next) => {
        try {
            const reports = await report_model_1.ReportModel.find().sort({ createdAt: -1 });
            (0, apihelper_util_1.sendResponse)(res, 200, true, 'Complaints fetched successfully', reports);
        }
        catch (error) {
            next(error);
        }
    };
    /** GET /complaints/me — same as CivicConnectWeb */
    getMyReports = async (req, res, next) => {
        try {
            const userId = req.user?.userId;
            if (!userId) {
                throw new http_exception_1.HttpException(401, 'Authentication required');
            }
            const user = await user_model_1.UserModel.findById(userId).select('email');
            if (!user?.email) {
                throw new http_exception_1.HttpException(404, 'User not found');
            }
            const reports = await report_model_1.ReportModel.find({ submittedBy: user.email }).sort({
                createdAt: -1,
            });
            (0, apihelper_util_1.sendResponse)(res, 200, true, 'Complaints fetched successfully', reports);
        }
        catch (error) {
            next(error);
        }
    };
    getReportDetail = async (req, res, next) => {
        try {
            const id = req.params.id;
            const report = await report_model_1.ReportModel.findById(id);
            if (!report) {
                throw new http_exception_1.HttpException(404, 'Complaint not found');
            }
            (0, apihelper_util_1.sendResponse)(res, 200, true, 'Complaint fetched successfully', report);
        }
        catch (error) {
            next(error);
        }
    };
    createReport = async (req, res, next) => {
        try {
            const validatedBody = report_dto_1.CreateReportSchema.parse(req.body);
            const imageUrl = normalizeImageUrl(req, req.file?.filename);
            const report = await report_model_1.ReportModel.create({
                ...validatedBody,
                imageUrl,
                createdAt: validatedBody.createdAt
                    ? new Date(validatedBody.createdAt)
                    : new Date(),
            });
            (0, apihelper_util_1.sendResponse)(res, 201, true, 'Complaint created successfully', report);
        }
        catch (error) {
            next(error);
        }
    };
    /** PATCH /complaints/:id/admin — same as CivicConnectWeb */
    updateReportStatus = async (req, res, next) => {
        try {
            const id = req.params.id;
            const { status } = req.body;
            if (!status) {
                throw new http_exception_1.HttpException(400, 'Status is required');
            }
            const report = await report_model_1.ReportModel.findByIdAndUpdate(id, { status }, { new: true });
            if (!report) {
                throw new http_exception_1.HttpException(404, 'Complaint not found');
            }
            (0, apihelper_util_1.sendResponse)(res, 200, true, 'Complaint updated successfully', report);
        }
        catch (error) {
            next(error);
        }
    };
}
exports.ReportController = ReportController;
