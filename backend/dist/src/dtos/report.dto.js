"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.CreateReportSchema = void 0;
const zod_1 = require("zod");
exports.CreateReportSchema = zod_1.z.object({
    title: zod_1.z.string().min(1, 'Title is required'),
    description: zod_1.z.string().min(1, 'Description is required'),
    category: zod_1.z.string().min(1, 'Category is required').default('Other'),
    status: zod_1.z.string().optional().default('pending'),
    location: zod_1.z.string().min(1, 'Location is required'),
    submittedBy: zod_1.z.string().min(1, 'Submitted by is required'),
    createdAt: zod_1.z.string().optional(),
});
