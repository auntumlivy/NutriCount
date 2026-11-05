/// Resep singkat untuk makanan di daftar rekomendasi.
/// Kunci harus sama persis dengan nama di BmiUtils (utils/bmi_utils.dart).
class ResepBawaan {
  final String porsi;
  final List<String> bahan;
  final List<String> langkah;
  const ResepBawaan(this.porsi, this.bahan, this.langkah);
}

ResepBawaan? cariResepBawaan(String nama) => kResepBawaan[nama];

const Map<String, ResepBawaan> kResepBawaan = {
  'Nasi Ayam Goreng': ResepBawaan('1 porsi', [
    '1 piring nasi putih (±150 g)',
    '1 potong paha ayam (±100 g)',
    '2 siung bawang putih, haluskan',
    '1/2 sdt garam dan 1/2 sdt ketumbar bubuk',
    'Minyak secukupnya',
  ], [
    'Lumuri ayam dengan bawang putih, garam, dan ketumbar. Diamkan 15 menit.',
    'Goreng ayam dengan api sedang hingga matang kecokelatan (±12 menit).',
    'Tiriskan, sajikan dengan nasi hangat dan lalapan.',
  ]),
  'Alpukat': ResepBawaan('1 buah sedang', [
    '1 buah alpukat matang',
    '1 sdt madu (opsional)',
    '50 ml susu cair (opsional)',
  ], [
    'Belah alpukat, buang biji, ambil dagingnya.',
    'Sajikan langsung dengan madu, atau blender bersama susu hingga halus.',
  ]),
  'Susu Full Cream': ResepBawaan('1 gelas (200 ml)', [
    '200 ml susu full cream',
  ], [
    'Hangatkan susu hingga uap tipis muncul (jangan sampai mendidih).',
    'Tuang ke gelas dan minum selagi hangat.',
  ]),
  'Roti Selai Kacang': ResepBawaan('2 lembar', [
    '2 lembar roti tawar',
    '2 sdm selai kacang',
  ], [
    'Oles selai kacang merata pada satu sisi roti.',
    'Tangkupkan dengan lembar roti lainnya, potong dua.',
  ]),
  'Pisang': ResepBawaan('1 buah sedang', [
    '1 buah pisang matang',
  ], [
    'Kupas dan makan langsung, atau iris di atas oatmeal atau yogurt.',
  ]),
  'Telur Dadar': ResepBawaan('1 porsi (2 telur)', [
    '2 butir telur',
    '1 batang daun bawang, iris halus',
    '1/4 sdt garam',
    '1 sdm minyak',
  ], [
    'Kocok telur bersama daun bawang dan garam.',
    'Panaskan minyak, tuang telur, masak api kecil hingga bagian bawah matang.',
    'Balik sebentar, angkat dan sajikan.',
  ]),
  'Kentang Panggang': ResepBawaan('1 buah sedang', [
    '1 buah kentang ukuran sedang',
    '1 sdt minyak zaitun',
    'Garam dan lada secukupnya',
  ], [
    'Cuci kentang, tusuk-tusuk dengan garpu.',
    'Lumuri minyak, garam, dan lada.',
    'Panggang di oven 200°C selama 45 menit hingga empuk.',
  ]),
  'Kacang Almond': ResepBawaan('1 genggam (±30 g)', [
    '30 g kacang almond tanpa garam',
  ], [
    'Sajikan langsung sebagai camilan, atau taburkan di atas yogurt dan oatmeal.',
  ]),
  'Smoothie Pisang Susu': ResepBawaan('1 gelas', [
    '1 buah pisang',
    '200 ml susu cair',
    '3 butir es batu',
    '1 sdt madu (opsional)',
  ], [
    'Masukkan semua bahan ke blender.',
    'Blender hingga halus, tuang ke gelas.',
  ]),
  'Nasi Uduk Telur': ResepBawaan('1 porsi', [
    '1 piring nasi uduk',
    '1 butir telur',
    'Bawang goreng dan kerupuk secukupnya',
    'Sambal (opsional)',
  ], [
    'Goreng atau dadar telur hingga matang.',
    'Tata nasi uduk di piring, letakkan telur di atasnya.',
    'Taburi bawang goreng dan tambahkan kerupuk.',
  ]),
  'Keju': ResepBawaan('1 slice (±25 g)', [
    '1 slice keju cheddar',
  ], [
    'Sajikan langsung, atau selipkan di antara roti.',
  ]),
  'Bubur Ayam': ResepBawaan('1 mangkuk', [
    '1 mangkuk bubur nasi hangat',
    '50 g ayam suwir rebus',
    'Bawang goreng, daun bawang, dan seledri',
    'Kecap asin dan merica secukupnya',
  ], [
    'Tuang bubur hangat ke mangkuk.',
    'Taburkan ayam suwir, bawang goreng, daun bawang, dan seledri.',
    'Beri sedikit kecap asin dan merica.',
  ]),
  'Dada Ayam Rebus': ResepBawaan('1 potong (±100 g)', [
    '1 potong dada ayam tanpa kulit',
    '1 ruas jahe, geprek',
    '1 siung bawang putih, geprek',
    '1/2 sdt garam',
  ], [
    'Didihkan air bersama jahe, bawang putih, dan garam.',
    'Masukkan dada ayam, rebus 15-20 menit hingga matang.',
    'Tiriskan, suwir atau iris, sajikan dengan sayur.',
  ]),
  'Sayur Bening': ResepBawaan('1 mangkuk', [
    '1 ikat bayam, petik daunnya',
    '1 buah jagung manis, potong',
    '2 siung bawang putih dan 3 siung bawang merah, iris',
    '1/2 sdt garam',
  ], [
    'Rebus air bersama bawang putih dan bawang merah.',
    'Masukkan jagung, masak hingga empuk.',
    'Masukkan bayam dan garam, masak 2 menit lalu angkat.',
  ]),
  'Telur Rebus': ResepBawaan('1 butir', [
    '1 butir telur',
    'Air secukupnya',
  ], [
    'Masukkan telur ke air dingin lalu didihkan.',
    'Setelah mendidih, rebus 8-10 menit.',
    'Rendam di air dingin, kupas, dan sajikan.',
  ]),
  'Apel': ResepBawaan('1 buah sedang', [
    '1 buah apel',
  ], [
    'Cuci bersih, iris, dan makan dengan kulitnya agar seratnya tetap ada.',
  ]),
  'Oatmeal': ResepBawaan('1 mangkuk', [
    '40 g rolled oats',
    '200 ml air atau susu',
    '1/2 buah pisang, iris',
    'Madu secukupnya (opsional)',
  ], [
    'Masak oats dengan air atau susu, aduk 3-5 menit hingga mengental.',
    'Tuang ke mangkuk, tambahkan pisang dan madu.',
  ]),
  'Pepes Ikan': ResepBawaan('1 bungkus', [
    '1 potong ikan (±100 g)',
    '2 siung bawang merah, 1 siung bawang putih, 1 buah cabai (haluskan)',
    'Daun kemangi dan tomat iris',
    'Daun pisang untuk membungkus',
  ], [
    'Lumuri ikan dengan bumbu halus dan garam.',
    'Bungkus bersama kemangi dan tomat dalam daun pisang.',
    'Kukus 25 menit, lalu bakar sebentar di teflon agar harum.',
  ]),
  'Salad Sayur': ResepBawaan('1 mangkuk', [
    'Selada, timun, tomat, dan wortel parut',
    '1 sdm perasan lemon atau jeruk nipis',
    '1 sdt minyak zaitun',
    'Garam dan lada secukupnya',
  ], [
    'Cuci dan potong semua sayuran.',
    'Campur lemon, minyak zaitun, garam, dan lada untuk dressing.',
    'Aduk sayuran dengan dressing, sajikan segera.',
  ]),
  'Brokoli Kukus': ResepBawaan('1 mangkuk', [
    '150 g brokoli, potong kuntum',
    '1 siung bawang putih, cincang',
    'Sedikit garam',
  ], [
    'Kukus brokoli 5-6 menit hingga hijau cerah dan empuk.',
    'Tumis cepat bawang putih dengan sedikit minyak, tuang ke brokoli.',
  ]),
  'Tahu Kukus': ResepBawaan('2 potong', [
    '2 potong tahu putih',
    '1 siung bawang putih, haluskan',
    'Sedikit kecap asin dan merica',
  ], [
    'Lumuri tahu dengan bawang putih, kecap asin, dan merica.',
    'Kukus 10 menit, sajikan hangat.',
  ]),
  'Pepaya': ResepBawaan('1 potong besar', [
    '1 potong pepaya matang (±150 g)',
  ], [
    'Buang biji, iris, dan sajikan dingin.',
  ]),
  'Timun': ResepBawaan('1 buah', [
    '1 buah timun',
    'Perasan jeruk nipis (opsional)',
  ], [
    'Cuci, iris tipis, beri perasan jeruk nipis bila suka.',
  ]),
  'Yogurt Plain': ResepBawaan('1 cup (±150 g)', [
    '150 g yogurt plain',
    'Potongan buah dan 1 sdt madu (opsional)',
  ], [
    'Tuang yogurt ke mangkuk, tambahkan buah dan madu.',
  ]),
  'Sup Sayur': ResepBawaan('1 mangkuk', [
    'Wortel, kentang, buncis, dan kol, potong kecil',
    '2 siung bawang putih, cincang',
    '500 ml air atau kaldu',
    'Garam dan merica',
  ], [
    'Tumis bawang putih hingga harum.',
    'Tuang air, masukkan wortel dan kentang, masak 10 menit.',
    'Masukkan buncis dan kol, masak 5 menit, bumbui.',
  ]),
  'Bayam Rebus': ResepBawaan('1 mangkuk', [
    '1 ikat bayam',
    'Air untuk merebus',
    'Sedikit garam',
  ], [
    'Didihkan air dengan sedikit garam.',
    'Masukkan bayam 1-2 menit, angkat dan tiriskan.',
  ]),
  'Semangka': ResepBawaan('1 potong besar', [
    '1 potong semangka (±250 g)',
  ], [
    'Dinginkan sebentar, potong, dan sajikan.',
  ]),
  'Jeruk': ResepBawaan('1 buah', [
    '1 buah jeruk manis',
  ], [
    'Kupas dan makan langsung. Lebih baik dimakan utuh daripada diperas agar seratnya tetap ada.',
  ]),
  'Ikan Kukus': ResepBawaan('1 potong', [
    '1 potong ikan (±120 g)',
    '1 ruas jahe, iris tipis',
    '2 batang daun bawang',
    '1 sdm kecap asin dan perasan jeruk nipis',
  ], [
    'Lumuri ikan dengan jeruk nipis dan sedikit garam.',
    'Taruh jahe dan daun bawang di atas ikan, siram kecap asin.',
    'Kukus 12-15 menit hingga matang.',
  ]),
  'Nasi Merah + Ikan': ResepBawaan('1 porsi', [
    '1 centong nasi merah (±100 g)',
    '1 potong ikan kukus atau panggang (±100 g)',
    'Sayur rebus sebagai pendamping',
  ], [
    'Siapkan nasi merah hangat.',
    'Masak ikan dengan cara dikukus atau dipanggang.',
    'Sajikan bersama sayur rebus.',
  ]),
  'Tempe Panggang': ResepBawaan('3 potong', [
    '3 potong tempe',
    '1 siung bawang putih, haluskan',
    '1 sdt kecap manis',
  ], [
    'Lumuri tempe dengan bawang putih dan sedikit garam.',
    'Panggang di teflon antilengket atau oven hingga kecokelatan di kedua sisi.',
    'Oles kecap manis tipis-tipis, angkat.',
  ]),
  'Sayur Bening Bayam': ResepBawaan('1 mangkuk', [
    '1 ikat bayam',
    '3 siung bawang merah dan 2 siung bawang putih',
    '1/2 sdt garam',
  ], [
    'Rebus air bersama irisan bawang merah dan bawang putih.',
    'Masukkan bayam dan garam, masak 2 menit lalu angkat.',
  ]),
  'Salad Buah': ResepBawaan('1 mangkuk', [
    'Apel, pepaya, melon, dan anggur secukupnya',
    '3 sdm yogurt plain',
    '1 sdt madu',
  ], [
    'Potong dadu semua buah.',
    'Campur yogurt dan madu, tuang ke atas buah, aduk rata.',
    'Dinginkan 15 menit sebelum disajikan.',
  ]),
  'Gado-gado': ResepBawaan('1 porsi', [
    'Kangkung, tauge, kol, dan buncis, rebus sebentar',
    '1 potong tahu dan 1 potong tempe, goreng',
    '1 butir telur rebus',
    'Saus kacang (kacang tanah, bawang putih, cabai, gula merah, garam)',
  ], [
    'Rebus sayuran 2-3 menit, tiriskan.',
    'Haluskan bahan saus kacang, encerkan dengan air hangat.',
    'Tata sayur, tahu, tempe, dan telur, siram saus kacang.',
  ]),
  'Soto Ayam': ResepBawaan('1 mangkuk', [
    '100 g ayam rebus, suwir',
    '500 ml kaldu ayam',
    'Bumbu halus: bawang merah, bawang putih, kunyit, jahe',
    'Tauge, seledri, dan bawang goreng',
  ], [
    'Tumis bumbu halus hingga harum, masukkan ke kaldu.',
    'Didihkan 10 menit, koreksi rasa.',
    'Tata ayam suwir dan tauge di mangkuk, siram kuah, taburi seledri dan bawang goreng.',
  ]),
  'Nasi Putih': ResepBawaan('1 piring (±180 g)', [
    '1 gelas beras',
    '1,5 gelas air',
  ], [
    'Cuci beras 2-3 kali.',
    'Masak dengan rice cooker hingga matang, diamkan 10 menit lalu aduk.',
  ]),
  'Ayam Goreng': ResepBawaan('1 potong', [
    '1 potong ayam',
    '3 siung bawang putih, haluskan',
    '1 sdt ketumbar bubuk dan 1 sdt garam',
    'Minyak untuk menggoreng',
  ], [
    'Lumuri ayam dengan bumbu, diamkan 30 menit.',
    'Goreng api sedang hingga matang kecokelatan.',
    'Tiriskan agar minyak berkurang.',
  ]),
  'Tempe Goreng': ResepBawaan('2 potong', [
    '2 potong tempe',
    '1 siung bawang putih, haluskan',
    '1/2 sdt garam dan sedikit air',
  ], [
    'Rendam tempe sebentar dalam bumbu bawang putih dan garam.',
    'Goreng hingga kuning kecokelatan, tiriskan.',
  ]),
  'Tahu Goreng': ResepBawaan('2 potong', [
    '2 potong tahu putih',
    '1/2 sdt garam dan 1 siung bawang putih',
    'Minyak untuk menggoreng',
  ], [
    'Rendam tahu dalam air garam dan bawang putih 10 menit.',
    'Goreng hingga kekuningan, tiriskan.',
  ]),
  'Ikan Goreng': ResepBawaan('1 potong', [
    '1 potong ikan (±120 g)',
    '2 siung bawang putih dan 1/2 sdt kunyit bubuk',
    'Perasan jeruk nipis dan garam',
    'Minyak untuk menggoreng',
  ], [
    'Lumuri ikan dengan jeruk nipis, bawang putih, kunyit, dan garam. Diamkan 15 menit.',
    'Goreng hingga matang kedua sisinya, tiriskan.',
  ]),
  'Nasi Goreng': ResepBawaan('1 piring', [
    '1 piring nasi putih dingin',
    '1 butir telur',
    '2 siung bawang putih dan 3 siung bawang merah, iris',
    '1 sdm kecap manis dan sedikit garam',
    '1 sdm minyak',
  ], [
    'Tumis bawang hingga harum, masukkan telur dan orak-arik.',
    'Masukkan nasi, kecap manis, dan garam, aduk rata dengan api besar.',
    'Angkat saat nasi terasa kering dan harum.',
  ]),
  'Mie Instan Goreng': ResepBawaan('1 bungkus', [
    '1 bungkus mie instan goreng',
    'Sawi atau kol secukupnya',
    '1 butir telur (opsional)',
  ], [
    'Rebus mie dan sayur hingga empuk, tiriskan.',
    'Aduk dengan bumbu mie, tambahkan telur rebus atau goreng.',
    'Tips: pakai setengah bumbu agar lebih rendah garam.',
  ]),
  'Mie Ayam': ResepBawaan('1 mangkuk', [
    '100 g mie basah',
    '50 g ayam cincang',
    '1 sdm kecap manis, 1 siung bawang putih, sedikit minyak',
    'Sawi, daun bawang, bawang goreng',
  ], [
    'Tumis bawang putih dan ayam cincang dengan kecap manis hingga meresap.',
    'Rebus mie dan sawi sebentar, tiriskan.',
    'Aduk mie dengan sedikit minyak, tata topping ayam dan taburan.',
  ]),
  'Bakso': ResepBawaan('1 mangkuk', [
    '5 butir bakso sapi',
    '500 ml kaldu',
    'Mie atau bihun secukupnya',
    'Sawi, seledri, dan bawang goreng',
  ], [
    'Panaskan kaldu bersama bakso hingga mendidih.',
    'Seduh mie dan sawi.',
    'Tata di mangkuk, siram kuah, taburi seledri dan bawang goreng.',
  ]),
  'Seblak': ResepBawaan('1 porsi', [
    '50 g kerupuk mentah, rendam air',
    '1 butir telur',
    'Sawi dan sosis secukupnya',
    'Bumbu: bawang putih, kencur, cabai, garam',
  ], [
    'Tumis bumbu halus hingga harum.',
    'Masukkan telur dan orak-arik, tambahkan air dan sosis.',
    'Masukkan kerupuk dan sawi, masak hingga empuk dan kuah menyusut.',
  ]),
  'Gorengan (Bakwan)': ResepBawaan('2 buah', [
    '5 sdm tepung terigu',
    'Wortel parut, kol iris, dan tauge',
    '1 batang daun bawang dan 1 siung bawang putih',
    'Air, garam, dan minyak',
  ], [
    'Campur semua bahan dengan air hingga adonan agak kental.',
    'Sendok adonan ke minyak panas.',
    'Goreng hingga keemasan dan tiriskan.',
  ]),
  'Pecel': ResepBawaan('1 porsi', [
    'Bayam, kangkung, tauge, dan kacang panjang, rebus',
    'Saus pecel (kacang tanah, cabai, kencur, gula merah, garam)',
    'Rempeyek atau tempe (opsional)',
  ], [
    'Rebus semua sayuran sebentar, tiriskan.',
    'Haluskan bumbu pecel dan encerkan dengan air hangat.',
    'Siram sayuran dengan saus pecel.',
  ]),
  'Lontong Sayur': ResepBawaan('1 porsi', [
    '3 potong lontong',
    'Labu siam dan tahu, potong',
    '300 ml santan encer dan bumbu kuning',
    'Telur rebus dan bawang goreng',
  ], [
    'Tumis bumbu halus, tuang santan encer dan didihkan.',
    'Masukkan labu siam dan tahu, masak hingga empuk.',
    'Siram ke lontong, tambahkan telur dan bawang goreng.',
  ]),
  'Roti Tawar (2 lembar)': ResepBawaan('2 lembar', [
    '2 lembar roti tawar',
    'Selai atau telur dadar sebagai isian',
  ], [
    'Panggang roti sebentar jika suka.',
    'Beri isian sesuai selera.',
  ]),
  'Kopi Susu': ResepBawaan('1 gelas', [
    '1 sdt kopi bubuk atau 1 shot espresso',
    '100 ml susu cair',
    'Gula atau pemanis secukupnya',
  ], [
    'Seduh kopi dengan air panas.',
    'Tambahkan susu hangat atau dingin, aduk dengan gula.',
  ]),
  'Es Teh Manis': ResepBawaan('1 gelas', [
    '1 kantong teh celup',
    '200 ml air panas',
    '1 sdm gula (kurangi untuk lebih sehat)',
    'Es batu',
  ], [
    'Seduh teh dengan air panas 3 menit.',
    'Larutkan gula, tuang ke gelas berisi es batu.',
  ]),
  'Kentang Goreng': ResepBawaan('1 porsi', [
    '1 buah kentang besar',
    'Minyak untuk menggoreng dan garam',
  ], [
    'Potong kentang memanjang, rendam air dingin 15 menit, keringkan.',
    'Goreng hingga keemasan dan renyah, tiriskan lalu beri garam.',
  ]),
  'Biskuit': ResepBawaan('4 keping', [
    '4 keping biskuit',
  ], [
    'Sajikan sebagai camilan bersama teh atau susu.',
  ]),
  'Cokelat': ResepBawaan('3 kotak (±30 g)', [
    '30 g cokelat batang',
  ], [
    'Nikmati perlahan. Pilih cokelat dengan kakao tinggi agar gulanya lebih sedikit.',
  ]),
  'Es Krim': ResepBawaan('1 scoop besar', [
    '1 scoop es krim',
  ], [
    'Sajikan dingin. Cukup sesekali karena gula dan lemaknya tinggi.',
  ]),
};
