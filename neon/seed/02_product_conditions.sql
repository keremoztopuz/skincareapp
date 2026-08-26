-- Skinner katalog seed
-- Uretim: scratchpad/generate_sql.py. Elle duzenleme, scripti guncelle.
-- Neon Console > SQL Editor icinde ya da psql ile, dosya sirasiyla calistir.

-- Routine onerileri yalnizca bu tablodaki satirlar uzerinden calisir
insert into public.product_conditions (product_id, condition_id) values
  ('276877c1-a1b3-54ab-ae88-704675c5f81a'::uuid, '82771f2c-1b0a-5404-8c90-8bc58151bfb3'::uuid),  -- redness -> Hydrating Facial Cleanser
  ('4b464323-7f4c-5d85-827b-22e97069649d'::uuid, '3b785e3c-be84-5e2e-8326-9511297d1832'::uuid),  -- acne -> Foaming Facial Cleanser
  ('3d84732f-4009-5305-b46e-1d40f61699ed'::uuid, '3b785e3c-be84-5e2e-8326-9511297d1832'::uuid),  -- acne -> SA Smoothing Cleanser
  ('701293c3-fe15-52b0-a44c-092760d9e6bf'::uuid, '3b785e3c-be84-5e2e-8326-9511297d1832'::uuid),  -- acne -> Acne Foaming Cream Cleanser
  ('dea36574-0ef3-5f77-a7f0-a4f52588c901'::uuid, '82771f2c-1b0a-5404-8c90-8bc58151bfb3'::uuid),  -- redness -> Toleriane Hydrating Gentle Cleanser
  ('44b3afe5-ae33-5dcc-a1cc-e3c757441c0f'::uuid, '3b785e3c-be84-5e2e-8326-9511297d1832'::uuid),  -- acne -> Effaclar Purifying Foaming Gel
  ('ad47f0e8-5aa5-5d5a-bd9d-03a7265b7045'::uuid, '3b785e3c-be84-5e2e-8326-9511297d1832'::uuid),  -- acne -> Effaclar Clarifying Toner
  ('ad47f0e8-5aa5-5d5a-bd9d-03a7265b7045'::uuid, 'e9223a50-65ca-5963-88c8-e5433f6c0e49'::uuid),  -- pigmentation -> Effaclar Clarifying Toner
  ('5c0370ac-170c-53ce-a9b4-1f26d15a2843'::uuid, '82771f2c-1b0a-5404-8c90-8bc58151bfb3'::uuid),  -- redness -> Sensibio H2O Micellar Water
  ('34a80118-6765-5b04-bb40-45feb4741b24'::uuid, '3b785e3c-be84-5e2e-8326-9511297d1832'::uuid),  -- acne -> Sebium Foaming Gel
  ('6643685c-5b54-5b4b-8b19-72754e7493a8'::uuid, '82771f2c-1b0a-5404-8c90-8bc58151bfb3'::uuid),  -- redness -> Sensibio H2O AR Micellar Water
  ('1a6fa930-0dc9-5084-9011-b971f6d233b0'::uuid, '3b785e3c-be84-5e2e-8326-9511297d1832'::uuid),  -- acne -> Cleanance Cleansing Gel
  ('1a6fa930-0dc9-5084-9011-b971f6d233b0'::uuid, '82771f2c-1b0a-5404-8c90-8bc58151bfb3'::uuid),  -- redness -> Cleanance Cleansing Gel
  ('44d84fb1-fb7f-5ef4-a222-c95046ebcee7'::uuid, '82771f2c-1b0a-5404-8c90-8bc58151bfb3'::uuid),  -- redness -> Gentle Milk Cleanser
  ('38b8e161-f276-523c-9ab5-df2fd30c9869'::uuid, '82771f2c-1b0a-5404-8c90-8bc58151bfb3'::uuid),  -- redness -> Purete Thermale Mineral Micellar Water
  ('73c511cf-8972-5ab9-8a3d-e9a3ea48218c'::uuid, '82771f2c-1b0a-5404-8c90-8bc58151bfb3'::uuid),  -- redness -> Gentle Skin Cleanser
  ('b6b12f3b-bffe-5a6c-8a3a-4b80ca2b1cdf'::uuid, '3b785e3c-be84-5e2e-8326-9511297d1832'::uuid),  -- acne -> Oily Skin Cleanser
  ('2389ca20-2536-539e-8921-3df786a70866'::uuid, '3b785e3c-be84-5e2e-8326-9511297d1832'::uuid),  -- acne -> Clear & Defend 1% Salicylic Acid Wash
  ('f9db2494-f628-5e93-89c0-fab83756f668'::uuid, '3b785e3c-be84-5e2e-8326-9511297d1832'::uuid),  -- acne -> Purifying Gentle Foaming Cleanser
  ('af28f61b-0749-59f5-8b62-acc68c80f37a'::uuid, '3b785e3c-be84-5e2e-8326-9511297d1832'::uuid),  -- acne -> Hyseac Purifying Cleansing Gel
  ('23017ed8-4f1c-582c-9b0f-44dc57cc7817'::uuid, '82771f2c-1b0a-5404-8c90-8bc58151bfb3'::uuid),  -- redness -> Mineral 89 Hyaluronic Acid Booster
  ('722f2b3a-5cc4-5810-855d-3f33d3488ebd'::uuid, '29bfd43d-b889-5776-bb43-a7354fd168d9'::uuid),  -- wrinkles -> Liftactiv Supreme Serum 10
  ('f87dc0a8-a3fd-5dad-8c3e-f95c7a5b8043'::uuid, '29bfd43d-b889-5776-bb43-a7354fd168d9'::uuid),  -- wrinkles -> Hyalu B5 Hyaluronic Acid Serum
  ('f87dc0a8-a3fd-5dad-8c3e-f95c7a5b8043'::uuid, '82771f2c-1b0a-5404-8c90-8bc58151bfb3'::uuid),  -- redness -> Hyalu B5 Hyaluronic Acid Serum
  ('53c39527-122f-58d4-9d5e-d0d844907b7c'::uuid, 'e9223a50-65ca-5963-88c8-e5433f6c0e49'::uuid),  -- pigmentation -> Skin Renewing Vitamin C Serum
  ('bd0dfcc9-c9e7-5242-92a7-9035f54645c9'::uuid, '3b785e3c-be84-5e2e-8326-9511297d1832'::uuid),  -- acne -> Resurfacing Retinol Serum
  ('bd0dfcc9-c9e7-5242-92a7-9035f54645c9'::uuid, 'e9223a50-65ca-5963-88c8-e5433f6c0e49'::uuid),  -- pigmentation -> Resurfacing Retinol Serum
  ('395e424b-233d-555d-b396-34c47a8f8bb4'::uuid, '29bfd43d-b889-5776-bb43-a7354fd168d9'::uuid),  -- wrinkles -> Granactive Retinoid 2% Emulsion
  ('395e424b-233d-555d-b396-34c47a8f8bb4'::uuid, 'e9223a50-65ca-5963-88c8-e5433f6c0e49'::uuid),  -- pigmentation -> Granactive Retinoid 2% Emulsion
  ('720f36e4-3cc6-5a3c-b799-c099e825c96c'::uuid, '29bfd43d-b889-5776-bb43-a7354fd168d9'::uuid),  -- wrinkles -> Growth Factor 15% Solution
  ('1bcca0ef-2ef8-576c-a6df-4356f12d0f7f'::uuid, 'e9223a50-65ca-5963-88c8-e5433f6c0e49'::uuid),  -- pigmentation -> Pigmentbio C-Concentrate
  ('ab9ba74d-5eea-5512-856c-3a5d245a6d01'::uuid, 'e9223a50-65ca-5963-88c8-e5433f6c0e49'::uuid),  -- pigmentation -> Vinoperfect Brightening Dark Spot Serum
  ('e0a4f4b6-37f4-59d8-958b-46edbf86f514'::uuid, '29bfd43d-b889-5776-bb43-a7354fd168d9'::uuid),  -- wrinkles -> Resveratrol Lift Firming Serum
  ('0744d766-37e0-5a9c-8090-07998b734d91'::uuid, '3b785e3c-be84-5e2e-8326-9511297d1832'::uuid),  -- acne -> DermoPure Triple Effect Serum
  ('0744d766-37e0-5a9c-8090-07998b734d91'::uuid, 'e9223a50-65ca-5963-88c8-e5433f6c0e49'::uuid),  -- pigmentation -> DermoPure Triple Effect Serum
  ('e6b00d62-c03a-5510-88fb-371ba67706bb'::uuid, '29bfd43d-b889-5776-bb43-a7354fd168d9'::uuid),  -- wrinkles -> Double Serum Complete Age Control
  ('50800d17-bcfa-514e-8d8a-063759961bbd'::uuid, '29bfd43d-b889-5776-bb43-a7354fd168d9'::uuid),  -- wrinkles -> Revitalift 1.5% Pure Hyaluronic Acid Ser
  ('bc925bb7-cfae-5ec8-a1fc-4883982827b3'::uuid, 'e9223a50-65ca-5963-88c8-e5433f6c0e49'::uuid),  -- pigmentation -> Bright Reveal Niacinamide Serum
  ('bc925bb7-cfae-5ec8-a1fc-4883982827b3'::uuid, '3b785e3c-be84-5e2e-8326-9511297d1832'::uuid),  -- acne -> Bright Reveal Niacinamide Serum
  ('52a162af-3b85-5dc5-95e3-49608155002a'::uuid, '29bfd43d-b889-5776-bb43-a7354fd168d9'::uuid),  -- wrinkles -> Regenerist Retinol 24 Max Serum
  ('0e53c6d6-6b20-5ded-9df6-8a754f7a3930'::uuid, '3b785e3c-be84-5e2e-8326-9511297d1832'::uuid),  -- acne -> Age-Purify Intensive Serum
  ('0e53c6d6-6b20-5ded-9df6-8a754f7a3930'::uuid, '29bfd43d-b889-5776-bb43-a7354fd168d9'::uuid),  -- wrinkles -> Age-Purify Intensive Serum
  ('c1009406-0d66-5c70-a27c-a2db5f09ffd8'::uuid, '3b785e3c-be84-5e2e-8326-9511297d1832'::uuid),  -- acne -> Effaclar Duo+ Anti-Blemish Care
  ('c1009406-0d66-5c70-a27c-a2db5f09ffd8'::uuid, 'e9223a50-65ca-5963-88c8-e5433f6c0e49'::uuid),  -- pigmentation -> Effaclar Duo+ Anti-Blemish Care
  ('c4112429-1ecb-5dd9-955d-8f5c037ce8a8'::uuid, '3b785e3c-be84-5e2e-8326-9511297d1832'::uuid),  -- acne -> Effaclar Sebum-Regulating Mask
  ('1f286fc8-50be-5d7f-af9c-dbfb89d8feeb'::uuid, '82771f2c-1b0a-5404-8c90-8bc58151bfb3'::uuid),  -- redness -> Cicaplast Baume B5 Soothing Balm
  ('a4de0952-f221-5f63-9b39-a7b7c0d948a8'::uuid, 'e9223a50-65ca-5963-88c8-e5433f6c0e49'::uuid),  -- pigmentation -> AHA 30% + BHA 2% Peeling Solution
  ('a4de0952-f221-5f63-9b39-a7b7c0d948a8'::uuid, '3b785e3c-be84-5e2e-8326-9511297d1832'::uuid),  -- acne -> AHA 30% + BHA 2% Peeling Solution
  ('8c0b186a-5a1e-59f8-93f9-e83fd37e3bf2'::uuid, 'e9223a50-65ca-5963-88c8-e5433f6c0e49'::uuid),  -- pigmentation -> Vinoperfect Glycolic Peel Mask
  ('6a00c1c9-6d86-5777-a032-4f9891fc2f41'::uuid, 'e9223a50-65ca-5963-88c8-e5433f6c0e49'::uuid),  -- pigmentation -> Vinoperfect Glycolic Night Cream
  ('7ee5272f-4d63-52b2-bd25-1a63878415b1'::uuid, '3b785e3c-be84-5e2e-8326-9511297d1832'::uuid),  -- acne -> Cleanance Comedomed Exfoliating Care
  ('0d57441e-9d1d-5e8d-9196-850f03b22063'::uuid, '82771f2c-1b0a-5404-8c90-8bc58151bfb3'::uuid),  -- redness -> Soothing Hydrating Mask
  ('15fe4965-7397-5f83-a2c7-5c768f2a8b87'::uuid, '82771f2c-1b0a-5404-8c90-8bc58151bfb3'::uuid),  -- redness -> Cicabio Repairing Cream
  ('dcbcea41-9dd6-520b-bb47-2a953278c019'::uuid, '3b785e3c-be84-5e2e-8326-9511297d1832'::uuid),  -- acne -> Hyseac Purifying Mask
  ('b8554d6c-1bdd-594f-8eb2-56b1df836a6a'::uuid, '3b785e3c-be84-5e2e-8326-9511297d1832'::uuid),  -- acne -> Hyseac SOS Paste Local Care
  ('6094c764-aa3a-5915-99bf-a90afe75dba1'::uuid, '29bfd43d-b889-5776-bb43-a7354fd168d9'::uuid),  -- wrinkles -> NCEF Night Mask
  ('5226add8-35fb-50b9-afdd-98414ba8b613'::uuid, '3b785e3c-be84-5e2e-8326-9511297d1832'::uuid),  -- acne -> Pure Active Charcoal Mask
  ('db2d540e-037e-55cf-bd17-ab1e77e08290'::uuid, '82771f2c-1b0a-5404-8c90-8bc58151bfb3'::uuid),  -- redness -> Moisturizing Cream
  ('e850b50d-1710-56c2-84ec-b77d64e0341d'::uuid, '29bfd43d-b889-5776-bb43-a7354fd168d9'::uuid),  -- wrinkles -> Skin Renewing Night Cream
  ('1233203b-42ef-5a7e-a7e4-97af77b82dd2'::uuid, '82771f2c-1b0a-5404-8c90-8bc58151bfb3'::uuid),  -- redness -> Toleriane Ultra Soothing Cream
  ('6e122d1b-20e0-5155-8111-bd33da8038bd'::uuid, '82771f2c-1b0a-5404-8c90-8bc58151bfb3'::uuid),  -- redness -> Hydrance Optimale Hydrating Cream
  ('d2ec5c93-9802-5a27-9ca5-b4713a766ff6'::uuid, '82771f2c-1b0a-5404-8c90-8bc58151bfb3'::uuid),  -- redness -> Tolerance Control Soothing Cream
  ('78c42f30-bb83-5a66-96e5-31af00e75951'::uuid, '82771f2c-1b0a-5404-8c90-8bc58151bfb3'::uuid),  -- redness -> Cicalfate+ Repairing Protective Cream
  ('bcd7686b-3b5c-5521-9ca6-3c3580fabb88'::uuid, '3b785e3c-be84-5e2e-8326-9511297d1832'::uuid),  -- acne -> Sebium Sensitive Soothing Care
  ('bcd7686b-3b5c-5521-9ca6-3c3580fabb88'::uuid, '82771f2c-1b0a-5404-8c90-8bc58151bfb3'::uuid),  -- redness -> Sebium Sensitive Soothing Care
  ('c1fa6904-d274-59c4-8761-0c29d6725ad5'::uuid, '82771f2c-1b0a-5404-8c90-8bc58151bfb3'::uuid),  -- redness -> Sensibio Defensive Cream
  ('f1b6b9c5-bdda-5942-92f2-80d82c87a028'::uuid, '29bfd43d-b889-5776-bb43-a7354fd168d9'::uuid),  -- wrinkles -> Liftactiv Collagen Specialist
  ('164dfef5-b61c-5a79-a54f-72c34379c7fa'::uuid, '82771f2c-1b0a-5404-8c90-8bc58151bfb3'::uuid),  -- redness -> Moisturizing Cream
  ('e7729d0d-693a-5f46-b204-e2c448540942'::uuid, 'e9223a50-65ca-5963-88c8-e5433f6c0e49'::uuid),  -- pigmentation -> Bright Boost Gel Cream
  ('f4fbf679-2784-5c7d-96ba-59bf006439ba'::uuid, '29bfd43d-b889-5776-bb43-a7354fd168d9'::uuid),  -- wrinkles -> Hyaluron-Filler 3x Effect Day Cream
  ('1eb05b8e-cceb-5b02-b78e-800e8b15cb01'::uuid, '82771f2c-1b0a-5404-8c90-8bc58151bfb3'::uuid),  -- redness -> Vinosource SOS Intense Moisturizing Crea
  ('9f9599e1-cfc2-5d31-9f11-4618345f819c'::uuid, '29bfd43d-b889-5776-bb43-a7354fd168d9'::uuid),  -- wrinkles -> Extra-Firming Emulsion
  ('ab43c966-0ff3-563b-8449-616d4701667d'::uuid, '43bb440a-6d6e-52e6-a726-ae74e71f71df'::uuid),  -- eyebags -> Skin Renewing Eye Cream
  ('ab43c966-0ff3-563b-8449-616d4701667d'::uuid, '29bfd43d-b889-5776-bb43-a7354fd168d9'::uuid),  -- wrinkles -> Skin Renewing Eye Cream
  ('560cd8db-962c-506a-a95d-e080c3fdd455'::uuid, '43bb440a-6d6e-52e6-a726-ae74e71f71df'::uuid),  -- eyebags -> Hydro Boost Awakening Eye Cream
  ('bbab49e9-6a12-5ecb-9379-07a38414304f'::uuid, '43bb440a-6d6e-52e6-a726-ae74e71f71df'::uuid),  -- eyebags -> Vitamin C Brightening Eye Cream
  ('bbab49e9-6a12-5ecb-9379-07a38414304f'::uuid, 'e9223a50-65ca-5963-88c8-e5433f6c0e49'::uuid),  -- pigmentation -> Vitamin C Brightening Eye Cream
  ('aa5189c2-3383-576d-8689-e4201eaaf3f7'::uuid, '43bb440a-6d6e-52e6-a726-ae74e71f71df'::uuid),  -- eyebags -> Resveratrol Lift Eye Lifting Balm
  ('aa5189c2-3383-576d-8689-e4201eaaf3f7'::uuid, '29bfd43d-b889-5776-bb43-a7354fd168d9'::uuid),  -- wrinkles -> Resveratrol Lift Eye Lifting Balm
  ('ea7fbea6-c8ab-5cab-a07b-348679a52bbd'::uuid, '43bb440a-6d6e-52e6-a726-ae74e71f71df'::uuid),  -- eyebags -> Hydrating Eye Contour Cream
  ('835fe836-a6fc-50a0-a09a-9c3ff5328451'::uuid, '43bb440a-6d6e-52e6-a726-ae74e71f71df'::uuid),  -- eyebags -> Kind To Skin Soothing Eye Balm
  ('835fe836-a6fc-50a0-a09a-9c3ff5328451'::uuid, '82771f2c-1b0a-5404-8c90-8bc58151bfb3'::uuid),  -- redness -> Kind To Skin Soothing Eye Balm
  ('26ac0e27-fb5b-5cc3-9596-afd6896b7b2d'::uuid, '29bfd43d-b889-5776-bb43-a7354fd168d9'::uuid),  -- wrinkles -> Anti-Age Eye Cream
  ('26ac0e27-fb5b-5cc3-9596-afd6896b7b2d'::uuid, '43bb440a-6d6e-52e6-a726-ae74e71f71df'::uuid),  -- eyebags -> Anti-Age Eye Cream
  ('39e75860-da19-5013-a74f-981ad1a40eba'::uuid, '43bb440a-6d6e-52e6-a726-ae74e71f71df'::uuid),  -- eyebags -> GinZing Refreshing Eye Cream
  ('e4f83d72-59c4-5ff3-907d-ee78c14a9d90'::uuid, '43bb440a-6d6e-52e6-a726-ae74e71f71df'::uuid),  -- eyebags -> Banana Bright+ Eye Creme
  ('e4f83d72-59c4-5ff3-907d-ee78c14a9d90'::uuid, 'e9223a50-65ca-5963-88c8-e5433f6c0e49'::uuid),  -- pigmentation -> Banana Bright+ Eye Creme
  ('21e136c4-5a7d-5187-9d6d-069bd929a81a'::uuid, '43bb440a-6d6e-52e6-a726-ae74e71f71df'::uuid),  -- eyebags -> Eye Contour Cream
  ('f2e02901-ae77-5e28-96ef-df082cb0b628'::uuid, '43bb440a-6d6e-52e6-a726-ae74e71f71df'::uuid),  -- eyebags -> Nectar de Roses Cooling Eye Gel
  ('4c9a92ad-f843-5412-850c-8e3252d286cd'::uuid, '29bfd43d-b889-5776-bb43-a7354fd168d9'::uuid),  -- wrinkles -> Peptide Firming Eye Cream
  ('4c9a92ad-f843-5412-850c-8e3252d286cd'::uuid, '43bb440a-6d6e-52e6-a726-ae74e71f71df'::uuid),  -- eyebags -> Peptide Firming Eye Cream
  ('86be636b-b1f5-5a5a-9e96-0bf64f683c6d'::uuid, '29bfd43d-b889-5776-bb43-a7354fd168d9'::uuid),  -- wrinkles -> Expert Anti-Ageing Eye Contour
  ('86be636b-b1f5-5a5a-9e96-0bf64f683c6d'::uuid, '43bb440a-6d6e-52e6-a726-ae74e71f71df'::uuid),  -- eyebags -> Expert Anti-Ageing Eye Contour
  ('aa3f64a3-4c91-5d96-83d0-ccb9a66d6216'::uuid, '43bb440a-6d6e-52e6-a726-ae74e71f71df'::uuid),  -- eyebags -> Revitalift Filler Eye Serum
  ('aa3f64a3-4c91-5d96-83d0-ccb9a66d6216'::uuid, '29bfd43d-b889-5776-bb43-a7354fd168d9'::uuid),  -- wrinkles -> Revitalift Filler Eye Serum
  ('2b5d3f40-084f-54f3-8478-d8b75597c3d3'::uuid, '43bb440a-6d6e-52e6-a726-ae74e71f71df'::uuid),  -- eyebags -> Guava Eye Serum
  ('7471b946-3b2f-5475-ba28-f168e29d31c9'::uuid, 'e9223a50-65ca-5963-88c8-e5433f6c0e49'::uuid),  -- pigmentation -> Anthelios UVMune 400 Fluid SPF50+
  ('714f4fb0-ad09-5b71-b476-b2b03017f7c0'::uuid, '3b785e3c-be84-5e2e-8326-9511297d1832'::uuid),  -- acne -> Anthelios Anti-Imperfections Gel-Cream S
  ('cc6a5e01-28ab-5894-9af5-ad4cc83204fd'::uuid, 'e9223a50-65ca-5963-88c8-e5433f6c0e49'::uuid),  -- pigmentation -> Photoderm Spot-Age SPF50+
  ('cc6a5e01-28ab-5894-9af5-ad4cc83204fd'::uuid, '29bfd43d-b889-5776-bb43-a7354fd168d9'::uuid),  -- wrinkles -> Photoderm Spot-Age SPF50+
  ('f98e5545-b047-51ae-bc14-b617a05f0516'::uuid, '82771f2c-1b0a-5404-8c90-8bc58151bfb3'::uuid),  -- redness -> Very High Protection Ultra Fluid SPF50+
  ('e60ebe90-6dd0-5a06-b68a-ad8561168944'::uuid, '82771f2c-1b0a-5404-8c90-8bc58151bfb3'::uuid),  -- redness -> Antirougeurs Rosamed SPF50+
  ('00c42cf9-a1a4-56c8-a59c-5b774f5b6585'::uuid, '29bfd43d-b889-5776-bb43-a7354fd168d9'::uuid),  -- wrinkles -> Capital Soleil UV Age Daily SPF50+
  ('00c42cf9-a1a4-56c8-a59c-5b774f5b6585'::uuid, 'e9223a50-65ca-5963-88c8-e5433f6c0e49'::uuid),  -- pigmentation -> Capital Soleil UV Age Daily SPF50+
  ('8324987d-335e-5562-951a-a999cb54e0fb'::uuid, '82771f2c-1b0a-5404-8c90-8bc58151bfb3'::uuid),  -- redness -> Bariesun Mineral Cream SPF50+
  ('871dbe9f-3fd8-5954-ab2c-342efa419da5'::uuid, '3b785e3c-be84-5e2e-8326-9511297d1832'::uuid),  -- acne -> Hyseac 3-Regul Global Care SPF30
  ('ca2079d3-cd06-5034-84c7-c54a74781151'::uuid, '3b785e3c-be84-5e2e-8326-9511297d1832'::uuid),  -- acne -> Clear Face Sunscreen SPF50
  ('0564dcf5-5b1c-52f8-9a9f-545b5137ff5a'::uuid, '3b785e3c-be84-5e2e-8326-9511297d1832'::uuid),  -- acne -> Sun Gel-Cream Oil Control SPF50+
  ('a5538225-54e9-592d-9542-0c208654bc7c'::uuid, '29bfd43d-b889-5776-bb43-a7354fd168d9'::uuid),  -- wrinkles -> UV-Bronze Anti-Ageing Sun Fluid SPF50+
  ('3da3a023-8f02-5c95-aebe-779c1bd85229'::uuid, '82771f2c-1b0a-5404-8c90-8bc58151bfb3'::uuid),  -- redness -> Vinosun Protect Invisible Fluid SPF50+
  ('d9b60c3b-8395-567e-91fd-25e31c5b1ac5'::uuid, 'e9223a50-65ca-5963-88c8-e5433f6c0e49'::uuid)  -- pigmentation -> SkinActive Super UV Glow Fluid SPF50+
on conflict do nothing;
