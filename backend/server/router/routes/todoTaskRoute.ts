import express, { Request, Response, NextFunction } from 'express';
import admin from 'firebase-admin';
import { FirebaseError } from 'firebase/app';
import { TodoTask } from '../../models/models'; // Assuming the model is defined elsewhere

const router = express.Router();
const db = admin.firestore();

// GET all todo tasks
router.get('/', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const snapshot = await db.collection('todoTasks').get(); // Assuming 'todoTasks' is your collection name
    const todoTasks: TodoTask[] = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() as TodoTask }));
    res.status(200).json(todoTasks);
  } catch (error: any) {
    next(error);
  }
});

// POST a new todo task
router.post('/', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { title, description, completed } = req.body;

    if (!title || typeof title !== 'string' || typeof completed !== 'boolean') {
      return res.status(400).json({ message: 'Invalid or missing title or completed status' });
    }

    // Validate description if provided
    if (description && typeof description !== 'string') {
      return res.status(400).json({ message: 'Invalid description format' });
    }

    const newTodoTask: TodoTask = {
      title,
      completed,
      description, // Include description if provided
      // Add any additional properties from req.body if needed
      ...req.body 
    };

    const docRef = await db.collection('todoTasks').add(newTodoTask);

    res.status(201).json({ id: docRef.id, message: 'Todo task created successfully' });
  } catch (error: any) {
    next(error);
  }
});

// GET a todo task by ID
router.get('/:id', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const doc = await db.collection('todoTasks').doc(req.params.id).get();

    if (!doc.exists) {
      return res.status(404).json({ message: 'Todo task not found' });
    }

    res.status(200).json({ id: doc.id, ...doc.data() });
  } catch (error: any) {
    if ((error as FirebaseError).code === 'invalid-argument') {
      return res.status(400).json({ message: 'Invalid todo task ID format.' });
    }
    next(error);
  }
});

// PUT (update) a todo task by ID
router.put('/:id', async (req: Request, res: Response, next: NextFunction) => {
  try {
    if (Object.keys(req.body).length === 0) {
      return res.status(400).json({ message: 'Request body cannot be empty for update.' });
    }

    // You might add additional validation here for the updated data

    await db.collection('todoTasks').doc(req.params.id).update(req.body);

    res.status(200).json({ message: 'Todo task updated successfully' });
  } catch (error: any) {
    if ((error as FirebaseError).code === 'invalid-argument') {
      return res.status(400).json({ message: 'Invalid todo task ID format.' });
    }
    next(error);
  }
});

// DELETE a todo task by ID
router.delete('/:id', async (req: Request, res: Response, next: NextFunction) => {
  try {
    await db.collection('todoTasks').doc(req.params.id).delete();

    res.status(204).send(); // 204 No Content for successful deletion
  } catch (error: any) {
    if ((error as FirebaseError).code === 'invalid-argument') {
      return res.status(400).json({ message: 'Invalid todo task ID format.' });
    }
    next(error);
  }
});

export default router;