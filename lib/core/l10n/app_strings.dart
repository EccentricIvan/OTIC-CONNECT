import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLocale {
  en('English', 'EN', '🇬🇧'),
  lg('Luganda', 'LG', '🇺🇬'),
  sw('Kiswahili', 'SW', '🇰🇪');

  const AppLocale(this.label, this.code, this.flag);
  final String label;
  final String code;
  final String flag;
}

final localeProvider = StateNotifierProvider<LocaleNotifier, AppLocale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<AppLocale> {
  LocaleNotifier() : super(AppLocale.en);

  void set(AppLocale locale) {
    state = locale;
    SharedPreferences.getInstance().then((p) => p.setString('app_locale', locale.name));
  }

  void loadFromPrefs(String? saved) {
    if (saved == null) return;
    for (final l in AppLocale.values) {
      if (l.name == saved) {
        state = l;
        return;
      }
    }
  }
}

class S {
  S._();

  static String tr(BuildContext context, WidgetRef ref, String key) {
    final locale = ref.watch(localeProvider);
    return _strings[key]?[locale] ?? _strings[key]?[AppLocale.en] ?? key;
  }

  static String trFromLocale(String key, AppLocale locale) {
    return _strings[key]?[locale] ?? _strings[key]?[AppLocale.en] ?? key;
  }

