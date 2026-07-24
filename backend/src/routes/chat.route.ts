import { Router } from 'express';
import { ChatController } from '../controllers/chat.controller';
import { authenticate } from '../middlewares/auth.middleware';

const router = Router();
const chatController = new ChatController();

// Shared CivicConnect API: POST /api/v1/ai/chat (same as CivicConnectWeb)
router.post('/chat', authenticate, chatController.chat);

export default router;
