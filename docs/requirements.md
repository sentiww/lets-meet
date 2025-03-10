# Wymagania

## Wymagania funkcjonalne

### WF-001: Rejestracja użytkownika

Użytkownik musi mieć możliwość zarejestrowania się w systemie poprzez wypełnienie formularza (login, hasło, imię, nazwisko, i data urodzenia). System powinien potwierdzić udaną rejestrację lub wyświetlić komunikat o błędzie.

### WF-002: Logowanie użytkownika
Użytkownik musi mieć możliwość podania informacji (login,hasło) potrzebnych do zalogowania na wybrane przez niego konto.
System w razie potrzeby powinien poinformować o niepoprawnych danych logowania jak i przekierować użytkownika do aplikacji w przypadku podania poprawnych danych.

### WF-003: Wyświetlenie profilu użytkownika
Użytkownik powinien posiadać opcje zobaczenia wybranego przez niego profilu użytkownika,
takich jak znajomi, organizatorzy, uczestnicy wydarzeń czy on sam.
Do danych tych zaliczają się zdjęcie profilowe, imię, nazwisko oraz data urodzenia.

### WF-004: Edycja profilu użytkownika
Użytkownik powinien posiadać możliwość edycji danych profilu identyfikowalnych przez jego login.
Do danych tych zaliczają się zdjęcie profilowe, imię, nazwisko oraz data urodzenia.
Proces edycji powinien się odbywać w miejscu w którym użytkownik wyświetla informacje o swoim koncie.

### WF-005: Dodanie wydarzenia
Zalogowany użytkownik musi mieć możliwość dodania nowego wydarzenia do systemu. Formularz dodawania wydarzenia powinien zawierać pola: tytuł, opis, data i godzina, miejsce oraz opcjonalnie dodatkowe informacje. Po poprawnym wypełnieniu formularza system powinien zapisać wydarzenie i wyświetlić potwierdzenie. W przypadku błędnych lub brakujących danych system powinien poinformować użytkownika o konieczności ich poprawienia.

### WF-006: Edycja wydarzenia
Zalogowany użytkownik musi mieć możliwość edytowania wcześniej dodanych przez siebie wydarzeń. Powinien móc zmieniać wszystkie informacje dotyczące wydarzenia, takie jak tytuł, opis, data, godzina i miejsce. Po zapisaniu zmian system powinien potwierdzić sukces edycji lub wyświetlić komunikat o błędzie, jeśli wprowadzone dane są niepoprawne.

### WF-007: Usunięcie wydarzenia
Zalogowany użytkownik musi mieć możliwość usunięcia wydarzenia, które dodał. Po wybraniu opcji usunięcia system powinien zapytać użytkownika o potwierdzenie tej operacji. Po zatwierdzeniu system powinien usunąć wydarzenie i poinformować użytkownika o sukcesie operacji. W przypadku błędu system powinien wyświetlić stosowny komunikat.

### WF-008: Interakcje między użytkownikami

Zalogowani użtkownicy muszą mieć możliwość zablokowania interakcji między sobą oraz wskazanymi użytkownikami. Zalogowani użtkownicy muszą mieć możliwość zaproszenia innych użytkowników do grona znajowmych.

### WF-009: Wysyłanie wiadomości

Zalogowany użytkownik musi mieć możliwość wysłania wiadomości użytkownikom, którzy go nie zablokowali.

### WF-010: Tworzenie czatu wydarzenia

Użytkownik będący organizatorem musi mieć możliwość stworzenia catu wydarzenia, w którym uczastnicy wydarzenia będą mogli komunikować się między sobą oraz z organizatorem.

### WF-011: Tworzenie i zarządzanie grupami

System powinien dopuszczać możliwość tworzenia grup o określonej tematyce
i nazwie między użytkownikami. W ramach grupy użytkownicy mogliby organizować
określone wydarzenia i czatować. Założyciel grupy, a także osoby o odpowiednich
uprawnieniach mogą edytować listęczłonków, ich uprawnienia, czy tematykę.

### WF-012: Feed wydarzeń

Użytkownik powinien w czytelny sposób móc przeglądać, a także wybierać
interesujące go wydarzenia oraz odrzucaćte, w których nie chce brać udziału.
System powinien wyświetlać użytkownikowi po kolei dostępne wydarzenia,
uwzględniając ewentualne określone przez niego filtry takie jak data, lokalizacja,
grupa, czy ograniczenie tylko do wydarzeń znajomych.

### WF-013: Zarządzanie treściami przez administratora

Administrator musi mieć możliwość zarządzania treściami na platformie,
aby ograniczać te nieodpowiednie, czy blokować użytkowników łamiących
regulamin użytkowania aplikacji. W tym celu system musi udostępniać mu odpowiedni
widok z listą wydarzeń oraz użytkowników i możliwością moderowania - usuwania
wydarzeń, grup, czy blokowania - czasowego lub trwałego - regularnych użytkowników.

## Wymagania niefunkcjonalne

### WNF-001: Wydajność

System powinien obsługiwać do 100 jednoczesnych użytkowników bez zauważalnego spadku
wydajności. Czas odpowiedzi serwera na żądania użytkowników nie powinien przekraczać
2 sekund w warunkach normalnego obciążenia. Baza danych powinna być zoptymalizowana
pod kątem wydajności, na przykład poprzez stosowanie indeksów.

### WNF-002: Dostępność

System powinien być dostępny dla użytkowników przez całą dobę, siedem dni w tygodniu.
W przypadku awarii czas przywrócenia działania systemu nie powinien przekraczać 2 godzin.

### WNF-003: Bezpieczeństwo

Dostęp do systemu powinien być zabezpieczony poprzez mechanizm autoryzacji
i uwierzytelniania użytkowników. Wszystkie hasła użytkowników powinny być przechowywane
w postaci zaszyfrowanej. System powinien być odporny na najczęstsze ataki, takie jak SQL Injection,
a dane przesyłane między użytkownikami a serwerem powinny być szyfrowane protokołem HTTPS.

### WNF-004: Skalowalność

System powinien umożliwiać łatwe dodawanie nowych funkcjonalności bez konieczności gruntownej
przebudowy architektury. Architektura powinna wspierać podział obciążenia na wiele serwerów,
co pozwoli na skalowanie systemu w miarę wzrostu liczby użytkowników.

### WNF-005: Interoperacyjność

System powinien umożliwiać integrację z zewnętrznymi usługami poprzez API, a wymiana danych
powinna odbywać się w standardowych formatach, takich jak JSON lub XML.

### WNF-006: Użyteczność

Interfejs użytkownika powinien być intuicyjny i zgodny z zasadami UX/UI. System powinien być dostępny
na różnych urządzeniach, takich jak komputery stacjonarne, tablety i smartfony. Wszystkie istotne funkcje
powinny być dostępne maksymalnie w trzech kliknięciach, co zwiększy wygodę użytkowania.

### WNF-007: Zgodność z przepisami

System powinien być zgodny z obowiązującymi regulacjami dotyczącymi ochrony danych osobowych,
takimi jak RODO. Wszelkie działania użytkownika powinny być logowane w systemie w celu audytu
i zgodności z politykami bezpieczeństwa.

### WNF-008: Backup danych

System powinien automatycznie wykonywać kopie zapasowe danych co 24 godziny, a kopie te powinny być
przechowywane przez co najmniej 30 dni, co zapewni ochronę przed utratą danych.