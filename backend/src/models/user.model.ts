import { Schema, model, Document } from 'mongoose';

export interface IUser extends Document {
  firstName: string;
  lastName: string;
  email: string;
  username: string;
  password?: string;
  role: 'admin' | 'user';
  phoneNumber?: string;
  report?: string;
  createdAt: Date;
  updatedAt: Date;
}

const UserSchema = new Schema<IUser>(
  {
    firstName: { type: String, required: true },
    lastName: { type: String, required: true },
    email: { type: String, required: true, unique: true },
    username: { type: String, required: true, unique: true },
    password: { type: String, required: true },
    role: { type: String, enum: ['admin', 'user'], default: 'user' },
    phoneNumber: { type: String },
    report: { type: String },
  },
  {
    timestamps: true,
  }
);

export const UserModel = model<IUser>('User', UserSchema);
