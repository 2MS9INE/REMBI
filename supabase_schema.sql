-- supabase_schema.sql

-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- USERS TABLE
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  full_name TEXT NOT NULL,
  phone TEXT NOT NULL,
  whatsapp TEXT,
  role TEXT NOT NULL DEFAULT 'farmer',
  wilaya TEXT NOT NULL,
  profile_photo_url TEXT,
  is_verified BOOLEAN DEFAULT false,
  verification_requested BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- LISTINGS TABLE
CREATE TABLE listings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  farmer_id UUID REFERENCES users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  category TEXT NOT NULL,
  subcategory TEXT NOT NULL,
  dynamic_fields JSONB,
  price NUMERIC,
  is_negotiable BOOLEAN DEFAULT false,
  wilaya TEXT NOT NULL,
  status TEXT DEFAULT 'available',
  view_count INT DEFAULT 0,
  is_featured BOOLEAN DEFAULT false,
  expires_at TIMESTAMPTZ DEFAULT NOW() + INTERVAL '60 days',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- LISTING_PHOTOS TABLE
CREATE TABLE listing_photos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  listing_id UUID REFERENCES listings(id) ON DELETE CASCADE,
  photo_url TEXT NOT NULL,
  display_order INT DEFAULT 0
);

-- REVIEWS TABLE
CREATE TABLE reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  seller_id UUID REFERENCES users(id) ON DELETE CASCADE,
  reviewer_name TEXT NOT NULL,
  rating INT CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- REPORTS TABLE
CREATE TABLE reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  listing_id UUID REFERENCES listings(id) ON DELETE CASCADE,
  reason TEXT NOT NULL,
  status TEXT DEFAULT 'pending',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- CATEGORY_SCHEMAS TABLE
CREATE TABLE category_schemas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  category TEXT NOT NULL,
  subcategory TEXT NOT NULL,
  fields_schema JSONB NOT NULL
);

-- INDEXES
CREATE INDEX idx_users_wilaya ON users(wilaya);
CREATE INDEX idx_users_created_at ON users(created_at);

CREATE INDEX idx_listings_wilaya ON listings(wilaya);
CREATE INDEX idx_listings_category ON listings(category);
CREATE INDEX idx_listings_status ON listings(status);
CREATE INDEX idx_listings_created_at ON listings(created_at);

-- ROW LEVEL SECURITY (RLS)
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE listings ENABLE ROW LEVEL SECURITY;
ALTER TABLE listing_photos ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE category_schemas ENABLE ROW LEVEL SECURITY;

-- RLS Policies

-- users: anyone can SELECT public profile fields (assuming all fields are public, otherwise we can just grant SELECT)
CREATE POLICY "anyone can SELECT public profile fields" ON users FOR SELECT USING (true);
-- users: only the owner can UPDATE their own profile
CREATE POLICY "only the owner can UPDATE their own profile" ON users FOR UPDATE USING (auth.uid() = id);

-- listings: anyone can SELECT available listings
CREATE POLICY "anyone can SELECT available listings" ON listings FOR SELECT USING (status = 'available');
-- listings: only the owner (farmer_id = auth.uid()) can INSERT, UPDATE, DELETE their own listings
CREATE POLICY "only the owner can INSERT their own listings" ON listings FOR INSERT WITH CHECK (auth.uid() = farmer_id);
CREATE POLICY "only the owner can UPDATE their own listings" ON listings FOR UPDATE USING (auth.uid() = farmer_id);
CREATE POLICY "only the owner can DELETE their own listings" ON listings FOR DELETE USING (auth.uid() = farmer_id);

