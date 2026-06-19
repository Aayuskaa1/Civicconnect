import { z } from 'zod';

export const CreateReportSchema = z.object({
  title: z.string().min(1, 'Title is required'),
  description: z.string().min(1, 'Description is required'),
  category: z.string().min(1, 'Category is required').default('Other'),
  status: z.string().optional().default('pending'),
  location: z.string().min(1, 'Location is required'),
  submittedBy: z.string().min(1, 'Submitted by is required'),
  createdAt: z.string().optional(),
});

export type CreateReportDto = z.infer<typeof CreateReportSchema>;
