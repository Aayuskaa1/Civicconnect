import { Router } from 'express';
import multer from 'multer';
import path from 'path';
import { ReportController } from '../controllers/report.controller';
import { authenticate, requireAdmin } from '../middlewares/auth.middleware';
import { uploadsPath } from '../configs/uploads.config';

const storage = multer.diskStorage({
  destination: (_req, _file, cb) => {
    cb(null, uploadsPath);
  },
  filename: (_req, file, cb) => {
    const ext = path.extname(file.originalname || '');
    cb(null, `${Date.now()}-${Math.round(Math.random() * 1e9)}${ext}`);
  },
});

const upload = multer({ storage });
const router = Router();
const reportController = new ReportController();

// Shared CivicConnect API: /api/v1/complaints (same as CivicConnectWeb)
router.use(authenticate);

router.get('/me', reportController.getMyReports);
router.get('/admin', requireAdmin, reportController.getReports);
router.get('/', reportController.getReports);
router.post('/', upload.single('image'), reportController.createReport);
router.patch('/:id/admin', requireAdmin, reportController.updateReportStatus);
router.get('/:id', reportController.getReportDetail);

export default router;
