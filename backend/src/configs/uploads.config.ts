import fs from 'fs';
import path from 'path';

// Keep uploads outside iCloud-synced Documents to avoid macOS File Provider hangs.
export const uploadsDir =
  process.env.UPLOADS_DIR || '/tmp/civicconnect_uploads';

fs.mkdirSync(uploadsDir, { recursive: true });

export const uploadsPath = path.resolve(uploadsDir);
