import { Router } from 'express';
import multer from 'multer';
import path from 'path';
import fs from 'fs';
import { UserController } from '../controllers/user.controller';
import { authenticate } from '../middlewares/auth.middleware';

const uploadsDir = path.resolve(process.cwd(), 'uploads');
fs.mkdirSync(uploadsDir, { recursive: true });

const storage = multer.diskStorage({
  destination: (_req, _file, cb) => {
    cb(null, uploadsDir);
  },
  filename: (_req, file, cb) => {
    const ext = path.extname(file.originalname || '');
    cb(null, `profile-${Date.now()}-${Math.round(Math.random() * 1e9)}${ext}`);
  },
});

const upload = multer({ storage });
const router = Router();
const userController = new UserController();

// Shared CivicConnect API (same paths as CivicConnectWeb)
router.post('/register', userController.register);
router.post('/login', userController.login);
router.get('/whoami', authenticate, userController.getProfile);
router.put(
  '/update',
  authenticate,
  upload.single('profileImage'),
  userController.updateProfile
);

export default router;
