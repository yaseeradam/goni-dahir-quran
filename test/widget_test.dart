import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gwani_dahiru_app/models/surah.dart';
import 'package:gwani_dahiru_app/widgets/surah_card.dart';

void main() {
  testWidgets('SurahCard displays title, Arabic, and number correctly', (WidgetTester tester) async {
    final surah = Surah(
      id: 18,
      name: 'Al-Kahf',
      arabic: 'الكهف',
      verses: 110,
      type: 'Makki',
      reciter: 'Gwani Dahiru',
      style: "Warsh 'an Nafi'",
      sizeBytes: 13090896,
      sizeMb: 12.48,
      safeFileName: '018_al_kahf.mp3',
      audioUrl: 'https://quran.academyhub.com.ng/audio/018_al_kahf.mp3',
      isDownloaded: true,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SurahCard(
            surah: surah,
            isCurrent: true,
            onTap: () {},
            onDownload: () {},
            onFavorite: () {},
          ),
        ),
      ),
    );

    // Verify Surah Name and Arabic are present
    expect(find.text('Al-Kahf'), findsOneWidget);
    expect(find.text('الكهف'), findsOneWidget);
    expect(find.text('18'), findsOneWidget);
    expect(find.text('Offline'), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
  });
}
