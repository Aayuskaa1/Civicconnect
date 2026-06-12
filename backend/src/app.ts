import express from 'express';
import cors from 'cors';
import authRouter from './routes/user.route';
import { errorHandler } from './middlewares/error.middleware';

const app = express();

// Middlewares
app.use(cors());
app.use(express.json());

// Routes
app.use('/api/v1/auth', authRouter);

// Global Error Handler
app.use(errorHandler);

export default app;
