## Distributed Systems Directory

lab1 - sockets
```
Celem zadania jest napisanie aplikacji w języku C lub C++ (lub python, ale uwaga na punktację!), która pozwoli użytkownikom na przesyłanie (nadawanie i wyświetlanie) informacji bez wykorzystania serwera centralnego poprzez logiczną symulację architektury token ring. Każdy klient podczas uruchomienia otrzymuje cztery argumenty:

    tekstowy identyfikator użytkownika,
    port na którym dany klient nasłuchuje,
    adres IP i port sąsiada, do którego przekazywane będą wiadomości,
    informacja o tym, czy dany użytkownik po uruchomieniu posiada token,
    wybrany protokół: tcp lub udp.

Wiadomości przekazywane są tylko w jedną stronę. W sieci znajduje się tylko jeden token i żadna aplikacja nie może nadawać dopóki nie otrzyma wolnego tokenu, pierwotnie token jest wolny. 
Wysłanie wiadomości polega na zajęciu tokenu i wpisaniu jej zawartości. Token traktujemy jako kopertę, nośnik wiadomości. Odbiorca po przeczytaniu wiadomości zwalnia token (flaga, wyczyszczenie zawartości...) i przekazuje go dalej.
Dla celów symulacyjnych przyjmujemy, że token jest przetrzymywany przez każdego klienta przez około 1 sekundę (po otrzymaniu tokenu wywołujemy np. sleep(1000), po tym czasie przesyłamy go dalej po ewentualnym dodaniu wiadomości).
Dla uproszczenia zakładamy, że żaden klient nie będzie "złośliwy" i nie doprowadzi do sytuacji, w której w sieci znajdą się dwa tokeny - jednak za implementację mechanizmu, który to wyklucza, zostanie przyznany bonus punktowy.
Program ma umożliwiać dodawanie nowych użytkowników w trakcie działania systemu oraz zapewniać dla nich pełną funkcjonalność, a także zabezpieczać przed sytuajcą, w której wiadomość krąży w nieskończoność w sieci (należy odpowiednio przemyśleć protokół komunikacyjny).
Dodatkowo, każdy klient ma przesyłać multicastem informację o otrzymaniu tokenu (na dowolny adres grupowy, wspólny dla wszystkich klientów - może być wpisany "na sztywno" w kod).
Odbiorcami grupy multicastowej są wyłącznie loggery - proste aplikacje zapisujące ID nadawcy i timestamp otrzymania tokenu, do pliku. Ilość loggerów może być dowolna (co najmniej 2). Logger należy zaimplementować w języku innym niż klientów. 
```
lab2 - Distributed map using jgroup for communication
```
Celem zadania jest implementacja rozproszonej tablicy haszującej. Aplikacje z niej korzystające powinny mieć możliwość dodawania elementów do tablicy i jednocześnie pobierania elementów wcześniej dodanych, być może również przez inne aplikacje.

W wyniku realizacji zadania powinna powstać implementacja klasy DistributedMap, implementująca interfejs:

public interface SimpleStringMap {
    boolean containsKey(String key);

    Integer get(String key);

    void put(String key, Integer value);

    Integer remove(String key);
}

 

Powinna też zostać opracowana przykładowa aplikacja korzystająca z rozproszonej tablicy haszującej. Funkcjonalność aplikacji powinna umożliwiać interaktywną interakcję i eksponować metody zawarte w interfejsie implementowanej tablicy.
Własności rozproszonej tablicy

Uwzględniając teorię CAP , implementacja rozwiązania powinna cechować się dostępnością i tolerowaniem partycjonowania.

W związku z tym każda instancja klasy DistributedMap powinna mieć własną kopię tablicy rozproszonej, a uspójnianie stanu powinno być zrealizowana podczas operacji dodawania elementów do tablicy. Do rozproszonej komunikacji pomiędzy instancjami należy wykorzystać bibliotekę JGroups:

    w przypadku tworzenia nowej instancji klasy DistributedMap, powinna ona pozyskać początkowy stan od członków grupy, do której dołącza,
    w przypadku podziału grupy węzłów na dwie partycje, powinny one utrzymywać swój stan niezależnie; w przypadku ponownego scalania dwóch partycji, członkowie jednej z partycji powinni stracić swój stan i pozyskać go na nowo od członków drugiej z partycji.

```
lab3 - RabbitMQ
```
Scenariusz: Obsługujemy oddział ortopedyczny w szpitalu
• Mamy 3 typy użytkowników:
– Lekarz (zleca badania, dostaje wyniki)
– Technik (wykonuje badania, wysyła wyniki)
– Administrator (loguje całą aktywność, może wysyłać informacje do wszystkich)
• Szpital przyjmuje pacjentów z kontuzjami:
– Biodra (hip), kolana (knee) lub łokcia (elbow)

• Lekarz:
– Wysyła zlecenie badania podając typ badania (np. knee) oraz nazwisko pacjenta, do dowolnego technika, który umie wykonać takie badanie
– Otrzymuje wyniki asynchronicznie

• Technik
– Każdy technik umie wykonać 2 typy badań, które podawane są przy starcie (np. knee, hip)
– Przyjmuje zgłoszenia danego typu i odsyła wyniki do lekarza zlecającego (wynik to nazwa pacjenta + typ badania + „done”)
– Uwaga: jeśli jest dwóch techników z tym samym typem badania (np. knee) to wiadomość powinna być obsłużona tylko przez jednego (ale nie zawsze tego samego)

• Administrator
– Loguje całą aktywność (dostaje kopie wszystkich wiadomości – zleceń oraz odpowiedzi)
– Ma możliwość przesłania wiadomości (info) do wszystkich
```
lab4 - Middleware
```
Aplikacja obsługi kont bankowych

Opis funkcjonalności

Celem zadania jest stworzenie aplikacji do obsługi kont bankowych o następującej funkcjonalności

    obsługa kont typu Standard i Premium,
    nowe konto jest tworzone na podstawie podstawowych danych (imię, nazwisko, PESEL (stanowiący identyfikator klienta), deklarowany próg miesięcznych wpływów) - na bazie tej ostatniej informacji bank decyduje, czy konto będzie typu Standard czy Premium i powiadamia o tym klienta.
    autoryzacja dostępu do konta bankowego następuje w sytuacji każdorazowego podania poprawnego identyfikatora PESEL oraz klucza (hasła) który jest jednorazowo zwracany klientowi w momencie tworzenia konta (nie ma zatem pojęcia sesji z fazami logowania się i wylogowania z banku),
    użytkownik konta Premium może się starać o uzyskanie kredytu  w podanej przez siebie i  obsługiwanej przez bank walucie, żądanej kwocie i na zadany okres czasu. Bank  przedstawia całkowite koszty udzielenia pożyczki w wyrażone w walucie obcej oraz walucie rodzimej. Koszty powinny być skorelowane z aktualnym rynkowym kursem walut - o czym informuje Bank osobna usługa.
    użytkownik każdego typu konta może uzyskać informacje o jego aktualnym stanie (na potrzeby zadania ta funkcjonalność jest wystarczająca).

W aplikacji można więc wyróżnić trzy elementy: 
1. usługa informująca banki o aktualnym kursie walut, 
2. bank, 
3. klient banku.

Realizacja

Usługa informująca o aktualnym kurcie walut natychmiast po podłączeniu się jej klienta (czyli banku) przesyła kursy walut wszystkich wyspecyfikowanych przez Bank w walucie rodzimej,
 a później okresowo i niezależnie dla różnych walut informuje o zmianach ich kursów (symulując te zmiany). 
Różne banki mogą być zainteresowane różnymi walutami - usługa powinna to brać pod uwagę.  Komunikację pomiędzy bankiem a usługą należy zrealizować z wykorzystaniem gRPC i mechanizmu strumieniowania (stream), a nie pollingu. 
Kurs walut powinien się nieco wahać zmieniając dość często (np. co 5 sekund) by móc zaobserwować działanie usługi w czasie demonstracji zadania. Zbiór obsługiwanych walut jest zamknięty (enum).

Komunikację między klientem banku a bankiem należy zrealizować z wykorzystaniem ICE albo Thrift.

Realizując komunikację w ICE należy zaimplementować konta klientów jako osobne obiekty ICE tworzone przez odpowiednie factory (choć w przypadku tego zadania wielość obiektów nie znajduje uzasadnienia z inżynierskiego punktu widzenia) i rejestrowane w tablicy ASM z nazwą będącą wartością PESEL klienta i kategorią "standard" albo "premium" (para ta pozwala na uzyskanie referencji do obiektu konta). 
Klucz dostępowy powinien być przesyłany przez klienta jako kontekst wywołania operacji (dodatkowy, pozainterfejsowy argument wywołania „wyjmowany” z __current.ctx po stronie serwanta) by nie „psuć” elegancji interfejsu. Klient musi mieć możliwość korzystania ze swojego konta w dowolnym czasie, także po restarcie aplikacji (czyli przechowywanie w pamięci referencji nowoutworzonego obiektu nie może być jedynym sposobem uzyskania dostępu do konta).

Realizując komunikację z wykorzystaniem Thrift należy stworzyć trzy osobne usługi - zarządzająca (tworzenie kont), obsługująca wszystkie konta typu Standard i obsługująca wszystkie konta Premium. 
Pierwsza z tych usług powinna działać na innym porcie niż dwie pozostałe, które muszą używać tego samego numeru portu. 
Przy dostępie do konta, jego identyfikator konta stanowi dodatkowy argument wywołania usługi, natomiast klucz nie jest przesyłany wprost – zamiast niego jest przesyłany skrót kryptograficzny  (np. MD5) w taki sposób, by nawet podsłuchanie wiadomości uniemożliwiło niepowołanym na ustanowienie poprawnej komunikacji z usługą (por. np. uwierzytelnianie w RIPv2).

Aplikacja kliencka powinna mieć postać tekstową i może być minimalistyczna, lecz musi pozwalać na przetestowanie funkcjonalności aplikacji szybko i na różny sposób (musi więc być przynajmniej w części interaktywna). 
W szczególności powinno być możliwe łatwe przełączanie się pomiędzy kontami użytkownika (bez konieczności restartu aplikacji klienckiej).

Interfejs IDL powinien być prosty, ale zaprojektowany w sposób dojrzały (odpowiednie typy proste, właściwe wykorzystanie typów złożonych), uwzględniając możliwość wystąpienia różnego rodzaju błędów. 
Tam gdzie to możliwe należy wykorzystać dziedziczenie interfejsów IDL.

Stan usługi bankowej nie musi być persystowany (nie musi przetrwać restartu).

Do realizacji zadania należy wykorzystać przynajmniej dwa różne języki programowania.

Pliki generowane (stub, skeleton) powinny się znajdować w osobnym katalogu niż kod źródłowy klienta i serwera. Pliki stanowiące wynik kompilacji (.class, .o itp) powinny być w osobnych katalogach niż pliki źródłowe.

Dla chętnych: wielowątkowość implementacji strony serwerowej usługi bankowej.
```
lab5 - Akka
```
Obsługujemy księgarnię internetową

Umożliwia ona 3 typy operacji:

    Wyszukiwanie pozycji (zwraca cenę lub informację o braku pozycji)
    Zamówienie pozycji (zwraca potwierdzenie zamówienia)
    Strumieniowanie tekstu książki – z prędkością jednej linijki (lub zdania) na sekundę

Założenia:

    Klient posiada aplikację (konsolową) opartą o platformę Akka
    Serwer to pojedyncza maszyna, z dużą ilością zasobów (ale nie nieskończoną)
    Chcemy być w stanie obsłużyć jak najwięcej klientów równolegle (na jednym serwerze)
    Chcemy zminimalizować czasy odpowiedzi systemu
    Chcemy zminimalizować ilość danych przesyłanych przez sieć (należy unikać przesyłania wszystkich wiadomości jako String)

Wyszukiwanie pozycji:

    Należy przeszukać dwie bazy danych
    Każda baza danych ma postać pliku tekstowego (jedna linia -> jeden tytuł + cena)
    Zakładamy, że jedna lub obie bazy mogą być czasowo niedostępne
    Zakładamy, że wyszukiwanie w bazie może być czasochłonne (należy przeszukiwać obie bazy równolegle)
    Jeśli jakaś pozycja jest w obu bazach to ma tę samą cenę

Zamówienie pozycji

    Następuje przez: zapisanie nowej linii z tytułem (bez ceny) do pliku orders.txt, który stanowi bazę zamówień oraz wysłanie potwierdzenia do klienta
    Należy zwrócić uwagę na synchronizację dostępu do pliku (bazy)

Strumieniowanie tekstu

    Klient wysyła tytuł, serwer odpowiada strumieniem linii lub zdań z pliku o tej nazwie
    Jedna linia(lub zdanie) na sekundę (throttle)

Obsługa błędów

    Należy zastosować odpowiednie strategie obsługi błędów

Schemat

    Należy przygotować schemat w wersji elektronicznej
    Schemat powinien zawierać zaproponowaną strukturę aktorów wraz ze wskazaniem ich cyklu życia (stały/tymczasowy, strategia obsługi błędów)
```
