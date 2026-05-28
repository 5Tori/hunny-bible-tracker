import crypto from 'crypto';

import { sql } from '@/lib/db/postgres';

export interface CloudinaryUploadResponse {
  public_id: string;
  secure_url: string;
  width: number | null;
  height: number | null;
  bytes: number | null;
  format: string | null;
  resource_type: string;
  folder: string;
}

const MAX_IMAGE_BYTES = 5 * 1024 * 1024;
const TODAY_MESSAGE_UPLOAD_TRANSFORMATION =
  'c_fill,g_auto,w_1080,h_1350,q_auto';

function cloudinaryConfig() {
  const cloudName = process.env.CLOUDINARY_CLOUD_NAME?.trim();
  const apiKey = process.env.CLOUDINARY_API_KEY?.trim();
  const apiSecret = process.env.CLOUDINARY_API_SECRET?.trim();

  if (!cloudName || !apiKey || !apiSecret) {
    throw new Error('Cloudinary environment variables are not configured.');
  }

  return { cloudName, apiKey, apiSecret };
}

function encodeCloudinaryText(value: string) {
  return encodeURIComponent(value)
    .replace(/%2C/g, '%252C')
    .replace(/%2F/g, '%252F');
}

function truncateCloudinaryText(value: string, maxLength: number) {
  const normalized = value.replace(/\s+/g, ' ').trim();
  if (normalized.length <= maxLength) return normalized;
  return `${normalized.slice(0, maxLength - 1).trimEnd()}…`;
}

function createSignature(payload: string, secret: string) {
  return crypto.createHash('sha1').update(`${payload}${secret}`).digest('hex');
}

function createUploadSignature(
  params: Record<string, string | number | undefined>,
  secret: string,
) {
  const payload = Object.entries(params)
    .filter(([, value]) => value !== undefined && value !== '')
    .sort(([a], [b]) => a.localeCompare(b))
    .map(([key, value]) => `${key}=${value}`)
    .join('&');
  return createSignature(payload, secret);
}

function validateImageFile(file: File) {
  if (!file.type?.startsWith('image/')) {
    throw new Error('Only image files can be uploaded.');
  }

  if (file.size > MAX_IMAGE_BYTES) {
    throw new Error('Image must be smaller than 5MB.');
  }
}

export async function uploadImageToCloudinary(
  file: File,
  folder: string,
  options?: { transformation?: string },
) {
  validateImageFile(file);

  const { cloudName, apiKey, apiSecret } = cloudinaryConfig();
  const timestamp = Math.floor(Date.now() / 1000);
  const signature = createUploadSignature(
    {
      folder,
      timestamp,
      transformation: options?.transformation,
    },
    apiSecret,
  );

  const uploadForm = new FormData();
  uploadForm.append('file', file);
  uploadForm.append('api_key', apiKey);
  uploadForm.append('timestamp', String(timestamp));
  uploadForm.append('signature', signature);
  uploadForm.append('folder', folder);
  if (options?.transformation) {
    uploadForm.append('transformation', options.transformation);
  }

  const response = await fetch(`https://api.cloudinary.com/v1_1/${cloudName}/image/upload`, {
    method: 'POST',
    body: uploadForm,
  });

  const json = await response.json();

  if (!response.ok) {
    throw new Error(`Cloudinary upload failed: ${json.error?.message ?? response.statusText}`);
  }

  const result: CloudinaryUploadResponse = {
    public_id: json.public_id,
    secure_url: json.secure_url,
    width: typeof json.width === 'number' ? json.width : null,
    height: typeof json.height === 'number' ? json.height : null,
    bytes: typeof json.bytes === 'number' ? json.bytes : null,
    format: typeof json.format === 'string' ? json.format : null,
    resource_type: json.resource_type ?? 'image',
    folder,
  };

  await sql`
    insert into media_assets (
      provider,
      public_id,
      secure_url,
      resource_type,
      folder,
      width,
      height,
      bytes,
      format,
      created_at
    ) values (
      'cloudinary',
      ${result.public_id},
      ${result.secure_url},
      ${result.resource_type},
      ${result.folder},
      ${result.width},
      ${result.height},
      ${result.bytes},
      ${result.format},
      now()
    )
  `;

  return result;
}

export async function uploadPlanCoverImage(file: File) {
  return uploadImageToCloudinary(file, 'hunny-bible-tracker/plans');
}

export async function uploadTodayMessageImage(file: File) {
  return uploadImageToCloudinary(file, 'hunny-bible-tracker/today-messages', {
    transformation: TODAY_MESSAGE_UPLOAD_TRANSFORMATION,
  });
}

export async function uploadContentImage(file: File) {
  return uploadImageToCloudinary(file, 'hunny-bible-tracker/content');
}

export { buildTodayMessageShareImageUrl } from '@/lib/cloudinary-share-url';
