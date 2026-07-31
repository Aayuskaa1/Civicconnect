"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const multer_1 = __importDefault(require("multer"));
const path_1 = __importDefault(require("path"));
const report_controller_1 = require("../controllers/report.controller");
const auth_middleware_1 = require("../middlewares/auth.middleware");
const uploads_config_1 = require("../configs/uploads.config");
const storage = multer_1.default.diskStorage({
    destination: (_req, _file, cb) => {
        cb(null, uploads_config_1.uploadsPath);
    },
    filename: (_req, file, cb) => {
        const ext = path_1.default.extname(file.originalname || '');
        cb(null, `${Date.now()}-${Math.round(Math.random() * 1e9)}${ext}`);
    },
});
const upload = (0, multer_1.default)({ storage });
const router = (0, express_1.Router)();
const reportController = new report_controller_1.ReportController();
// Shared CivicConnect API: /api/v1/complaints (same as CivicConnectWeb)
router.use(auth_middleware_1.authenticate);
router.get('/me', reportController.getMyReports);
router.get('/admin', auth_middleware_1.requireAdmin, reportController.getReports);
router.get('/', reportController.getReports);
router.post('/', upload.single('image'), reportController.createReport);
router.patch('/:id/admin', auth_middleware_1.requireAdmin, reportController.updateReportStatus);
router.get('/:id', reportController.getReportDetail);
exports.default = router;
