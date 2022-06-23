/* HTL Escape, by Horvath Lorenz and Lawrence Federsel. */

:- dynamic i_am_at/1, at/2, holding/1, steps/1.
:- retractall(at(_, _)), retractall(i_am_at(_)), retractall(alive(_)), retractall(holding(_)).

holding([]).

/*north hallway paths */ 
path(nhallway, e, classRoom).
path(classRoom, w, nhallway).


path(nhallway, n, deptOffice) :- holding(X), member(masterKey, X).
path(deptOffice, s, nhallway).

path(nhallway, s, auditorium).
path(auditorium, n, nhallway).

path(nhallway, w, storage_room).
path(storage_room, e, nhallway).

/*north hallway path end */

/*south hallway path */

path(shallway, n, auditorium).
path(auditorium, s, shallway).

path(shallway, e, physicsroom).
path(physicsroom, w, shallway).

path(shallway, w, cafeteria).
path(cafeteria, e, shallway).

path(shallway, s, karpowiczOffice).

path(cafeteria, w, cafeteria_backroom) :- has_functioning_flashlight.
path(cafeteria_backroom, e, cafeteria).

/*south hallway path end */

path(auditorium, e, schoolExit) :- holding(X), member(masterKey, X).

at(flashlight, storage_room).
at(pack_of_batteries, physicsroom).
at(dropoutForm, deptOffice).
at(masterKey, cafeteria_backroom).


/* These rules describe how to pick up an object. */

take(flashlight) :- not(has_flashlight),
        write("The flashlight has no batteries, so it wont work."), nl,
        write("You should search for batteries."),nl, 
        fail.

take(X) :-
        holding(Y), member(X, Y),
        write("You're already holding it!"),
        !, nl.

take(X) :-
        i_am_at(Place),
        at(X, Place),
        retract(at(X, Place)),
        holding(Y),
        append(Y, [X], NewList),
        retractall(holding(_)),
        assert(holding(NewList)),
        write("OK."),
        !, nl.
take(_) :-
        write("I don't see it here."),
        nl.

/* These rules define the direction letters as calls to go/1. */

n :- go(n).

s :- go(s).

e :- go(e).

w :- go(w).


/* This rule tells how to move in a given direction. */

go(_) :- steps(15),
         write("Sunrise is nearing."), nl, 
         fail.

go(Direction) :-
        i_am_at(Here),
        path(Here, Direction, There),
        decrement_step,
        not(steps(0)),
        retract(i_am_at(Here)),
        assert(i_am_at(There)),
        !, look.

go(n) :- i_am_at(nhallway), 
         write("The door is locked. Seems like you need a key."),
         decrement_step.

go(_) :- steps(0),
         write("Its morning, Haxipopaxi found you and reported you to the headmaster."),
         write("You wasted too much time."),
         write("You failed."),
         die.

go(_) :- write("You can't go that way.").

decrement_step :-
        steps(OldSteps), 
        NewSteps is OldSteps-1,
        retractall(steps(_)),
        assert(steps(NewSteps)).

/* This rule tells how to look about you. */

look :-
        i_am_at(Place),
        describe(Place),
        nl,
        notice_objects_at(Place),
        nl.


/* These rules set up a loop to mention all the objects
   in your vicinity. */

notice_objects_at(physicsroom) :-
        at(X, physicsroom),
        write("There is a "), write(X), write(" here."), nl,
        fail.

notice_objects_at(storage_room) :-
        at(X, storage_room),
        write("There is a "), write(X), write(" here."), nl,
        fail.

notice_objects_at(Place) :-
        has_functioning_flashlight,
        at(X, Place),
        write("There is a "), write(X), write(" here."), nl,
        fail.
        
notice_objects_at(_) :- not(has_functioning_flashlight), not_in_lit_room, write("It's too dark to see anything! A functioning flashlight would be useful.").
notice_objects_at(_).

not_in_lit_room:- not(i_am_at(physicsroom)),not(i_am_at(storage_room)).

has_flashlight :- holding(X), member(flashlight, X).

has_functioning_flashlight :- holding(X), has_flashlight, member(pack_of_batteries, X).




/* This rule tells how to die. */
die :-
        finish.


/* Under UNIX, the "halt." command quits Prolog but does not
   remove the output window. On a PC, however, the window
   disappears before the final output can be seen. Hence this
   routine requests the user to perform the final "halt." */

finish :-
        nl,
        write("The game is over. Please enter the 'halt.' command."),
        nl.


