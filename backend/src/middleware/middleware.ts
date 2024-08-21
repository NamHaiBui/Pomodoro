import express from 'express';

export const notFound = (req: express.Request, res: express.Response, next: express.NextFunction) => {
  res.status(404).json({ message: 'Resource not found' });
};

export const errorHandler = (err: Error, req: express.Request, res: express.Response, next: express.NextFunction) => {
  console.error(err.stack);
  res.status(500).json({ message: 'Internal server error' });
};
