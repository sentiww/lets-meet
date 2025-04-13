# Przypadki użycia

W tym dokumencie opisane zostały przypadki użycia systemu.

## Definicje

### Aktorzy

- `Użytkownik` - osoba korzystająca z aplikacji
- `System` - aplikacja
- `Administrator` - użytkownik z uprawnieniami administracyjnymi

## M00: Nazwa modułu

Opis modułu.

### M00-PU001: Nazwa przypadku użycia

Aktor:

Opis:

## MO1: Użytkownik

### M01-PU001: Rejestracja użytkownika

Aktor:`Użytkownik`

Opis:
1. Użytkownik klika przycisk "Zarejestruj mnie".
2. Użytkownik wypełnia formularz w którym są kluczowe do rejestracji informacje(Login,Haslo,Imie,Nazwisko,Data urodzenia)
3. W razie powodzenia wyświetla się komunikat o udanej rejestracji,system tworzy nowy profil użytkownika i zamyka się wcześniej wypełniany formularz.
W razie nie powodzenia wyświetlany jest komunikat o nieudanej rejestracji oraz użytkownik wraca do wcześniej wypełnianego formularza.

### M01-PU002: Logowanie użytkownika

Aktor:`Użytkownik`

Opis:
1. Użytkownik w dwóch polach wpisuje swój login oraz hasło.
2. Klikając przycisk "Zaloguj" aplikacja próbuje rozpocząć sesje z podanymi informacjami w polach przez użytkownika.
3. Wyświetla się komunikat o powodzeniu operacji.
4. W razie powodzenia użytkownik jest przekierowany do strony głównej aplikacji.


### M01-PU003: Wyświetlenie profilu aktualnego użytkownika

Aktor:`Użytkownik`

Opis:
1. Użytkownik klika w ikonę swojego profilu.
2. System wyświetla informacje o profilu.

### M01-PU004: Edycja profilu użytkownika

Aktor:`Użytkownik`

Opis:
1. Użytkownik klika w ikonę swojego profilu.
2. Użytkownik klika w ikonę edycji profilu.
3. Użytkownik edytuje takie elementy jak zdjęcie profilowe,imię,nazwisko,Data Urodzenia itp.
4. Użytkownik kilka przycisk "zapisz zmiany"
5. System aktualizuje profil w swojej bazie danych.

## M02: Wydarzenie

### M02-PU001: Dodanie wydarzenia

Aktor: `Użytkownik`

Opis:
1. Użytkownik klika w przycisk "Stwórz Wydarzenie".
2. Użytkownik wypełnia formularz w którym podaje nazwę,opis i datę wydarzenia wraz z ewentualnymi zdjęciami.
3. Po kliknięciu przycisku "Stwórz" w formularzu System rejestruje nowe wydarzenie.

### M02-PU002: Edycja wydarzenia

Aktor: `Użytkownik`

Opis:
1. Użytkownik klika przycisk edycji obok stworzonego przez niego wydarzenia.
2. Przed użytkownikiem pojawia się formularz taki sam jak w przypadku Dodania wydarzenia z już wypełnionymi danymi.
3. Po kliknięciu przycisku "Zaakcpetuj zmiany" w formularzu System aktualizuje wydarzenie.

### M02-PU003: Usunięcie wydarzenia

Aktor: `Użytkownik`

Opis:
1. Użytkownik wybiera wydarzenie, które chce usunąć.
2. System wyświetla szczegóły wydarzenia wraz z opcją usunięcia.
3. Użytkownik potwierdza usunięcie wydarzenia.
4. System usuwa wydarzenie i informuje użytkownika o powodzeniu operacji.

### M02-PU004: Wyświetlanie zdjęć z wydarzenia

Aktor: `Użytkownik`

Opis:
1. Użytkownik wybiera przeszłe wydarzenie, które chce zobaczyć.
2. System wyświetla zdjęcia z wydarzenia.

## M03: Interakcje między użytkownikami

Moduł M03 odpowiada za zarządzanie interakcjami między użytkownikami w systemie. Obejmuje on funkcjonalności związane z wysyłaniem i akceptowaniem zaproszeń do znajomych, zarządzaniem listą znajomych oraz blokowaniem innych użytkowników.

### M03-PU001: Wysłanie zaproszenia do znajomych

Aktor: `Użytkownik`

Opis:
1. Użytkownik przegląda profil innego użytkownika.
2. System wyświetla opcję wysłania zaproszenia do znajomych.
3. Użytkownik klika opcję wysłania zaproszenia.
4. System wysyła zaproszenie i powiadamia drugiego użytkownika.

### M03-PU002: Akceptacja zaproszenia do znajomych

Aktor: `Użytkownik`

Opis:
1. Użytkownik otrzymuje powiadomienie o zaproszeniu do znajomych.
2. System umożliwia użytkownikowi zaakceptowanie lub odrzucenie zaproszenia.
3. Użytkownik wybiera opcję akceptacji.
4. System dodaje użytkownika do listy znajomych i powiadamia nadawcę zaproszenia.

### M03-PU003: Odrzucenie zaproszenia do znajomych

Aktor: `Użytkownik`

Opis:
1. Użytkownik otrzymuje powiadomienie o zaproszeniu do znajomych.
2. System umożliwia użytkownikowi zaakceptowanie lub odrzucenie zaproszenia.
3. Użytkownik wybiera opcję odrzucenia
4. System usuwa zaproszenie i nie informuje nadawcy.

### M03-PU004: Usunięcie znajomego