-- listing_photos: anyone can view photos for available listings
-- (implicit requirement for photos of available listings)
CREATE POLICY "anyone can SELECT listing photos" ON listing_photos FOR SELECT USING (
  EXISTS (SELECT 1 FROM listings WHERE id = listing_id AND status = 'available')
);
-- listing_photos: owner can manage photos
CREATE POLICY "only the owner can INSERT their listing photos" ON listing_photos FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM listings WHERE id = listing_id AND farmer_id = auth.uid())
);
CREATE POLICY "only the owner can UPDATE their listing photos" ON listing_photos FOR UPDATE USING (
  EXISTS (SELECT 1 FROM listings WHERE id = listing_id AND farmer_id = auth.uid())
);
CREATE POLICY "only the owner can DELETE their listing photos" ON listing_photos FOR DELETE USING (
  EXISTS (SELECT 1 FROM listings WHERE id = listing_id AND farmer_id = auth.uid())
);

-- reviews: anyone can INSERT a review
CREATE POLICY "anyone can INSERT a review" ON reviews FOR INSERT WITH CHECK (true);
-- reviews: no one can DELETE their own review (only admin role can delete)
CREATE POLICY "no one can DELETE their own review" ON reviews FOR DELETE USING (
  EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin')
);
-- reviews: anyone can select a review (implicit assumption)
CREATE POLICY "anyone can SELECT reviews" ON reviews FOR SELECT USING (true);


-- reports: anyone can INSERT a report
CREATE POLICY "anyone can INSERT a report" ON reports FOR INSERT WITH CHECK (true);
-- reports: only admin role can SELECT and UPDATE reports
CREATE POLICY "only admin role can SELECT reports" ON reports FOR SELECT USING (
  EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin')
);
CREATE POLICY "only admin role can UPDATE reports" ON reports FOR UPDATE USING (
  EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin')
);

-- category_schemas: anyone can SELECT schemas
CREATE POLICY "anyone can SELECT category_schemas" ON category_schemas FOR SELECT USING (true);
-- category_schemas: no one but admin can change (assuming read only for others)
CREATE POLICY "only admin role can insert schemes" ON category_schemas FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin')
);


-- CATEGORY_SCHEMAS SEED DATA

INSERT INTO category_schemas (category, subcategory, fields_schema) VALUES
('LIVESTOCK', 'Cattle', '{"critical": ["species", "age_months", "weight_kg", "sex", "health_status", "price", "wilaya", "photos"], "optional": ["breed", "vaccinated", "color", "quantity", "notes"]}'),
('LIVESTOCK', 'Sheep', '{"critical": ["species", "age_months", "weight_kg", "sex", "health_status", "price", "wilaya", "photos"], "optional": ["breed", "vaccinated", "color", "quantity", "notes"]}'),
('LIVESTOCK', 'Goats', '{"critical": ["species", "age_months", "weight_kg", "sex", "health_status", "price", "wilaya", "photos"], "optional": ["breed", "vaccinated", "color", "quantity", "notes"]}'),
('LIVESTOCK', 'Poultry', '{"critical": ["species", "age_months", "weight_kg", "sex", "health_status", "price", "wilaya", "photos"], "optional": ["breed", "vaccinated", "color", "quantity", "notes"]}'),
('LIVESTOCK', 'Camels', '{"critical": ["species", "age_months", "weight_kg", "sex", "health_status", "price", "wilaya", "photos"], "optional": ["breed", "vaccinated", "color", "quantity", "notes"]}'),
('LIVESTOCK', 'Other', '{"critical": ["species", "age_months", "weight_kg", "sex", "health_status", "price", "wilaya", "photos"], "optional": ["breed", "vaccinated", "color", "quantity", "notes"]}'),

