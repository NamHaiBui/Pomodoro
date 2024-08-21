// src/app.ts
import express, { Express, Request, Response } from 'express';
import bodyParser from 'body-parser';
import cors from 'cors';
import dotenv from 'dotenv';

import {
  uploadRouter,
  sessionTypeRouter,
  todoTaskRouter,
  ongoingSessionRouter,
} from './router';

import { notFound, errorHandler } from './middleware';

dotenv.config();

const app: Express = express();
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