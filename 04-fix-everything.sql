-- WORLD DIAMOND - ملف الإصلاح 04 - نفذه مرة وحدة كامل
-- يصلح 3 مشاكل: 1) عمود owner_email ناقص  2) إيميلات غير مؤكدة  3) الكاش قديم

-- 1) ضيف الحقول الناقصة للجدول القديم (اذا كانت موجودة ما يسوي شي)
alter table public.videos add column if not exists owner_id uuid references auth.users(id) on delete set null;
alter table public.videos add column if not exists owner_email text default '';
alter table public.videos add column if not exists description text default '';
alter table public.videos add column if not exists image_url text default '';
alter table public.videos add column if not exists is_published boolean default false;
alter table public.videos add column if not exists created_at timestamptz default now();
alter table public.videos add column if not exists updated_at timestamptz default now();

-- 2) تأكد أن جدول الأدمن موجود
create table if not exists public.admins (
  user_id uuid primary key references auth.users(id) on delete cascade,
  email text not null,
  created_at timestamptz default now()
);

-- 3) أكّد كل الإيميلات الموجودة (حتى اللي ما أكدوا إيميلهم يقدرون يدخلون)
update auth.users set email_confirmed_at = coalesce(email_confirmed_at, now()), confirmed_at = coalesce(confirmed_at, now()) where email_confirmed_at is null;

-- 4) حدّث الكاش حتى يشوف الأعمدة الجديدة فوراً
notify pgrst, 'reload schema';

-- للتأكد: لازم يطلع عمود owner_email و owner_id بالقائمة
select column_name, data_type from information_schema.columns where table_schema='public' and table_name='videos' order by ordinal_position;
