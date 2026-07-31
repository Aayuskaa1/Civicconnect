import express from 'express';
import cors from 'cors';
import authRouter from './routes/user.route';
import reportRouter from './routes/report.route';
import chatRouter from './routes/chat.route';
import { errorHandler } from './middlewares/error.middleware';
import { uploadsPath } from './configs/uploads.config';

const app = express();

// Middlewares
app.use(cors());
app.use(express.json());

// Shared CivicConnect API paths (same contract as CivicConnectWeb)
app.use('/api/v1/auth', authRouter);
app.use('/api/v1/complaints', reportRouter);
app.use('/api/v1/ai', chatRouter);
app.use('/uploads', express.static(uploadsPath));

// Global Error Handler
app.use(errorHandler);

export default app;
