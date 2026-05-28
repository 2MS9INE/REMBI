-- Rembi Phase 2 Seed Data
-- 5 mock farmers, 20 listings, 3 reviews

-- Create mock users in auth (assuming minimal insert or just bypass for profiles if possible).
-- Wait, we can't insert into auth.users easily without passwords if we are just mocking.
-- But Supabase allows inserting directly into auth.users in SQL, or we can just insert into profiles 
-- assuming public inserts or bypassing RLS. Since these are mock UUIDs, we will insert them into auth.users first.

-- Mock UUIDs
-- Farmer 1: aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1
-- Farmer 2: aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2
-- Farmer 3: aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa3
-- Farmer 4: aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa4
-- Farmer 5: aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa5
-- Buyer 1:  bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb1
-- Buyer 2:  bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb2

-- Insert into auth.users
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, recovery_sent_at, last_sign_in_at, app_metadata, user_metadata, created_at, updated_at, confirmation_token, email_change, email_change_token_new, recovery_token)
VALUES
('00000000-0000-0000-0000-000000000000', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1', 'authenticated', 'authenticated', 'farmer1@rembi.dz', 'crypt(123456)', now(), now(), now(), '{"provider":"email","providers":["email"]}', '{}', now(), now(), '', '', '', ''),
('00000000-0000-0000-0000-000000000000', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2', 'authenticated', 'authenticated', 'farmer2@rembi.dz', 'crypt(123456)', now(), now(), now(), '{"provider":"email","providers":["email"]}', '{}', now(), now(), '', '', '', ''),
('00000000-0000-0000-0000-000000000000', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa3', 'authenticated', 'authenticated', 'farmer3@rembi.dz', 'crypt(123456)', now(), now(), now(), '{"provider":"email","providers":["email"]}', '{}', now(), now(), '', '', '', ''),
('00000000-0000-0000-0000-000000000000', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa4', 'authenticated', 'authenticated', 'farmer4@rembi.dz', 'crypt(123456)', now(), now(), now(), '{"provider":"email","providers":["email"]}', '{}', now(), now(), '', '', '', ''),
('00000000-0000-0000-0000-000000000000', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa5', 'authenticated', 'authenticated', 'farmer5@rembi.dz', 'crypt(123456)', now(), now(), now(), '{"provider":"email","providers":["email"]}', '{}', now(), now(), '', '', '', ''),
('00000000-0000-0000-0000-000000000000', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb1', 'authenticated', 'authenticated', 'buyer1@rembi.dz', 'crypt(123456)', now(), now(), now(), '{"provider":"email","providers":["email"]}', '{}', now(), now(), '', '', '', ''),
('00000000-0000-0000-0000-000000000000', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb2', 'authenticated', 'authenticated', 'buyer2@rembi.dz', 'crypt(123456)', now(), now(), now(), '{"provider":"email","providers":["email"]}', '{}', now(), now(), '', '', '', '')
ON CONFLICT (id) DO NOTHING;

-- Insert into public.profiles
-- The trigger from Phase 1 might have created empty ones securely. We will UPDATE them instead.
UPDATE public.profiles SET 
  full_name = 'Mohamed B.', phone_number = '0555000001', wilaya = '16 Alger', 
  avatar_url = 'https://i.pravatar.cc/150?u=a1', is_farmer = true, is_verified = true, rating = 4.8 
WHERE id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1';

UPDATE public.profiles SET 
  full_name = 'Ali F.', phone_number = '0555000002', wilaya = '14 Tiaret', 
  avatar_url = 'https://i.pravatar.cc/150?u=a2', is_farmer = true, is_verified = false, rating = 4.2 
WHERE id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2';

UPDATE public.profiles SET 
  full_name = 'Youssef S.', phone_number = '0555000003', wilaya = '08 Béchar', 
  avatar_url = 'https://i.pravatar.cc/150?u=a3', is_farmer = true, is_verified = true, rating = 4.9 
WHERE id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa3';

UPDATE public.profiles SET 
  full_name = 'Karim W.', phone_number = '0555000004', wilaya = '31 Oran', 
  avatar_url = 'https://i.pravatar.cc/150?u=a4', is_farmer = true, is_verified = false, rating = 0 
WHERE id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa4';

UPDATE public.profiles SET 
  full_name = 'Omar M.', phone_number = '0555000005', wilaya = '25 Constantine', 
  avatar_url = 'https://i.pravatar.cc/150?u=a5', is_farmer = true, is_verified = true, rating = 4.5 
WHERE id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa5';

UPDATE public.profiles SET 
  full_name = 'Samir Buyer', phone_number = '0555000006', wilaya = '09 Blida', 
  is_farmer = false 
WHERE id = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb1';

UPDATE public.profiles SET 
  full_name = 'Amine Buyer', phone_number = '0555000007', wilaya = '16 Alger', 
  is_farmer = false 
WHERE id = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb2';

-- Note: In case the trigger didn't run, handle inserts
INSERT INTO public.profiles (id, full_name, phone_number, wilaya, avatar_url, is_farmer, is_verified, rating) 
VALUES 
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1', 'Mohamed B.', '0555000001', '16 Alger', 'https://i.pravatar.cc/150?u=a1', true, true, 4.8),
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2', 'Ali F.', '0555000002', '14 Tiaret', 'https://i.pravatar.cc/150?u=a2', true, false, 4.2),
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa3', 'Youssef S.', '0555000003', '08 Béchar', 'https://i.pravatar.cc/150?u=a3', true, true, 4.9),
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa4', 'Karim W.', '0555000004', '31 Oran', 'https://i.pravatar.cc/150?u=a4', true, false, 0),
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa5', 'Omar M.', '0555000005', '25 Constantine', 'https://i.pravatar.cc/150?u=a5', true, true, 4.5),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb1', 'Samir Buyer', '0555000006', '09 Blida', null, false, false, 0),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb2', 'Amine Buyer', '0555000007', '16 Alger', null, false, false, 0)
ON CONFLICT (id) DO NOTHING;

-- Insert 20 Listings
INSERT INTO public.listings (id, farmer_id, title, description, category, price, is_negotiable, wilaya, status, view_count, is_featured, photo_urls, expires_at)
VALUES 
-- Livestock (5)
(gen_random_uuid(), 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2', 'أغنام أولاد جلال', 'كبش أولاد جلال أصيل ذو سلالة نقية', 'livestock', 85000, true, '14 Tiaret', 'available', 150, true, '{"https://fastly.picsum.photos/id/1025/4951/3301.jpg?hmac=_aGh5AtoOChip_iaMo8ZvvytfEojcgqbCH7dzaz-H8Y"}', now() + interval '30 days'),
(gen_random_uuid(), 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2', 'بقرة حلوب', 'بقرة حلوب 20 لتر في اليوم صحة جيدة', 'livestock', 250000, false, '14 Tiaret', 'available', 45, false, '{"https://fastly.picsum.photos/id/1003/1181/1772.jpg?hmac=oN9fHMXiqe9Zq2RM6XT-RVZzO2OToBowkG2teawK8us"}', now() + interval '30 days'),
(gen_random_uuid(), 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa5', 'دجاج بياض للبيع', 'كمية 500 دجاجة بياض', 'livestock', 1200, true, '25 Constantine', 'sold', 230, false, '{"https://fastly.picsum.photos/id/1012/3973/2639.jpg?hmac=s2eybz51lnKy2ZHkE2wsgc6S81fVD1W2NKYOSh8hdDc"}', now() + interval '30 days'),
(gen_random_uuid(), 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1', 'معز شامي', 'ماعز شامي منتج للحليب', 'livestock', 35000, false, '16 Alger', 'available', 12, false, '{"https://fastly.picsum.photos/id/1069/2713/1809.jpg?hmac=wsz-Q1iIuQc0v9q9q5R0WqTmsFp3cI0hN1wzU0F9q1k"}', now() + interval '30 days'),
(gen_random_uuid(), 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa3', 'عجل تسمين', 'عجول تسمين سلالة جيدة للبيع', 'livestock', 120000, true, '08 Béchar', 'available', 125, false, '{"https://fastly.picsum.photos/id/200/1920/1280.jpg?hmac=eTnkR-HnU3Q-s1l_2K6-A6Fq92YvHw9mQZ0Q4R5r7A0"}', now() + interval '30 days'),

-- Crops (5)
(gen_random_uuid(), 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1', 'بطاطا واد سوف', 'بطاطا نوعية أولى بالجملة', 'crops', 45, false, '16 Alger', 'available', 300, true, '{"https://fastly.picsum.photos/id/292/3852/2556.jpg?hmac=cOME6_m4CjYp8Y9E3y8wZ_sC8E11Z4n2-e9kS9qZw"}', now() + interval '30 days'),
(gen_random_uuid(), 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa4', 'قمح صلب', 'قمح صلب نوعية جيدة محصول السنة', 'crops', 3000, true, '31 Oran', 'available', 80, false, '{"https://fastly.picsum.photos/id/312/3888/2592.jpg?hmac=8v6uF8Z4oH4p1D5R1k1s6N4N5qO3n6N4N5qO3n6N4N5"}', now() + interval '30 days'),
(gen_random_uuid(), 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa3', 'تمر دقلة نور', 'تمر دقلة نور بسكرة نوعية ممتازة', 'crops', 450, true, '07 Biskra', 'sold', 500, false, '{"https://fastly.picsum.photos/id/312/3888/2592.jpg?hmac=8v6uF8Z4oH4p1D5R1k1s6N4N5qO3n6N4N5qO3n6N4N5"}', now() + interval '30 days'),
(gen_random_uuid(), 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa5', 'زيتون أشملال', 'زيتون أشملال للزيت', 'crops', 120, false, '15 Tizi Ouzou', 'available', 40, false, '{"https://fastly.picsum.photos/id/312/3888/2592.jpg?hmac=8v6uF8Z4oH4p1D5R1k1s6N4N5qO3n6N4N5qO3n6N4N5"}', now() + interval '30 days'),
(gen_random_uuid(), 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2', 'بصل أحمر', 'بصل أحمر بالجملة', 'crops', 30, true, '29 Mascara', 'available', 15, false, '{"https://fastly.picsum.photos/id/312/3888/2592.jpg?hmac=8v6uF8Z4oH4p1D5R1k1s6N4N5qO3n6N4N5qO3n6N4N5"}', now() + interval '30 days'),

-- Artisan (5)
(gen_random_uuid(), 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa3', 'زيت زيتون بكر', 'زيت زيتون عصرة أولى باردة', 'artisan', 800, false, '15 Tizi Ouzou', 'available', 100, false, '{"https://fastly.picsum.photos/id/312/3888/2592.jpg?hmac=8v6uF8Z4oH4p1D5R1k1s6N4N5qO3n6N4N5qO3n6N4N5"}', now() + interval '30 days'),
(gen_random_uuid(), 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1', 'عسل النحل الطبيعي', 'عسل السدر طبيعي 100%', 'artisan', 4500, false, '16 Alger', 'available', 200, false, '{"https://fastly.picsum.photos/id/312/3888/2592.jpg?hmac=8v6uF8Z4oH4p1D5R1k1s6N4N5qO3n6N4N5qO3n6N4N5"}', now() + interval '30 days'),
(gen_random_uuid(), 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa4', 'جبن ماعز تقليدي', 'جبن ماعز تقليدي خالي من المواد الحافظة', 'artisan', 250, true, '31 Oran', 'available', 30, false, '{"https://fastly.picsum.photos/id/312/3888/2592.jpg?hmac=8v6uF8Z4oH4p1D5R1k1s6N4N5qO3n6N4N5qO3n6N4N5"}', now() + interval '30 days'),
(gen_random_uuid(), 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa5', 'مربى التين', 'مربى تين طبيعي صنع منزلي', 'artisan', 350, true, '25 Constantine', 'available', 60, false, '{"https://fastly.picsum.photos/id/312/3888/2592.jpg?hmac=8v6uF8Z4oH4p1D5R1k1s6N4N5qO3n6N4N5qO3n6N4N5"}', now() + interval '30 days'),
(gen_random_uuid(), 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2', 'خلطة توابل', 'خلطة توابل تقليدية للطهي', 'artisan', 1500, false, '14 Tiaret', 'available', 12, false, '{"https://fastly.picsum.photos/id/312/3888/2592.jpg?hmac=8v6uF8Z4oH4p1D5R1k1s6N4N5qO3n6N4N5qO3n6N4N5"}', now() + interval '30 days'),

-- Services (5)
(gen_random_uuid(), 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1', 'كراء جرار فلاحي', 'كراء جرار فلاحي مع السائق للحصاد أو الحرث', 'services', 4000, true, '16 Alger', 'available', 55, false, '{"https://fastly.picsum.photos/id/312/3888/2592.jpg?hmac=8v6uF8Z4oH4p1D5R1k1s6N4N5qO3n6N4N5qO3n6N4N5"}', now() + interval '30 days'),
(gen_random_uuid(), 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa3', 'تقليم الأشجار', 'خدمات متخصصة في تقليم الأشجار المثمرة', 'services', null, true, '15 Tizi Ouzou', 'available', 20, false, '{"https://fastly.picsum.photos/id/312/3888/2592.jpg?hmac=8v6uF8Z4oH4p1D5R1k1s6N4N5qO3n6N4N5qO3n6N4N5"}', now() + interval '30 days'),
(gen_random_uuid(), 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa4', 'حفر الآبار', 'شركة حفر آبار بالمعدات الثقيلة', 'services', 15000, true, '31 Oran', 'available', 110, false, '{"https://fastly.picsum.photos/id/312/3888/2592.jpg?hmac=8v6uF8Z4oH4p1D5R1k1s6N4N5qO3n6N4N5qO3n6N4N5"}', now() + interval '30 days'),
(gen_random_uuid(), 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa5', 'نقل محاصيل', 'شاحنة لنقل المحاصيل الزراعية', 'services', 2000, true, '25 Constantine', 'available', 75, false, '{"https://fastly.picsum.photos/id/312/3888/2592.jpg?hmac=8v6uF8Z4oH4p1D5R1k1s6N4N5qO3n6N4N5qO3n6N4N5"}', now() + interval '30 days'),
(gen_random_uuid(), 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2', 'استشارة زراعية', 'مهندس زراعي لتقديم استشارات ونصائح ومتابعة', 'services', 1000, false, '14 Tiaret', 'available', 95, false, '{"https://fastly.picsum.photos/id/312/3888/2592.jpg?hmac=8v6uF8Z4oH4p1D5R1k1s6N4N5qO3n6N4N5qO3n6N4N5"}', now() + interval '30 days');

-- Insert Reviews (3)
INSERT INTO public.reviews (id, listing_id, reviewer_id, farmer_id, rating, comment)
VALUES
(gen_random_uuid(), (SELECT id FROM public.listings WHERE farmer_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1' LIMIT 1), 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb1', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1', 5, 'منتجات ممتازة وفلاح موثوق!'),
(gen_random_uuid(), (SELECT id FROM public.listings WHERE farmer_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2' LIMIT 1), 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb2', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2', 4, 'جودة مقبولة والسعر قابل للتفاوض، أنصح بالتعامل معه.'),
(gen_random_uuid(), (SELECT id FROM public.listings WHERE farmer_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa3' LIMIT 1), 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb1', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa3', 5, 'زيت زيتون بكر بالفعل، جودة عالية جدا ولذيذ.')
ON CONFLICT DO NOTHING;