  static const _strings = <String, Map<AppLocale, String>>{
    // ── App-wide ──
    'app_name': {
      AppLocale.en: 'Otic She Connect',
      AppLocale.lg: 'Otic She Connect',
      AppLocale.sw: 'Otic She Connect',
    },
    'online': {
      AppLocale.en: 'Online',
      AppLocale.lg: 'Ku mutimbagano',
      AppLocale.sw: 'Mtandaoni',
    },
    'offline': {
      AppLocale.en: 'Offline',
      AppLocale.lg: 'Toli ku mutimbagano',
      AppLocale.sw: 'Nje ya mtandao',
    },

    // ── Greeting ──
    'good_morning': {
      AppLocale.en: 'Good morning',
      AppLocale.lg: 'Wasuze otya',
      AppLocale.sw: 'Habari za asubuhi',
    },
    'good_afternoon': {
      AppLocale.en: 'Good afternoon',
      AppLocale.lg: 'Osiibye otya',
      AppLocale.sw: 'Habari za mchana',
    },
    'good_evening': {
      AppLocale.en: 'Good evening',
      AppLocale.lg: 'Oweddeko otya',
      AppLocale.sw: 'Habari za jioni',
    },

    // ── Home screen ──
    'hero_title': {
      AppLocale.en: 'Empowering your\ndigital journey',
      AppLocale.lg: 'Tukubudde mu\nntambula yo ey\'ekikompyuta',
      AppLocale.sw: 'Kuwezesha safari\nyako ya kidijitali',
    },
    'hero_subtitle': {
      AppLocale.en: 'Learn, Earn, Grow & Thrive — your path to opportunity starts here.',
      AppLocale.lg: 'Soma, Funa, Kukula & Terera — ekkubo lyo ery\'emikisa litandikira wano.',
      AppLocale.sw: 'Jifunze, Pata, Kua & Stawi — njia yako ya fursa inaanzia hapa.',
    },
    'continue_learning': {
      AppLocale.en: 'Continue Learning',
      AppLocale.lg: 'Weyongere Okusoma',
      AppLocale.sw: 'Endelea Kujifunza',
    },
    'day_streak': {
      AppLocale.en: 'day streak!',
      AppLocale.lg: 'ennaku empita!',
      AppLocale.sw: 'siku mfululizo!',
    },
    'your_progress': {
      AppLocale.en: 'YOUR PROGRESS',
      AppLocale.lg: 'ENTAMBULA YO',
      AppLocale.sw: 'MAENDELEO YAKO',
    },
    'quick_actions': {
      AppLocale.en: 'QUICK ACTIONS',
      AppLocale.lg: 'BIKOLWA EBYANGUWA',
      AppLocale.sw: 'VITENDO VYA HARAKA',
    },
    'explore_pillars': {
      AppLocale.en: 'EXPLORE PILLARS',
      AppLocale.lg: 'NOONYEREZA EMPAGI',
      AppLocale.sw: 'GUNDUA NGUZO',
    },
    'all_services': {
      AppLocale.en: 'ALL SERVICES',
      AppLocale.lg: 'EMPEEREZA ZONNA',
      AppLocale.sw: 'HUDUMA ZOTE',
    },
    'courses': {
      AppLocale.en: 'Courses',
      AppLocale.lg: 'Amasomo',
      AppLocale.sw: 'Kozi',
    },
    'points': {
      AppLocale.en: 'Points',
      AppLocale.lg: 'Obubonero',
      AppLocale.sw: 'Pointi',
    },
    'streak': {
      AppLocale.en: 'Streak',
      AppLocale.lg: 'Empita',
      AppLocale.sw: 'Mfululizo',
    },

    // ── Pillars ──
    'learn': {
      AppLocale.en: 'Learn',
      AppLocale.lg: 'Soma',
      AppLocale.sw: 'Jifunze',
    },
    'earn': {
      AppLocale.en: 'Earn',
      AppLocale.lg: 'Funa',
      AppLocale.sw: 'Pata',
    },
    'grow': {
      AppLocale.en: 'Grow',
      AppLocale.lg: 'Kukula',
      AppLocale.sw: 'Kua',
    },
    'thrive': {
      AppLocale.en: 'Thrive',
      AppLocale.lg: 'Terera',
      AppLocale.sw: 'Stawi',
    },
    'learn_desc': {
      AppLocale.en: 'Courses & digital skills',
      AppLocale.lg: 'Amasomo n\'obukugu bw\'ekikompyuta',
      AppLocale.sw: 'Kozi na ujuzi wa kidijitali',
    },
    'earn_desc': {
      AppLocale.en: 'Marketplace & finance',
      AppLocale.lg: 'Akatale n\'ensimbi',
      AppLocale.sw: 'Soko na fedha',
    },
    'grow_desc': {
      AppLocale.en: 'Mentorship & careers',
      AppLocale.lg: 'Obuyambi n\'emirimu',
      AppLocale.sw: 'Ushauri na kazi',
    },
    'thrive_desc': {
      AppLocale.en: 'Health & community',
      AppLocale.lg: 'Obulamu n\'ekibiina',
      AppLocale.sw: 'Afya na jamii',
    },

    // ── Quick actions ──
    'ask_ai': {
      AppLocale.en: 'Ask AI',
      AppLocale.lg: 'Buuza AI',
      AppLocale.sw: 'Uliza AI',
    },
    'find_jobs': {
      AppLocale.en: 'Find Jobs',
      AppLocale.lg: 'Noonya Emirimu',
      AppLocale.sw: 'Tafuta Kazi',
    },
    'marketplace': {
      AppLocale.en: 'Marketplace',
      AppLocale.lg: 'Akatale',
      AppLocale.sw: 'Soko',
    },

    // ── Services ──
    'finance': {
      AppLocale.en: 'Finance',
      AppLocale.lg: 'Ensimbi',
      AppLocale.sw: 'Fedha',
    },
    'mentors': {
      AppLocale.en: 'Mentors',
      AppLocale.lg: 'Abayambi',
      AppLocale.sw: 'Washauri',
    },
    'jobs': {
      AppLocale.en: 'Jobs',
      AppLocale.lg: 'Emirimu',
      AppLocale.sw: 'Kazi',
    },
    'skills': {
      AppLocale.en: 'Skills',
      AppLocale.lg: 'Obukugu',
      AppLocale.sw: 'Ujuzi',
    },
    'health': {
      AppLocale.en: 'Health',
      AppLocale.lg: 'Obulamu',
      AppLocale.sw: 'Afya',
    },
    'community': {
      AppLocale.en: 'Community',
      AppLocale.lg: 'Ekibiina',
      AppLocale.sw: 'Jamii',
    },
    'wellbeing': {
      AppLocale.en: 'Wellbeing',
      AppLocale.lg: 'Embeera ennungi',
      AppLocale.sw: 'Ustawi',
    },
    'settings': {
      AppLocale.en: 'Settings',
      AppLocale.lg: 'Entegeka',
      AppLocale.sw: 'Mipangilio',
    },
    'profile': {
      AppLocale.en: 'Profile',
      AppLocale.lg: 'Ebikukwatako',
      AppLocale.sw: 'Wasifu',
    },
    'ai_chat': {
      AppLocale.en: 'AI Chat',
      AppLocale.lg: 'Yogera ne AI',
      AppLocale.sw: 'Soga na AI',
    },
    'home': {
      AppLocale.en: 'Home',
      AppLocale.lg: 'Ennyumba',
      AppLocale.sw: 'Nyumbani',
    },
    'market': {
      AppLocale.en: 'Market',
      AppLocale.lg: 'Akatale',
      AppLocale.sw: 'Soko',
    },
    'chat': {
      AppLocale.en: 'Chat',
      AppLocale.lg: 'Yogera',
      AppLocale.sw: 'Soga',
    },

    // ── Daily tips ──
    'finance_tip': {
      AppLocale.en: 'Finance Tip',
      AppLocale.lg: 'Amagezi g\'Ensimbi',
      AppLocale.sw: 'Kidokezo cha Fedha',
    },
    'community_tip': {
      AppLocale.en: 'Community Tip',
      AppLocale.lg: 'Amagezi g\'Ekibiina',
      AppLocale.sw: 'Kidokezo cha Jamii',
    },
    'business_tip': {
      AppLocale.en: 'Business Tip',
      AppLocale.lg: 'Amagezi g\'Obusubuzi',
      AppLocale.sw: 'Kidokezo cha Biashara',
    },
    'health_tip': {
      AppLocale.en: 'Health Tip',
      AppLocale.lg: 'Amagezi g\'Obulamu',
      AppLocale.sw: 'Kidokezo cha Afya',
    },
    'skills_tip': {
      AppLocale.en: 'Skills Tip',
      AppLocale.lg: 'Amagezi g\'Obukugu',
      AppLocale.sw: 'Kidokezo cha Ujuzi',
    },
    'tip_save': {
      AppLocale.en: 'Save at least 10% of your income each week — small amounts grow fast!',
      AppLocale.lg: 'Tereka watoowozo 10% ey\'ensimbi zo buli wiiki — ebitono bikula mangu!',
      AppLocale.sw: 'Weka akiba angalau 10% ya mapato yako kila wiki — kiasi kidogo hukua haraka!',
    },
    'tip_sacco': {
      AppLocale.en: 'Join a local savings group (SACCO) to access loans and build credit.',
      AppLocale.lg: 'Yingira mu kibiina ky\'okuterekawo (SACCO) ofune ebbanja era ozimbe okwesigwa.',
      AppLocale.sw: 'Jiunge na kikundi cha akiba (SACCO) kupata mikopo na kujenga sifa ya mkopo.',
    },
    'tip_photos': {
      AppLocale.en: 'Take photos of your products in natural light for better online sales.',
      AppLocale.lg: 'Kuba ebifaananyi by\'ebyobusubuzi byo mu musana ogw\'obutonde ofune okutunda obulungi.',
      AppLocale.sw: 'Piga picha za bidhaa zako kwenye mwanga wa asili kwa mauzo bora mtandaoni.',
    },
    'tip_water': {
      AppLocale.en: 'Drink at least 8 glasses of water daily for better health and energy.',
      AppLocale.lg: 'Okunywa watoowozo gilasi 8 ez\'amazzi buli lunaku olw\'obulamu obulungi n\'amaanyi.',
      AppLocale.sw: 'Kunywa angalau glasi 8 za maji kila siku kwa afya na nishati bora.',
    },
    'tip_digital': {
      AppLocale.en: 'Practice one new digital skill each week — consistency beats speed.',
      AppLocale.lg: 'Gezaako obukugu bw\'ekikompyuta obuggya buli wiiki — okugoberera kusinga okwanguyiriza.',
      AppLocale.sw: 'Fanya mazoezi ya ujuzi mpya wa kidijitali kila wiki — uthabiti unashinda kasi.',
    },

    // ── Onboarding ──
    'welcome_to': {
      AppLocale.en: 'Welcome to\nOtic She Connect',
      AppLocale.lg: 'Tukusanyukira ku\nOtic She Connect',
      AppLocale.sw: 'Karibu kwenye\nOtic She Connect',
    },
    'welcome_desc': {
      AppLocale.en: 'Your digital companion for learning, earning, growing, and thriving. Works online and offline — your progress is always safe.',
      AppLocale.lg: 'Munno wo ow\'ekikompyuta okusoma, okufuna, okukula, n\'okuterera. Akola ku mutimbagano ne bw\'otaba — entambula yo etereka.',
      AppLocale.sw: 'Mwenzako wa kidijitali wa kujifunza, kupata, kukua, na kustawi. Inafanya kazi mtandaoni na nje — maendeleo yako ni salama daima.',
    },
    'whats_your_name': {
      AppLocale.en: "What's your name?",
      AppLocale.lg: "Erinnya lyo ggwe ani?",
      AppLocale.sw: "Jina lako ni nani?",
    },
    'enter_your_name': {
      AppLocale.en: 'Enter your name',
      AppLocale.lg: 'Wandiika erinnya lyo',
      AppLocale.sw: 'Ingiza jina lako',
    },
    'continue_btn': {
      AppLocale.en: 'Continue',
      AppLocale.lg: 'Okwongera',
      AppLocale.sw: 'Endelea',
    },
    'back': {
      AppLocale.en: 'Back',
      AppLocale.lg: 'Nnyuma',
      AppLocale.sw: 'Rudi',
    },
    'start_journey': {
      AppLocale.en: 'Start your journey',
      AppLocale.lg: 'Sooka olugendo lwo',
      AppLocale.sw: 'Anza safari yako',
    },
    'about_you': {
      AppLocale.en: 'About you',
      AppLocale.lg: 'Ebikukwatako',
      AppLocale.sw: 'Kuhusu wewe',
    },
    'about_you_desc': {
      AppLocale.en: 'This helps us personalise your experience with relevant opportunities and resources.',
      AppLocale.lg: 'Kino kituyamba okukukolera ebikugyanira mu mbeera n\'ebyobulamu.',
      AppLocale.sw: 'Hii inatusaidia kubinafsisha uzoefu wako na fursa na rasilimali zinazofaa.',
    },
    'what_describes_you': {
      AppLocale.en: 'What best describes you?',
      AppLocale.lg: 'Kiki ekikukubaganya?',
      AppLocale.sw: 'Ni nini kinachokuelezea vyema?',
    },
    'where_based': {
      AppLocale.en: 'Where are you based?',
      AppLocale.lg: 'Obeera wa?',
      AppLocale.sw: 'Uko wapi?',
    },
    'location_hint': {
      AppLocale.en: 'e.g. Kampala, Mukono, Mbale',
      AppLocale.lg: 'okugeza Kampala, Mukono, Mbale',
      AppLocale.sw: 'mf. Kampala, Mukono, Mbale',
    },
    'choose_language': {
      AppLocale.en: 'Choose your language',
      AppLocale.lg: 'Londa olulimi lwo',
      AppLocale.sw: 'Chagua lugha yako',
    },
    'please_enter_name': {
      AppLocale.en: 'Please enter your name',
      AppLocale.lg: 'Nsaba wandiike erinnya lyo',
      AppLocale.sw: 'Tafadhali ingiza jina lako',
    },

    // ── Roles ──
    'role_entrepreneur': {
      AppLocale.en: 'Entrepreneur',
      AppLocale.lg: 'Omusubuzi',
      AppLocale.sw: 'Mjasiriamali',
    },
    'role_entrepreneur_desc': {
      AppLocale.en: 'I run or want to start a business',
      AppLocale.lg: 'Nkola obusubuzi oba njagala okutandika',
      AppLocale.sw: 'Ninaendesha au nataka kuanzisha biashara',
    },
    'role_farmer': {
      AppLocale.en: 'Farmer',
      AppLocale.lg: 'Omulimi',
      AppLocale.sw: 'Mkulima',
    },
    'role_farmer_desc': {
      AppLocale.en: 'I work in agriculture or agribusiness',
      AppLocale.lg: 'Nkola mu bulimi',
      AppLocale.sw: 'Ninafanya kazi katika kilimo',
    },
    'role_student': {
      AppLocale.en: 'Student',
      AppLocale.lg: 'Omuyizi',
      AppLocale.sw: 'Mwanafunzi',
    },
    'role_student_desc': {
      AppLocale.en: 'I am currently studying or in training',
      AppLocale.lg: 'Ndi mu kusoma oba okutendekebwa',
      AppLocale.sw: 'Ninasoma au ninafunzwa sasa',
    },
    'role_job_seeker': {
      AppLocale.en: 'Job Seeker',
      AppLocale.lg: 'Anoonya omulimu',
      AppLocale.sw: 'Mtafuta kazi',
    },
    'role_job_seeker_desc': {
      AppLocale.en: 'I am looking for employment',
      AppLocale.lg: 'Nnoonya omulimu',
      AppLocale.sw: 'Ninatafuta ajira',
    },
    'role_leader': {
      AppLocale.en: 'Community Leader',
      AppLocale.lg: 'Omukulembeze w\'ekibiina',
      AppLocale.sw: 'Kiongozi wa jamii',
    },
    'role_leader_desc': {
      AppLocale.en: 'I lead or organize in my community',
      AppLocale.lg: 'Nkulembera oba ntegeka mu kibiina kyange',
      AppLocale.sw: 'Ninaongoza au ninapanga katika jamii yangu',
    },
    'role_artisan': {
      AppLocale.en: 'Artisan / Creator',
      AppLocale.lg: 'Omukozi w\'emikono',
      AppLocale.sw: 'Fundi / Muundaji',
    },
    'role_artisan_desc': {
      AppLocale.en: 'I create handmade goods or crafts',
      AppLocale.lg: 'Nkola ebintu n\'emikono gyange',
      AppLocale.sw: 'Ninaunda bidhaa za mikono au sanaa',
    },

    // ── Settings ──
    'appearance': {
      AppLocale.en: 'Appearance',
      AppLocale.lg: 'Endabika',
      AppLocale.sw: 'Muonekano',
    },
    'language': {
      AppLocale.en: 'Language',
      AppLocale.lg: 'Olulimi',
      AppLocale.sw: 'Lugha',
    },
    'app_language': {
      AppLocale.en: 'App Language',
      AppLocale.lg: 'Olulimi lw\'App',
      AppLocale.sw: 'Lugha ya App',
    },
    'data_sync': {
      AppLocale.en: 'Data & Sync',
      AppLocale.lg: 'Ebikukwatako n\'Okukolagana',
      AppLocale.sw: 'Data na Usawazishaji',
    },
    'notifications': {
      AppLocale.en: 'Notifications',
      AppLocale.lg: 'Amawulire',
      AppLocale.sw: 'Arifa',
    },
    'about': {
      AppLocale.en: 'About',
      AppLocale.lg: 'Ebikwata ku',
      AppLocale.sw: 'Kuhusu',
    },

    // ── Nav ──
    'new_chat': {
      AppLocale.en: 'New chat',
      AppLocale.lg: 'Emboozi empya',
      AppLocale.sw: 'Mazungumzo mapya',
    },
    'ask_anything': {
      AppLocale.en: 'Ask anything...',
      AppLocale.lg: 'Buuza ekikyamu kyonna...',
      AppLocale.sw: 'Uliza chochote...',
    },
    'thinking': {
      AppLocale.en: 'Thinking...',
      AppLocale.lg: 'Nlowooza...',
      AppLocale.sw: 'Nafikiri...',
    },
  };
}
