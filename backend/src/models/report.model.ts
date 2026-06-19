import { Schema, model, Document } from 'mongoose';

export interface IReport extends Document {
  title: string;
  description: string;
  category: string;
  status: string;
  imageUrl?: string;
  location: string;
  submittedBy: string;
  createdAt: Date;
  updatedAt: Date;
}

const ReportSchema = new Schema<IReport>(
  {
    title: { type: String, required: true, trim: true },
    description: { type: String, required: true, trim: true },
    category: { type: String, required: true, default: 'Other', trim: true },
    status: { type: String, required: true, default: 'pending', trim: true },
    imageUrl: { type: String, trim: true },
    location: { type: String, required: true, trim: true },
    submittedBy: { type: String, required: true, trim: true },
  },
  {
    timestamps: true,
  }
);

export const ReportModel = model<IReport>('Report', ReportSchema);