/* This rule just writes out game instructions. */

instructions :-
        nl,
        write("Enter commands using standard Prolog syntax."), nl,
        write("Available commands are:"), nl,
        write("start.             -- to start the game."), nl,
        write("n.  s.  e.  w.     -- to go in that direction."), nl,
        write("take(Object).      -- to pick up an object."), nl,
        write("look.              -- to look around you again."), nl,
        write("instructions.      -- to see this message again."), nl,
        write("halt.              -- to end the game and quit."), nl,
        write("inventory.         -- to list all the elements in your inventory press Space after every element to see the next."), nl,
        nl.


/* This rule prints out instructions and tells where you are. */

start :-
        assert(steps(25)),
        assert(i_am_at(classRoom)),
        instructions,
        intro.

inventory :- holding(X), not(proper_length(X, 0)), write(X).

intro :- write("You wake up in a dark classroom in HTL Leonding at night."), nl,
         write("You want to escape from the school before sunrise so you don't get caught and can get home safely."), nl,
         write("You can see a small glimmer of light coming from the hallway to the west."), nl, nl,
         notice_objects_at(classRoom).

         
/* These rules describe the various rooms.  Depending on
   circumstances, a room may have more than one description. */

/* north hallway descriptions */

describe(classRoom) :- write("You are in your classroom"), nl,
                       write("To the west is the north hallway."), nl.                      

describe(nhallway) :-  write("You are in the north hallway."), nl,
                       write("To the north is the head of department's office."), nl,
                       write("To the south is the auditorium."), nl,
                       write("There seems to be some light coming from the storage room in the west."), nl,
                       write("Your classroom is to the east."), nl.

describe(deptOffice) :- write("You are in the head of department's office."), nl,
                        write("To the south is the north hallway."), nl.

describe(storage_room) :- write("You are in the well lit storage room."), nl,
                          write("To the east is the north hallway."), nl.


/* end of north hallway descriptions */

/* south hallway descriptions */


describe(physicsroom) :-  has_functioning_flashlight,
                          write("You are in the physicsroom."), nl,
                          write("There is a small lamp now without batteries in it on the teachers table."), nl,
                          write("The south hallway is to the west."), nl.

 describe(physicsroom) :- write("You are in the physicsroom."), nl,
                          write("There is a small lamp with batteries in it on the teachers table."), nl,
                          write("The south hallway is to the west."), nl.

describe(shallway) :- has_functioning_flashlight(), 
                          write("You are in the south hallway."), nl,
                          write("To the east is the physicsroom."), nl,
                          write("To the west is the cafeteria."), nl,
                          write("To the south is Prof. Karpowicz's office."), nl,
                          write("To the north is the auditorium."), nl.
                        
describe(shallway) :-     write("You are in the south hallway."), nl,
                          write("To the east is the physicsroom, there is some light coming out of it."), nl,
                          write("To the west is the cafeteria."), nl,
                          write("To the south is Prof. Karpowicz's office."), nl,
                          write("To the north is the auditorium."), nl.

 describe(karpowiczOffice) :- write("You are in Prof. Karpowicz's office."), nl,
                                 write("The door closes behind you."), nl,
                                 write("You try your best to get out but to no avail."), nl,
                                 write("Prof. Karpowicz catches you in the morning and reports you to the principal."), nl,
                                 write("You fail."), nl,
                                 die.

 describe(cafeteria) :- has_functioning_flashlight,
                        write("You are in the cafeteria."), nl,
                        write("To the west is the cafeteria backroom."), nl,
                        write("To the east is the south hallway."), nl.

 describe(cafeteria) :- write("You are in the cafeteria."), nl,
                        write("To the east is the south hallway."), nl.

 describe(cafeteria_backroom) :- write("You are in the cafeteria backroom."), nl,
                                 write("To the east is the cafeteria."), nl.



/* end of south hallway descriptions */

 describe(auditorium) :- write("You are in the auditorium."), nl,
                       write("There are hallways to the north and south."), nl,
                       write("The exit is to the east."), nl.

 describe(schoolExit) :- holding(X), member(dropoutForm, X),
                                write("Congratulations!"), nl,
                                write("You made it out of the school before sunrise and won the game."), nl,
                                write("You even get to keep a dropout form as souvenir."), nl,
                                finish.
 describe(schoolExit) :- write("Congratulations!"), nl,
                                 write("You made it out of the school before sunrise and won the game."), nl,
                                 finish.
