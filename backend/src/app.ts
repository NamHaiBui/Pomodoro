import express, { Express } from 'express';
import bodyParser from 'body-parser';
import cors from 'cors';
import admin from 'firebase-admin';
import dotenv from 'dotenv';

dotenv.config();
// Initialize Firebase Admin SDK
dotenv.config(); // Load environment variables from .env file

const serviceAccount = require(process.env.PATH_TO_SAK!);
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  storageBucket: process.env.FIREBASE_STORAGE_BUCKET
});

import {
  sessionTypeRouter,
  todoTaskRouter,
  ongoingSessionRouter,
} from './router';

import { notFound, errorHandler } from './middleware';


const app: Express = express();
const port = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(bodyParser.json());

// Routes
app.use('/api/session_types', sessionTypeRouter);
app.use('/api/todo_tasks', todoTaskRouter);
app.use('/api/ongoing_sessions', ongoingSessionRouter);


// Error handling middleware
app.use(notFound);
app.use(errorHandler);

app.listen(port, () => {
  console.log(`Pomodoro app backend listening at http://localhost:${port}`);
});

export default app;