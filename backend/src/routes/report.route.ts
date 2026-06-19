import { Router } from 'express';
import multer from 'multer';
import path from 'path';
import fs from 'fs';
import { ReportController } from '../controllers/report.controller';

const uploadsDir = path.resolve(process.cwd(), 'uploads');
fs.mkdirSync(uploadsDir, { recursive: true });

const storage = multer.diskStorage({
  destination: (_req, _file, cb) => {
    cb(null, uploadsDir);
  },
  filename: (_req, file, cb) => {
    const ext = path.extname(file.originalname || '');
    cb(null, `${Date.now()}-${Math.round(Math.random() * 1e9)}${ext}`);
  },
});

const upload = multer({ storage });
const router = Router();
const reportController = new ReportController();

router.get('/', reportController.getReports);
router.get('/user/:userId', reportController.getMyReports);
router.get('/:reportId', reportController.getReportDetail);
router.post('/', upload.single('image'), reportController.createReport);
router.patch('/:reportId/status', reportController.updateReportStatus);

export default router;
