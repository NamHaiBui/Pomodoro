import express, { Request, Response, NextFunction } from 'express';
import admin from 'firebase-admin';
import { FirebaseError } from 'firebase/app';
import { OngoingSession } from '../../models/models';

const router = express.Router();
const db = admin.firestore();

// GET all ongoing sessions
router.get('/', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const snapshot = await db.collection('ongoingSessions').get();
    const ongoingSessions: OngoingSession[] = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() as OngoingSession }));
    res.status(200).json(ongoingSessions);
  } catch (error: any) {
    next(error);
  }
});

// POST a new ongoing session
router.post('/', async (req: Request, res: Response, next: NextFunction) => {
  try {
    // 1. Extract data from req.body
    const { sessionTypeId, startTime, endTime } = req.body;

    // 2. Validate data types and required fields
    if (!sessionTypeId || typeof sessionTypeId !== 'string') {
      return res.status(400).json({ message: 'Invalid or missing sessionTypeId' });
    }

    let parsedStartTime: Date | admin.firestore.FieldValue = admin.firestore.FieldValue.serverTimestamp();
    if (startTime) {
      parsedStartTime = new Date(startTime);
      if (isNaN(parsedStartTime.getTime())) {
        return res.status(400).json({ message: 'Invalid startTime format' });
      }
    }

    let parsedEndTime: string = '';
    if (endTime) {
      parsedEndTime = new Date(endTime).toString();
      if (isNaN(new Date(parsedEndTime).getTime())) {
        return res.status(400).json({ message: 'Invalid endTime format' });
      }
    }

    // 3. Create OngoingSession object
    const newSession: OngoingSession = {
      sessionTypeId,
      startTime: parsedStartTime.toString(),
      endTime: parsedEndTime,
    };

    // 4. Add to Firestore (await the write operation)
    const docRef = await db.collection('ongoingSessions').add(newSession);

    res.status(201).json({ id: docRef.id, message: 'Ongoing session created successfully' });
  } catch (error: any) {
    next(error);
  }
});

// GET an ongoing session by ID
router.get('/:id', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const doc = await db.collection('ongoingSessions').doc(req.params.id).get();

    if (!doc.exists) {
      return res.status(404).json({ message: 'Ongoing session not found' });
    }
    res.status(200).json({ id: doc.id, ...doc.data() });
  } catch (error: any) {
    if ((error as FirebaseError).code === 'invalid-argument') {
      return res.status(400).json({ message: 'Invalid ongoing session ID format.' });
    }
    next(error);
  }
});

// PUT (update) an ongoing session by ID
router.put('/:id', async (req: Request, res: Response, next: NextFunction) => {
  try {
    if (Object.keys(req.body).length === 0) {
      return res.status(400).json({ message: 'Request body cannot be empty for update.' });
    }

    // Validate endTime if provided
    if (req.body.endTime) {
      const parsedEndTime = new Date(req.body.endTime);
      if (isNaN(parsedEndTime.getTime())) {
        return res.status(400).json({ message: 'Invalid endTime format' });
      }
      req.body.endTime = parsedEndTime;
    }

    // Await the update operation
    await db.collection('ongoingSessions').doc(req.params.id).update(req.body);

    res.status(200).json({ message: 'Ongoing session updated successfully' });
  } catch (error: any) {
    if ((error as FirebaseError).code === 'invalid-argument') {
      return res.status(400).json({ message: 'Invalid ongoing session ID format.' });
    }
    next(error);
  }
});

// DELETE an ongoing session by ID
router.delete('/:id', async (req: Request, res: Response, next: NextFunction) => {
  try {
    await db.collection('ongoingSessions').doc(req.params.id).delete();

    res.status(204).json({ message: 'Ongoing session deleted successfully' });
  } catch (error: any) {
    if ((error as FirebaseError).code === 'invalid-argument') {
      return res.status(400).json({ message: 'Invalid ongoing session ID format.' });
    }
    next(error);
  }
});

export default router;