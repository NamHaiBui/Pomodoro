import mongoose from 'mongoose';

const sessionTypeSchema = new mongoose.Schema({
    name: { type: String, required: true },
    duration: { type: Number, required: true }
});

const todoTaskSchema = new mongoose.Schema({
    title: { type: String, required: true },
    description: { type: String },
    completed: { type: Boolean, default: false }
});

const ongoingSessionSchema = new mongoose.Schema({
    sessionTypeId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'SessionType', // Reference the SessionType model
        required: true
    },
    startTime: { type: Date, required: true },
    endTime: { type: Date } // endTime might be optional if the session is still ongoing
});

export const SessionType = mongoose.model('SessionType', sessionTypeSchema);
export const TodoTask = mongoose.model('TodoTask', todoTaskSchema);
export const OngoingSession = mongoose.model('OngoingSession', ongoingSessionSchema);
