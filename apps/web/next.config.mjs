import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  images: {
    remotePatterns: [
      { protocol: 'https', hostname: 'res.cloudinary.com', pathname: '/**' },
    ],
  },
  // Monorepo (apps/web under repo root): trace dependencies from the workspace root
  // so serverless output includes the right files. Wrong root can manifest as missing
  // /_next/static CSS or JS and a suddenly “unstyled” HTML page after deploy or refresh.
  outputFileTracingRoot: path.join(__dirname, '../..'),
};

if (process.env.NODE_ENV === 'development') {
  const { initOpenNextCloudflareForDev } = await import('@opennextjs/cloudflare');
  initOpenNextCloudflareForDev();
}

export default nextConfig;
