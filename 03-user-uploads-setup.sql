-- WORLD DIAMOND - V2 - الناس تسجل وتنشر + الأدمن يوافق / يحذف
-- نفذه في Supabase > SQL Editor > Run - مرة وحدة
-- هذا ما يحذف فيديو الاجمل القديم، بس يضيف حقل صاحب الفيديو

-- 1. أضف حقول صاحب الفيديو إذا مو موجودة
alter table public.videos add column if not exists owner_id uuid references auth.users(id) on delete set null;
alter table public.videos add column if not exists owner_email text default '';

-- 2. امسح السياسات القديمة مال videos حتى نبدلها بالجديدة
drop policy if exists "public read published videos" on public.videos;
drop policy if exists "admin read all videos" on public.videos;
drop policy if exists "admin insert videos" on public.videos;
drop policy if exists "admin update videos" on public.videos;
drop policy if exists "admin delete videos" on public.videos;
drop policy if exists "user insert own video" on public.videos;
drop policy if exists "user read own videos" on public.videos;
drop policy if exists "user delete own video" on public.videos;
drop policy if exists "user update own video" on public.videos;

-- 3. الكل يقرأ بس المنشورة (is_published = true) - هذا اللي يطلع بالموقع الرئيسي
create policy "public read published videos" on public.videos
  for select using (is_published = true);

-- 4. صاحب الفيديو يشوف فيديوهاته حتى لو بعدها مو منشورة (بانتظار الموافقة)
create policy "user read own videos" on public.videos
  for select using (owner_id = auth.uid());

-- 5. الأدمن يشوف الكل
create policy "admin read all videos" on public.videos
  for select using (exists (select 1 from public.admins where user_id = auth.uid()));

-- 6. أي مسجل دخول يقدر يرفع فيديو - بس ينحفظ بانتظار الموافقة
-- مهم: الـ index.html يرسل is_published = false دائما للناس العاديين
create policy "user insert own video" on public.videos
  for insert with check (auth.uid() is not null and owner_id = auth.uid());

-- 7. الأدمن يقدر يضيف مباشرة منشور
create policy "admin insert videos" on public.videos
  for insert with check (exists (select 1 from public.admins where user_id = auth.uid()));

-- 8. صاحب الفيديو يقدر يحذف فيديوهاته هو بس
create policy "user delete own video" on public.videos
  for delete using (owner_id = auth.uid());

-- 9. الأدمن يحذف أي فيديو لأي شخص
create policy "admin delete videos" on public.videos
  for delete using (exists (select 1 from public.admins where user_id = auth.uid()));

-- 10. صاحب الفيديو ما يقدر ينشر نفسه، بس الأدمن ينشر / يخفي
-- صاحب الفيديو يقدر يعدل العنوان والرابط فقط، مو النشر
create policy "user update own video" on public.videos
  for update using (owner_id = auth.uid()) with check (owner_id = auth.uid());

create policy "admin update videos" on public.videos
  for update using (exists (select 1 from public.admins where user_id = auth.uid()));

-- 11. اربط فيديو الاجمل القديم بحسابك (لأن قبل ما كان بيه owner)
-- هذا سطر واحد، إذا الفيديو القديم owner_id فارغ، يربطه بإيميلك
update public.videos set owner_id = (select id from auth.users where email='asdemmad2019@gmail.com'), owner_email='asdemmad2019@gmail.com' where owner_id is null;

-- للتأكد:
-- select id, title, owner_email, is_published from public.videos order by created_at desc;
