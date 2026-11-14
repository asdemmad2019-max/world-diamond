-- WORLD DIAMOND - تفعيل الأدمن: asdemmad2019@gmail.com
-- نفذ هذا بعد ما تنشئ حساب الأدمن من صفحة admin.html
-- الخطوة: 1) نفذ ملف 01  2) انشئ حساب من admin.html  3) نفذ هذا الملف  4) ادخل بـ UNLOCK

insert into public.admins (user_id, email)
select id, email from auth.users where email = 'asdemmad2019@gmail.com'
on conflict (user_id) do nothing;

-- للتأكد: لازم يطلع سطر واحد بيه ايميلك
select * from public.admins where email = 'asdemmad2019@gmail.com';
