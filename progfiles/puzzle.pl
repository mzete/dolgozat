% A puzzle feladat megoldása - listákkal.
% A feladat paramétere egy lista, melynek
% mérete NxN.

% puzzle(Kezdet,Ut) - a kezdeti állapotból visszatérít
% egy utat, mellyel a Cél-állapotba jutunk.
puzzle(Kezdet,Ut) :-
    length(Kezdet,Nk),
    N is ceiling(sqrt(Nk)),
    N * N =:= Nk,
    generate(Nk,Cel),
    ut(N,Kezdet,Cel,Ut).

% generate(N,Lista) - generálja az [1,N-1,0]
% listát, ahol az utolsó elem nulla.
generate(N,Veg):-
    N1 is N - 1,
    generate(N1,[0],Veg).

% listageneralo egy AKK-ral.
generate(0,Veg,Veg):-!.
generate(K,L,Veg) :-
    K1 is K - 1,
    generate(K1,[K|L],Veg).

% ut(N,Kezdet,Cel,Ut) - az NxN-es puzzle-ben keres
% utat a Kezdet és a Cél között. Az Ut-ban a NULLÁS
% elem mozgása van.
ut(_,Kezd,Kezd,[]) :- !.
ut(N,Kezd,Cel,Utak) :-
    ut(N,Kezd,[],[Kezd],Cel,Utak).

% ut(N,Kezd,TÚt,ÁllList,Cél,Út) - a Kezd
% és Cél-állapotok között talál egy utat.
% A TÚt-ba gyujtjük a lépéseket.
%$ Megállunk, ha Kezd és Cél megegyezik.
ut(_,Cel,TUt,_,Cel,Ut):-
    reverse(TUt,Ut), !.


% Lépünk a Kezd-bol egyet és keressük az
% utat a Cél-ba. Az ÁllList tárolja a
% már bejárt állapotokat.
ut(N,Kezd,TUt,Volt,Cel,VUt) :-
    egylepes(N,Kezd,IEgy,Koz),
    \+ member(Koz,Volt),
    length(Volt,Nb),Nb < N*N,
    ut(N,Koz,[IEgy|TUt],[Kezd|Volt],Cel,VUt).

% egylepes(Honnan,Merre,Hova) - a Honnan-ból a Hová-ba jutunk az
% állapottérben. Merre jelzi, hogy az ÜRES pozíció merre mozdul.
egylepes(N,Honnan,Irany,Hova) :-
    zerusPoz(Honnan,IndN),
    ujInd(N,IndN,IndLKi,Irany),
    cserel(Honnan,IndN,IndLKi,Hova).

% ujInd(N,IndReg,IndUj,Irany) - az Irányba
% lépés által generált új index.
ujInd(N,IndReg,IndUj,Irany) :-
    ijPoz(N,IndReg,I,J),
    member(Pi/Pj/Irany, %
      [ 1/0/le,0/(-1)/bal,
      (-1)/0/fel,0/1/jobb] ),
    Iuj is I + Pi, Iuj > 0, Iuj =< N,
    Juj is J + Pj, Juj > 0, Juj =< N,
    IndUj is N*(Iuj-1) + Juj.

% ijPoz(N,K,I,J) - az NxN-es táblában a
% K-hoz tartozó indexeket téríti vissza
ijPoz(N,K,I,J) :-
    J is ((K-1) rem N) + 1,
    I is ((K-1)//N) +1.

% cserel(Lista,Ind1,Ind2,Valasz) -
% cseréli az Ind1 és Ind2 elemeket.
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
% megkeresi a nullát.
zerusPoz([0|_],1):- !.
zerusPoz([_|Marad],Ind) :-
    zerusPoz(Marad,IM),
    Ind is IM + 1.

%%%%%%%%%%%%%%%%% MEGJELENITES %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% tikzSor(Kezdet,Ut) - egy tikz sorozatba kiírja a
% puzzle megoldásokat. Ha a második argumentum ÜRES,
% csak egy állapotot ír ki.
tikzSor(Kezdet,Ut) :-
    length(Kezdet,N2), N is ceiling(sqrt(N2)),
    writeln('%---------------------\n%---Generált szöveg---'),
    tikzListaKiir(N,Kezdet,Ut),
    writeln('%-----Szöveg vége-----\n%---------------------').

%% tikzListaKiir(N,Kezdet,Ut) - a Kezdet-bol indulva kiírja
% a puzzle lépéseket. ÜRES ÚT-nál egy TÁBLÁT írunk ki.
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

% tikzElemKiir(N,Puzzle) - egy TIKZ ábrába kiír egy állapotot
tikzElemKiir(N,Puzzle) :-
    writePre(N),
    tikzPuzzleLista(N,1,Puzzle),
    writePost.

% tikzPuzzleLista(N,I,J,Puzzle) - kiírja az (I,J) pozícióba
% a Lista fejét, növeli az értékeket.
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

% Preambulum a TIKZ képhez
writePre(N) :-
    writeln('\\begin{tikzpicture}[line width=1.2pt,scale=0.5]'),
    write('  \\draw[step=1cm,gray!25!red!25!] (-0.1,-0.1) grid ('),
    write(N),write('.1,'),write(N),writeln('.1);'),
    writeln('  \\begin{scope}[color=blue!35!green!,minimum size=0.2cm,\%'),
    writeln('      rectangle,xshift=-0.5cm,yshift=-0.5cm,inner sep=3pt,\%'),
    writeln('      outer sep=4pt]').


writePost :-  % vége - nincs paraméter
    writeln('  \\end{scope}\n\\end{tikzpicture}').