('CROPS', 'Cereals', '{"critical": ["crop_type", "quantity", "unit", "harvest_date", "price_per_unit", "wilaya", "photos"], "optional": ["organic", "irrigation_method", "storage_conditions", "notes"]}'),
('CROPS', 'Vegetables', '{"critical": ["crop_type", "quantity", "unit", "harvest_date", "price_per_unit", "wilaya", "photos"], "optional": ["organic", "irrigation_method", "storage_conditions", "notes"]}'),
('CROPS', 'Fruits', '{"critical": ["crop_type", "quantity", "unit", "harvest_date", "price_per_unit", "wilaya", "photos"], "optional": ["organic", "irrigation_method", "storage_conditions", "notes"]}'),
('CROPS', 'Legumes', '{"critical": ["crop_type", "quantity", "unit", "harvest_date", "price_per_unit", "wilaya", "photos"], "optional": ["organic", "irrigation_method", "storage_conditions", "notes"]}'),
('CROPS', 'Herbs', '{"critical": ["crop_type", "quantity", "unit", "harvest_date", "price_per_unit", "wilaya", "photos"], "optional": ["organic", "irrigation_method", "storage_conditions", "notes"]}'),
('CROPS', 'Other', '{"critical": ["crop_type", "quantity", "unit", "harvest_date", "price_per_unit", "wilaya", "photos"], "optional": ["organic", "irrigation_method", "storage_conditions", "notes"]}'),

('ARTISAN PRODUCTS', 'Honey', '{"critical": ["product_type", "quantity", "unit", "price", "wilaya", "photos"], "optional": ["ingredients", "origin_region", "shelf_life", "certifications", "notes"]}'),
('ARTISAN PRODUCTS', 'Cheese & Dairy', '{"critical": ["product_type", "quantity", "unit", "price", "wilaya", "photos"], "optional": ["ingredients", "origin_region", "shelf_life", "certifications", "notes"]}'),
('ARTISAN PRODUCTS', 'Wool & Leather', '{"critical": ["product_type", "quantity", "unit", "price", "wilaya", "photos"], "optional": ["ingredients", "origin_region", "shelf_life", "certifications", "notes"]}'),
('ARTISAN PRODUCTS', 'Dried herbs', '{"critical": ["product_type", "quantity", "unit", "price", "wilaya", "photos"], "optional": ["ingredients", "origin_region", "shelf_life", "certifications", "notes"]}'),
('ARTISAN PRODUCTS', 'Olive oil', '{"critical": ["product_type", "quantity", "unit", "price", "wilaya", "photos"], "optional": ["ingredients", "origin_region", "shelf_life", "certifications", "notes"]}'),
('ARTISAN PRODUCTS', 'Other', '{"critical": ["product_type", "quantity", "unit", "price", "wilaya", "photos"], "optional": ["ingredients", "origin_region", "shelf_life", "certifications", "notes"]}'),

('AGRICULTURAL SERVICES', 'Plowing', '{"critical": ["service_type", "wilaya_coverage", "availability", "contact_preference", "price"], "optional": ["equipment_used", "experience_years", "service_radius_km", "notes"]}'),
('AGRICULTURAL SERVICES', 'Harvesting', '{"critical": ["service_type", "wilaya_coverage", "availability", "contact_preference", "price"], "optional": ["equipment_used", "experience_years", "service_radius_km", "notes"]}'),
('AGRICULTURAL SERVICES', 'Irrigation', '{"critical": ["service_type", "wilaya_coverage", "availability", "contact_preference", "price"], "optional": ["equipment_used", "experience_years", "service_radius_km", "notes"]}'),
('AGRICULTURAL SERVICES', 'Transport', '{"critical": ["service_type", "wilaya_coverage", "availability", "contact_preference", "price"], "optional": ["equipment_used", "experience_years", "service_radius_km", "notes"]}'),
('AGRICULTURAL SERVICES', 'Veterinary', '{"critical": ["service_type", "wilaya_coverage", "availability", "contact_preference", "price"], "optional": ["equipment_used", "experience_years", "service_radius_km", "notes"]}'),
('AGRICULTURAL SERVICES', 'Pest control', '{"critical": ["service_type", "wilaya_coverage", "availability", "contact_preference", "price"], "optional": ["equipment_used", "experience_years", "service_radius_km", "notes"]}'),
('AGRICULTURAL SERVICES', 'Other', '{"critical": ["service_type", "wilaya_coverage", "availability", "contact_preference", "price"], "optional": ["equipment_used", "experience_years", "service_radius_km", "notes"]}');
