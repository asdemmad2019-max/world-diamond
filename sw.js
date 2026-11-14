const CACHE='world-diamond-v13';
self.addEventListener('install',e=>{self.skipWaiting()});
self.addEventListener('activate',e=>{e.waitUntil(caches.keys().then(ks=>Promise.all(ks.map(k=>k!==CACHE?caches.delete(k):null))).then(()=>self.clients.claim()))});
self.addEventListener('fetch',e=>{
  if(e.request.method!=='GET')return;
  const url=new URL(e.request.url);
  // HTML: never serve from cache - always fresh from GitHub
  if(url.pathname.endsWith('.html')||url.pathname.endsWith('/')||url.pathname.endsWith('world-diamond')){
    e.respondWith(fetch(e.request).catch(()=>caches.match(e.request)));
    return;
  }
  e.respondWith(fetch(e.request).then(r=>{const c=r.clone(); caches.open(CACHE).then(cache=>cache.put(e.request,c)); return r;}).catch(()=>caches.match(e.request)));
});
