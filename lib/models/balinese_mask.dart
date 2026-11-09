class BalineseMask {
  final String id;
  final String name;
  final String subtitle;
  final String category; // 'Sakral', 'Bebalihan'
  final String characterType; // 'Dharma', 'Adharma', 'Manis', 'Keras', 'Punakawan'
  final String ritualType;
  final String material;
  final String description;
  final String philosophy;
  final String historicalOrigin;
  final List<String> commonQuestions;
  final String modelFileName;
  final String emoji;
  final int colorValue;

  /// Apakah file GLB model 3D sudah tersedia di assets/models/
  bool get hasModel3D => _availableModels.contains(modelFileName);

  /// Daftar file model yang sudah ada di folder assets/models/
  static const Set<String> _availableModels = {
    'TopengTua3d.glb',
  };

  /// Path asset lengkap untuk ModelViewer
  String get modelAssetPath => 'assets/models/$modelFileName';

  const BalineseMask({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.category,
    required this.characterType,
    required this.ritualType,
    required this.material,
    required this.description,
    required this.philosophy,
    required this.historicalOrigin,
    required this.commonQuestions,
    required this.modelFileName,
    required this.emoji,
    required this.colorValue,
  });

  static const List<BalineseMask> sampleMasks = [
    BalineseMask(
      id: 'barong',
      name: 'Topeng Barong Ket',
      subtitle: 'Raja Roh Suci & Pelindung Kebajikan',
      category: 'Sakral',
      characterType: 'Dharma (Kebajikan)',
      ritualType: 'Tari Wali & Bebalihan (Sakral Pura)',
      material: 'Kayu Pule pilihan, Bulu Ijuk/Kambing & Prada Emas',
      description:
          'Barong Ket adalah figur mitologis berkaki empat berwajah singa yang dipuja sebagai pelindung spiritual desa dari marabahaya.',
      philosophy:
          'Melambangkan kebaikan abadi (Dharma) yang senantiasa menyeimbangkan kekuatan destruktif (Adharma) dalam kosmologi Rwa Bhineda.',
      historicalOrigin:
          'Telah ada sejak era pra-Hindu di Bali dan disempurnakan pada masa Dinasti Gelgel sebagai simbol keselamatan jagat.',
      commonQuestions: [
        '🎭 Apa filosofi Barong dalam kosmologi Bali?',
        '⚔️ Siapakah musuh abadi Barong Ket?',
        '🪵 Mengapa Barong wajib dibuat dari Kayu Pule?',
      ],
      modelFileName: 'TopengTua3d.glb',
      emoji: '🦁',
      colorValue: 0xFFFFB300,
    ),
    BalineseMask(
      id: 'rangda',
      name: 'Topeng Rangda',
      subtitle: 'Ratu Para Leak & Kekuatan Magis Mistis',
      category: 'Sakral',
      characterType: 'Adharma (Keras & Magis)',
      ritualType: 'Tari Wali Sakral (Calonarang)',
      material: 'Kayu Pule Keramat, Rambut Kuda/Manusia & Kain Poleng',
      description:
          'Memiliki ciri khas lidah api yang menjulur panjang hingga ke dada, taring runcing melengkung, mata melotot, dan payudara menjulur.',
      philosophy:
          'Bukan sekadar lambang kejahatan, Rangda adalah manifestasi Dewi Durga yang mengingatkan manusia akan hukuman karma dan kekuatan takdir.',
      historicalOrigin:
          'Berkaitan erat dengan legenda Ratu Mahendradatta dari abad ke-11 dan kisah epik Calonarang di Jawa Timur dan Bali.',
      commonQuestions: [
        '🔥 Apa makna lidah api menjulur pada Rangda?',
        '📜 Siapakah sosok bersejarah di balik Rangda?',
        '✨ Mengapa topeng Rangda harus disucikan lewat Pasupati?',
      ],
      modelFileName: 'rangda.glb',
      emoji: '👹',
      colorValue: 0xFFE53935,
    ),
    BalineseMask(
      id: 'sidhakarya',
      name: 'Topeng Sidhakarya',
      subtitle: 'Penyelesai & Pemberi Berkah Upacara Suci',
      category: 'Sakral',
      characterType: 'Brahmana Sakral',
      ritualType: 'Tari Wali Yadnya (Penutup Piodalan)',
      material: 'Kayu Pule Halus & Rambut Putih Alami',
      description:
          'Berwajah putih dengan mata sipit tersenyum ramah namun memiliki taring kecil. Menari sambil menaburkan beras kuning dan uang kepeng.',
      philosophy:
          '"Sidha" (berhasil) dan "Karya" (upacara). Maknanya adalah karya yadnya umat manusia telah berhasil, suci, dan direstui Ida Sang Hyang Widhi.',
      historicalOrigin:
          'Berasal dari kisah Danghyang Dwijendra dan Brahmana Keling dari Kerajaan Madura pada masa Raja Dalem Waturenggong di Gelgel.',
      commonQuestions: [
        '🙏 Mengapa upacara belum sah tanpa Topeng Sidhakarya?',
        '🌾 Mengapa Sidhakarya menaburkan beras kuning?',
        '📖 Bagaimana kisah Brahmana Keling di Gelgel?',
      ],
      modelFileName: 'sidhakarya.glb',
      emoji: '👴',
      colorValue: 0xFF00E5FF,
    ),
    BalineseMask(
      id: 'dalem',
      name: 'Topeng Dalem Arsa Wijaya',
      subtitle: 'Raja Agung Berkarakter Halus & Bijaksana',
      category: 'Bebalihan',
      characterType: 'Manis (Halus & Anggun)',
      ritualType: 'Tari Bebalihan & Pementasan Babad',
      material: 'Kayu Pule Halus berlabur Prada Emas Asli',
      description:
          'Topeng berkulit kuning langsat dengan mata teduh dan senyum menawan, berhiaskan mahkota gelungan prada emas megah.',
      philosophy:
          'Menggambarkan kepemimpinan ideal seorang ksatria: tenang di bawah tekanan, welas asih pada rakyat, dan berpegang teguh pada keadilan.',
      historicalOrigin:
          'Terinspirasi dari masa keemasan kerajaan-kerajaan Bali seperti Gelgel dan Klungkung yang makmur dan tenteram.',
      commonQuestions: [
        '👑 Nilai kepemimpinan apa yang diajarkan Topeng Dalem?',
        '🎨 Mengapa ekspresi wajah Topeng Dalem selalu tersenyum?',
        '💃 Bagaimana ciri khas gerakan tari Topeng Dalem?',
      ],
      modelFileName: 'dalem.glb',
      emoji: '👑',
      colorValue: 0xFFFFD54F,
    ),
    BalineseMask(
      id: 'jauk',
      name: 'Topeng Jauk Keras',
      subtitle: 'Panglima Raksasa yang Gagah & Enerjik',
      category: 'Bebalihan',
      characterType: 'Keras (Dinamis & Kuat)',
      ritualType: 'Tari Bebalihan Seni Pertunjukan',
      material: 'Kayu Pule, Mahkota Gelungan & Kuku Panjang (Canggal)',
      description:
          'Topeng merah kecokelatan dengan kumis tebal, mata membelalak bundar, dan penari mengenakan kuku-kuku panjang yang bergetar dinamis.',
      philosophy:
          'Menampilkan energi maskulin, keberanian, kewaspadaan tinggi, serta ketangkasan seorang panglima perang yang setia.',
      historicalOrigin:
          'Berkembang dari tarian keprajuritan masa kerajaan yang menguji ketangkasan ekspresi gerak mata (Seledet) dan kelenturan jari penari.',
      commonQuestions: [
        '⚡ Apa fungsi kuku panjang (Canggal) pada Tari Jauk?',
        '👀 Bagaimana penari Jauk mengekspresikan karakter lewat mata?',
        '🥁 Mengapa irama gamelan Tari Jauk sangat cepat dan dinamis?',
      ],
      modelFileName: 'jauk.glb',
      emoji: '👺',
      colorValue: 0xFFFF7043,
    ),
    BalineseMask(
      id: 'penasar',
      name: 'Topeng Penasar / Wijil',
      subtitle: 'Punakawan Bijak Pengantar Cerita & Filosofi',
      category: 'Bebalihan',
      characterType: 'Punakawan (Penuh Humor & Nasehat)',
      ritualType: 'Tari Pengantar Cerita Sejarah Bali',
      material: 'Kayu Pule berukir ekspresif',
      description:
          'Topeng setengah wajah atau berahang bawah yang dapat bergerak, bertugas menerjemahkan sabda raja dan mengedukasi penonton.',
      philosophy:
          'Jembatan antara kaum bangsawan dan rakyat jelata. Mengajarkan bahwa kebijaksanaan tertinggi dapat disampaikan melalui humor yang santun.',
      historicalOrigin:
          'Tradisi teater tutur rakyat Bali yang bertugas mendemokrasikan nilai-nilai sastra babad kuno agar dipahami seluruh lapisan masyarakat.',
      commonQuestions: [
        '📜 Apa peran penting Penasar dalam teater topeng Bali?',
        '🎭 Mengapa sebagian topeng Penasar hanya menutupi setengah wajah?',
        '💡 Bagaimana Penasar menyampaikan kritik sosial?',
      ],
      modelFileName: 'penasar.glb',
      emoji: '🧓',
      colorValue: 0xFF26A69A,
    ),
  ];
}
