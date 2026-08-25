-- Skinner katalog seed
-- Uretim: scratchpad/generate_sql.py. Elle duzenleme, scripti guncelle.
-- Supabase Dashboard > SQL Editor icinde sirayla calistir.

insert into public.articles
  (id, title, title_tr, content, content_tr, image_url, read_time, article_type, is_active, is_fixed)
values
  ('f6abbc14-c8ef-5d8e-aef7-938144e441b8'::uuid, 'Where To Start If You Have Never Had A Routine', 'Hiç Rutinin Olmadıysa Nereden Başlamalı', 'Most people who ask where to start have already read a list of twelve steps and given up. You do not need twelve. You need three, and you need to do them for long enough to see whether they work.

The three are a cleanser, a moisturiser, and a sunscreen. Cleanser at night to take off the day. Moisturiser after, while the skin is still slightly damp. Sunscreen in the morning, every morning, including the ones where you barely leave the house.

That is the whole thing. No serum yet, no acid, no retinol. Those come later, and they come one at a time so that when something goes wrong you know what caused it.

Give this six weeks before you change anything. Skin turns over slowly and most products need at least a month before there is anything to judge. Six weeks also gets you past the first two weeks, where almost everything feels like it is either working brilliantly or ruining your face. Neither impression is usually accurate.

Pick products that match how your skin behaves, not what you wish it did. If your face feels tight an hour after washing, your cleanser is too strong. If it shines by noon, a heavy cream is not going to help. This is the part where trial and error is genuinely the method, and there is no shortcut around it.

When the three steps are automatic and you have stopped thinking about them, that is the signal you are ready to add a fourth.', 'Nereden başlayacağını soranların çoğu aslında on iki adımlık bir liste okuyup vazgeçmiş oluyor. On iki adıma ihtiyacın yok. Üç adıma ve bunları işe yarayıp yaramadığını görecek kadar uzun süre uygulamaya ihtiyacın var.

Bu üç adım: temizleyici, nemlendirici ve güneş kremi. Akşam temizleyici, günü yüzünden almak için. Hemen ardından, cilt hâlâ hafif nemliyken nemlendirici. Sabah güneş kremi, her sabah, evden neredeyse hiç çıkmadığın günler dahil.

Hepsi bu. Henüz serum yok, asit yok, retinol yok. Onlar sonra geliyor ve teker teker geliyor; böylece bir şey ters gittiğinde sebebini biliyorsun.

Bir şeyi değiştirmeden önce buna altı hafta ver. Cilt yavaş yenileniyor ve çoğu ürün için değerlendirilecek bir şey oluşması en az bir ay sürüyor. Altı hafta ayrıca ilk iki haftayı geride bırakmanı sağlıyor; o dönemde neredeyse her şey ya mucize gibi ya da yüzünü mahvediyormuş gibi geliyor. Genellikle ikisi de doğru değil.

Ürünleri cildinin nasıl davrandığına göre seç, nasıl davranmasını istediğine göre değil. Yıkadıktan bir saat sonra yüzün geriliyorsa temizleyicin fazla sert. Öğlene doğru parlıyorsa ağır bir krem işe yaramayacak. Burada deneme yanılma gerçekten yöntemin kendisi ve kestirme bir yolu yok.

Üç adım otomatikleştiğinde ve artık onları düşünmediğinde, dördüncüyü eklemeye hazırsın demektir.', 'https://images.pexels.com/photos/3552894/pexels-photo-3552894.jpeg?auto=compress&cs=tinysrgb&h=650&w=940', 1, 'Tips', true, false),
  ('2eabc216-be86-50b8-9ccf-5558dbe2a335'::uuid, 'The Order You Apply Things Actually Matters', 'Ürünleri Sürme Sırası Gerçekten Fark Ediyor', 'The rule is simple: thinnest to thickest. A watery serum goes on before a cream, because a cream will block it from getting anywhere.

In practice a morning looks like this. Cleanse. Any liquid step, like a toner or an essence. Serum. Eye cream if you use one. Moisturiser. Sunscreen last, always last, because anything applied over it disturbs the film it needs to form.

Evenings follow the same logic without the sunscreen. If you use a treatment such as retinol or an acid, it goes on after cleansing and before moisturiser, on skin that is properly dry. Damp skin absorbs actives faster, which sounds good and is actually the reason people end up irritated.

Wait a minute or so between layers. Not the ten minutes some routines insist on, just enough that the previous layer is not still sitting wet on the surface. If two products pill and roll off each other, that gap is usually what was missing.

One thing that trips people up: sunscreen is not the step you improvise with. Applying it under moisturiser, mixing it into foundation, or patting a thin layer on top of a wet serum all reduce the protection you actually get. It is the one product where the manufacturer''s instructions are worth following exactly.

If you cannot remember the order in the moment, ask which product would struggle to get through the other. That one goes first.', 'Kural basit: inceden kalına doğru. Su kıvamındaki bir serum kremden önce sürülür, çünkü krem serumun hiçbir yere ulaşmasına izin vermez.

Pratikte bir sabah şöyle görünüyor. Temizlik. Varsa tonik ya da esans gibi sıvı bir adım. Serum. Kullanıyorsan göz kremi. Nemlendirici. En son güneş kremi, her zaman en son; çünkü üzerine sürülen her şey oluşturması gereken filmi bozuyor.

Akşamlar aynı mantıkla ilerliyor, sadece güneş kremi yok. Retinol ya da asit gibi bir bakım ürünü kullanıyorsan, temizlikten sonra ve nemlendiriciden önce, tamamen kuru cilde uygulanıyor. Nemli cilt aktifleri daha hızlı emiyor; kulağa iyi geliyor ama insanların tahriş olmasının asıl sebebi tam olarak bu.

Katmanlar arasında bir dakika kadar bekle. Bazı rutinlerin dayattığı on dakika değil, sadece önceki katman yüzeyde ıslak durmayacak kadar. İki ürün topaklanıp birbirinin üzerinden kayıyorsa, eksik olan genellikle bu aradır.

İnsanları yanıltan bir nokta var: güneş kremi doğaçlama yapılacak adım değil. Nemlendiricinin altına sürmek, fondötene karıştırmak ya da ıslak serumun üzerine ince bir tabaka koymak, gerçekte aldığın korumayı düşürüyor. Üretici talimatına birebir uyulması gereken tek ürün bu.

O anda sırayı hatırlayamazsan şunu sor: hangi ürün diğerinin içinden geçmekte zorlanır. Önce o gelir.', 'https://images.pexels.com/photos/7321503/pexels-photo-7321503.jpeg?auto=compress&cs=tinysrgb&h=650&w=940', 1, 'Tips', true, false),
  ('0be43923-0123-5fb7-88d0-b1d17d55ee32'::uuid, 'Why Your Skin Feels Tight Every Winter', 'Kışın Cildin Neden Sürekli Gergin Hissediyor', 'It is rarely the cold outside. It is the heating inside.

Warm indoor air holds very little moisture, and it pulls water out of whatever is nearby, including your face. Then you step outside into wind that strips whatever is left. Doing this four or five times a day is why skin that behaved all summer suddenly feels like paper in November.

The fix is mostly about holding water in rather than adding more. A hydrating serum is fine, but on its own it evaporates. What keeps it there is the layer over the top, which means winter is the season to move up a texture. If you use a lotion, switch to a cream. If you use a cream, consider a balm for the driest patches around the nose and the corners of the mouth.

Water temperature matters more than people expect. Hot showers feel excellent and leave skin noticeably worse. Lukewarm is enough, and keeping the face out of the direct stream helps.

Cut back on anything exfoliating while this is going on. Winter is not the time to start an acid or push your retinol to nightly. A compromised barrier reacts to actives that were perfectly fine two months ago.

If a humidifier is an option in the room where you sleep, it does more than most products will. Eight hours of less aggressive air adds up.', 'Sorun genellikle dışarıdaki soğuk değil, içerideki kalorifer.

Sıcak iç mekan havası çok az nem tutuyor ve yakınındaki her şeyden su çekiyor; yüzün de buna dahil. Sonra dışarı çıkıp kalanı da alıp götüren rüzgara giriyorsun. Bunu günde dört beş kez yapmak, yaz boyunca uslu duran cildin kasımda neden kağıt gibi hissettiğini açıklıyor.

Çözüm daha fazla nem eklemekten çok, olanı içeride tutmakla ilgili. Nemlendirici serum iyidir ama tek başına buharlaşıp gidiyor. Onu yerinde tutan şey üstteki katman; bu da kışın doku kalınlaştırma mevsimi olduğu anlamına geliyor. Losyon kullanıyorsan kreme geç. Krem kullanıyorsan burun kenarı ve ağız köşeleri gibi en kuru bölgeler için bir balm düşün.

Su sıcaklığı sanılandan daha çok fark ediyor. Sıcak duş harika hissettiriyor ve cildi gözle görülür şekilde kötüleştiriyor. Ilık yeterli, yüzü doğrudan suyun altına tutmamak da işe yarıyor.

Bu dönem boyunca peeling yapan her şeyi azalt. Kış, asit başlatmanın ya da retinolü her geceye çıkarmanın zamanı değil. Zayıflamış bir bariyer, iki ay önce gayet iyi giden aktiflere tepki veriyor.

Uyuduğun odada nemlendirici cihaz kullanma imkanın varsa, çoğu üründen daha fazla iş görüyor. Sekiz saatlik daha yumuşak hava birikiyor.', 'https://images.pexels.com/photos/6149176/pexels-photo-6149176.jpeg?auto=compress&cs=tinysrgb&h=650&w=940', 1, 'Tips', true, false),
  ('719fae13-1a3a-5d25-b0e5-6319ca56dbc7'::uuid, 'Lightening Up Your Routine For Hot Weather', 'Sıcak Havalarda Rutini Hafifletmek', 'The routine that worked in February will feel like a mistake in July. Nothing has gone wrong. Skin genuinely needs less occlusion when the air is humid and you are sweating.

The usual move is to drop one texture level across the board. Cream becomes gel cream. Gel cream becomes a light lotion. If your face feels coated by mid morning, that is the signal, not a sign you need a stronger cleanser to deal with it.

Some steps can be combined. A moisturiser with SPF is often enough for a day spent mostly indoors, which removes a layer without removing protection. If you are outside for any length of time, keep them separate and apply the sunscreen properly.

Cleansing usually needs to go up rather than down. Sweat, sunscreen and higher oil production together make evening cleansing more of a job than it is in winter. A cleansing oil or balm followed by your normal wash handles it without needing a stronger, more stripping product.

Sunscreen reapplication is the part everyone skips. Once in the morning covers a commute. It does not cover an afternoon outdoors. A stick or a fluid in a bag makes the difference between intending to reapply and actually doing it.

Come autumn, move everything back up. Routines are seasonal, and treating them as fixed is why they stop working twice a year.', 'Şubatta işe yarayan rutin temmuzda hata gibi hissettirecek. Ters giden bir şey yok. Hava nemliyken ve terlerken cilt gerçekten daha az kapatıcılığa ihtiyaç duyuyor.

Alışıldık hamle, her adımda bir doku seviyesi aşağı inmek. Krem, jel kreme dönüşür. Jel krem, hafif losyona. Öğlene doğru yüzün kaplanmış gibi hissediyorsa işaret budur; bununla başa çıkmak için daha güçlü bir temizleyiciye ihtiyacın olduğunun göstergesi değil.

Bazı adımlar birleştirilebilir. Çoğunlukla içeride geçen bir gün için SPF''li nemlendirici genellikle yeterli; korumayı kaldırmadan bir katman eksiltiyor. Dışarıda uzunca vakit geçireceksen ikisini ayrı tut ve güneş kremini gerektiği gibi uygula.

Temizlik genellikle azalmak yerine artmalı. Ter, güneş kremi ve yükselen yağ üretimi bir araya gelince akşam temizliği kışa göre daha ciddi bir iş haline geliyor. Temizleyici yağ ya da balm, ardından normal yıkaman bunu daha sert ve soyucu bir ürüne ihtiyaç duymadan hallediyor.

Güneş kremini tazelemek herkesin atladığı kısım. Sabah bir kez sürmek işe gidiş gelişi karşılıyor. Dışarıda geçen bir öğleden sonrayı karşılamıyor. Çantada duran bir stick ya da fluid, tazelemeyi düşünmekle gerçekten yapmak arasındaki farkı yaratıyor.

Sonbahar gelince her şeyi tekrar yukarı çek. Rutinler mevsimlik ve onları sabit saymak, yılda iki kez neden çalışmayı bıraktıklarını açıklıyor.', 'https://images.pexels.com/photos/5202462/pexels-photo-5202462.jpeg?auto=compress&cs=tinysrgb&h=650&w=940', 1, 'Tips', true, false),
  ('6c6de664-b2ba-5cf2-9292-ac3da44ccd0f'::uuid, 'What A Bad Night Of Sleep Does To Your Face', 'Kötü Bir Gecenin Yüzüne Yaptığı Şey', 'You can usually see a bad night on your face before you feel it anywhere else. There are a few separate things happening at once.

Fluid is the obvious one. Lying flat lets fluid settle around the eyes, and the thin skin there shows it immediately. This is why puffiness is worse in the morning and eases over an hour or two once you are upright. Sleeping with your head slightly raised genuinely helps, and cold on the area speeds up what would happen anyway.

Colour is the second. Poor sleep changes how blood sits in the small vessels under the eye, and because that skin is thin, what is underneath shows through as grey or blue. No cream removes this. Concealer covers it, sleep fixes it.

The third is less visible and matters more. Skin does most of its repair work overnight, and repeatedly cutting that short shows up over months as duller texture and slower healing. One bad night is nothing. A bad year is something.

What helps in the short term is unglamorous. Hydrate the skin properly before bed so it is not also dealing with water loss. Keep the room cool. Change the pillowcase more often than feels necessary.

What helps in the long term is the sleep itself, which no product replaces and every product implies it can.', 'Kötü bir geceyi genellikle başka hiçbir yerde hissetmeden önce yüzünde görüyorsun. Aynı anda birkaç ayrı şey oluyor.

En bariz olanı sıvı. Düz yatmak sıvının göz çevresine birikmesine izin veriyor ve oradaki ince cilt bunu anında gösteriyor. Şişliğin sabah daha kötü olması ve ayağa kalktıktan bir iki saat sonra azalması bu yüzden. Başı hafif yüksekte uyumak gerçekten işe yarıyor, bölgeye soğuk uygulamak da zaten olacak olanı hızlandırıyor.

İkincisi renk. Yetersiz uyku göz altındaki küçük damarlarda kanın duruşunu değiştiriyor ve o cilt ince olduğu için alttaki gri ya da mavi olarak dışarı vuruyor. Hiçbir krem bunu ortadan kaldırmıyor. Kapatıcı örtüyor, uyku düzeltiyor.

Üçüncüsü daha az görünür ve daha önemli. Cilt onarım işinin çoğunu gece yapıyor ve bunu sürekli yarıda kesmek, aylar içinde donuk bir doku ve yavaşlayan iyileşme olarak ortaya çıkıyor. Tek bir kötü gece hiçbir şey. Kötü bir yıl bir şey.

Kısa vadede işe yarayanlar çok da parlak değil. Yatmadan önce cildi düzgün nemlendir ki bir de su kaybıyla uğraşmasın. Odayı serin tut. Yastık kılıfını gerekli hissettiğinden daha sık değiştir.

Uzun vadede işe yarayan şey uykunun kendisi; hiçbir ürünün yerini tutamadığı ama her ürünün tutabilirmiş gibi ima ettiği şey.', 'https://images.pexels.com/photos/3807626/pexels-photo-3807626.jpeg?auto=compress&cs=tinysrgb&h=650&w=940', 1, 'Tips', true, false),
  ('cdf15482-ac69-574d-b133-62340e05b8ed'::uuid, 'Does Drinking More Water Actually Hydrate Your Skin', 'Daha Çok Su İçmek Cildi Gerçekten Nemlendirir mi', 'Partly, and less directly than the advice suggests.

If you are properly dehydrated, it shows on your skin along with everything else, and drinking water fixes it. But once you are adequately hydrated, drinking more does not push extra water into the outer layer of skin. Your body distributes it where it is needed, and the surface of your face is low on that list.

The dryness most people are trying to solve is a barrier problem, not a supply problem. Water is arriving fine. It is leaving too quickly because the outer layer is not holding it. That is what moisturisers address, and it is why someone can drink three litres a day and still have flaking cheeks in February.

This is also why hydrating serums work the way they do. Hyaluronic acid pulls water into the upper layers and holds it there, and the cream over the top slows down how fast it escapes. Neither of those has anything to do with what you drank.

None of this is an argument against drinking water. Being properly hydrated matters for reasons that have nothing to do with your face, and mild dehydration does make skin look flatter and more tired.

Just do not expect it to replace a moisturiser. If your skin is dry, the thing that fixes it goes on the outside.', 'Kısmen, ve tavsiyenin ima ettiği kadar doğrudan değil.

Gerçekten susuz kaldıysan bu her şeyle birlikte cildinde de görülüyor ve su içmek bunu düzeltiyor. Ama yeterince su almış durumdaysan, daha fazla içmek cildin dış katmanına fazladan su göndermiyor. Vücut suyu ihtiyaç olan yere dağıtıyor ve yüzünün yüzeyi o listede aşağı sıralarda.

Çoğu insanın çözmeye çalıştığı kuruluk bir bariyer sorunu, arz sorunu değil. Su zaten geliyor. Dış katman tutamadığı için çok hızlı gidiyor. Nemlendiricilerin çözdüğü şey bu ve birinin günde üç litre içip yine de şubatta yanaklarının pul pul olmasının sebebi de bu.

Nemlendirici serumların çalışma biçimi de bundan kaynaklanıyor. Hyaluronik asit suyu üst katmanlara çekip orada tutuyor, üstteki krem de kaçış hızını yavaşlatıyor. İkisinin de ne içtiğinle bir ilgisi yok.

Bunların hiçbiri su içmemek için bir gerekçe değil. Yeterli su almak yüzünle hiç ilgisi olmayan sebeplerle önemli ve hafif susuzluk cildi gerçekten daha yassı ve yorgun gösteriyor.

Sadece bunun nemlendiricinin yerini tutmasını bekleme. Cildin kuruysa onu düzelten şey dışarıdan sürülüyor.', 'https://images.pexels.com/photos/2311854/pexels-photo-2311854.jpeg?auto=compress&cs=tinysrgb&h=650&w=940', 1, 'Tips', true, false),
  ('cbd59af7-e0be-53a5-9571-ac4ecaf14ff4'::uuid, 'The Fabric Your Face Touches Every Night', 'Yüzünün Her Gece Değdiği Kumaş', 'You spend roughly a third of your life with one side of your face pressed into a pillowcase. It is worth thinking about occasionally.

The main issue is accumulation. Oil, sweat, product residue and hair product all transfer overnight and stay there. Sleep on the same side for a week and you are rubbing seven days of that back into your skin. If you break out consistently on one cheek and not the other, this is the first thing to check.

Once or twice a week is a reasonable change interval for most people. More often if you have oily skin, use heavy hair products, or are in the middle of a breakout.

Fabric matters less than frequency, though it is not nothing. Silk and satin create less friction, which helps if you wake up with sleep creases that take an hour to settle. Cotton is more absorbent, which means it pulls moisture and product off your face during the night. Neither is wrong. If you use a rich night cream and want it to stay on your skin, the smoother fabric has an advantage.

Face towels are the same problem in a shorter cycle. A damp towel on a hook stays damp, and a towel used for four days is not clean. Use a separate small towel for your face and change it every couple of days, or pat dry with a tissue.

None of this replaces a routine. It just stops undoing one.', 'Hayatının kabaca üçte birini yüzünün bir yanı yastık kılıfına yapışık geçiriyorsun. Arada bir düşünmeye değer.

Asıl mesele birikim. Yağ, ter, ürün kalıntısı ve saç ürünleri gece boyunca geçip orada kalıyor. Bir hafta aynı tarafta uyuduğunda, yedi günlük birikimi cildine geri sürüyorsun. Sürekli tek yanağında sivilce çıkıp diğerinde çıkmıyorsa, ilk bakılacak yer burası.

Çoğu kişi için haftada bir ya da iki kez değiştirmek makul bir aralık. Cildin yağlıysa, ağır saç ürünleri kullanıyorsan ya da sivilce döneminin ortasındaysan daha sık.

Kumaş türü sıklık kadar önemli değil, ama önemsiz de değil. İpek ve saten daha az sürtünme yaratıyor; sabah bir saat geçmeyen uyku izleriyle uyanıyorsan bu işe yarıyor. Pamuk daha emici, yani gece boyunca yüzünden nem ve ürün çekiyor. İkisi de yanlış değil. Zengin bir gece kremi kullanıyorsan ve cildinde kalmasını istiyorsan, pürüzsüz kumaşın avantajı var.

Yüz havluları aynı sorunun daha kısa döngüsü. Askıda duran nemli havlu nemli kalıyor ve dört gün kullanılmış bir havlu temiz değil. Yüzün için ayrı küçük bir havlu kullan ve iki günde bir değiştir, ya da peçeteyle kurula.

Bunların hiçbiri bir rutinin yerini tutmuyor. Sadece rutini bozmayı bırakıyor.', 'https://images.pexels.com/photos/4108896/pexels-photo-4108896.jpeg?auto=compress&cs=tinysrgb&h=650&w=940', 1, 'Tips', true, false),
  ('cb9a12be-f7f4-50f0-ab1f-e9b6aba04cd0'::uuid, 'What To Do With Your Face After The Gym', 'Spordan Sonra Yüzüne Ne Yapmalı', 'Sweat itself is not the problem. Leaving it to dry on your face along with everything it mixed with is.

During a workout you produce more oil, your pores are more open from the heat, and sweat sits on top of whatever you were already wearing. If that includes makeup or a heavy sunscreen, the combination has an easy time settling into places you would rather it did not. This is where post workout breakouts along the hairline and jaw usually come from.

The fix is a cleanse within a reasonable time of finishing, not an aggressive one. Your skin has just been through heat and friction; a strong foaming wash on top of that is more than it needs. A gentle gel or a micellar water does the job.

If you cannot get to a sink, wipe down with a micellar pad and cleanse properly later. Splashing with water alone leaves the oil behind, which is the part that matters.

Two habits worth adding. Tie your hair back before you start, because hair product transfers to the forehead as soon as you sweat. And stop touching your face with your hands, which is harder than it sounds in a gym.

Afterwards, keep it light. Skin that is warm and slightly flushed does not want an occlusive layer straight away. Moisturiser is fine, actives can wait until evening.', 'Sorun terin kendisi değil. Karıştığı her şeyle birlikte yüzünde kurumaya bırakılması.

Antrenman sırasında daha fazla yağ üretiyorsun, sıcaktan gözeneklerin daha açık oluyor ve ter zaten üzerinde olan her şeyin üstüne oturuyor. Buna makyaj ya da ağır bir güneş kremi de dahilse, bu karışım istemediğin yerlere kolayca yerleşiyor. Spor sonrası saç çizgisinde ve çene hattında çıkan sivilcelerin kaynağı genellikle burası.

Çözüm, bitirdikten sonra makul bir süre içinde temizlik yapmak; sert bir temizlik değil. Cildin az önce sıcak ve sürtünmeden geçti, üstüne güçlü bir köpüklü yıkama ihtiyacından fazlası olur. Yumuşak bir jel ya da misel su işi görüyor.

Lavaboya ulaşamıyorsan misel pedle sil, düzgün temizliği sonraya bırak. Sadece suyla çarpmak yağı yerinde bırakıyor ve asıl mesele o yağ.

Eklenmeye değer iki alışkanlık. Başlamadan önce saçını topla, çünkü terlemeye başladığın anda saç ürünü alnına geçiyor. Ve yüzüne elinle dokunmayı bırak; spor salonunda kulağa geldiğinden daha zor.

Sonrasında hafif tut. Sıcak ve hafif kızarmış bir cilt hemen kapatıcı bir katman istemiyor. Nemlendirici uygun, aktifler akşamı bekleyebilir.', 'https://images.pexels.com/photos/5000199/pexels-photo-5000199.jpeg?auto=compress&cs=tinysrgb&h=650&w=940', 1, 'Tips', true, false),
  ('68c4cdd5-b79c-544e-ac31-34cc45781e3f'::uuid, 'Long Flights And The Dry Skin That Follows', 'Uzun Uçuşlar ve Ardından Gelen Kuruluk', 'Cabin air sits at around ten to twenty percent humidity. Most indoor spaces are somewhere between thirty and fifty. You are effectively sitting in a desert for however long the flight lasts.

What that does is straightforward. Water evaporates from your skin faster than usual, and there is no moisture in the air to slow it down. Add cabin pressure, dehydration from not drinking enough, and a night of bad sleep, and the tight, dull face you land with makes sense.

The useful preparation happens before boarding, not during. Cleanse and moisturise properly before you go, with something heavier than your usual daytime layer. A cream rather than a lotion. The occlusive layer is the part doing the work here, because it slows evaporation.

Skip makeup if you can. It is not that it damages anything, it is that it makes it awkward to add more moisturiser mid flight, which is the one thing worth doing.

On long flights, reapply something around the halfway point. A balm on the driest areas is enough. Facial mists feel good and evaporate quickly, which can leave skin drier than before unless you seal them with a cream.

Drink water steadily rather than in one go, and go easy on coffee and alcohol.

Once you land, go back to your normal routine. Skin usually recovers within a day.', 'Uçak kabini havası yüzde on ile yirmi arasında nem oranına sahip. Çoğu kapalı mekan otuz ile elli arasında. Uçuş boyunca fiilen çölde oturuyorsun.

Bunun etkisi basit. Su cildinden normalden hızlı buharlaşıyor ve havada bunu yavaşlatacak nem yok. Üzerine kabin basıncını, yeterince su içmemekten gelen susuzluğu ve kötü bir uyku gecesini ekleyince, indiğinde karşılaştığın o gergin ve donuk yüz anlam kazanıyor.

Faydalı hazırlık uçuş sırasında değil, binmeden önce oluyor. Gitmeden önce düzgün temizlik yap ve her zamanki gündüz katmanından daha ağır bir şeyle nemlendir. Losyon yerine krem. Burada asıl işi yapan kapatıcı katman, çünkü buharlaşmayı yavaşlatıyor.

Yapabiliyorsan makyaj yapma. Bir şeye zarar verdiği için değil, uçuşun ortasında nemlendirici eklemeyi zorlaştırdığı için; ki yapmaya değer tek şey o.

Uzun uçuşlarda yarı yolda bir şey tazele. En kuru bölgelere balm sürmek yeterli. Yüz spreyleri iyi hissettiriyor ve hızla buharlaşıyor; kremle üzerini kapatmazsan cildi öncekinden daha kuru bırakabiliyor.

Suyu tek seferde değil, düzenli aralıklarla iç; kahve ve alkolde ölçülü ol.

İndikten sonra normal rutinine dön. Cilt genellikle bir gün içinde toparlıyor.', 'https://images.pexels.com/photos/735236/pexels-photo-735236.jpeg?auto=compress&cs=tinysrgb&h=650&w=940', 1, 'Tips', true, false),
  ('7122490d-26b1-5bb6-a94f-f5161b348550'::uuid, 'Calming Skin That Reacts After Shaving', 'Tıraştan Sonra Tepki Veren Cildi Yatıştırmak', 'Shaving removes hair and a thin layer of skin along with it. That is why the same routine that felt fine on Monday can sting on Thursday.

Most irritation comes down to three things: a blunt blade, not enough lubrication, and going against the direction of growth. A blade that has done more than five or six shaves drags rather than cuts, and dragging is what causes the burn. Changing it more often solves more problems than any product will.

Warm water and a proper shaving cream or gel first, and give it a minute to soften the hair before you start. Short strokes, light pressure, and rinse the blade often.

Afterwards, skip anything with alcohol. It feels bracing and it is exactly the wrong thing on skin that has just been abraded. What helps is a plain, fragrance free moisturiser or a soothing balm with panthenol or centella. Cold water at the end of the rinse calms things down.

If you get ingrown hairs, a low strength salicylic acid product two or three times a week keeps the follicles clear. Do not use it the same day you shave.

And leave actives alone for the evening. Retinol or an acid on freshly shaved skin is the most common way people end up with a reaction they blame on the product rather than the timing.', 'Tıraş kılı alırken beraberinde ince bir cilt katmanını da alıyor. Pazartesi sorunsuz gelen aynı rutinin perşembe yakmasının sebebi bu.

Tahrişin çoğu üç şeye dayanıyor: körelmiş bıçak, yetersiz kayganlık ve çıkış yönünün tersine gitmek. Beş altı tıraştan fazlasını görmüş bir bıçak kesmek yerine sürüklüyor ve yanmaya sebep olan şey o sürüklenme. Bıçağı daha sık değiştirmek, hiçbir ürünün çözemeyeceği kadar çok sorunu çözüyor.

Önce ılık su ve düzgün bir tıraş kremi ya da jeli; başlamadan önce kılın yumuşaması için bir dakika bekle. Kısa hareketler, hafif basınç ve bıçağı sık sık durula.

Sonrasında alkol içeren hiçbir şeye dokunma. Canlandırıcı hissettiriyor ve az önce aşınmış bir cilt için tam olarak yanlış şey. İşe yarayan şey sade, parfümsüz bir nemlendirici ya da pantenol veya centella içeren yatıştırıcı bir balm. Durulamanın sonunda soğuk su işleri sakinleştiriyor.

Batık kılın oluyorsa, haftada iki üç kez düşük dozlu salisilik asitli bir ürün folikülleri açık tutuyor. Tıraş olduğun gün kullanma.

Ve akşam aktifleri es geç. Yeni tıraş olmuş cilde retinol ya da asit sürmek, insanların zamanlamayı değil ürünü suçladığı tepkilerin en yaygın sebebi.', 'https://images.pexels.com/photos/19535224/pexels-photo-19535224.jpeg?auto=compress&cs=tinysrgb&h=650&w=940', 1, 'Tips', true, false),
  ('46d06a76-093f-59fd-8dac-284cd041eafa'::uuid, 'Building A Morning Routine You Will Actually Keep', 'Gerçekten Sürdürebileceğin Bir Sabah Rutini Kurmak', 'A morning routine has to survive being tired and running late. If it only works on a good day, it is not a routine.

Three steps is the version that survives. Rinse or cleanse, moisturiser, sunscreen. If your skin is oily, cleanse properly in the morning. If it is dry or sensitive, plain water is often enough, since you cleansed the night before and nothing much happened while you slept.

A serum is the fourth step, and it goes between the first and second. Morning is the sensible slot for antioxidants such as vitamin C, because they work alongside sunscreen rather than against it. If you only own one serum and it is hydrating, morning is fine too.

Sunscreen goes on last and needs more than most people use. Roughly two fingers worth for the face and neck. Applying half the amount does not give you half the protection, it gives you considerably less, which is why underapplication is the most common reason sunscreen appears not to work.

Leave a short gap before makeup so the sunscreen sets. A minute or two is usually enough to stop foundation from moving around.

What makes a morning routine stick is keeping the products in one place and not requiring any decisions. If you have to think about the order, you will skip it on the mornings that count.', 'Bir sabah rutini yorgun ve geç kalmış halinden sağ çıkabilmeli. Sadece iyi bir günde işliyorsa o rutin değil.

Ayakta kalan versiyon üç adımlık. Durulama ya da temizlik, nemlendirici, güneş kremi. Cildin yağlıysa sabah düzgün temizlik yap. Kuru ya da hassassa çoğu zaman sade su yeterli; zaten önceki akşam temizlemiştin ve uyurken pek bir şey olmadı.

Serum dördüncü adım ve birinciyle ikincinin arasına giriyor. C vitamini gibi antioksidanlar için mantıklı yer sabah, çünkü güneş kremine karşı değil onunla birlikte çalışıyorlar. Tek bir serumun varsa ve o da nemlendiriciyse, sabah yine uygun.

Güneş kremi en son geliyor ve çoğu insanın kullandığından fazlasını gerektiriyor. Yüz ve boyun için kabaca iki parmak boyu. Yarısını sürmek korumanın yarısını vermiyor, epeyce daha azını veriyor; güneş kremi çalışmıyor gibi görünmesinin en yaygın sebebi bu.

Makyajdan önce kısa bir ara bırak ki güneş kremi otursun. Fondötenin kaymasını engellemek için bir iki dakika genellikle yeterli.

Bir sabah rutinini kalıcı kılan şey, ürünleri tek bir yerde tutmak ve hiçbir karar gerektirmemesi. Sırayı düşünmen gerekiyorsa, tam da önemli olan sabahlarda atlayacaksın.', 'https://images.pexels.com/photos/4202321/pexels-photo-4202321.jpeg?auto=compress&cs=tinysrgb&h=650&w=940', 1, 'Routine', true, false),
  ('b74be03e-2fa1-59e2-92df-ff476caba9d3'::uuid, 'The Evening Routine Explained Step By Step', 'Akşam Rutini Adım Adım', 'Evening is where the actual work happens. Morning protects, evening repairs.

Start with removal. If you wore sunscreen or makeup, one cleanse is not enough. An oil or balm first to break down what is water resistant, then your normal cleanser to clear what is left. This is the double cleanse, and it is only necessary on days you actually wore something.

Next is your treatment step, if you have one. Retinol, an acid, or a targeted serum. Only one of these per night. Skin applies the same tolerance budget to all of them, and stacking two is how people end up with a red, tight face and no idea which product caused it.

Wait a couple of minutes, then moisturise. Heavier than your morning cream if your skin will take it, since there is no makeup or sunscreen going on top and nothing to interfere with.

Eye cream, if you use one, goes before moisturiser. Pat, do not rub.

Two things worth doing regardless of routine. Cleanse before you are exhausted, because the routine you do at eleven is better than the one you skip at one. And leave the face alone afterwards, since touching, picking and checking in the mirror undoes more than most products can fix.', 'Asıl iş akşam yapılıyor. Sabah koruyor, akşam onarıyor.

Temizlemeyle başla. Güneş kremi ya da makyaj kullandıysan tek temizlik yetmiyor. Önce suya dayanıklı olanı çözmek için yağ ya da balm, ardından kalanı almak için normal temizleyicin. Buna çift temizlik deniyor ve sadece gerçekten bir şey sürdüğün günlerde gerekiyor.

Sırada varsa bakım adımın var. Retinol, bir asit ya da hedefli bir serum. Gecede bunlardan sadece biri. Cilt hepsine aynı tolerans bütçesini uyguluyor ve iki tanesini üst üste koymak, insanların kırmızı ve gergin bir yüzle kalıp hangi ürünün sebep olduğunu bilememesine yol açıyor.

Birkaç dakika bekle, sonra nemlendir. Cildin kaldırıyorsa sabah kreminden daha ağır olabilir, çünkü üzerine makyaj ya da güneş kremi gelmiyor ve karışacak bir şey yok.

Kullanıyorsan göz kremi nemlendiriciden önce geliyor. Ovalamadan, hafifçe bastırarak.

Rutin ne olursa olsun yapmaya değer iki şey var. Bitkin düşmeden temizlik yap, çünkü on birde yaptığın rutin birde atladığından iyidir. Ve sonrasında yüzüne dokunma; ellemek, sıkmak ve aynada kontrol etmek çoğu ürünün düzeltebileceğinden fazlasını bozuyor.', 'https://images.pexels.com/photos/10222467/pexels-photo-10222467.jpeg?auto=compress&cs=tinysrgb&h=650&w=940', 1, 'Routine', true, false),
  ('f9a39b98-b3f8-5805-9ffe-950c54200d42'::uuid, 'A Routine That Works With Oily Skin Not Against It', 'Yağlı Ciltle Savaşmayan, Onunla Çalışan Bir Rutin', 'The instinct with oily skin is to strip it. It is also the reason so many people stay stuck in a cycle of dry, tight skin that gets oilier by the afternoon.

When you remove too much oil, the skin does not decide to produce less. It responds to the loss of barrier lipids by producing more. Harsh foaming cleansers, alcohol toners and washing four times a day all feed that loop.

What works instead is a gentle gel cleanser twice a day, no more. Then a lightweight moisturiser, which is the step most oily skin routines skip. Skin that is properly hydrated produces less surface oil, and gel creams exist specifically so this does not feel heavy.

For the oil itself, niacinamide is the most reliable daily option. It reduces the appearance of pores and helps regulate sebum without irritation, and it sits comfortably alongside almost everything else.

Salicylic acid handles the clogging. Two or three nights a week is enough to start. It is oil soluble, which is why it gets into pores where other acids stay on the surface.

Sunscreen is the step oily skin most often abandons, usually because the texture is unbearable. Fluids and gel creams marked oil free solve this, and skipping it undoes everything the rest of the routine is doing.', 'Yağlı ciltte ilk içgüdü onu soymak oluyor. Bu aynı zamanda bu kadar çok insanın kuru ve gergin, öğleden sonra daha da yağlanan bir cilt döngüsünde sıkışıp kalmasının sebebi.

Fazla yağ aldığında cilt daha az üretmeye karar vermiyor. Bariyer lipitlerinin kaybına daha fazla üreterek karşılık veriyor. Sert köpüklü temizleyiciler, alkollü tonikler ve günde dört kez yıkamak bu döngüyü besliyor.

Bunun yerine işe yarayan şey günde iki kez, daha fazla değil, yumuşak bir jel temizleyici. Ardından hafif bir nemlendirici; yağlı cilt rutinlerinin en çok atladığı adım. Düzgün nemlendirilmiş cilt yüzeyde daha az yağ üretiyor ve jel kremler tam da ağır hissettirmesin diye var.

Yağın kendisi için niasinamid en güvenilir günlük seçenek. Gözeneklerin görünümünü azaltıyor, sebum dengesini tahriş etmeden düzenliyor ve neredeyse her şeyin yanında rahat duruyor.

Tıkanıklığı salisilik asit hallediyor. Başlangıç için haftada iki üç gece yeterli. Yağda çözünüyor, diğer asitler yüzeyde kalırken bu yüzden gözeneğin içine giriyor.

Güneş kremi yağlı cildin en sık terk ettiği adım; genellikle dokusu çekilmez geldiği için. Yağsız olarak işaretlenmiş fluid ve jel kremler bunu çözüyor ve bu adımı atlamak rutinin geri kalanının yaptığı her şeyi geri alıyor.', 'https://images.pexels.com/photos/7648163/pexels-photo-7648163.jpeg?auto=compress&cs=tinysrgb&h=650&w=940', 1, 'Routine', true, false),
  ('61f9060a-47a0-5a02-8d4a-f6fc47d2b10f'::uuid, 'Layering For Skin That Never Feels Like Enough', 'Hiçbir Şeyin Yetmediği Cilt İçin Katmanlama', 'Dry skin is usually not short of products. It is short of the layer that keeps them there.

There are two different problems that look identical in the mirror. Dry skin lacks oil. Dehydrated skin lacks water. Oily skin can be dehydrated, which is why some people are shiny and flaky at the same time. If your skin feels tight but still gets oily, treat the water. If it feels rough and never shines, treat the oil.

For most people the answer is both, in order. A hydrating layer first, while the skin is still slightly damp from cleansing. Hyaluronic acid or glycerin, applied to damp skin rather than dry, since it needs water to pull in.

Then the layer that holds it. This is where dry skin routines fall apart, because a light lotion is not enough. A cream with ceramides, or a balm on the driest areas. The point of this layer is not hydration, it is stopping the hydration underneath from evaporating.

Cleansing needs to change too. Foaming washes remove the oil you are trying to keep. A cream or milk cleanser, or an oil, and only once a day for most dry skin.

Do not exfoliate to fix flaking. Flaking on dry skin is a barrier problem, and scrubbing it makes the next round worse.', 'Kuru ciltte genellikle ürün eksikliği yok. Onları yerinde tutan katman eksik.

Aynada aynı görünen iki farklı sorun var. Kuru ciltte yağ eksik. Susuz kalmış ciltte su eksik. Yağlı bir cilt susuz kalabiliyor; bazı insanların aynı anda hem parlak hem pul pul olmasının sebebi bu. Cildin gergin hissediyor ama yine de yağlanıyorsa suyu tedavi et. Pürüzlü hissedip hiç parlamıyorsa yağı.

Çoğu kişi için cevap ikisi birden, sırayla. Önce nemlendirici katman, cilt temizlikten hâlâ hafif nemliyken. Hyaluronik asit ya da gliserin, kuru cilde değil nemli cilde uygulanmalı; çünkü çekecek suya ihtiyacı var.

Sonra onu tutan katman. Kuru cilt rutinlerinin dağıldığı yer burası, çünkü hafif bir losyon yetmiyor. Seramidli bir krem ya da en kuru bölgelere balm. Bu katmanın amacı nemlendirmek değil, alttaki nemin buharlaşmasını engellemek.

Temizliğin de değişmesi gerekiyor. Köpüklü yıkamalar tutmaya çalıştığın yağı alıyor. Krem ya da süt temizleyici veya yağ, ve çoğu kuru cilt için günde sadece bir kez.

Pullanmayı düzeltmek için peeling yapma. Kuru ciltte pullanma bir bariyer sorunu ve ovalamak bir sonraki turu daha kötü hale getiriyor.', 'https://images.pexels.com/photos/9774854/pexels-photo-9774854.jpeg?auto=compress&cs=tinysrgb&h=650&w=940', 1, 'Routine', true, false),
  ('da4562dd-6f6d-5540-80f3-1ff064a04738'::uuid, 'When Your T Zone And Cheeks Want Different Things', 'T Bölgen ve Yanakların Farklı Şeyler İstediğinde', 'Combination skin is the one where following the instructions on the box does not work, because the box assumes your whole face behaves the same way.

The straightforward answer is to stop treating it as one surface. Use different products in different places. A mattifying gel on the forehead, nose and chin, a richer cream on the cheeks. It sounds fussy and takes about fifteen extra seconds.

What you should not do is pick products for the oily part and apply them everywhere. That is how cheeks end up dry and flaking while the T zone carries on exactly as before.

Cleansing can stay uniform if you pick something gentle. A mild gel works across the whole face. The mistake is choosing a strong cleanser aimed at the T zone, which strips the cheeks and does not solve the oil anyway.

Actives can also be zoned. Salicylic acid on the areas that clog, nothing on the areas that do not. Niacinamide is one of the few things you can use across the whole face regardless, since it helps oil regulation and barrier support at the same time.

Sunscreen is easier to keep uniform. A fluid or gel cream texture generally suits both areas well enough, and applying two different sunscreens is more trouble than it is worth.

Expect the balance to shift with the seasons. The zoning that works in July will be wrong in January.', 'Karma cilt, kutunun üzerindeki talimatı uygulamanın işe yaramadığı cilt tipi; çünkü kutu tüm yüzünün aynı davrandığını varsayıyor.

Basit cevap onu tek bir yüzey olarak görmeyi bırakmak. Farklı yerlerde farklı ürünler kullan. Alın, burun ve çeneye matlaştırıcı jel, yanaklara daha zengin bir krem. Kulağa zahmetli geliyor ve fazladan on beş saniye alıyor.

Yapmaman gereken şey, yağlı bölge için ürün seçip her yere sürmek. Yanakların kuruyup pullanırken T bölgesinin aynen devam etmesi bu şekilde oluyor.

Yumuşak bir şey seçersen temizlik aynı kalabilir. Hafif bir jel tüm yüzde çalışıyor. Hata, T bölgesini hedefleyen güçlü bir temizleyici seçmek; yanakları soyuyor ve yağı da zaten çözmüyor.

Aktifler de bölgesel uygulanabilir. Tıkanan bölgelere salisilik asit, tıkanmayanlara hiçbir şey. Niasinamid, tüm yüze uygulanabilecek birkaç şeyden biri; çünkü aynı anda hem yağ dengesine hem bariyer desteğine katkı veriyor.

Güneş kremini aynı tutmak daha kolay. Fluid ya da jel krem dokusu genellikle her iki bölgeye de yetecek kadar uyuyor ve iki farklı güneş kremi sürmek zahmetine değmiyor.

Dengenin mevsimle kayacağını bekle. Temmuzda işe yarayan bölgeleme ocakta yanlış olacak.', 'https://images.pexels.com/photos/5938260/pexels-photo-5938260.jpeg?auto=compress&cs=tinysrgb&h=650&w=940', 1, 'Routine', true, false),
  ('b21da51b-6405-57bc-929c-6d372248593b'::uuid, 'Short Routines For Skin That Reacts To Everything', 'Her Şeye Tepki Veren Ciltler İçin Kısa Rutinler', 'With sensitive skin, the number of products matters more than which ones. Every additional step is another set of ingredients that might be the problem, and another variable when you are trying to work out what went wrong.

Three steps. Gentle cleanser, moisturiser, sunscreen. That is the whole routine and it should stay that way for at least a month before you add anything.

Read for what is absent rather than what is present. No fragrance, including the natural kind, which is a common trigger. No essential oils. No drying alcohol high in the list. Short ingredient lists in general, since fewer ingredients means fewer candidates when something reacts.

Patch test properly. Inner forearm, twice a day, for five days. Most reactions show up within that window, and finding out on your forearm is considerably better than finding out on your face.

Introduce one product at a time and leave two weeks between additions. If you add three things at once and your face reacts, you have learned nothing except that one of them was a mistake.

Mineral sunscreens are often better tolerated than chemical filters. If a chemical sunscreen stings around the eyes, this is usually why.

When your skin is actively reacting, stop everything except cleanser and moisturiser. The instinct to add a soothing product is understandable and usually makes the timeline longer.', 'Hassas ciltte ürünlerin sayısı hangileri olduğundan daha çok fark ediyor. Her ek adım, sorun olabilecek yeni bir içerik grubu ve neyin ters gittiğini anlamaya çalışırken yeni bir değişken demek.

Üç adım. Yumuşak temizleyici, nemlendirici, güneş kremi. Rutinin tamamı bu ve bir şey eklemeden önce en az bir ay böyle kalmalı.

Ne olduğuna değil, ne olmadığına bakarak oku. Parfüm yok; doğal olanı dahil, yaygın bir tetikleyici. Uçucu yağ yok. Listenin başlarında kurutucu alkol yok. Genel olarak kısa içerik listeleri; çünkü az içerik, bir tepki olduğunda az sayıda şüpheli demek.

Yama testini düzgün yap. İç ön kol, günde iki kez, beş gün. Çoğu tepki bu süre içinde ortaya çıkıyor ve bunu ön kolunda öğrenmek yüzünde öğrenmekten epey iyi.

Ürünleri teker teker dahil et ve eklemeler arasında iki hafta bırak. Aynı anda üç şey ekleyip yüzün tepki verirse, birinin hata olduğu dışında hiçbir şey öğrenmiş olmuyorsun.

Mineral güneş kremleri genellikle kimyasal filtrelerden daha iyi tolere ediliyor. Kimyasal bir güneş kremi göz çevresinde yakıyorsa sebebi genellikle bu.

Cildin aktif olarak tepki verdiği dönemde temizleyici ve nemlendirici dışında her şeyi bırak. Yatıştırıcı bir ürün ekleme dürtüsü anlaşılır ve genellikle süreci uzatıyor.', 'https://images.pexels.com/photos/7670694/pexels-photo-7670694.jpeg?auto=compress&cs=tinysrgb&h=650&w=940', 1, 'Routine', true, false),
  ('33e92e4e-d447-5d68-9faf-9b2d66c53920'::uuid, 'Cutting Your Routine Down To What Works', 'Rutini İşe Yarayana İndirmek', 'If you own eleven products and your skin is not noticeably better than it was two years ago, the problem is probably not that you need a twelfth.

Long routines create two issues. Ingredients interfere with each other, and you lose the ability to tell what is doing what. A person using six actives who develops a reaction has no realistic way of identifying the cause, which usually ends with them stopping everything and starting over.

The way out is a reset. Go back to cleanser, moisturiser and sunscreen for four weeks. This feels like giving up and is closer to running a controlled experiment. Most people find their skin is the same or better, which is useful information about the other eight products.

Then add back one thing, the one you believe was doing the most. Give it three weeks. If you cannot tell whether it helped, that is an answer.

Some things are worth keeping regardless. A sunscreen you will actually wear. A moisturiser that suits the season. One active that addresses your main concern, whatever that is.

Almost everything else is optional, including several categories that marketing treats as essential. Toner, essence, ampoule, and separate day and night serums are choices, not requirements.

A routine you complete every night beats a better routine you manage three times a week.', 'On bir ürünün varsa ve cildin iki yıl öncesine göre gözle görülür şekilde iyi değilse, sorun muhtemelen on ikinciye ihtiyacın olması değil.

Uzun rutinler iki sorun yaratıyor. İçerikler birbirine karışıyor ve neyin ne yaptığını ayırt etme yeteneğini kaybediyorsun. Altı aktif kullanan ve tepki geliştiren birinin sebebi bulmak için gerçekçi bir yolu yok; bu genellikle her şeyi bırakıp baştan başlamakla sonuçlanıyor.

Çıkış yolu bir sıfırlama. Dört hafta boyunca temizleyici, nemlendirici ve güneş kremine geri dön. Pes etmek gibi hissettiriyor ama kontrollü bir deney yürütmeye daha yakın. Çoğu kişi cildinin aynı ya da daha iyi olduğunu görüyor; bu da diğer sekiz ürün hakkında kullanışlı bir bilgi.

Sonra tek bir şeyi geri ekle; en çok işe yaradığına inandığını. Ona üç hafta ver. Fayda edip etmediğini söyleyemiyorsan, bu da bir cevap.

Bazı şeyleri her halükarda tutmaya değer. Gerçekten süreceğin bir güneş kremi. Mevsime uyan bir nemlendirici. Asıl derdine yönelik bir aktif, o her neyse.

Geri kalan neredeyse her şey isteğe bağlı; pazarlamanın zorunlu gösterdiği birkaç kategori dahil. Tonik, esans, ampul ve ayrı gündüz-gece serumları birer tercih, gereklilik değil.

Her gece tamamladığın bir rutin, haftada üç kez yetiştirdiğin daha iyi bir rutini yener.', 'https://images.pexels.com/photos/4202321/pexels-photo-4202321.jpeg?auto=compress&cs=tinysrgb&h=650&w=940', 1, 'Routine', true, false),
  ('db1df1a3-7bde-523c-bb18-9b642248fbdf'::uuid, 'How Often Is Too Often', 'Ne Sıklıkta Fazla Sıklık Olur', 'More often is not more effective, and with active ingredients it is usually the opposite.

Retinol is the clearest example. Nightly use is the end point, not the starting point. Two nights a week for a month, then three, then build from there over several months. People who start nightly almost always stop within two weeks because their skin is peeling, and then conclude retinol does not suit them.

Exfoliating acids have a lower ceiling than most routines assume. Two or three times a week is enough for most skin. Strong peels are weekly at most. The visible smoothness after a peel is tempting and is not a reason to do it again the next day.

Hydrating products have no meaningful limit. Hyaluronic acid, glycerin, ceramides, plain moisturiser. Use them as often as your skin wants them.

Clay masks are once or twice a week. Every day dries the skin out and increases oil production.

Cleansing is twice a day for most people, once for dry or sensitive skin. Washing more does not make skin cleaner, it makes the barrier weaker.

The general principle: anything that changes the skin needs recovery time, anything that supports the skin does not. If a product makes your face tingle, it belongs in the first category, regardless of what the packaging says about being gentle.', 'Daha sık kullanmak daha etkili değil ve aktif içeriklerde genellikle tam tersi.

Retinol en net örnek. Her gece kullanım varış noktası, başlangıç noktası değil. Bir ay boyunca haftada iki gece, sonra üç, sonra birkaç ay içinde yukarı doğru. Her gece başlayanlar neredeyse her zaman iki hafta içinde cildi soyulduğu için bırakıyor ve ardından retinolün kendilerine uymadığı sonucuna varıyor.

Peeling asitlerinin tavanı çoğu rutinin sandığından daha düşük. Çoğu cilt için haftada iki üç kez yeterli. Güçlü peelingler en fazla haftada bir. Peeling sonrası görünen pürüzsüzlük cezbedici ve ertesi gün tekrarlamak için bir sebep değil.

Nemlendirici ürünlerin anlamlı bir sınırı yok. Hyaluronik asit, gliserin, seramidler, sade nemlendirici. Cildin istediği sıklıkta kullan.

Kil maskeleri haftada bir ya da iki. Her gün cildi kurutuyor ve yağ üretimini artırıyor.

Temizlik çoğu kişi için günde iki kez, kuru ya da hassas ciltte bir kez. Daha çok yıkamak cildi daha temiz yapmıyor, bariyeri daha zayıf yapıyor.

Genel ilke şu: cildi değiştiren her şey toparlanma süresi istiyor, cildi destekleyen hiçbir şey istemiyor. Bir ürün yüzünde karıncalanma yapıyorsa, ambalajında yumuşak yazsa da birinci kategoriye giriyor.', 'https://images.pexels.com/photos/11773871/pexels-photo-11773871.jpeg?auto=compress&cs=tinysrgb&h=650&w=940', 1, 'Routine', true, false),
  ('6bc83a97-e07a-594e-bef0-5705e8797d2c'::uuid, 'Niacinamide In Plain Language', 'Sade Bir Dille Niasinamid', 'Niacinamide is a form of vitamin B3, and it is in a large share of products on the shelf because it does several useful things without being difficult to use.

It helps regulate oil, which is why it turns up in products for oily and blemish prone skin. It supports the barrier, so skin holds water better. And it helps with uneven tone, particularly the flat brown marks left after spots heal.

None of these effects are dramatic on their own. Together they add up to skin that looks more even and behaves more predictably, which is usually what people mean when they say a product worked.

The strengths you see are mostly between 4 and 10 percent. Higher is available and is not better; above 10 percent some people get flushing, and the extra does not buy much. If you are new to it, start at the lower end.

It is one of the easiest actives to combine. It sits fine alongside retinol, hyaluronic acid, ceramides and most sunscreens. The old advice about not mixing it with vitamin C came from lab conditions that do not reflect finished products, and most formulators now consider it a non issue.

Timing is flexible. Morning, evening or both. If your skin flushes when you apply it, use less or drop to a lower percentage.', 'Niasinamid, B3 vitamininin bir formu ve raftaki ürünlerin büyük bölümünde bulunuyor; çünkü kullanımı zor olmadan birkaç işe yarar şey yapıyor.

Yağ dengesini düzenlemeye yardımcı oluyor, bu yüzden yağlı ve sivilceye eğilimli cilt ürünlerinde çıkıyor. Bariyeri destekliyor, böylece cilt suyu daha iyi tutuyor. Ve ton eşitsizliğine, özellikle sivilceler iyileştikten sonra kalan düz kahverengi izlere iyi geliyor.

Bu etkilerin hiçbiri tek başına çarpıcı değil. Bir araya geldiklerinde daha eşit görünen ve daha öngörülebilir davranan bir cilt ortaya çıkıyor; insanların "bu ürün işe yaradı" derken kastettiği şey genellikle bu.

Gördüğün oranlar çoğunlukla yüzde 4 ile 10 arasında. Daha yükseği var ve daha iyi değil; yüzde 10''un üzerinde bazı insanlarda kızarma oluyor ve fazlası pek bir şey kazandırmıyor. Yeni başlıyorsan alt sınırdan başla.

Birleştirilmesi en kolay aktiflerden biri. Retinol, hyaluronik asit, seramidler ve çoğu güneş kremiyle sorunsuz duruyor. C vitaminiyle karıştırmama tavsiyesi, bitmiş ürünleri yansıtmayan laboratuvar koşullarından geliyordu ve formülatörlerin çoğu artık bunu sorun saymıyor.

Zamanlama esnek. Sabah, akşam ya da ikisi. Sürdüğünde cildin kızarıyorsa daha az kullan ya da daha düşük bir orana in.', 'https://images.pexels.com/photos/28994388/pexels-photo-28994388.jpeg?auto=compress&cs=tinysrgb&h=650&w=940', 1, 'Ingredient', true, false),
  ('d485837b-5eff-51e7-bca3-36d09be32ab4'::uuid, 'Hyaluronic Acid And The Thing Nobody Mentions', 'Hyaluronik Asit ve Kimsenin Söylemediği Şey', 'Hyaluronic acid is a humectant. It pulls water towards itself and holds it, which is why a hyaluronic serum makes skin look plumper within minutes.

Here is the part that gets left out. It pulls water from wherever it can find it. In humid air that means from the environment. In dry air, it can end up drawing water from the deeper layers of your skin and releasing it into the atmosphere, which leaves you drier than before you applied it.

This is why the same serum can feel excellent in August and make your face tight in January. It is also why the standard advice matters more than it sounds: apply it to damp skin, and put a moisturiser over it.

Damp skin gives it water to work with. The moisturiser on top stops what it has gathered from evaporating. Skip either step in dry conditions and you can genuinely end up worse off.

Molecular weight comes up a lot in marketing. The short version is that a mix of sizes is more useful than one, since different sizes sit at different depths. Most decent products already contain a mix, and it is not worth choosing a product on this alone.

If a hyaluronic serum has never done anything noticeable for you, try applying it to a damp face and sealing it. That is usually the whole issue.', 'Hyaluronik asit bir nem tutucu. Suyu kendine çekiyor ve tutuyor; hyaluronik serumun cildi dakikalar içinde dolgun göstermesinin sebebi bu.

Atlanan kısım şu. Suyu bulabildiği her yerden çekiyor. Nemli havada bu çevreden anlamına geliyor. Kuru havada ise cildinin derin katmanlarından su çekip atmosfere salabiliyor; bu da sürmeden öncesine göre daha kuru kalmana yol açıyor.

Aynı serumun ağustosta harika hissettirip ocakta yüzünü germesinin sebebi bu. Standart tavsiyenin kulağa geldiğinden daha önemli olmasının sebebi de: nemli cilde uygula ve üzerine nemlendirici sür.

Nemli cilt ona çalışacak su veriyor. Üstteki nemlendirici topladığı suyun buharlaşmasını engelliyor. Kuru koşullarda bu adımlardan birini atlarsan gerçekten daha kötü durumda kalabiliyorsun.

Moleküler ağırlık pazarlamada çok geçiyor. Kısa özet şu: farklı boyutların karışımı tek bir boyuttan daha kullanışlı, çünkü farklı boyutlar farklı derinliklerde duruyor. Düzgün ürünlerin çoğunda zaten karışım var ve sadece buna bakarak ürün seçmeye değmiyor.

Bir hyaluronik serum senin için hiç gözle görülür bir şey yapmadıysa, nemli yüze uygulayıp üzerini kapatmayı dene. Sorun genellikle tam olarak bu.', 'https://images.pexels.com/photos/3751227/pexels-photo-3751227.jpeg?auto=compress&cs=tinysrgb&h=650&w=940', 1, 'Ingredient', true, false),
  ('942fb7a3-5f35-511c-b4c5-b9a55ecf5a76'::uuid, 'Starting Retinol Without Wrecking Your Skin', 'Cildini Mahvetmeden Retinole Başlamak', 'Retinol works. It is also the ingredient people most often abandon, almost always because of how they started.

The first few weeks involve an adjustment period. Dryness, some flaking, occasionally a run of small spots as things that were already under the surface come up faster. This is expected and temporary. What is not expected is a red, burning, tight face, and that comes from using too much too often.

Start with two nights a week. A pea sized amount for the entire face, applied to skin that is completely dry. Damp skin absorbs it faster and that is the wrong kind of faster. Moisturiser after.

Stay at two nights for a month. If your skin is calm, move to three. Then four, and so on over several months. There is no advantage to arriving at nightly quickly.

The sandwich method helps if you are sensitive. Moisturiser, retinol, moisturiser. It slows absorption and reduces irritation without meaningfully reducing the effect.

Skip acids on retinol nights. Skip retinol entirely for a few days if you have been in the sun, waxed, or shaved that area.

Sunscreen is not optional with retinol. It increases sun sensitivity, and using it without daily SPF works against the exact thing you started it for.

Not suitable during pregnancy or breastfeeding.', 'Retinol işe yarıyor. Aynı zamanda insanların en sık bıraktığı içerik ve neredeyse her zaman nasıl başladıkları yüzünden.

İlk birkaç hafta bir alışma dönemi içeriyor. Kuruluk, bir miktar pullanma, ara sıra zaten yüzeyin altında olan şeylerin daha hızlı çıkmasıyla küçük sivilce dalgaları. Bu beklenen ve geçici. Beklenmeyen şey kırmızı, yanan ve gergin bir yüz; o da fazla miktarı fazla sıklıkla kullanmaktan geliyor.

Haftada iki gece ile başla. Tüm yüz için bezelye büyüklüğünde bir miktar, tamamen kuru cilde. Nemli cilt daha hızlı emiyor ve bu yanlış türden bir hız. Ardından nemlendirici.

Bir ay boyunca iki gecede kal. Cildin sakinse üçe çık. Sonra dörde ve birkaç ay içinde yukarı doğru. Her geceye hızlı varmanın hiçbir avantajı yok.

Hassassan sandviç yöntemi işe yarıyor. Nemlendirici, retinol, nemlendirici. Emilimi yavaşlatıp tahrişi azaltıyor, etkiyi anlamlı ölçüde düşürmeden.

Retinol gecelerinde asitleri atla. Güneşte kaldıysan, ağda ya da tıraş yaptıysan o bölgede birkaç gün retinolü tamamen bırak.

Retinolle güneş kremi isteğe bağlı değil. Güneş hassasiyetini artırıyor ve günlük SPF olmadan kullanmak, ona başlama sebebinin tam tersine çalışıyor.

Hamilelikte ve emzirme döneminde uygun değil.', 'https://images.pexels.com/photos/8102129/pexels-photo-8102129.jpeg?auto=compress&cs=tinysrgb&h=650&w=940', 1, 'Ingredient', true, false),
  ('00abdb4a-4e39-50ff-8a59-5343206f71c2'::uuid, 'Vitamin C And Why The Bottle Turns Orange', 'C Vitamini ve Şişenin Neden Turuncuya Döndüğü', 'Vitamin C is an antioxidant. During the day it helps limit the damage that gets through your sunscreen, and over months it helps even out tone and fade the marks left behind by sun and spots.

The complication is that the most studied form, L-ascorbic acid, is unstable. Light, heat and air degrade it, and as it degrades it oxidises and turns yellow, then orange, then brown. A brown serum is not dangerous. It is just no longer doing much.

This is why the packaging matters more than usual. Opaque bottles, airless pumps, small sizes you will finish. A clear dropper bottle sitting on a sunny bathroom shelf is the worst case, and it is also how most of them are sold.

Store it away from the window, close it properly, and if it goes dark orange, replace it.

Derivatives such as sodium ascorbyl phosphate or ascorbyl glucoside are more stable and gentler. They are also less potent, which is a reasonable trade if L-ascorbic acid irritates you.

Concentration is between 10 and 20 percent for L-ascorbic acid. Below 8 does little, above 20 mostly adds irritation.

Morning is the usual slot, under sunscreen. If it stings, try applying it to fully dry skin, or move to a derivative.', 'C vitamini bir antioksidan. Gün içinde güneş kreminden sızan hasarı sınırlamaya yardımcı oluyor ve aylar içinde tonu eşitleyip güneşin ve sivilcelerin bıraktığı izleri açıyor.

Karmaşık kısım şu: en çok çalışılmış form olan L-askorbik asit kararsız. Işık, ısı ve hava onu bozuyor; bozuldukça oksitlenip önce sarıya, sonra turuncuya, sonra kahverengiye dönüyor. Kahverengi bir serum tehlikeli değil. Sadece artık pek bir şey yapmıyor.

Ambalajın alışıldıktan daha önemli olmasının sebebi bu. Işık geçirmeyen şişeler, havasız pompalar, bitirebileceğin küçük boyutlar. Güneş alan bir banyo rafında duran şeffaf damlalıklı şişe en kötü senaryo ve çoğu da tam olarak böyle satılıyor.

Pencereden uzakta sakla, kapağını düzgün kapat ve koyu turuncuya dönerse değiştir.

Sodyum askorbil fosfat ya da askorbil glukozit gibi türevler daha kararlı ve daha yumuşak. Aynı zamanda daha az güçlüler; L-askorbik asit seni tahriş ediyorsa makul bir takas.

L-askorbik asit için oran yüzde 10 ile 20 arasında. 8''in altı pek bir şey yapmıyor, 20''nin üstü çoğunlukla tahriş ekliyor.

Alışıldık yer sabah, güneş kreminin altı. Yakıyorsa tamamen kuru cilde uygulamayı dene ya da bir türeve geç.', 'https://images.pexels.com/photos/7818182/pexels-photo-7818182.jpeg?auto=compress&cs=tinysrgb&h=650&w=940', 1, 'Ingredient', true, false),
  ('349b3c82-577d-54a9-91db-60fc4d831949'::uuid, 'Salicylic Acid And Clogged Pores', 'Salisilik Asit ve Tıkalı Gözenekler', 'Salicylic acid is oil soluble, and that single property is why it is the standard recommendation for clogged pores.

Most exfoliating acids are water soluble, which means they work on the surface. Salicylic acid dissolves in oil, so it can get down inside a pore that is already full of it and break up what is sitting there. That is the difference between smoothing the surface and clearing the blockage underneath.

It works on blackheads, whiteheads and the small rough bumps that are not quite spots. It is less useful for cystic breakouts, which sit deeper than it reaches.

Concentrations are usually between 0.5 and 2 percent. Two percent is the practical maximum in daily products; higher belongs in professional peels. In a cleanser it does less than in a leave on product, since contact time is under a minute, though a cleanser is a gentler place to start.

Two or three nights a week is a sensible beginning. It can be increased if your skin stays comfortable, and daily use is fine for many people with oily skin.

Do not stack it with retinol on the same night when you are starting out, and do not follow a peel with it the next day.

It increases sun sensitivity. Sunscreen during the day is part of using it, not an optional addition.', 'Salisilik asit yağda çözünüyor ve tıkalı gözenekler için standart öneri olmasının sebebi tam olarak bu tek özellik.

Peeling asitlerinin çoğu suda çözünüyor, yani yüzeyde çalışıyorlar. Salisilik asit yağda çözündüğü için zaten yağla dolu bir gözeneğin içine inip orada duranı çözebiliyor. Yüzeyi pürüzsüzleştirmekle alttaki tıkanıklığı açmak arasındaki fark bu.

Siyah noktalarda, beyaz noktalarda ve tam sivilce sayılmayan küçük pürüzlü kabartılarda işe yarıyor. Ulaştığından daha derinde duran kistik sivilcelerde daha az faydalı.

Oranlar genellikle yüzde 0,5 ile 2 arasında. Günlük ürünlerde pratik üst sınır yüzde iki; daha yükseği profesyonel peelinglere ait. Temizleyicide, ciltte kalan bir üründe olduğundan daha az iş yapıyor çünkü temas süresi bir dakikanın altında; yine de temizleyici başlamak için daha yumuşak bir yer.

Haftada iki üç gece makul bir başlangıç. Cildin rahat kalırsa artırılabilir ve yağlı ciltlerin çoğunda günlük kullanım da uygun.

Başlangıçta aynı gece retinolle üst üste kullanma ve bir peelingin ertesi günü arkasından sürme.

Güneş hassasiyetini artırıyor. Gündüz güneş kremi, kullanmanın bir parçası; isteğe bağlı bir ek değil.', 'https://images.pexels.com/photos/5240364/pexels-photo-5240364.jpeg?auto=compress&cs=tinysrgb&h=650&w=940', 1, 'Ingredient', true, false),
  ('50b6f967-e70e-5d94-abf7-3ae9df29eb84'::uuid, 'Ceramides And Your Skin Barrier', 'Seramidler ve Cilt Bariyerin', 'Your outer skin layer works roughly like a brick wall. The cells are the bricks and the lipids between them are the mortar. Ceramides make up about half of that mortar.

When the mortar thins out, the wall leaks. Water escapes faster than it should, and irritants get in more easily than they should. That combination is what people are describing when they say their skin barrier is damaged: dryness that moisturiser does not seem to fix, sudden sensitivity to products that were fine last month, redness that comes and goes.

Ceramides in a product help refill the gaps. Unlike a humectant, which adds water, or an occlusive, which seals the surface, they replace something the skin is actually short of.

They work best alongside cholesterol and fatty acids, which is the natural ratio, and most well formulated creams include all three rather than ceramides alone.

There is nothing to build up to and no adjustment period. They are not an active in the irritating sense, and you can use them every day, morning and night, on any skin type.

If your skin has been through a rough patch of over exfoliation or a hard winter, a ceramide cream and nothing else for two weeks does more than adding another treatment product on top.', 'Cildinin dış katmanı kabaca bir tuğla duvar gibi çalışıyor. Hücreler tuğlalar, aralarındaki lipitler ise harç. Seramidler o harcın yaklaşık yarısını oluşturuyor.

Harç inceldiğinde duvar sızdırıyor. Su olması gerekenden hızlı kaçıyor ve tahriş ediciler olması gerekenden kolay giriyor. İnsanlar cilt bariyerim hasar gördü derken bu birleşimi tarif ediyor: nemlendiricinin çözemediği kuruluk, geçen ay sorunsuz olan ürünlere ani hassasiyet, gelip giden kızarıklık.

Bir üründeki seramidler boşlukları doldurmaya yardım ediyor. Su ekleyen bir nem tutucudan ya da yüzeyi kapatan bir örtücüden farklı olarak, cildin gerçekten eksiğini çektiği bir şeyi yerine koyuyorlar.

En iyi kolesterol ve yağ asitleriyle birlikte çalışıyorlar; doğal oran bu ve iyi formüle edilmiş kremlerin çoğu seramid tek başına yerine üçünü birden içeriyor.

Kademeli olarak alışılacak bir şey ve alışma dönemi yok. Tahriş edici anlamda bir aktif değiller; her cilt tipinde, sabah akşam, her gün kullanabilirsin.

Cildin aşırı peelingden ya da zorlu bir kıştan geçtiyse, iki hafta boyunca sadece seramidli bir krem kullanmak, üzerine bir bakım ürünü daha eklemekten daha çok iş görüyor.', 'https://images.pexels.com/photos/20469559/pexels-photo-20469559.jpeg?auto=compress&cs=tinysrgb&h=650&w=940', 1, 'Ingredient', true, false),
  ('d5107e2d-61ad-5d82-9576-cb28e83c26bf'::uuid, 'Reading An SPF Label Without Guessing', 'SPF Etiketini Tahmin Etmeden Okumak', 'The number on the bottle only describes one half of the protection.

SPF measures protection against UVB, the wavelength that causes burning. It says nothing about UVA, which penetrates deeper, does not burn, and is responsible for most of the visible ageing and a good deal of pigmentation. A sunscreen can have SPF 50 and weak UVA protection.

Broad spectrum is the term that covers both. In Europe you will also see a circled UVA symbol, which means UVA protection is at least a third of the SPF value. PA ratings, written as PA+ through PA++++, do a similar job on Asian products. If none of these appear anywhere on the packaging, that is worth noticing.

The numbers themselves are less dramatic than they look. SPF 30 filters roughly 97 percent of UVB, SPF 50 around 98. The jump from 15 to 30 matters more than the jump from 30 to 50.

The bigger variable is quantity. The lab figure assumes two milligrams per square centimetre, which is around two fingers worth for face and neck. Most people apply between a quarter and half of that, and the protection drops accordingly. A well applied SPF 30 beats a thin layer of SPF 50.

Reapplication is every two hours in direct sun, and after swimming or heavy sweating regardless of what the label claims about water resistance.', 'Şişenin üzerindeki rakam korumanın yalnızca yarısını anlatıyor.

SPF, yanmaya sebep olan dalga boyu olan UVB''ye karşı korumayı ölçüyor. Daha derine işleyen, yakmayan ve görünür yaşlanmanın çoğundan ve leke oluşumunun önemli bir kısmından sorumlu olan UVA hakkında hiçbir şey söylemiyor. Bir güneş kremi SPF 50 olup zayıf UVA koruması sunabiliyor.

İkisini birden kapsayan terim geniş spektrum. Avrupa''da ayrıca daire içine alınmış UVA sembolünü göreceksin; bu, UVA korumasının SPF değerinin en az üçte biri olduğu anlamına geliyor. PA+ ile PA++++ arasında yazılan PA derecelendirmeleri Asya ürünlerinde benzer işi görüyor. Bunların hiçbiri ambalajın hiçbir yerinde yoksa bu dikkate değer.

Rakamların kendisi göründükleri kadar dramatik değil. SPF 30 UVB''nin kabaca yüzde 97''sini, SPF 50 ise yaklaşık 98''ini filtreliyor. 15''ten 30''a çıkış, 30''dan 50''ye çıkıştan daha önemli.

Daha büyük değişken miktar. Laboratuvar değeri santimetrekare başına iki miligram varsayıyor; bu yüz ve boyun için yaklaşık iki parmak boyu. Çoğu kişi bunun dörtte biri ile yarısı arasında sürüyor ve koruma da buna göre düşüyor. Düzgün sürülmüş bir SPF 30, ince bir SPF 50 tabakasını yener.

Doğrudan güneşte iki saatte bir tazeleme gerekiyor; yüzdükten ya da çok terledikten sonra da, etikette suya dayanıklılık ne yazarsa yazsın.', 'https://images.pexels.com/photos/16615433/pexels-photo-16615433.jpeg?auto=compress&cs=tinysrgb&h=650&w=940', 1, 'Ingredient', true, false),
  ('20447756-a544-58c0-b8a7-de098c045e88'::uuid, 'Peptides And Realistic Expectations', 'Peptitler ve Gerçekçi Beklentiler', 'Peptides are short chains of amino acids. Amino acids build proteins, and collagen is a protein, which is the entire basis of the marketing you have read.

The reasoning is that certain peptides act as signals, telling skin cells to behave as though repair is needed. Some are studied reasonably well and show modest improvements in firmness and fine lines over a few months. Others appear in products because the word tests well.

What peptides are not is a substitute for retinol. Retinol has decades of evidence behind it and a much larger effect. Peptides sit somewhere below that: gentler, slower, and considerably less likely to irritate.

That gentleness is the real argument for them. If retinol is not an option because your skin will not tolerate it, or because you are pregnant or breastfeeding, a peptide serum is a reasonable thing to use instead. It is doing less, and it is doing something.

Look for named complexes with published work behind them, such as Matrixyl or Argireline, rather than a label that only says peptide complex.

They combine with everything. No adjustment period, no sun sensitivity, no waiting between layers.

Set the expectation at gradual improvement in firmness over three to six months, not a visible change by next week.', 'Peptitler kısa amino asit zincirleri. Amino asitler protein inşa ediyor ve kolajen bir protein; okuduğun pazarlamanın tüm dayanağı bu.

Mantık şu: bazı peptitler sinyal görevi görüp cilt hücrelerine onarım gerekiyormuş gibi davranmalarını söylüyor. Bir kısmı makul ölçüde çalışılmış durumda ve birkaç ay içinde sıkılık ile ince çizgilerde ölçülü iyileşmeler gösteriyor. Diğerleri ise kelime pazarlamada iyi çalıştığı için ürünlerde bulunuyor.

Peptitlerin olmadığı şey retinolün yerine geçen bir seçenek. Retinolün arkasında onlarca yıllık kanıt ve çok daha büyük bir etki var. Peptitler bunun biraz altında duruyor: daha yumuşak, daha yavaş ve tahriş etme ihtimali epeyce daha düşük.

O yumuşaklık aslında onlar için asıl gerekçe. Cildin tolere edemediği için ya da hamile veya emziren biri olduğun için retinol bir seçenek değilse, peptit serumu yerine kullanılacak makul bir şey. Daha azını yapıyor ve bir şey yapıyor.

Sadece peptit kompleksi yazan bir etiket yerine Matrixyl ya da Argireline gibi arkasında yayınlanmış çalışma olan isimli kompleksleri ara.

Her şeyle birleşiyorlar. Alışma dönemi yok, güneş hassasiyeti yok, katmanlar arası bekleme yok.

Beklentini gelecek haftaya görünür bir değişime değil, üç ila altı ay içinde sıkılıkta kademeli iyileşmeye ayarla.', 'https://images.pexels.com/photos/9628804/pexels-photo-9628804.jpeg?auto=compress&cs=tinysrgb&h=650&w=940', 1, 'Ingredient', true, false),
  ('782e25ce-b572-50a2-8d93-01e36bdf2cc0'::uuid, 'Centella And Why It Is In Everything Now', 'Centella ve Neden Artık Her Üründe', 'Centella asiatica is a plant that has been used in traditional medicine across Asia for a long time, and in the last few years it has ended up in a very large number of Western products.

The useful compounds are madecassoside, asiaticoside and the related asiatic acids. On the packaging you will see them as centella extract, cica, or the individual compound names. Cica is just shorthand and does not tell you much about the concentration.

What it does is calm things down. It helps with redness, supports the barrier, and speeds up recovery in skin that has been irritated. That makes it useful in exactly the situations where most active ingredients are the wrong idea: after over exfoliating, during a retinol adjustment period, in the middle of a reactive stretch.

The evidence is better than for most botanical ingredients, which is part of why dermocosmetic brands adopted it rather than only natural focused ones.

It is not a treatment for anything specific. It will not clear breakouts or fade marks. It makes skin more comfortable while something else does the work, and sometimes comfort is the entire goal for a couple of weeks.

Fine for daily use, layers under anything, and one of the safer things to reach for when your face is annoyed and you are not sure why.', 'Centella asiatica, Asya''da uzun süredir geleneksel tıpta kullanılan bir bitki ve son birkaç yılda çok sayıda Batı ürününde yer buldu.

İşe yarayan bileşenler madekasosit, asiatikosit ve ilgili asiatik asitler. Ambalajda bunları centella özütü, cica ya da tek tek bileşen adları olarak göreceksin. Cica sadece kısaltma ve konsantrasyon hakkında pek bir şey söylemiyor.

Yaptığı şey işleri yatıştırmak. Kızarıklığa iyi geliyor, bariyeri destekliyor ve tahriş olmuş ciltte toparlanmayı hızlandırıyor. Bu da onu tam olarak çoğu aktif içeriğin yanlış fikir olduğu durumlarda kullanışlı kılıyor: aşırı peeling sonrası, retinol alışma döneminde, tepkili bir dönemin ortasında.

Kanıt düzeyi çoğu bitkisel içerikten daha iyi; dermokozmetik markaların sadece doğal odaklı olanlar yerine buna yönelmesinin sebeplerinden biri de bu.

Belirli bir şeyin tedavisi değil. Sivilceleri geçirmeyecek, lekeleri açmayacak. Başka bir şey işi yaparken cildi daha rahat ettiriyor ve bazen birkaç haftalığına tek hedef rahatlık oluyor.

Günlük kullanıma uygun, her şeyin altına giriyor ve yüzün huysuzlaşmışken sebebini bilmiyorsan uzanılacak daha güvenli şeylerden biri.', 'https://images.pexels.com/photos/1334149/pexels-photo-1334149.jpeg?auto=compress&cs=tinysrgb&h=650&w=940', 1, 'Ingredient', true, false),
  ('5c5cf5e8-f80a-520f-b21c-1f5872331e51'::uuid, 'AHA Or BHA Which One Is For You', 'AHA mı BHA mı, Hangisi Sana Göre', 'Both exfoliate. The difference is where they can reach.

AHAs are water soluble and work on the surface. Glycolic acid is the smallest and penetrates most, lactic acid is larger and gentler and also hydrates, mandelic acid is larger still and the mildest of the three. They are the right choice for dullness, uneven tone, rough texture and sun marks.

BHA, in practice salicylic acid, is oil soluble and gets inside pores. That makes it the choice for blackheads, congestion and blemish prone skin, since it clears the blockage rather than only smoothing what is on top.

If your main complaint is dull, uneven or rough, start with an AHA. If it is clogged, bumpy or spotty, start with a BHA. If it is both, some products combine them, though combining is also a faster route to irritation.

Start at two nights a week either way. Lower concentrations, around 5 to 8 percent for AHAs and 1 to 2 percent for BHA, are enough for regular use.

Do not use them the same night as retinol when you are starting out, and do not layer an AHA and a BHA on the same evening.

Both increase sun sensitivity, AHAs noticeably so. Daily sunscreen is not a suggestion here.', 'İkisi de peeling yapıyor. Fark, nereye ulaşabildikleri.

AHA''lar suda çözünüyor ve yüzeyde çalışıyor. Glikolik asit en küçüğü ve en çok işleyeni, laktik asit daha büyük ve daha yumuşak, ayrıca nemlendiriyor, mandelik asit daha da büyük ve üçünün en ılımlısı. Donukluk, ton eşitsizliği, pürüzlü doku ve güneş lekeleri için doğru seçim.

BHA, pratikte salisilik asit, yağda çözünüyor ve gözeneklerin içine giriyor. Bu da onu siyah nokta, tıkanıklık ve sivilceye eğilimli cilt için tercih haline getiriyor; çünkü sadece üsttekini pürüzsüzleştirmek yerine tıkanıklığı açıyor.

Asıl şikayetin donukluk, eşitsizlik ya da pürüz ise AHA ile başla. Tıkanıklık, kabartı ya da sivilce ise BHA ile. İkisi birdense, bazı ürünler ikisini birleştiriyor; ama birleştirmek aynı zamanda tahrişe giden daha hızlı bir yol.

Her iki durumda da haftada iki gece ile başla. Düşük konsantrasyonlar, AHA''lar için yüzde 5-8 ve BHA için yüzde 1-2, düzenli kullanım için yeterli.

Başlangıçta retinolle aynı gece kullanma ve aynı akşam bir AHA ile BHA''yı üst üste sürme.

İkisi de güneş hassasiyetini artırıyor, AHA''lar gözle görülür şekilde. Burada günlük güneş kremi bir öneri değil.', 'https://images.pexels.com/photos/7797741/pexels-photo-7797741.jpeg?auto=compress&cs=tinysrgb&h=650&w=940', 1, 'Ingredient', true, false),
  ('df9f3c89-2706-51c3-9cd5-692c513804e9'::uuid, 'What Fragrance Free Actually Means On A Label', 'Etikette Parfümsüz Ne Anlama Geliyor', 'Fragrance free and unscented are not the same thing, and the difference matters if you react to things.

Fragrance free means no fragrance materials were added. Unscented often means fragrance was added specifically to mask the smell of the other ingredients, so the product smells of nothing while still containing the thing you were trying to avoid. If your skin reacts to fragrance, unscented is not a safe assumption.

On an EU ingredient list, added fragrance appears as parfum or aroma. Twenty six specific allergens have to be named individually when above a threshold, so you may also see linalool, limonene, citronellol, geraniol and similar names. Those are fragrance components, not preservatives or actives.

Essential oils count as fragrance for this purpose. Lavender, citrus oils and tea tree are common sensitisers, and being plant derived does not change how skin responds to them.

None of this means fragrance is harmful. Most people use fragranced products daily without any issue at all. It is specifically a problem for sensitive, reactive or compromised skin, and for the eye area where the skin is thinner.

If you are working out what is irritating you, removing fragrance is the single most useful change to make first, because it eliminates the largest category of common triggers in one step.', 'Parfümsüz ve kokusuz aynı şey değil ve tepki veren biriysen bu fark önemli.

Parfümsüz, hiçbir parfüm maddesinin eklenmediği anlamına geliyor. Kokusuz ise genellikle diğer içeriklerin kokusunu maskelemek için özellikle parfüm eklendiği anlamına geliyor; yani ürün hiçbir şey kokmuyor ama kaçınmaya çalıştığın şeyi hâlâ içeriyor. Cildin parfüme tepki veriyorsa kokusuz güvenli bir varsayım değil.

AB içerik listesinde eklenen parfüm parfum ya da aroma olarak görünüyor. Yirmi altı belirli alerjen, bir eşiğin üzerindeyse ayrı ayrı yazılmak zorunda; bu yüzden linalool, limonene, citronellol, geraniol ve benzeri isimleri de görebilirsin. Bunlar parfüm bileşenleri, koruyucu ya da aktif değil.

Uçucu yağlar bu açıdan parfüm sayılıyor. Lavanta, narenciye yağları ve çay ağacı yaygın duyarlılaştırıcılar ve bitkisel kaynaklı olmaları cildin onlara verdiği tepkiyi değiştirmiyor.

Bunların hiçbiri parfümün zararlı olduğu anlamına gelmiyor. Çoğu insan parfümlü ürünleri her gün hiçbir sorun yaşamadan kullanıyor. Bu özellikle hassas, tepkili ya da zayıflamış ciltler ve cildin daha ince olduğu göz çevresi için bir sorun.

Seni neyin tahriş ettiğini bulmaya çalışıyorsan, ilk yapılacak en faydalı değişiklik parfümü çıkarmak; çünkü tek adımda en büyük yaygın tetikleyici kategorisini eliyor.', 'https://images.pexels.com/photos/5864762/pexels-photo-5864762.jpeg?auto=compress&cs=tinysrgb&h=650&w=940', 1, 'Ingredient', true, false),
  ('22713126-6800-5350-9577-3c6fa58c5347'::uuid, 'Squalane And Oils That Do Not Feel Greasy', 'Squalane ve Yağlı Hissettirmeyen Yağlar', 'Squalene, with an e, is something your skin already produces. It is part of your natural surface oil, and production drops with age. Squalane, with an a, is the stable version made for products, since the original oxidises too quickly to put in a bottle.

What makes it useful is the texture. It is an emollient, so it fills the small gaps between skin cells and makes the surface feel smooth, and it does this without the heavy, sitting on top feeling most oils have. It absorbs quickly and does not leave a film.

It is also non comedogenic, which is unusual for an oil. That makes it one of the few oils that oily and blemish prone skin can generally use without trouble.

Most squalane on the market is derived from olives or sugarcane. Both are fine and the sugarcane version is more consistent in quality.

Where it fits: after your serum, before or instead of a moisturiser depending on how dry your skin is. A few drops is enough for the whole face. In winter it works well as a final layer over a cream to slow evaporation.

It is not an active. It will not treat anything. It makes skin more comfortable and helps other products stay where you put them, which for a lot of routines is the missing piece.', 'Squalene, sonu e ile, cildinin zaten ürettiği bir şey. Doğal yüzey yağının bir parçası ve üretimi yaşla birlikte düşüyor. Squalane, sonu a ile, ürünler için yapılmış kararlı versiyonu; çünkü orijinali şişeye konamayacak kadar hızlı oksitleniyor.

Onu kullanışlı kılan şey dokusu. Bir yumuşatıcı, yani cilt hücreleri arasındaki küçük boşlukları doldurup yüzeyi pürüzsüz hissettiriyor ve bunu çoğu yağın sahip olduğu ağır, üstte duran his olmadan yapıyor. Hızlı emiliyor ve film bırakmıyor.

Aynı zamanda gözenek tıkamıyor, ki bu bir yağ için alışılmadık. Bu da onu yağlı ve sivilceye eğilimli ciltlerin genellikle sorunsuz kullanabildiği birkaç yağdan biri yapıyor.

Piyasadaki squalane''in çoğu zeytinden ya da şeker kamışından elde ediliyor. İkisi de uygun ve şeker kamışı versiyonu kalite açısından daha tutarlı.

Nereye oturuyor: serumdan sonra, cildinin ne kadar kuru olduğuna göre nemlendiriciden önce ya da onun yerine. Tüm yüz için birkaç damla yeterli. Kışın kremin üzerine son katman olarak buharlaşmayı yavaşlatmak için iyi çalışıyor.

Bir aktif değil. Hiçbir şeyi tedavi etmeyecek. Cildi daha rahat ettiriyor ve diğer ürünlerin koyduğun yerde kalmasına yardım ediyor; birçok rutin için eksik parça bu.', 'https://images.pexels.com/photos/4089997/pexels-photo-4089997.jpeg?auto=compress&cs=tinysrgb&h=650&w=940', 1, 'Ingredient', true, false),
  ('5542f32d-9958-5208-8843-50ac335fb8ba'::uuid, 'Oily Skin Still Needs Moisturiser', 'Yağlı Cildin de Nemlendiriciye İhtiyacı Var', 'This is the most common mistake in oily skin routines, and the logic behind it seems sound. Skin is producing too much oil, so why add more.

Because oil and water are different things. Oily skin can be dehydrated, and very often is. The shine on the surface says nothing about whether the deeper layers are holding enough water.

What happens when you skip moisturiser is a feedback loop. The barrier dries out, the skin registers the loss, and it compensates by producing more sebum. You end up oilier than when you started, usually by mid afternoon, and the natural response is to wash again, which makes the next round worse.

The other clue is the specific combination people describe: tight after cleansing, shiny by lunchtime. That is not oily skin behaving normally. That is dehydrated skin overcompensating.

The fix is a light moisturiser, twice a day. A gel cream or a fluid, something marked oil free or non comedogenic. It is not going to make you shinier, and within a few weeks it usually makes you less so.

If the idea of a cream still feels wrong, look at it this way. You are not adding oil, you are stopping water from leaving. Those are different jobs and only one of them is the problem you were worried about.', 'Bu, yağlı cilt rutinlerindeki en yaygın hata ve arkasındaki mantık kulağa doğru geliyor. Cilt zaten fazla yağ üretiyor, neden daha fazlasını ekleyesin.

Çünkü yağ ve su farklı şeyler. Yağlı cilt susuz kalabiliyor ve çoğu zaman kalıyor. Yüzeydeki parlaklık, derin katmanların yeterli suyu tutup tutmadığı hakkında hiçbir şey söylemiyor.

Nemlendiriciyi atladığında bir geri besleme döngüsü oluşuyor. Bariyer kuruyor, cilt kaybı algılıyor ve daha fazla sebum üreterek telafi ediyor. Başladığından daha yağlı bir halde, genellikle öğleden sonra, karşına çıkıyorsun ve doğal tepki tekrar yıkamak oluyor; bu da bir sonraki turu daha kötü yapıyor.

Diğer ipucu insanların tarif ettiği o belirli kombinasyon: temizlikten sonra gergin, öğlene doğru parlak. Bu, yağlı cildin normal davranışı değil. Bu, susuz kalmış cildin aşırı telafisi.

Çözüm günde iki kez hafif bir nemlendirici. Jel krem ya da fluid, yağsız veya gözenek tıkamayan olarak işaretlenmiş bir şey. Seni daha parlak yapmayacak ve birkaç hafta içinde genellikle daha az parlak yapıyor.

Krem fikri hâlâ yanlış geliyorsa şöyle bak. Yağ eklemiyorsun, suyun gitmesini engelliyorsun. Bunlar farklı işler ve endişelendiğin sorun sadece bunlardan biri.', 'https://images.pexels.com/photos/6635916/pexels-photo-6635916.jpeg?auto=compress&cs=tinysrgb&h=650&w=940', 1, 'Myth', true, false),
  ('7c3622c7-725e-531e-a1f8-51ded4d53707'::uuid, 'Natural Does Not Automatically Mean Gentler', 'Doğal Olmak Otomatik Olarak Daha Yumuşak Demek Değil', 'Poison ivy is natural. So is nickel, which is one of the most common contact allergens there is. Origin is not a safety category.

In cosmetics specifically, some of the most reliable irritants are plant derived. Essential oils are the clearest case. Lavender, citrus oils, peppermint and tea tree all cause reactions in a meaningful share of people, and they turn up constantly in products marketed as gentle because they are natural.

There is also a consistency problem. A plant extract varies with the harvest, the region and the season. A synthetic ingredient is the same every batch, which is why formulators reach for them when precision matters.

None of this makes natural formulations bad. Plenty of them are well made and suit people perfectly well. Squalane from olives, glycerin, plant oils, oat extracts, centella. These are all natural and all sensible.

The point is that natural on the front of a bottle tells you about sourcing and marketing, not about how your skin will respond. It is not a regulated term in most places, so it also does not guarantee much about what is actually inside.

Read the ingredient list rather than the claim. Whether a molecule came from a plant or a laboratory matters much less than whether your skin tolerates it.', 'Zehirli sarmaşık doğaldır. Nikel de öyle ve o, var olan en yaygın temas alerjenlerinden biri. Köken bir güvenlik kategorisi değil.

Özellikle kozmetikte, en güvenilir tahriş edicilerin bir kısmı bitki kaynaklı. Uçucu yağlar en net örnek. Lavanta, narenciye yağları, nane ve çay ağacı, insanların kayda değer bir kısmında tepki yaratıyor ve doğal oldukları için yumuşak diye pazarlanan ürünlerde sürekli karşımıza çıkıyorlar.

Bir de tutarlılık sorunu var. Bitki özütü hasada, bölgeye ve mevsime göre değişiyor. Sentetik bir içerik her partide aynı; hassasiyet önemli olduğunda formülatörlerin ona yönelmesinin sebebi bu.

Bunların hiçbiri doğal formülleri kötü yapmıyor. Birçoğu iyi hazırlanmış ve insanlara gayet uyuyor. Zeytinden squalane, gliserin, bitkisel yağlar, yulaf özütleri, centella. Hepsi doğal ve hepsi mantıklı.

Mesele şu: şişenin önündeki doğal ibaresi sana tedarik ve pazarlama hakkında bilgi veriyor, cildinin nasıl tepki vereceği hakkında değil. Çoğu yerde düzenlenmiş bir terim de değil, yani içeride gerçekte ne olduğu konusunda pek bir garanti sunmuyor.

İddiayı değil içerik listesini oku. Bir molekülün bitkiden mi laboratuvardan mı geldiği, cildinin onu tolere edip etmediğinden çok daha az önemli.', 'https://images.pexels.com/photos/8490304/pexels-photo-8490304.jpeg?auto=compress&cs=tinysrgb&h=650&w=940', 1, 'Myth', true, false),
  ('bf08e51c-d10e-57bc-96f4-89ef88877ba9'::uuid, 'Does A Higher Price Mean Better Skincare', 'Daha Pahalı Ürün Daha İyi Bakım Demek mi', 'Sometimes, and much less often than the price gap suggests.

What you are paying for in an expensive product is frequently packaging, brand, retail margin and marketing. The raw materials in a well formulated moisturiser are not expensive, and the same active ingredients appear across every price bracket. Niacinamide at 5 percent works the same whether it costs eight euros or eighty.

Where higher prices can genuinely buy something: better stabilisation of unstable ingredients like vitamin C, more sophisticated delivery systems, nicer textures, and formulation work that took longer. Those are real, and they are incremental rather than transformative.

Where they buy nothing: the basic categories. Cleansers are on your face for under a minute. A gentle cleanser at a low price does the same job as an expensive one. The same is largely true of plain moisturisers and of sunscreen, where regulation sets the performance floor.

The most reliable indicator is not price, it is whether the brand tells you the concentration of the active and puts it in packaging that protects it.

A practical approach: spend where formulation is genuinely difficult, which usually means a good sunscreen and one well made active. Save on cleanser and basic moisturiser. Almost nobody needs an expensive product in every category.', 'Bazen, ve fiyat farkının ima ettiğinden çok daha az sıklıkla.

Pahalı bir üründe ödediğin şey sıklıkla ambalaj, marka, perakende marjı ve pazarlama. İyi formüle edilmiş bir nemlendiricideki hammaddeler pahalı değil ve aynı aktif içerikler her fiyat aralığında karşımıza çıkıyor. Yüzde 5 niasinamid, sekiz euroya da seksen euroya da aynı şekilde çalışıyor.

Yüksek fiyatın gerçekten bir şey satın alabildiği yerler: C vitamini gibi kararsız içeriklerin daha iyi stabilizasyonu, daha gelişmiş taşıyıcı sistemler, daha hoş dokular ve daha uzun süren formülasyon çalışması. Bunlar gerçek ve dönüştürücü değil, kademeli.

Hiçbir şey satın almadığı yerler: temel kategoriler. Temizleyiciler yüzünde bir dakikadan az kalıyor. Ucuz ve yumuşak bir temizleyici, pahalı olanla aynı işi görüyor. Aynı şey büyük ölçüde sade nemlendiriciler ve performans tabanını mevzuatın belirlediği güneş kremleri için de geçerli.

En güvenilir gösterge fiyat değil; markanın aktifin konsantrasyonunu söyleyip söylemediği ve onu koruyan bir ambalaja koyup koymadığı.

Pratik bir yaklaşım: formülasyonun gerçekten zor olduğu yere harca, ki bu genellikle iyi bir güneş kremi ve iyi yapılmış bir aktif demek. Temizleyici ve temel nemlendiricide tasarruf et. Neredeyse hiç kimsenin her kategoride pahalı bir ürüne ihtiyacı yok.', 'https://images.pexels.com/photos/13068356/pexels-photo-13068356.jpeg?auto=compress&cs=tinysrgb&h=650&w=940', 1, 'Myth', true, false),
  ('6e16107d-6f45-5bd8-98b9-2399aa389994'::uuid, 'Sunscreen Is Not A Summer Only Thing', 'Güneş Kremi Sadece Yaz Ürünü Değil', 'UVB, the wavelength that burns you, does drop off considerably in winter. That is the part of the intuition that is correct.

UVA does not. It stays relatively steady across the year and across the day, and it is the wavelength responsible for most of the visible ageing, a large share of pigmentation, and damage that accumulates without you noticing because it never produces a burn.

UVA also passes through window glass. UVB mostly does not. This is why the classic dermatology example is the delivery driver photographed after decades on the road, where one side of the face aged visibly faster than the other. That was UVA through a side window, in all weather, for years.

Cloud cover reduces UV but does not remove it. Depending on the cloud type, a meaningful proportion still reaches the ground, and thin cloud can scatter it in ways that increase exposure on some surfaces.

None of this argues for the same product all year. In winter a moisturiser with SPF 30 is often enough for a day spent mostly indoors. In summer, or any day with real time outside, use a dedicated sunscreen and reapply it.

The practical version is simple. If you are working on pigmentation or using retinol or acids, daily sunscreen is doing more for the result than the active is.', 'Seni yakan dalga boyu olan UVB kışın gerçekten epeyce düşüyor. Sezginin doğru olan kısmı bu.

UVA düşmüyor. Yıl boyunca ve gün boyunca göreceli olarak sabit kalıyor ve görünür yaşlanmanın çoğundan, leke oluşumunun büyük kısmından ve hiç yanık üretmediği için fark etmeden biriken hasardan sorumlu olan dalga boyu bu.

UVA ayrıca pencere camından geçiyor. UVB çoğunlukla geçmiyor. Klasik dermatoloji örneğinin, onlarca yıl yolda geçirdikten sonra fotoğraflanan ve yüzünün bir tarafı diğerinden gözle görülür şekilde daha hızlı yaşlanmış kamyon şoförü olmasının sebebi bu. O, yıllarca, her havada, yan camdan gelen UVA''ydı.

Bulut örtüsü UV''yi azaltıyor ama ortadan kaldırmıyor. Bulut tipine bağlı olarak kayda değer bir oran yine yere ulaşıyor ve ince bulut, bazı yüzeylerde maruziyeti artıracak şekilde ışığı saçabiliyor.

Bunların hiçbiri yıl boyunca aynı ürünü kullanmayı savunmuyor. Kışın, çoğunlukla içeride geçen bir gün için SPF 30''lu nemlendirici genellikle yeterli. Yazın ya da gerçekten dışarıda vakit geçirdiğin herhangi bir günde ayrı bir güneş kremi kullan ve tazele.

Pratik özeti basit. Leke üzerinde çalışıyorsan ya da retinol veya asit kullanıyorsan, sonuç için günlük güneş kremi aktiften daha fazlasını yapıyor.', 'https://images.pexels.com/photos/10976078/pexels-photo-10976078.jpeg?auto=compress&cs=tinysrgb&h=650&w=940', 1, 'Myth', true, false),
  ('2ab58722-0f10-5e03-83fa-db8341c36df9'::uuid, 'Pores Do Not Open And Close', 'Gözenekler Açılıp Kapanmıyor', 'Pores have no muscle. There is nothing there that could open or close them, so the entire framework behind steaming to open and cold water to close does not describe anything that happens.

What does change is how visible they look. Heat and steam soften the sebum inside a pore, which makes the contents easier to shift. That is a real effect and it is why steaming before an extraction is useful. Cold water constricts blood vessels and briefly reduces swelling in the surrounding skin, which makes pores look slightly smaller for a short time. Neither is the pore itself changing size.

Pore size is mostly genetic. Beyond that, the main things that make them look larger are the amount of oil being produced, whether they are congested, and loss of firmness in the surrounding skin with age, which lets the opening slacken.

What actually helps: salicylic acid to keep them clear, since a pore full of oxidised sebum reads as a much larger dark dot than an empty one. Niacinamide over time. Retinoids for the firmness of the surrounding skin. Sunscreen, because sun damage accelerates exactly the loss of support that makes pores look bigger.

What does not help: anything promising to close, shrink or seal them, and squeezing, which stretches the opening and makes the next round more visible.', 'Gözeneklerin kası yok. Orada onları açıp kapatabilecek hiçbir şey yok, yani buharla açıp soğuk suyla kapatma çerçevesinin tamamı gerçekte olan bir şeyi tarif etmiyor.

Değişen şey ne kadar görünür oldukları. Isı ve buhar gözenekteki sebumu yumuşatıyor, bu da içeriğin yerinden oynamasını kolaylaştırıyor. Bu gerçek bir etki ve temizlik öncesi buhar uygulamanın işe yaramasının sebebi. Soğuk su kan damarlarını daraltıp çevredeki ciltteki şişliği kısa süre azaltıyor, bu da gözenekleri kısa bir süreliğine biraz daha küçük gösteriyor. İkisinde de gözeneğin kendisi boyut değiştirmiyor.

Gözenek boyutu çoğunlukla genetik. Bunun ötesinde onları büyük gösteren asıl şeyler üretilen yağ miktarı, tıkalı olup olmadıkları ve yaşla birlikte çevredeki ciltte sıkılığın azalıp ağzın gevşemesi.

Gerçekten işe yarayanlar: gözenekleri açık tutmak için salisilik asit, çünkü oksitlenmiş sebumla dolu bir gözenek boş olandan çok daha büyük koyu bir nokta olarak görünüyor. Zamanla niasinamid. Çevredeki cildin sıkılığı için retinoidler. Güneş kremi, çünkü güneş hasarı gözenekleri büyük gösteren o destek kaybını tam olarak hızlandırıyor.

İşe yaramayanlar: kapatma, küçültme veya mühürleme vaat eden her şey ve sıkmak; sıkmak ağzı geriyor ve bir sonraki turu daha görünür yapıyor.', 'https://images.pexels.com/photos/3064717/pexels-photo-3064717.jpeg?auto=compress&cs=tinysrgb&h=650&w=940', 1, 'Myth', true, false),
  ('63c1b295-a759-575c-bc22-226ef937087d'::uuid, 'More Products Does Not Mean Better Skin', 'Daha Çok Ürün Daha İyi Cilt Demek Değil', 'There is a point where adding another product stops helping and starts causing problems. Most people pass it without noticing.

The first issue is interaction. Actives compete, some destabilise each other, and layering several at once raises the total irritation load well beyond what any of them would cause alone. Skin has a tolerance budget and it does not care that you spread the spending across four bottles.

The second is diagnostic. If you use eight products and something goes wrong, you cannot identify the cause. You either stop everything or keep going and hope. Neither is a good position, and both waste months.

The third is dilution, in a practical sense. Layers do not all get through. A serum under three other products is not reaching the skin the way it would on its own, so half of what you bought is doing less than the label suggests.

A routine that is working typically has three to five steps and one, maybe two actives. Beyond that you are usually adding cost and risk rather than results.

If you are unsure whether a product is earning its place, stop using it for three weeks and watch. Most of the time nothing happens, which is the answer. Occasionally something does, and then you have learned which product was actually doing the work.', 'Bir ürün daha eklemenin fayda etmeyi bırakıp sorun yaratmaya başladığı bir nokta var. Çoğu insan bunu fark etmeden geçiyor.

İlk sorun etkileşim. Aktifler birbiriyle yarışıyor, bazıları birbirini kararsızlaştırıyor ve birkaçını aynı anda katmanlamak toplam tahriş yükünü hiçbirinin tek başına yaratacağının epeyce üzerine çıkarıyor. Cildin bir tolerans bütçesi var ve harcamayı dört şişeye yaymış olman umurunda değil.

İkincisi teşhis. Sekiz ürün kullanıyorsan ve bir şey ters giderse sebebi bulamıyorsun. Ya her şeyi bırakıyorsun ya devam edip umuyorsun. İkisi de iyi bir konum değil ve ikisi de aylar harcatıyor.

Üçüncüsü pratik anlamda seyrelme. Katmanların hepsi geçmiyor. Üç ürünün altındaki bir serum, tek başınayken ulaşacağı şekilde cilde ulaşmıyor; yani satın aldığının yarısı etiketin ima ettiğinden azını yapıyor.

İşleyen bir rutin tipik olarak üç ila beş adım ve bir, belki iki aktif içeriyor. Bunun ötesinde genellikle sonuç değil maliyet ve risk ekliyorsun.

Bir ürünün yerini hak edip etmediğinden emin değilsen üç hafta kullanmayı bırak ve izle. Çoğu zaman hiçbir şey olmuyor, ki cevap bu. Ara sıra bir şey oluyor ve o zaman asıl işi hangi ürünün yaptığını öğrenmiş oluyorsun.', 'https://images.pexels.com/photos/11703557/pexels-photo-11703557.jpeg?auto=compress&cs=tinysrgb&h=650&w=940', 1, 'Myth', true, false),
  ('7152e610-c716-5048-b1d8-861bcd1bb796'::uuid, 'Mineral And Chemical Sunscreens Are Both Fine', 'Mineral ve Kimyasal Güneş Kremlerinin İkisi de İyi', 'The two work differently, and the difference matters less for protection than for how they feel.

Mineral filters, zinc oxide and titanium dioxide, sit on the surface and mostly reflect and scatter UV, with some absorption. Chemical filters absorb UV and convert it to a small amount of heat. Both end up doing the same job.

Mineral is usually the better tolerated option for sensitive skin, and it works immediately on application. The trade off is texture. Mineral formulas tend to be thicker and leave a white cast, which is a genuine problem on deeper skin tones and the reason many people abandon them.

Chemical filters are lighter, more transparent and easier to wear daily, which matters because the sunscreen you actually apply beats the one you avoid. Modern European filters such as Tinosorb and Mexoryl offer strong UVA coverage in cosmetically pleasant textures.

Points worth knowing. Chemical filters do not need twenty minutes to work in the way often claimed, though applying before you leave is sensible either way. Neither type is meaningfully absorbed in ways regulators consider a safety concern at normal use. And reef safety claims are mostly about specific filters rather than the mineral versus chemical split.

Pick on texture and tolerance. The best sunscreen is the one you will put on properly every morning.', 'İkisi farklı çalışıyor ve bu fark koruma açısından, nasıl hissettirdikleri kadar önemli değil.

Mineral filtreler, çinko oksit ve titanyum dioksit, yüzeyde durup UV''yi çoğunlukla yansıtıyor ve saçıyor, bir miktar da emiyor. Kimyasal filtreler UV''yi emip az miktarda ısıya çeviriyor. Sonuçta ikisi de aynı işi yapıyor.

Mineral genellikle hassas ciltler için daha iyi tolere edilen seçenek ve sürüldüğü anda çalışıyor. Takas dokuda. Mineral formüller daha kalın olma eğiliminde ve beyaz iz bırakıyor; koyu ciltlerde bu gerçek bir sorun ve birçok kişinin onları bırakmasının sebebi.

Kimyasal filtreler daha hafif, daha şeffaf ve günlük kullanımı daha kolay; bu önemli çünkü gerçekten sürdüğün güneş kremi, kaçındığını yener. Tinosorb ve Mexoryl gibi modern Avrupa filtreleri, kozmetik olarak hoş dokularda güçlü UVA koruması sunuyor.

Bilmeye değer noktalar. Kimyasal filtreler sıkça iddia edildiği gibi çalışmak için yirmi dakikaya ihtiyaç duymuyor, yine de çıkmadan önce sürmek her halükarda mantıklı. Normal kullanımda hiçbir tip, düzenleyicilerin güvenlik sorunu saydığı ölçüde emilmiyor. Ve mercan güvenliği iddiaları çoğunlukla belirli filtrelerle ilgili, mineral-kimyasal ayrımıyla değil.

Dokuya ve toleransa göre seç. En iyi güneş kremi, her sabah düzgünce süreceğin olan.', 'https://images.pexels.com/photos/1029896/pexels-photo-1029896.jpeg?auto=compress&cs=tinysrgb&h=650&w=940', 1, 'Product News', true, false),
  ('5846f437-b1fa-5844-b01f-03e64a5e00bb'::uuid, 'Why Every Brand Suddenly Talks About Your Barrier', 'Neden Bütün Markalar Birden Bariyerden Bahsediyor', 'Barrier repair went from a technical term to a marketing category in about three years, and the reason is worth understanding.

Through the late 2010s routines got longer and stronger. Acids, retinoids, vitamin C, often several at once, encouraged by an internet that rewarded visible results. A lot of people ended up with over exfoliated, reactive skin and did not know what had happened. Barrier damage became a widely recognised complaint, and the industry responded.

The underlying science is not new. Ceramides, cholesterol and fatty acids as the mortar between skin cells, and the value of replacing them, has been understood for decades. What changed is that consumers started asking for it.

The useful part of the trend is real. Ceramide creams, gentler cleansers, fewer aggressive actives and a general move away from routines that treat the skin as something to be corrected constantly. That is a genuine improvement.

The less useful part is that barrier is now printed on products that contain nothing especially barrier supporting. It has become a term like brightening, which describes a positioning rather than a mechanism.

What to look for on the label: ceramides, cholesterol, fatty acids, niacinamide, panthenol, centella. What to ignore: the word barrier by itself, on the front, with nothing on the back to support it.', 'Bariyer onarımı yaklaşık üç yılda teknik bir terimden pazarlama kategorisine dönüştü ve sebebini anlamaya değer.

2010''ların sonuna doğru rutinler uzadı ve sertleşti. Asitler, retinoidler, C vitamini, çoğu zaman aynı anda birkaçı; görünür sonucu ödüllendiren bir internet tarafından teşvik edilerek. Birçok insan aşırı peelinglenmiş, tepkili bir ciltle kaldı ve ne olduğunu bilmiyordu. Bariyer hasarı yaygın olarak tanınan bir şikayet haline geldi ve sektör karşılık verdi.

Altındaki bilim yeni değil. Cilt hücreleri arasındaki harç olarak seramidler, kolesterol ve yağ asitleri ve bunları yerine koymanın değeri onlarca yıldır biliniyor. Değişen şey, tüketicilerin bunu talep etmeye başlaması.

Trendin işe yarar kısmı gerçek. Seramidli kremler, daha yumuşak temizleyiciler, daha az agresif aktif ve cildi sürekli düzeltilmesi gereken bir şey olarak gören rutinlerden genel bir uzaklaşma. Bu gerçek bir iyileşme.

Daha az işe yarar kısmı şu: bariyer artık özellikle bariyeri destekleyen hiçbir şey içermeyen ürünlerin üzerine basılıyor. Aydınlatıcı gibi, bir mekanizmadan çok bir konumlandırmayı tarif eden bir terime dönüştü.

Etikette aranacaklar: seramidler, kolesterol, yağ asitleri, niasinamid, pantenol, centella. Görmezden gelinecek: arkasında bunu destekleyen hiçbir şey olmadan ön yüze yazılmış tek başına bariyer kelimesi.', 'https://images.pexels.com/photos/6801215/pexels-photo-6801215.jpeg?auto=compress&cs=tinysrgb&h=650&w=940', 1, 'Product News', true, false),
  ('c2f35dd7-6132-5382-b039-45da91eb1be3'::uuid, 'Shorter Ingredient Lists Are Having A Moment', 'Kısa İçerik Listeleri Yükselişte', 'A visible shift over the past few years: brands advertising how few ingredients are in a product rather than how many.

Some of this is a response to sensitive skin. Fewer ingredients means fewer candidates when something reacts, and for people trying to identify a trigger that is genuinely useful. Brands built around short lists and sterile packaging exist because there was demand for them.

Some of it is a correction. Products with forty ingredients, half of them plant extracts present at levels too low to do anything, were common. Trimming that is honest work.

But short is not automatically better. A cream needs emulsifiers, preservatives and a stable base, and a formula stripped below what it needs is less stable, not more elegant. Preservatives in particular get cut for marketing reasons, and a product without adequate preservation is a real problem rather than a purer one.

There are also ingredients that only work in combination. Ceramides perform best with cholesterol and fatty acids. Removing two of the three to shorten the list makes the product worse.

The useful reading of the trend is not fewer ingredients, it is fewer pointless ones. A twelve ingredient cream where each one has a job beats both a forty ingredient list padded with extracts and a six ingredient list that dropped something it needed.', 'Son birkaç yılda görünür bir kayma: markalar bir üründe ne kadar çok değil, ne kadar az içerik olduğunu reklam ediyor.

Bunun bir kısmı hassas cilde verilen bir yanıt. Az içerik, bir tepki olduğunda az sayıda şüpheli demek ve tetikleyiciyi bulmaya çalışanlar için bu gerçekten faydalı. Kısa listeler ve steril ambalaj üzerine kurulmuş markalar var, çünkü talep vardı.

Bir kısmı ise düzeltme. Kırk içerikli, yarısı hiçbir şey yapamayacak kadar düşük oranda bulunan bitki özütlerinden oluşan ürünler yaygındı. Bunu budamak dürüst bir iş.

Ama kısa olmak otomatik olarak daha iyi değil. Bir kremin emülgatöre, koruyucuya ve kararlı bir baza ihtiyacı var; ihtiyacının altına indirilmiş bir formül daha zarif değil, daha kararsız oluyor. Özellikle koruyucular pazarlama sebebiyle çıkarılıyor ve yeterli koruması olmayan bir ürün daha saf değil, gerçek bir sorun.

Bir de sadece kombinasyon halinde çalışan içerikler var. Seramidler en iyi kolesterol ve yağ asitleriyle performans gösteriyor. Listeyi kısaltmak için üçünden ikisini çıkarmak ürünü kötüleştiriyor.

Trendin faydalı okuması daha az içerik değil, daha az gereksiz içerik. Her birinin bir işi olan on iki içerikli bir krem, hem özütlerle şişirilmiş kırk içerikli bir listeyi hem de ihtiyacı olan bir şeyi atmış altı içerikli bir listeyi yener.', 'https://images.pexels.com/photos/8015796/pexels-photo-8015796.jpeg?auto=compress&cs=tinysrgb&h=650&w=940', 1, 'Product News', true, false),
  ('591759a7-51a1-5802-9349-d6dcd36f1d81'::uuid, 'Moisturisers With SPF And What They Miss', 'SPF''li Nemlendiriciler ve Atladıkları Şey', 'A moisturiser with SPF is convenient, and convenience is worth something. The question is what you give up.

The main issue is quantity. Sunscreen is tested at two milligrams per square centimetre, roughly two fingers worth for face and neck. Almost nobody applies moisturiser that thickly. Most people use a fraction of it, and since protection drops faster than the amount applied, the SPF 30 on the label is often delivering something closer to SPF 10 in practice.

The second is reapplication. You can reapply sunscreen at midday. Reapplying a moisturiser over makeup is not something most people will do, so the protection you started with is the protection you finish with.

The third is UVA. Some SPF moisturisers are broad spectrum with a proper UVA rating and some carry only an SPF number. The label is worth reading rather than assuming.

Where they work well: days spent mostly indoors, winter, and as a way of getting someone who will never use a separate sunscreen to use something. That last case is a real benefit and outweighs the theoretical objections.

Where they do not: any day with meaningful time outdoors, holidays, working near a window, or if you are actively treating pigmentation. Those days want a dedicated sunscreen applied properly and reapplied.', 'SPF''li nemlendirici pratik ve pratiklik bir şey ifade ediyor. Soru şu: karşılığında neyden vazgeçiyorsun.

Asıl sorun miktar. Güneş kremi santimetrekare başına iki miligramla test ediliyor; yüz ve boyun için kabaca iki parmak boyu. Neredeyse hiç kimse nemlendiriciyi o kalınlıkta sürmüyor. Çoğu kişi bunun küçük bir kısmını kullanıyor ve koruma sürülen miktardan daha hızlı düştüğü için, etiketteki SPF 30 pratikte çoğu zaman SPF 10''a yakın bir şey veriyor.

İkincisi tazeleme. Güneş kremini öğlen tazeleyebiliyorsun. Makyajın üzerine nemlendirici tazelemek çoğu insanın yapacağı bir şey değil, yani başladığın koruma bitirdiğin koruma oluyor.

Üçüncüsü UVA. Bazı SPF''li nemlendiriciler düzgün UVA derecesiyle geniş spektrum, bazıları ise sadece bir SPF rakamı taşıyor. Varsaymak yerine etiketi okumaya değer.

İyi çalıştıkları yerler: çoğunlukla içeride geçen günler, kış ve ayrı bir güneş kremi asla kullanmayacak birine bir şey kullandırmanın yolu olarak. Bu son durum gerçek bir fayda ve teorik itirazlara ağır basıyor.

Çalışmadıkları yerler: dışarıda kayda değer vakit geçirilen herhangi bir gün, tatiller, pencere kenarında çalışmak ya da aktif olarak leke tedavi ediyor olmak. O günler düzgün sürülmüş ve tazelenmiş ayrı bir güneş kremi istiyor.', 'https://images.pexels.com/photos/12243554/pexels-photo-12243554.jpeg?auto=compress&cs=tinysrgb&h=650&w=940', 1, 'Product News', true, false)
on conflict (id) do update set
  title = excluded.title,
  title_tr = excluded.title_tr,
  content = excluded.content,
  content_tr = excluded.content_tr,
  image_url = excluded.image_url,
  read_time = excluded.read_time,
  article_type = excluded.article_type,
  is_active = excluded.is_active;
