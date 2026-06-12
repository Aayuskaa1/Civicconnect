import dotenv from 'dotenv';
dotenv.config();

import app from './src/app';
import { connectDB } from './src/configs/db.config';

const PORT = process.env.PORT || 3000;

const startServer = async () => {
  // Connect to Database
  await connectDB();

  // Listen
  app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
  });
};

startServer();
