import express from 'express';
import bodyParser from 'body-parser';
import cors from 'cors';
import admin from 'firebase-admin';
import dotenv from 'dotenv';
// Initialize Firebase Admin SDK
dotenv.config(); // Load environment variables from .env file

const serviceAccount = require(process.env.PATH_TO_SAK!);
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  storageBucket: process.env.FIREBASE_STORAGE_BUCKET
});

import uploadRouter from './router/routes/uploadRoute';
import sessionTypeRouter from './router/routes/sessionTypeRoute';
import todoTaskRouter from './router/routes/todoTaskRoute';
import ongoingSessionRouter from './router/routes/ongoingSessionRoute';
import { notFound, errorHandler } from './middleware/middleware';

// Initialize Firebase Admin SDK
//

const app = express();
const port = process.env.PORT || 3000;


// Middleware
app.use(cors());
app.use(bodyParser.json());


// Routes
app.use('/api/session_types', sessionTypeRouter);
app.use('/api/todo_tasks', todoTaskRouter);
app.use('/api/ongoing_sessions', ongoingSessionRouter);
app.use('/api/upload', uploadRouter);

// Error handling middleware
app.use(notFound);
app.use(errorHandler);

app.listen(port, () => {
  console.log(`Pomodoro app backend listening at http://localhost:${port}`);
});

export default app;
