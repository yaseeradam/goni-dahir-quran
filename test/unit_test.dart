import 'package:flutter_test/flutter_test.dart';
import 'package:gwani_dahiru_app/models/surah.dart';

void main() {
  group('Surah Model Tests', () {
    test('Surah parses correctly from JSON', () {
      final jsonMap = {
        "id": 18,
        "name": "Al-Kahf",
        "arabic": "الكهف",
        "verses": 110,
        "type": "Makki",
        "reciter": "Gwani Dahiru",
        "style": "Hafs 'an 'Asim",
        "sizeBytes": 13090896,
        "sizeMb": 12.48,
        "safeFileName": "018_al_kahf.mp3",
        "audioUrl": "https://quran.academyhub.com.ng/audio/018_al_kahf.mp3"
      };

      final surah = Surah.fromJson(jsonMap);

      expect(surah.id, 18);
      expect(surah.name, 'Al-Kahf');
      expect(surah.arabic, 'الكهف');
      expect(surah.verses, 110);
      expect(surah.type, 'Makki');
      expect(surah.reciter, 'Goni Dahir Idris Maiduguri');
      expect(surah.style, "Hafs 'an 'Asim");
      expect(surah.sizeMb, 12.48);
      expect(surah.safeFileName, '018_al_kahf.mp3');
      expect(surah.audioUrl, 'https://quran.academyhub.com.ng/audio/018_al_kahf.mp3');
      expect(surah.isDownloaded, false);
      expect(surah.isFavorite, false);
    });

    test('Surah defensively normalizes legacy Warsh style to Hafs', () {
      final jsonMap = {
        "id": 1,
        "name": "Al-Fatihah",
        "arabic": "الفاتحة",
        "verses": 7,
        "type": "Makki",
        "style": "Warsh 'an Nafi'",
        "sizeBytes": 376272,
        "sizeMb": 0.36,
        "safeFileName": "001_al_fatihah.mp3",
        "audioUrl": "https://quran.academyhub.com.ng/audio/001_al_fatihah.mp3"
      };

      final surah = Surah.fromJson(jsonMap);
      expect(surah.style, "Hafs 'an 'Asim");
    });

    test('Surah converts back to JSON correctly', () {
      final surah = Surah(
        id: 1,
        name: 'Al-Fatihah',
        arabic: 'الفاتحة',
        verses: 7,
        type: 'Makki',
        reciter: 'Gwani Dahiru',
        style: "Hafs 'an 'Asim",
        sizeBytes: 376272,
        sizeMb: 0.36,
        safeFileName: '001_al_fatihah.mp3',
        audioUrl: 'https://quran.academyhub.com.ng/audio/001_al_fatihah.mp3',
      );

      final map = surah.toJson();
      expect(map['id'], 1);
      expect(map['name'], 'Al-Fatihah');
      expect(map['arabic'], 'الفاتحة');
      expect(map['safeFileName'], '001_al_fatihah.mp3');
      expect(map['style'], "Hafs 'an 'Asim");
    });

    test('Surah state mutation for offline download', () {
      final surah = Surah(
        id: 114,
        name: 'An-Nas',
        arabic: 'الناس',
        verses: 6,
        type: 'Makki',
        reciter: 'Gwani Dahiru',
        style: "Hafs 'an 'Asim",
        sizeBytes: 362544,
        sizeMb: 0.35,
        safeFileName: '114_an_nas.mp3',
        audioUrl: 'https://quran.academyhub.com.ng/audio/114_an_nas.mp3',
      );

      expect(surah.isDownloaded, false);
      expect(surah.localPath, isNull);

      surah.isDownloaded = true;
      surah.localPath = '/mock/storage/114_an_nas.mp3';
      surah.isFavorite = true;

      expect(surah.isDownloaded, true);
      expect(surah.localPath, '/mock/storage/114_an_nas.mp3');
      expect(surah.isFavorite, true);
    });

    test('Surah equality and hashCode based on id', () {
      final surah1 = Surah(
        id: 1,
        name: 'Al-Fatihah',
        arabic: 'الفاتحة',
        verses: 7,
        type: 'Makki',
        reciter: 'Goni Dahir Idris Maiduguri',
        style: "Hafs 'an 'Asim",
        sizeBytes: 376272,
        sizeMb: 0.36,
        safeFileName: '001_al_fatihah.mp3',
        audioUrl: 'https://quran.academyhub.com.ng/audio/001_al_fatihah.mp3',
      );
      final surah2 = Surah(
        id: 1,
        name: 'Al-Fatihah Duplicate',
        arabic: 'الفاتحة',
        verses: 7,
        type: 'Makki',
        reciter: 'Goni Dahir Idris Maiduguri',
        style: "Hafs 'an 'Asim",
        sizeBytes: 376272,
        sizeMb: 0.36,
        safeFileName: '001_al_fatihah.mp3',
        audioUrl: 'https://quran.academyhub.com.ng/audio/001_al_fatihah.mp3',
      );
      final surah3 = Surah(
        id: 2,
        name: 'Al-Baqarah',
        arabic: 'البقرة',
        verses: 286,
        type: 'Madani',
        reciter: 'Goni Dahir Idris Maiduguri',
        style: "Hafs 'an 'Asim",
        sizeBytes: 15000000,
        sizeMb: 14.3,
        safeFileName: '002_al_baqarah.mp3',
        audioUrl: 'https://quran.academyhub.com.ng/audio/002_al_baqarah.mp3',
      );

      expect(surah1, equals(surah2));
      expect(surah1.hashCode, equals(surah2.hashCode));
      expect(surah1, isNot(equals(surah3)));
    });
  });
}
