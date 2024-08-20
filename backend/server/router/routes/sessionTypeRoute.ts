import express from 'express';
import admin from 'firebase-admin';
const router = express.Router();
const db = admin.firestore();

router.get('/', async (req, res, next) => {
  try {
    const snapshot = await db.collection('ongoingSessions')
      .orderBy('startTime', 'desc')
      .limit(1)
      .get();

    if (snapshot.empty) {
      res.status(404).json({ message: 'No ongoing session found' });
    } else {
      const session = snapshot.docs[0];
      res.json({ id: session.id, ...session.data() });
    }
  } catch (error) {
    next(error);
  }
});

router.post('/', async (req, res, next) => {
  try {
    const session = {
      ...req.body,
      startTime: admin.firestore.FieldValue.serverTimestamp()
    };
    const docRef = await db.collection('ongoingSessions').add(session);
    res.status(201).json({ id: docRef.id, message: 'Ongoing session created successfully' });
  } catch (error) {
    next(error);
  }
});

router.put('/:id', async (req, res, next) => {
  try {
    await db.collection('ongoingSessions').doc(req.params.id).update({
      endTime: admin.firestore.FieldValue.serverTimestamp()
    });
    res.json({ message: 'Ongoing session updated successfully' });
  } catch (error) {
    next(error);
  }
});

router.delete('/:id', async (req, res, next) => {
  try {
    await db.collection('ongoingSessions').doc(req.params.id).delete();
    res.json({ message: 'Ongoing session deleted successfully' });
  } catch (error) {
    next(error);
  }
});


export default router;