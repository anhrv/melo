# melo

Seminarski rad iz predmeta Razvoj Softvera II

## Info

- Dokumentacija za sistem preporuke se nalazi u _**root**_ folderu
- Unutar _**.\Melo**_ se nalazi source code projekta, kao i konfiguracijski fajl backend servisa
- Unutar _**.\Melo\Melo.UI\melo_desktop**_ i _**.\Melo\Melo.UI\melo_mobile**_ se nalaze konfiguracijski fajlovi respektivnih frontend aplikacija
- Build-ane frontend aplikacije se nalaze u _**.\Melo\Melo.UI**_, zipovane u arhivu _**fit-build-2025-08-22.zip**_ (pod šifrom _"fit"_)

## Kredencijali

_**Korisnik: korisničko ime / lozinka**_

Admin: admin / testtest

User1: user1 / testtest\
User2: user2 / testtest\
...\
User9: user9 / testtest

Korisnik _Admin_ je korisnik sa administratorskom ulogom, ostali korisnici imaju običnu, korisničku ulogu.

Za obične korisnike je potrebno uraditi _Stripe_ plaćanje pretplate. Koristiti testni broj kartice: **4242 4242 4242 4242**

## Pokretanje

Backend: izvršiti komandu _docker-compose up --build_ unutar _**.\Melo**_

- Pokrenuti će se SQL Server instanca, RabbitMQ instanca, i dva backend servisa _Melo.API_ i _Melo.Files_
- Kreirati će se baza _210038_ i popuniti testnim podacima
- Istrenirati će se modeli za sistem preporuke

Frontend:

- Unzip arhivu _**.\Melo\Melo.UI\fit-build-2025-08-22.zip**_
- U njoj se nalaze dva foldera: _**flutter_apk**_ i _**Release**_
- Za mobilnu aplikaciju koristiti _**flutter_apk\apk-release.apk**_
- Za desktop aplikaciju pokrenuti _**Release\Melo.exe**_

## Opis implementacije

### Baza podataka

Korišten SQL Server, pripremljena migracija pri pokretanju aplikacije za kreiranje baze i popunjavanje testnim podacima.

### Mikro servisi

Napravljena dva backend servisa: Melo.API (servis sa biznis logikom i većinom funkcionalnosti) i Melo.Files (servis za pohranjivanje fajlova).
Kada korisnik posluša pjesmu, šalje se poruka na Melo.API putem RabbitMQ queue-a. Melo.API zatim poveća broj slušanja u bazi za respektivnu pjesmu i njene srodne entitete. Slušanja se broje samo za korisnike (ne za administratore), te se slušanja broje u određenom (konfigurabilnom) intervalu, kako bi se spriječilo "spamovanje" slušanja (korišten in-memory cache). Pored asinhrone komunikacije, postoji i sinhrona komunikacija izmedju ova dva servisa, prilikom dodavanja i brisanja fajlova.

### Backend

Implementirana validacija unosa, error handling, mapiranje, logiranje, generične metode, kao i dockerizacija. Implementirani svi potrebni endpointi (CRUD i ostali). Korišten ASP.NET Core Web API.

### Autentifikacija

Sopstvena implementacija JWT autentifikacije. Također implementirani i refresh tokeni, kao i "rotiranje" refresh tokena (nakon svakog refresha JWT tokena, refresha se i sami refresh token). Refresh se dešava tako što UI provjeri da li je JWT token istekao ili je blizu isteka (3 minute do isteka) prije poziva nekog endpointa, ako jeste prvo će pozvati endpoint za refresh tokena pa tek onda nastaviti originalni poziv. Trajanje JWT tokena i refresh tokena je konfigurabilno. Svi endpointi su pokriveni autentifikacijom i autorizacijom (role based + subscribed/not subscribed user). Korisnici ostaju logirani sve dok trajanje refresh tokena nije isteklo.

### Stripe integracija

Implementirana pretplata putem Stripe. Korisnici se moraju pretplatiti da bi mogli koristiti aplikaciju. Status pretplate se uzima u obzir prilikom autentifikacije (ako je validan korisnik ali nije pretplaćen, endpointi će vratiti status 402 - Payment required). Obzirom da se projekat pokreće lokalno, nisam koristio opciju webhooks za provjeru / potvrdu pretplata na Stripe, već manuelne pozive Stripe endpoint-a sa retry logikom prilikom potvrde uspješne pretplate. Također, nakon "isteka" pretplate, poziva se Stripe endpoint da bi se potvrdilo stanje pretplate na Stripe (da li se pretplata obnovila ili ne). Shodno tome se vrši update u bazi.

### Kreiranje izvještaja

Administratori imaju mogućnost kreiranja i preuzimanja izvještaja o entitetima u .pdf formatu.

### Sistem preporuke

Implementiran sistem preporuke. Detaljno objašnjen u recommender-dokumentacija.pdf.

### UI

Implementirana Flutter desktop aplikacija samo za administratore.
Implementirana Flutter mobile aplikacija prvenstevno za obične korisnike, ali i za administratore (administratori imaju sve funkcionalnosti kao i na desktop aplikaciji).
