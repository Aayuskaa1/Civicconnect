import dotenv from 'dotenv';
dotenv.config();

console.log('[boot] env loaded, importing app...');

import app from './src/app';
import { connectDB } from './src/configs/db.config';

const PORT = Number(process.env.PORT) || 3001;

const startServer = async () => {
  try {
    console.log('[boot] connecting to MongoDB...');
    await connectDB();
    console.log('[boot] starting HTTP server on 0.0.0.0:' + PORT);

    // Listen on all interfaces so physical devices on the LAN can reach the Mac backend
    app.listen(PORT, '0.0.0.0', () => {
      console.log(`Server is running on port ${PORT}`);
      console.log(`LAN: http://192.168.1.70:${PORT}/api/v1/`);
      console.log(`Local: http://127.0.0.1:${PORT}/api/v1/`);
    });
  } catch (error) {
    console.error('[boot] failed to start server:', error);
    process.exit(1);
  }
};

startServer();
