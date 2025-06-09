import { Redis } from '@upstash/redis'

const redis = new Redis({
  url: 'https://gusc1-key-aardvark-31854.upstash.io',
  token: 'AXxuASQgNzFhMmZkMDEtMDRkMi00ZDQ2LWJjN2UtMDc3ZWRhYzBkYWVjNTllMjcxMjdlOTBhNDRlODkyZmZlZDE1OThkOTMwMDc=',
})

await redis.set('foo', 'bar');
const data = await redis.get('foo');