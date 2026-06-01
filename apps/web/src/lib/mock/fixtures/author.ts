import type { ContentAuthor } from '@/lib/content';
import { MOCK_IDS, MOCK_TS } from '@/lib/mock/fixtures/ids';

export const mockAuthor: ContentAuthor = {
  id: MOCK_IDS.author,
  slug: 'hunny-team',
  display_name: 'Hunny Team',
  bio: 'Short, approachable Bible reading guides from Hunny.',
  avatar_image_url: null,
  avatar_image_public_id: null,
  website_url: null,
  is_verified: true,
  is_active: true,
  created_at: MOCK_TS,
  updated_at: MOCK_TS,
};
