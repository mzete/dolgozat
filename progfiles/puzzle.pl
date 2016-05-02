% A puzzle feladat megold�sa - list�kkal.
% A feladat param�tere egy lista, melynek
% m�rete NxN.

% puzzle(Kezdet,Ut) - a kezdeti �llapotb�l visszat�r�t
% egy utat, mellyel a C�l-�llapotba jutunk.
puzzle(Kezdet,Ut) :-
    length(Kezdet,Nk),
    N is ceiling(sqrt(Nk)),
    N * N =:= Nk,
    generate(Nk,Cel),
    ut(N,Kezdet,Cel,Ut).

% generate(N,Lista) - gener�lja az [1,N-1,0]
% list�t, ahol az utols� elem nulla.
generate(N,Veg):-
    N1 is N - 1,
    generate(N1,[0],Veg).

% listageneralo egy AKK-ral.
generate(0,Veg,Veg):-!.
generate(K,L,Veg) :-
    K1 is K - 1,
    generate(K1,[K|L],Veg).

% ut(N,Kezdet,Cel,Ut) - az NxN-es puzzle-ben keres
% utat a Kezdet �s a C�l k�z�tt. Az Ut-ban a NULL�S
% elem mozg�sa van.
ut(_,Kezd,Kezd,[]) :- !.
ut(N,Kezd,Cel,Utak) :-
    ut(N,Kezd,[],[Kezd],Cel,Utak).

% ut(N,Kezd,T�t,�llList,C�l,�t) - a Kezd
% �s C�l-�llapotok k�z�tt tal�l egy utat.
% A T�t-ba gyujtj�k a l�p�seket.
%$ Meg�llunk, ha Kezd �s C�l megegyezik.
ut(_,Cel,TUt,_,Cel,Ut):-
    reverse(TUt,Ut), !.


% L�p�nk a Kezd-bol egyet �s keress�k az
% utat a C�l-ba. Az �llList t�rolja a
% m�r bej�rt �llapotokat.
ut(N,Kezd,TUt,Volt,Cel,VUt) :-
    egylepes(N,Kezd,IEgy,Koz),
    \+ member(Koz,Volt),
    length(Volt,Nb),Nb < N*N,
    ut(N,Koz,[IEgy|TUt],[Kezd|Volt],Cel,VUt).

% egylepes(Honnan,Merre,Hova) - a Honnan-b�l a Hov�-ba jutunk az
% �llapott�rben. Merre jelzi, hogy az �RES poz�ci� merre mozdul.
egylepes(N,Honnan,Irany,Hova) :-
    zerusPoz(Honnan,IndN),
    ujInd(N,IndN,IndLKi,Irany),
    cserel(Honnan,IndN,IndLKi,Hova).

% ujInd(N,IndReg,IndUj,Irany) - az Ir�nyba
% l�p�s �ltal gener�lt �j index.
ujInd(N,IndReg,IndUj,Irany) :-
    ijPoz(N,IndReg,I,J),
    member(Pi/Pj/Irany, %
      [ 1/0/le,0/(-1)/bal,
      (-1)/0/fel,0/1/jobb] ),
    Iuj is I + Pi, Iuj > 0, Iuj =< N,
    Juj is J + Pj, Juj > 0, Juj =< N,
    IndUj is N*(Iuj-1) + Juj.

