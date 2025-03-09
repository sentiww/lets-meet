# Technologie

Wybór poszczególnych technologii w projekcie oparty jest na ich zaletach, które najlepiej odpowiadają na potrzeby projektu. Poniżej przedstawione zostało uzasadnienie dla każdej z wybranych technologii.

## Frontend

### Blazor WASM 

Blazor WASM (WebAssembly) to technologia umożliwiające pisanie aplikacji frontendowych w języku C# zamiast w języku JavaScript. Pozwala na prostą integrację z ekosystemem .NET, co pozwala na wykorzystanie wspólnego kodu zarówno po stronie klienta, jak i serwera. Projekt zakłada współdzielenie kontraktu REST API przez backend i frontend.

### nginx

nginx został wybrany jako serwer WWW ze względu na swoją wysoką wydajność, niskie zużycie zasobów oraz elastyczność w konfiguracji. Serwer WWW wymagany jest do hostowania aplikacji frontendowej oraz serwowania statycznych zasobów.

## Backend

### .NET 9

Platforma .NET umożliwia tworzenie skalowalnych, łatwych w utrzymaniu i wydajnych aplikacji. Platforma ta posiada duże wsparcie w zakresie integracji z różnymi bazami danych, systemami i protokołami, a także oferuje solidne wsparcie dla nowoczesnych praktyk programistycznych, takich jak Dependency Injection i asynchroniczność.

## Baza danych

### PostgreSQL

PostgreSQL jest jedną z najpopularniejszych i najbardziej rozbudowanych relacyjnych baz danych. Dzięki swojej niezawodności, elastyczności oraz bogatym funkcjom, PostgreSQL jest idealnym wyborem do przechowywania i przetwarzania danych w aplikacjach o dużej skali.

## DevOps

### Docker

Docker został wybrany jako narzędzie do konteneryzacji w projekcie. Konteneryzacja pozwala na stworzenie przenośnego środowiska, które działa identycznie na różnych maszynach, niezależnie od systemu operacyjnego.