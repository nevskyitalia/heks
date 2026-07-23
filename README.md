# HEKS — Iks i Oks na šestougaonim mrežama

Mobilna igra (Flutter, Android): iks-oks na HEKS1 mreži (36 polja, default)
i HEKS2 mreži (25 polja). Dva igrača na istom telefonu ili igra protiv
telefona sa 10 nivoa jačine. Interfejs na srpskom, engleskom i albanskom.
Pri prvom pokretanju igra je u landscape režimu; u podešavanjima se može
prebaciti na portrait i izbor se trajno pamti.

## Kako da dobiješ APK (bez ikakvih alata na računaru)

APK se builduje automatski na GitHub-u (besplatno), koraci:

1. Napravi nalog na github.com (ako ga nemaš) i klikni **New repository**,
   nazovi ga npr. `heks`, ostavi Public, **Create repository**.
2. Na stranici repozitorijuma klikni **uploading an existing file** i
   prevuci CEO sadržaj ovog foldera (sve fajlove i foldere, uključujući
   skriveni folder `.github` — ako otpremaš kroz browser, najlakše je da
   otpremiš i `.github/workflows/build-apk.yml` ručno istim postupkom).
   Klikni **Commit changes**.
3. Otvori karticu **Actions** na repozitorijumu → workflow **Build APK**
   će se sam pokrenuti (ili ga pokreni dugmetom **Run workflow**).
4. Kad pozeleni (5–10 minuta), otvori taj run i pri dnu, pod
   **Artifacts**, skini **heks-apk** → unutra je `app-release.apk`.
5. Prebaci APK na telefon, dozvoli instalaciju iz nepoznatih izvora
   i instaliraj.

Alternativa (ako imaš git): `git init && git add -A && git commit -m init`
pa poveži repo i `git push` — Actions se pokreće sam.

Alternativa (ako imaš Flutter na računaru): `flutter create . --org rs.heks
--project-name heks --platforms android && flutter build apk --release`.

## Struktura

- `lib/game/board.dart` — definicije mreža (HEKS1, HEKS2). **Nova mreža se
  dodaje ovde**: napiši `buildMojaMreza()` sa poljima i pobedničkim
  linijama i dodaj je u `allBoards` — sve ostalo (crtanje, dodir, AI,
  meni) radi automatski.
- `lib/game/engine.dart` — pravila igre (potez, pobeda, nerešeno).
- `lib/game/ai.dart` — 10 nivoa telefona (nasumičan → verovatnosno
  viđenje pobede/blokade → jača polja i dvostruke pretnje → pretraga
  unapred sa malom stopom greške; nivo 10 je jak ali pobediv).
- `lib/ui/` — meni, tabla (crtanje + dodir), ekran igre, podešavanja.
- `lib/l10n/strings.dart` — prevodi (sr/en/sq).
- `test/` — testovi pravila i AI lestvice (pokreću se automatski u CI).

## iPhone (kasnije)

Isti kod se builduje i za iOS (`flutter build ipa`) — treba Apple
Developer nalog i macOS runner u Actions workflow-u.
