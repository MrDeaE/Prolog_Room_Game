/*
 * legenda do mapy:
 * b - biurko, sz - szafa, f - fotel
 * l - łóżko, k - kanapa, s - stół
 * d - drzwi - nie są traktowane jako 'przeszkoda'
 * 
 * mapa:
 *  b b b sz d sz
 *  f - - - - sz
 *  - - - s - k
 *  l l - s - k
 *  l l - - - k
 *  l l sz k k k
 * 
 * Możliwe akcje:
 * -przemieszczanie się używając move_<kierunek>, np. move_up
 * -chodzenie z góry ustaloną ścieżkę od drzwi do łóżka (path_to_bed_from_door) - 'teleportuje' to nas na początku do drzwi
 * -włączanie i wyłączanie światła - turn_on_light, turn_off_light (zakładam, że przycisk znajduje się tuż obok drzwi, więc trzeba być na (5, 1))
 * -sprawdzenie czy kubek jest na biurku i go tam polozyc lub zabrać: czy_jest_kubek_na_biurku, zabierz_kubek_z_biurka, poloz_kubek_na_biurku
 * -rozglądanie się dookoła czego się znajdujemy - look_around
 * -sprawdzenie, czy na dwóch różnych kratkach znajduje się taki sam przedmiot, np. czy na 1,1 i 2,1 jest cały czas biurko - check_if_the_same(X1, Y1, X2, Y2)
 */
:- style_check(-singleton).
:- use_module(library(lists)).
:- dynamic current_position/2.
:- dynamic day/1. /* 0 - zgaszone, 1 - włączone */
:- dynamic light/1. /* 0 - noc, 1 - dzień */
:- dynamic biurko/1.

/* początkowe wartości */
current_position(5, 2).
day(0).
light(1).

print_location :-
    current_position(X, Y),
    write('position: '), write(X), write(' '), write(Y), nl.

/* przedmioty w pokoju: X, Y, nazwa */
blocked(1, 1, biurko). blocked(2, 1, biurko). blocked(3, 1, biurko). 
blocked(4, 1, szafa). blocked(6, 1, szafa). blocked(1, 2, fotel). 
blocked(6, 2, szafa). blocked(4, 3, stół). blocked(6, 3, kanapa). 
blocked(1, 4, łóżko). blocked(2, 4, łóżko). blocked(4, 4, stół). 
blocked(6, 4, kanapa). blocked(1, 5, łóżko). blocked(2, 5, łóżko). 
blocked(6, 5, kanapa). blocked(1, 6, łóżko). blocked(2, 6, łóżko). 
blocked(3, 6, szafka_nocna). blocked(4, 6, kanapa). blocked(5, 6, kanapa). 
blocked(6, 6, kanapa).

move_left :- 
    current_position(X, Y),
    X2 is (X-1),
    check_blocked(X2, Y),
    check_wall(X2, Y),
    retract(current_position(X, Y)),
    assert(current_position(X2, Y))
    -> write('moving left to '), print_location, nl, true;
    write('not moving'), nl, false.

move_right :- 
    current_position(X, Y),
    X2 is (X+1),
    check_blocked(X2, Y),
    check_wall(X2, Y),
    retract(current_position(X, Y)),
    assert(current_position(X2, Y))
    -> write('moving right to '), print_location, nl, true;
    write('not moving'), nl, false.

move_down :- 
    current_position(X, Y),
    Y2 is (Y+1),
    check_blocked(X, Y2),
    check_wall(X, Y2),
    retract(current_position(X, Y)),
    assert(current_position(X, Y2))
    -> write('moving down to '), print_location, nl, true;
    write('not moving'), nl, false.

move_up :- 
    current_position(X, Y),
    Y2 is (Y-1),
    check_blocked(X, Y2),
    check_wall(X, Y2),
    retract(current_position(X, Y)),
    assert(current_position(X, Y2))
    -> write('moving up to '), print_location, nl, true;
    write('not moving'), nl, false.

check_position(X, Y) :-
    current_position(X1, Y1),
    X1=:=X,
    Y1=:=Y
    -> write('in position'), nl, true;
    write('not in position'), nl, !, false.