Aktor: `Użytkownik`

Opis:
1. Użytkownik przechodzi do listy znajomych.
2. System wyświetla opcję usunięcia znajomego.
3. Użytkownik wybiera opcję usunięcia.
4. System usuwa znajomego z listy i informuje użytkownika o powodzeniu operacji.

### M03-PU005: Zablokowanie użytkownika

Aktor: `Użytkownik`

Opis:
1. Użytkownik przechodzi do profilu innego użytkownika.
2. System wyświetla opcję zablokowania użytkownika.
3. Użytkownik wybiera opcję blokady.
4. System blokuje użytkownika, uniemożliwiając mu kontakt i wyświetlanie profilu.
5. System informuje użytkownika o powodzeniu operacji.

### M03-PU006: Odblokowanie użytkownika

Aktor: `Użytkownik`

Opis:
1. Użytkownik przechodzi do profilu zablokowanego użytkownika  
2. Użytkownik wybiera opcję odblokowania zablokowanego użytkownika
3. System odblokowuje możliwość kontaktu oraz wyświetlenia profilu oraz informuje o powodzeniu operacji

### M03-PU007: Wysłanie wiadomości do znajomego

Aktor: `Użytkownik`

Opis:
1. Użytkownik otwiera rozmowę ze znajomym poprzez wybór znajomego z listy znajomych
2. Użytkownik wysyła nową wiadomość w rozmowie ze znajomym

### M03-PU008: Utworzenie czatu wydarzenia

Aktor: `Użytkownik`

Opis:
1. Użytkownik organizujący wydarzenie otwiera czat wydzrzenia
2. Użytkownicy zapisani na wydarzenie dostają powiadomienie o otwarciu czatu wydarzenia

### M03-PU009: Utworzenie grupy użytkowników

Aktor: `Użytkownik`

Opis:
1. Użytkownik podaje nazwę oraz tematykę grupy
2. Użytkonik wybiera użytkoników zapraszanych do grupy
3. Uzytkownik tworzy grupę
3. Zaproszeni użytkownicy dostają powiadomienie o utworzeniu grupy i otrzymaniu zaproszenia

### M03-PU010: Edycja grupy użytkowników

Aktor: `Użytkownik`

Opis:
1. Użytkownik posiadający uprawnienia do edycji grupy przechodzi do panelu zarządzania grupą
2. Użytkonik edytuje grupę poprzez
    - edycję nazwy grupy
    - edycję temtyki grupy
    - zaproszenienowych członków grupy
    - usunięcie członków grupy
    - zmianę uprawnień członków grupy

### M03-PU011: Usunięcie grupy użytkowników

Aktor: `Użytkownik`

Opis:
1. Użytkownik posiadający uprawnienia do edycji grupy przechodzi do panelu zarządzania grupą
2. Uzytkownik usuwa grupę

## M04: Feed

### M04-PU001: Wyświetlenie feed-u wydarzeń

Aktor: `Użytkownik`

Opis:
1. Użytkownik wybiera z systemu widok z feed'em wydarzeń - system wyświetla na ekranie wydarzenie.
2. Użytkownik przeglądając feed może go filtrować, aby wyświetlane wydarzenia miały pewne ograniczenia - np. może wyświetlać tylko wydarzenia znajomych, określonej grupy, w zależności od daty, czy lokalizacji. Po wybraniu filtrów użytkownik je zatwierdza i feed ulega uaktualnieniu. 
3. Użytkownik może w dowolnej chwili usunąć bądź zmienić filtry klikając odpowiedni przycisk.

### M04-PU002: Wyrażenie chęci uczestnictwa w wydarzeniu

Aktor: `Użytkownik`

Opis:
1. Użytkownik przeglądający feed w przypadku zainteresowania wydarzeniem przesuwa je do prawej strony ekranu.
2. System wyświetla kolejne wydarzenie.

### M04-PU003: Wyrażenie braku chęci uczestnictwa w wydarzeniu

Aktor: `Użytkownik`

Opis:
1. Użytkownik przeglądający feed w przypadku braku zainteresowania wydarzeniem przesuwa je do lewej strony ekranu.
2. System wyświetla kolejne wydarzenie.

## M05: Administracja

### M05-PU001: Dodawany systemowo

Aktor: `System`

Opis:
1. Domyślny administrator dodawany jest przez system podczas inicjalizacji aplikacji, jeśli nie istnieje.

### M05-PU002: Zarządzanie treściami w aplikacji - usuwanie wydarzeń

Aktor: `Administrator`

Opis:
1. Administrator wybiera widok z listą wydarzeń użytkowników.
2. Przy wybranym wydarzeniu użytkownik klika przycisk "Usuń".
3. Wydarzenie zostaje usunięte.
4. 
### M05-PU003: Zarządzanie treściami w aplikacji - blokowanie użytkowników

Aktor: `Administrator`

Opis:
1. Administrator wybiera widok z listą aktywnych użytkowników.
2. Przy wybranym użytkowniku użytkownik klika przycisk "Zablokuj".
3. Użytkownik zostaje zablokowany i nie może zalogować się na konto.

### M05-PU004: Zarządzanie treściami w aplikacji - odblokowanie użytkowników

Aktor: `Administrator`

Opis:
1. Administrator wybiera widok z listą zablokowanych użytkowników.
2. Przy wybranym zablokowanym użytkowniku użytkownik klika przycisk "Odblokuj".
3. Użytkownik zostaje odblokowany i odzyskuje możliwość logowania na konto.