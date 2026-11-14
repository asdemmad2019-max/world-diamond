-- WORLD DIAMOND - Supabase مضبوط 100% - نفذه كامل في SQL Editor
-- 1. جدول الفيديوهات
create table if not exists public.videos (
  id bigint generated always as identity primary key,
  title text not null,
  description text default '',
  video_url text not null,
  image_url text default '',
  is_published boolean default true,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- 2. جدول الأدمن - منو مسموح يدير التطبيق
create table if not exists public.admins (
  user_id uuid primary key references auth.users(id) on delete cascade,
  email text not null,
  created_at timestamptz default now()
);

-- 3. RLS مضبوط - مو مفتوح للكل مثل قبل
alter table public.videos enable row level security;
alter table public.admins enable row level security;

drop policy if exists "public read published videos" on public.videos;
drop policy if exists "admin insert videos" on public.videos;
drop policy if exists "admin update videos" on public.videos;
drop policy if exists "admin delete videos" on public.videos;

-- الكل يقرأ بس الفيديوهات المنشورة
create policy "public read published videos" on public.videos
  for select using (is_published = true);

-- بس الأدمن يضيف / يعدل / يحذف
create policy "admin insert videos" on public.videos
  for insert with check (exists (select 1 from public.admins where user_id = auth.uid()));
create policy "admin update videos" on public.videos
  for update using (exists (select 1 from public.admins where user_id = auth.uid()));
create policy "admin delete videos" on public.videos
  for delete using (exists (select 1 from public.admins where user_id = auth.uid()));

-- الأدمن يشوف نفسه فقط
create policy "admin read self" on public.admins
  for select using (user_id = auth.uid());

-- 4. Storage للفيديوهات والصور
insert into storage.buckets (id, name, public) values ('videos', 'videos', true) on conflict (id) do nothing;
insert into storage.buckets (id, name, public) values ('covers', 'covers', true) on conflict (id) do nothing;

-- سياسات Storage
drop policy if exists "public read videos bucket" on storage.objects;
drop policy if exists "admin upload videos bucket" on storage.objects;
create policy "public read videos bucket" on storage.objects for select using (bucket_id in ('videos','covers'));
create policy "admin upload videos bucket" on storage.objects for insert with check (bucket_id in ('videos','covers') and exists (select 1 from public.admins where user_id = auth.uid()));

-- 5. بعد ما تسجل حساب الأدمن في التطبيق، نفذ هذا السطر وبدل الايميل بايميلك:
-- insert into public.admins (user_id, email) select id, email from auth.users where email = 'YOUR_ADMIN_EMAIL_HERE';