check_wall(X, Y) :- 
    X >= 1,
    X =< 6,
    Y >= 1,
    Y =< 6
    -> write('no wall'), nl, !, true;
    write('wall'), nl, false.

check_blocked(X, Y) :-
    blocked(X1, Y1, Name),
    X1=:=X,
    Y1=:=Y
    -> write(blocked(X1, Y1, Name)), nl, !, false;
    write('pusta przestrzeń'), nl, true.

path_to_bed_from_door :-
 	retract(current_position(X, Y)),
    assert(current_position(5, 1)),
    move_down,
    move_left,
    move_left,
    move_down,
    move_down,
    move_down,
    write('doszedles do lozka, '), print_location, nl, true.
   
check_day :-
    day(X),
    X=:=0
    ->  write('jest noc'), nl, !, false;
    write('jest dzień'), nl, true.

check_light :-
    light(X),
    X=:=0
    ->  write('światło zgaszone'), nl, !, false;
    write('światło włączone'), nl, true.

turn_on_light :-
	check_day
    -> write('jest dzień, nie ma potrzeby włączać światła'), nl, !, false;
    write('jest noc, możesz zapalić światło'), nl, true;
    check_light
    ->  write('światło już zapalone'), nl, !, false;
    write('światło zgaszone, możesz je włączyć'), nl, true;
    check_position(5, 1), /* sprawdzanie czy jesteśmy przy włączniku */
    light(X),
    retract(light(X)),
    assert(light(1)),
    check_light.

turn_off_light :-
    check_light,
    check_position(5, 1), /* sprawdzanie czy jesteśmy przy włączniku */
    light(X),
    retract(light(X)),
    assert(light(0)),
    check_light.

szafa(ksiazka1, ksiazka2, ksiazka3). /* terma zlożona */

/* listy */
biurko([klawiatura, glosniki, monitor]). /* lista rzeczy na biurku */

czy_jest_kubek_na_biurku :-
    member(kubek, biurko)
    -> write('nie ma tu kubka'), nl, !, false;
    write('kubek jest na biurku'), nl, true.

zabierz_kubek_z_biurka :-
    biurko(Lista1),
    czy_jest_kubek_na_biurku,
    delete(Lista1, kubek, Lista2),
    retract(biurko(Lista1)),
    assert(biurko(Lista2))
    ->  write('zabrano kubek z biurka'), nl, !, true;
        !,false.

poloz_kubek_na_biurku :-
    biurko(Lista1),
    czy_jest_kubek_na_biurku,
    retract(biurko(Lista1)),
    assert(biurko([kubek, klawiatura, glosniki, monitor]))
    -> write('nie polozono kubka'), nl, !,false;
    write('polozono kubek na biurko'), nl, !, true.


/* związki przestrzenne */
check_blocked_to_look(X, Y) :-
    blocked(X1, Y1, Name),
    X1=:=X,
    Y1=:=Y
    -> write(Name), nl;
    write('pusta przestrzeń'), nl, true.

look_around :-
	current_position(X, Y),
	XL is X-1,
	XR is X+1,
	YU is Y-1,
	YD is Y+1,
	write('Przedmioty dookoła:'), nl,
	write('Lewo: '), 
    check_blocked_to_look(XL, Y),
    write('Lewo Góra: '), 
    check_blocked_to_look(XL, YU),
    write('Góra: '), 
    check_blocked_to_look(X, YU),
    write('Prawo Góra: '), 
    check_blocked_to_look(XR, YU),
    write('Prawo: '), 
    check_blocked_to_look(XR, Y),
    write('Prawo Dół: '), 
    check_blocked_to_look(XR, YD),
    write('Dół: '), 
    check_blocked_to_look(X, YD),
    write('Lewo Dół: '), 
    check_blocked_to_look(XL, YD).

check_if_the_same(X1, Y1, X2, Y2) :-
	blocked(X1, Y1, Name1),
    blocked(X2, Y2, Name2),
	Name1=Name2 /* unifikacja */
    -> write('Taki sam obiekt'), nl, true;
    write('Inny obiekt'), nl, !, false.
    

