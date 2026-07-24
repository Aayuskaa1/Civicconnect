"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.ReportModel = void 0;
const mongoose_1 = require("mongoose");
const ReportSchema = new mongoose_1.Schema({
    title: { type: String, required: true, trim: true },
    description: { type: String, required: true, trim: true },
    category: { type: String, required: true, default: 'Other', trim: true },
    status: { type: String, required: true, default: 'pending', trim: true },
    imageUrl: { type: String, trim: true },
    location: { type: String, required: true, trim: true },
    submittedBy: { type: String, required: true, trim: true },
}, {
    timestamps: true,
});
exports.ReportModel = (0, mongoose_1.model)('Report', ReportSchema);
