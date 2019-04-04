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
Scenariusz: Obsługujemy oddział
ortopedyczny w szpitalu
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
