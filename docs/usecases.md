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

### M01-PU002: Logowanie użytkownika

### M01-PU003: Wyświetlenie profilu aktualnego użytkownika

### M01-PU004: Edycja profilu użytkownika

## M02: Wydarzenie

### M02-PU001: Dodanie wydarzenia

### M02-PU002: Edycja wydarzenia

### M02-PU003: Usunięcie wydarzenia

## M03: Interakcje między użytkownikami

### M03-PU001: Wysłanie zaproszenia do znajomych

### M03-PU002: Akceptacja zaproszenia do znajomych

### M03-PU003: Odrzucenie zaproszenia do znajomych

### M03-PU004: Usunięcie znajomego

### M03-PU005: Zablokowanie użytkownika

### M03-PU006: Odblokowanie użytkownika

Aktor: `użytkownik`

Opis:
1. Użytkownik przechodzi do profilu zablokowanego użytkownika  
2. Użytkownik wybiera opcję odblokowania zablokowanego użytkownika
3. System odblokowuje możliwość kontaktu oraz wyświetlenia profilu oraz informuje o powodzeniu operacji

### M03-PU007: Wysłanie wiadomości do znajomego

Aktor: `użytkownik`

Opis:
1. Użytkownik otwiera rozmowę ze znajomym poprzez wybór znajomego z listy znajomych
2. Użytkownik wysyła nową wiadomość w rozmowie ze znajomym

### M03-PU008: Utworzenie czatu wydarzenia

Aktor: `użytkownik`

Opis:
1. Użytkownik organizujący wydarzenie otwiera czat wydzrzenia
2. Użytkownicy zapisani na wydarzenie dostają powiadomienie o otwarciu czatu wydarzenia

### M03-PU009: Utworzenie grupy użytkowników

Aktor: `użytkownik`

Opis:
1. Użytkownik podaje nazwę oraz tematykę grupy
2. Użytkonik wybiera użytkoników zapraszanych do grupy
3. Uzytkownik tworzy grupę
3. Zaproszeni użytkownicy dostają powiadomienie o utworzeniu grupy i otrzymaniu zaproszenia

### M03-PU010: Edycja grupy użytkowników

Aktor: `użytkownik`

Opis:
1. Użytkownik posiadający uprawnienia do edycji grupy przechodzi do panelu zarządzania grupą
2. Użytkonik edytuje grupę poprzez
    - edycję nazwy grupy
    - edycję temtyki grupy
    - zaproszenienowych członków grupy
    - usunięcie członków grupy
    - zmianę uprawnień członków grupy

### M03-PU011: Usunięcie grupy użytkowników
Aktor: `użytkownik`

Opis:
1. Użytkownik posiadający uprawnienia do edycji grupy przechodzi do panelu zarządzania grupą
2. Uzytkownik usuwa grupę

## M04: Feed

### M04-PU001: Wyświetlenie feed-u wydarzeń

Aktor: 

Opis: 

- filtr daty
- w obrębie grupy
- w zadanej lokalizacji

### M04-PU002: Wyrażenie chęci uczestnictwa w wydarzeniu

Aktor: Użytkownik

Opis: 

### M04-PU003: Wyrażenie braku chęci uczestnictwa w wydarzeniu

Aktor: Użytkownik

Opis: 

## M05: Administracja

### M05-PU001: Dodawany systemowo

Aktor: System

Opis: Domyślny administrator dodawany jest przez system podczas inicjalizacji aplikacji, jeśli nie istnieje.

### M05-PU002: 