% ijPoz(N,K,I,J) - az NxN-es t�bl�ban a
% K-hoz tartoz� indexeket t�r�ti vissza
ijPoz(N,K,I,J) :-
    J is ((K-1) rem N) + 1,
    I is ((K-1)//N) +1.

% cserel(Lista,Ind1,Ind2,Valasz) -
% cser�li az Ind1 �s Ind2 elemeket.
cserel(LBe,Ind1,Ind2,LKi) :-
    Ind1<Ind2,
    csere_ord(LBe,Ind1,Ind2,LKi),  !.
cserel(LBe,Ind1,Ind2,LKi) :-
    csere_ord(LBe,Ind2,Ind1,LKi).
% csere_ord(Lista,I1,I2,Valasz), !I1<I2!
csere_ord(LBe,Ind1,Ind2,LKi) :-
    allista(LBe,Ind1,L_E1,E1,L_U),
    I22 is Ind2-Ind1,
    allista(L_U,I22,L_EU1,E2,L_UU),
    flatten([L_E1,E2,L_EU1,E1,L_UU],LKi).

allista([Elem|Marad],1,[],Elem,Marad) :- !.
allista([Fej|Marad],K,[Fej|EMarad],Elem,Uto) :-
    K>1,
    K1 is K - 1,
    allista(Marad,K1,EMarad,Elem,Uto).

% zerusPoz(Lista,Ind) - a Listaban
% megkeresi a null�t.
zerusPoz([0|_],1):- !.
zerusPoz([_|Marad],Ind) :-
    zerusPoz(Marad,IM),
    Ind is IM + 1.

%%%%%%%%%%%%%%%%% MEGJELENITES %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% tikzSor(Kezdet,Ut) - egy tikz sorozatba ki�rja a
% puzzle megold�sokat. Ha a m�sodik argumentum �RES,
% csak egy �llapotot �r ki.
tikzSor(Kezdet,Ut) :-
    length(Kezdet,N2), N is ceiling(sqrt(N2)),
    writeln('%---------------------\n%---Gener�lt sz�veg---'),
    tikzListaKiir(N,Kezdet,Ut),
    writeln('%-----Sz�veg v�ge-----\n%---------------------').

%% tikzListaKiir(N,Kezdet,Ut) - a Kezdet-bol indulva ki�rja
% a puzzle l�p�seket. �RES �T-n�l egy T�BL�T �runk ki.
tikzListaKiir(N,Kezdet,[]) :-
    tikzElemKiir(N,Kezdet).
tikzListaKiir(N,Kezdet,[Irany|MarUt]) :-
    tikzElemKiir(N,Kezdet),
    egylepes(N,Kezdet,Irany,Kov),
    iranyKiir(Irany),
    tikzListaKiir(N,Kov,MarUt).

iranyKiir(Irany) :-
    member(Irany/Dir,[bal/'Right',jobb/'Left',le/'Up',fel/'Down']),
    write('\%\n$\\stackrel{\\pmb \\'),write(Dir),
    writeln('arrow}{\\pmb \\longrightarrow}$\n\%').

% tikzElemKiir(N,Puzzle) - egy TIKZ �br�ba ki�r egy �llapotot
tikzElemKiir(N,Puzzle) :-
    writePre(N),
    tikzPuzzleLista(N,1,Puzzle),
    writePost.

% tikzPuzzleLista(N,I,J,Puzzle) - ki�rja az (I,J) poz�ci�ba
% a Lista fej�t, n�veli az �rt�keket.
tikzPuzzleLista(_,_,[]) :- !.
tikzPuzzleLista(N,K,[0|MarPuz]) :-
    K1 is K + 1,
    tikzPuzzleLista(N,K1,MarPuz),
    !.
tikzPuzzleLista(N,K,[Fej|MarPuz]) :-
    ijPoz(N,K,I,J),
    I1 is N + 1 - I,
    write('    \\node[draw] at ('), write(J),write(','),write(I1),
    write(') {\\bfseries\\tt '),write(Fej),writeln('};'),
    K1 is K + 1,
    tikzPuzzleLista(N,K1,MarPuz).

% Preambulum a TIKZ k�phez
writePre(N) :-
    writeln('\\begin{tikzpicture}[line width=1.2pt,scale=0.5]'),
    write('  \\draw[step=1cm,gray!25!red!25!] (-0.1,-0.1) grid ('),
    write(N),write('.1,'),write(N),writeln('.1);'),
    writeln('  \\begin{scope}[color=blue!35!green!,minimum size=0.2cm,\%'),
    writeln('      rectangle,xshift=-0.5cm,yshift=-0.5cm,inner sep=3pt,\%'),
    writeln('      outer sep=4pt]').


writePost :-  % v�ge - nincs param�ter
    writeln('  \\end{scope}\n\\end{tikzpicture}').
