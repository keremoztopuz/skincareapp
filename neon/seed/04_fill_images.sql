-- Urun gorselleri: 01_products.sql'in tasimadigi 43 adres.
--
-- 01_products.sql her calistiginda image_url'i excluded.image_url ile
-- eziyor, yani buradaki adresler orada degil burada yasiyor. Sira onemli:
-- bu dosya HER ZAMAN 01_products.sql'den SONRA calisir, yoksa gorseller
-- sessizce NULL'a doner.
--
-- Bir fotograf bir urune ait. Iki katalog satiri ayni OBF kaydini
-- isaretlediginde daha iyi eslesen alir; digeri yanlis siseyi gostermektense
-- gorselsiz kalir.
--
-- Kaynak: Open Beauty Facts (https://world.openbeautyfacts.org).
-- Gorseller CC BY-SA 3.0; yayina cikmadan once uygulamada atif gerekiyor.

-- === Onaylanmis gorseller ===

update public.products set image_url = 'https://images.openbeautyfacts.org/images/products/370/112/980/9082/front_en.3.400.jpg' where id = '6643685c-5b54-5b4b-8b19-72754e7493a8';  -- Bioderma Sensibio H2O AR Micellar Water
update public.products set image_url = 'https://images.openbeautyfacts.org/images/products/369/600/055/6523/front_en.3.400.jpg' where id = '4b464323-7f4c-5d85-827b-22e97069649d';  -- CeraVe Foaming Facial Cleanser
update public.products set image_url = 'https://images.openbeautyfacts.org/images/products/360/600/053/7576/front_en.11.400.jpg' where id = '276877c1-a1b3-54ab-ae88-704675c5f81a';  -- CeraVe Hydrating Facial Cleanser
update public.products set image_url = 'https://images.openbeautyfacts.org/images/products/349/932/001/5431/front_en.5.400.jpg' where id = '73c511cf-8972-5ab9-8a3d-e9a3ea48218c';  -- Cetaphil Gentle Skin Cleanser
update public.products set image_url = 'https://images.openbeautyfacts.org/images/products/890/600/527/5189/front_en.6.400.jpg' where id = 'b6b12f3b-bffe-5a6c-8a3a-4b80ca2b1cdf';  -- Cetaphil Oily Skin Cleanser
update public.products set image_url = 'https://images.openbeautyfacts.org/images/products/343/342/240/4366/front_en.4.400.jpg' where id = '44b3afe5-ae33-5dcc-a1cc-e3c757441c0f';  -- La Roche-Posay Effaclar Purifying Foaming Gel
update public.products set image_url = 'https://images.openbeautyfacts.org/images/products/333/787/554/5778/front_en.9.400.jpg' where id = 'dea36574-0ef3-5f77-a7f0-a4f52588c901';  -- La Roche-Posay Toleriane Hydrating Gentle Cleanser
update public.products set image_url = 'https://images.openbeautyfacts.org/images/products/357/466/149/9666/front_en.16.400.jpg' where id = '2389ca20-2536-539e-8921-3df786a70866';  -- Neutrogena Clear & Defend 1% Salicylic Acid Wash
update public.products set image_url = 'https://images.openbeautyfacts.org/images/products/506/095/514/0935/front_en.3.400.jpg' where id = '4c9a92ad-f843-5412-850c-8e3252d286cd';  -- Facetheory Peptide Firming Eye Cream
update public.products set image_url = 'https://images.openbeautyfacts.org/images/products/357/466/135/2527/front_fr.3.400.jpg' where id = '560cd8db-962c-506a-a95d-e080c3fdd455';  -- Neutrogena Hydro Boost Awakening Eye Cream
update public.products set image_url = 'https://images.openbeautyfacts.org/images/products/366/146/700/2036/front_fr.3.400.jpg' where id = '86be636b-b1f5-5a5a-9e96-0bf64f683c6d';  -- Novexpert Expert Anti-Ageing Eye Contour
update public.products set image_url = 'https://images.openbeautyfacts.org/images/products/360/052/402/5502/front_nl.8.400.jpg' where id = 'aa3f64a3-4c91-5d96-83d0-ccb9a66d6216';  -- L'Oréal Revitalift Filler Eye Serum
update public.products set image_url = 'https://images.openbeautyfacts.org/images/products/328/277/020/4698/front_en.19.400.jpg' where id = '78c42f30-bb83-5a66-96e5-31af00e75951';  -- Avène Cicalfate+ Repairing Protective Cream
update public.products set image_url = 'https://images.openbeautyfacts.org/images/products/328/277/920/6297/front_fr.3.400.jpg' where id = '6e122d1b-20e0-5155-8111-bd33da8038bd';  -- Avène Hydrance Optimale Hydrating Cream
update public.products set image_url = 'https://images.openbeautyfacts.org/images/products/328/277/013/8801/front_fr.12.400.jpg' where id = 'd2ec5c93-9802-5a27-9ca5-b4713a766ff6';  -- Avène Tolerance Control Soothing Cream
update public.products set image_url = 'https://images.openbeautyfacts.org/images/products/340/136/010/6994/front_fr.18.400.jpg' where id = 'bcd7686b-3b5c-5521-9ca6-3c3580fabb88';  -- Bioderma Sebium Sensitive Soothing Care
update public.products set image_url = 'https://images.openbeautyfacts.org/images/products/370/112/980/0843/front_fr.12.400.jpg' where id = 'c1fa6904-d274-59c4-8761-0c29d6725ad5';  -- Bioderma Sensibio Defensive Cream
update public.products set image_url = 'https://images.openbeautyfacts.org/images/products/352/293/000/2598/front_fr.3.400.jpg' where id = '1eb05b8e-cceb-5b02-b78e-800e8b15cb01';  -- Caudalie Vinosource SOS Intense Moisturizing Cream
update public.products set image_url = 'https://images.openbeautyfacts.org/images/products/360/600/053/7972/front_en.10.400.jpg' where id = 'db2d540e-037e-55cf-bd17-ab1e77e08290';  -- CeraVe Moisturizing Cream
update public.products set image_url = 'https://images.openbeautyfacts.org/images/products/333/787/590/3509/front_fr.3.400.jpg' where id = 'e850b50d-1710-56c2-84ec-b77d64e0341d';  -- CeraVe Skin Renewing Night Cream
update public.products set image_url = 'https://images.openbeautyfacts.org/images/products/400/580/019/8687/front_en.3.400.jpg' where id = 'f4fbf679-2784-5c7d-96ba-59bf006439ba';  -- Eucerin Hyaluron-Filler 3x Effect Day Cream
update public.products set image_url = 'https://images.openbeautyfacts.org/images/products/333/787/573/1638/front_xx.20.400.jpg' where id = '7ec2e7f4-1c8f-587f-a20b-c10258354224';  -- La Roche-Posay Hydraphase HA Light
update public.products set image_url = 'https://images.openbeautyfacts.org/images/products/357/466/159/1537/front_en.7.400.jpg' where id = 'e7729d0d-693a-5f46-b204-e2c448540942';  -- Neutrogena Bright Boost Gel Cream
update public.products set image_url = 'https://images.openbeautyfacts.org/images/products/026/001/000/7844/front_fr.3.400.jpg' where id = 'a938bbe4-730c-513a-8a4e-fc65e41dc913';  -- Nuxe Creme Fraiche de Beaute
update public.products set image_url = 'https://images.openbeautyfacts.org/images/products/333/787/572/2520/front_fr.4.400.jpg' where id = 'f1b6b9c5-bdda-5942-92f2-80d82c87a028';  -- Vichy Liftactiv Collagen Specialist
update public.products set image_url = 'https://images.openbeautyfacts.org/images/products/359/620/953/0341/front_fr.3.400.jpg' where id = 'e8807b3e-ae9c-55a8-850e-9be8891525ff';  -- Weleda Iris Hydrating Day Cream
update public.products set image_url = 'https://images.openbeautyfacts.org/images/products/400/580/029/4327/front_de.3.400.jpg' where id = '0744d766-37e0-5a9c-8090-07998b734d91';  -- Eucerin DermoPure Triple Effect Serum
update public.products set image_url = 'https://images.openbeautyfacts.org/images/products/354/055/000/9629/front_fr.3.400.jpg' where id = '0e53c6d6-6b20-5ded-9df6-8a754f7a3930';  -- Filorga Age-Purify Intensive Serum
update public.products set image_url = 'https://images.openbeautyfacts.org/images/products/007/124/937/7512/front_en.15.400.jpg' where id = '50800d17-bcfa-514e-8d8a-063759961bbd';  -- L'Oréal Paris Revitalift 1.5% Pure Hyaluronic Acid Serum
update public.products set image_url = 'https://images.openbeautyfacts.org/images/products/885/000/754/3336/front_en.3.400.jpg' where id = '69d29b53-f926-5a79-901c-6b33393b7b91';  -- Neutrogena Hydro Boost Hyaluronic Acid Serum
update public.products set image_url = 'https://images.openbeautyfacts.org/images/products/007/560/919/9202/front_en.3.400.jpg' where id = '52a162af-3b85-5dc5-95e3-49608155002a';  -- Olay Regenerist Retinol 24 Max Serum
update public.products set image_url = 'https://images.openbeautyfacts.org/images/products/076/991/519/0045/front_en.7.400.jpg' where id = '395e424b-233d-555d-b396-34c47a8f8bb4';  -- The Ordinary Granactive Retinoid 2% Emulsion
update public.products set image_url = 'https://images.openbeautyfacts.org/images/products/333/787/558/8867/front_fr.5.400.jpg' where id = 'ba996499-6bd7-55fd-a602-c42c1bc81f43';  -- Vichy Aqualia Thermal Hydrating Serum
update public.products set image_url = 'https://images.openbeautyfacts.org/images/products/333/787/548/9867/front_en.4.400.jpg' where id = '722f2b3a-5cc4-5810-855d-3f33d3488ebd';  -- Vichy Liftactiv Supreme Serum 10
update public.products set image_url = 'https://images.openbeautyfacts.org/images/products/340/152/850/9032/front_fr.8.400.jpg' where id = 'cc6a5e01-28ab-5894-9af5-ad4cc83204fd';  -- Bioderma Photoderm Spot-Age SPF50+
update public.products set image_url = 'https://images.openbeautyfacts.org/images/products/008/680/007/8517/front_en.3.400.jpg' where id = '8fd14f6d-58e3-5048-8997-1e15324756b8';  -- Neutrogena Ultra Sheer Dry-Touch Sunscreen
update public.products set image_url = 'https://images.openbeautyfacts.org/images/products/333/787/547/4900/front_fr.7.400.jpg' where id = '543b148a-8391-5303-8c38-87db126c3330';  -- Vichy Ideal Soleil Face Fluid SPF30
update public.products set image_url = 'https://images.openbeautyfacts.org/images/products/340/134/786/9546/front_es.16.400.jpg' where id = '15fe4965-7397-5f83-a2c7-5c768f2a8b87';  -- Bioderma Cicabio Repairing Cream
update public.products set image_url = 'https://images.openbeautyfacts.org/images/products/354/055/000/8523/front_en.3.400.jpg' where id = '6094c764-aa3a-5915-99bf-a90afe75dba1';  -- Filorga NCEF Night Mask
update public.products set image_url = 'https://images.openbeautyfacts.org/images/products/360/054/209/7123/front_en.8.400.jpg' where id = '5226add8-35fb-50b9-afdd-98414ba8b613';  -- Garnier Pure Active Charcoal Mask
update public.products set image_url = 'https://images.openbeautyfacts.org/images/products/333/787/581/6847/front_fr.12.400.jpg' where id = '1f286fc8-50be-5d7f-af9c-dbfb89d8feeb';  -- La Roche-Posay Cicaplast Baume B5 Soothing Balm
update public.products set image_url = 'https://images.openbeautyfacts.org/images/products/333/787/553/3317/front_fr.7.400.jpg' where id = 'c4112429-1ecb-5dd9-955d-8f5c037ce8a8';  -- La Roche-Posay Effaclar Sebum-Regulating Mask
update public.products set image_url = 'https://images.openbeautyfacts.org/images/products/366/143/400/4322/front_en.8.400.jpg' where id = 'dcbcea41-9dd6-520b-bb47-2a953278c019';  -- Uriage Hyseac Purifying Mask

-- === Gorseli olmayan 35 urun ===
--
-- Affiliate feed acildiginda ya da OBF'de eslesme bulundugunda: satirin
-- basindaki yorumu kaldir, URL'i doldur, yukaridaki bolume tasi.

-- update public.products set image_url = '' where id = '34a80118-6765-5b04-bb40-45feb4741b24';  -- Bioderma Sebium Foaming Gel
-- update public.products set image_url = '' where id = 'af28f61b-0749-59f5-8b62-acc68c80f37a';  -- Uriage Hyseac Purifying Cleansing Gel
-- update public.products set image_url = '' where id = 'ab43c966-0ff3-563b-8449-616d4701667d';  -- CeraVe Skin Renewing Eye Cream
-- update public.products set image_url = '' where id = 'bbab49e9-6a12-5ecb-9379-07a38414304f';  -- Garnier Vitamin C Brightening Eye Cream
-- update public.products set image_url = '' where id = 'f2e02901-ae77-5e28-96ef-df082cb0b628';  -- Melvita Nectar de Roses Cooling Eye Gel
-- update public.products set image_url = '' where id = '835fe836-a6fc-50a0-a09a-9c3ff5328451';  -- Simple Kind To Skin Soothing Eye Balm
-- update public.products set image_url = '' where id = '21e136c4-5a7d-5187-9d6d-069bd929a81a';  -- The Body Shop Eye Contour Cream
-- update public.products set image_url = '' where id = 'ea7fbea6-c8ab-5cab-a07b-348679a52bbd';  -- Weleda Hydrating Eye Contour Cream
-- update public.products set image_url = '' where id = '2b5d3f40-084f-54f3-8478-d8b75597c3d3';  -- Dr. Organic Guava Eye Serum
-- update public.products set image_url = '' where id = '164dfef5-b61c-5a79-a54f-72c34379c7fa';  -- Cetaphil Moisturizing Cream
-- update public.products set image_url = '' where id = '5e434ea4-3379-5300-9d6e-d12b1347dc89';  -- Vichy Aqualia Thermal Rehydrating Cream
-- update public.products set image_url = '' where id = '1bcca0ef-2ef8-576c-a6df-4356f12d0f7f';  -- Bioderma Pigmentbio C-Concentrate
-- update public.products set image_url = '' where id = 'bd0dfcc9-c9e7-5242-92a7-9035f54645c9';  -- CeraVe Resurfacing Retinol Serum
-- update public.products set image_url = '' where id = 'f87dc0a8-a3fd-5dad-8c3e-f95c7a5b8043';  -- La Roche-Posay Hyalu B5 Hyaluronic Acid Serum
-- update public.products set image_url = '' where id = '720f36e4-3cc6-5a3c-b799-c099e825c96c';  -- The Ordinary Growth Factor 15% Solution
-- update public.products set image_url = '' where id = 'e60ebe90-6dd0-5a06-b68a-ad8561168944';  -- Avène Antirougeurs Rosamed SPF50+
-- update public.products set image_url = '' where id = 'f98e5545-b047-51ae-bc14-b617a05f0516';  -- Avène Very High Protection Ultra Fluid SPF50+
-- update public.products set image_url = '' where id = '41d7f536-d1c3-5772-9d67-7ac17c62a211';  -- Bioderma Photoderm Max Aquafluide SPF50+
-- update public.products set image_url = '' where id = '3da3a023-8f02-5c95-aebe-779c1bd85229';  -- Caudalie Vinosun Protect Invisible Fluid SPF50+
-- update public.products set image_url = '' where id = '0564dcf5-5b1c-52f8-9a9f-545b5137ff5a';  -- Eucerin Sun Gel-Cream Oil Control SPF50+
-- update public.products set image_url = '' where id = 'a5538225-54e9-592d-9542-0c208654bc7c';  -- Filorga UV-Bronze Anti-Ageing Sun Fluid SPF50+
-- update public.products set image_url = '' where id = '714f4fb0-ad09-5b71-b476-b2b03017f7c0';  -- La Roche-Posay Anthelios Anti-Imperfections Gel-Cream SPF50+
-- update public.products set image_url = '' where id = '93abd479-8daa-5026-b385-15df86475409';  -- La Roche-Posay Anthelios Shaka Fluid SPF50+
-- update public.products set image_url = '' where id = '7471b946-3b2f-5475-ba28-f168e29d31c9';  -- La Roche-Posay Anthelios UVMune 400 Fluid SPF50+
-- update public.products set image_url = '' where id = 'ca2079d3-cd06-5034-84c7-c54a74781151';  -- Neutrogena Clear Face Sunscreen SPF50
-- update public.products set image_url = '' where id = '8324987d-335e-5562-951a-a999cb54e0fb';  -- Uriage Bariesun Mineral Cream SPF50+
-- update public.products set image_url = '' where id = '871dbe9f-3fd8-5954-ab2c-342efa419da5';  -- Uriage Hyseac 3-Regul Global Care SPF30
-- update public.products set image_url = '' where id = '00c42cf9-a1a4-56c8-a59c-5b774f5b6585';  -- Vichy Capital Soleil UV Age Daily SPF50+
-- update public.products set image_url = '' where id = '7ee5272f-4d63-52b2-bd25-1a63878415b1';  -- Avène Cleanance Comedomed Exfoliating Care
-- update public.products set image_url = '' where id = '0d57441e-9d1d-5e8d-9196-850f03b22063';  -- Avène Soothing Hydrating Mask
-- update public.products set image_url = '' where id = '6a00c1c9-6d86-5777-a032-4f9891fc2f41';  -- Caudalie Vinoperfect Glycolic Night Cream
-- update public.products set image_url = '' where id = '8c0b186a-5a1e-59f8-93f9-e83fd37e3bf2';  -- Caudalie Vinoperfect Glycolic Peel Mask
-- update public.products set image_url = '' where id = 'c1009406-0d66-5c70-a27c-a2db5f09ffd8';  -- La Roche-Posay Effaclar Duo+ Anti-Blemish Care
-- update public.products set image_url = '' where id = 'a4de0952-f221-5f63-9b39-a7b7c0d948a8';  -- The Ordinary AHA 30% + BHA 2% Peeling Solution
-- update public.products set image_url = '' where id = 'b8554d6c-1bdd-594f-8eb2-56b1df836a6a';  -- Uriage Hyseac SOS Paste Local Care
