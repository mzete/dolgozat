% lolepes(N,Lista) - az NxN-es sakktáblán lép a lóval
lolepes(N,Lista):-
    N2 is ceiling(N / 2), numlist(1,N2,NLista),
    member(Kx,NLista), member(Ky,[1,2]),
    egeszit(N,[Kx/Ky],Lista).

% egeszit(N,Lis1,Lis2).
% megáll, ha N*N mezon már voltunk.
egeszit(N,Lis1,Lis2) :-
    N2 is N * N,
    length(Lis1,N2),
    reverse(Lis1,Lis2),!.

% keresünk következő lépést
egeszit(N,[Fej|Mar],Valasz) :-
    egylepes(N,Fej,Utan,Mar),
    egeszit(N,[Utan,Fej|Mar],Valasz).

% egylepes(Ex/Ey,Ux/Uy,Tiltott) - Ex/Ey
% mezorol lép úgy, hogy a Tiltott
% elemeket kerüli.
egylepes(N,Ex/Ey,Ux/Uy,Tiltott) :-
    LL=[1/2, 2/1, 1/(-2),
       (-2)/1,(-1)/2, 2/(-1),
       (-1)/(-2),(-2)/(-1)],
    member(Ix/Iy,LL),
    Ux is Ex + Ix, Ux > 0, Ux =<N,
    Uy is Ey + Iy, Uy > 0, Uy =<N,
    \+ member(Ux/Uy,Tiltott).

korLepes(N,Lista) :-
    lolepes(N,Lista),
    [Fej|_] = Lista,
    last(Lista,Veg),
    egylepes(N,Fej,Veg,[]).

%%%%%%%%%%%% MEGJELENITES %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
% osszlepes(N) - kiírja az összes
% lehetséges bejárást, visszalépéssel
osszlepes(N) :-
    lolepes(N,Lista),
    tikzKiir(Lista),
    fail.

% tikzKorKiir(Lista) - a listaban szereplő teljes
% lólépés-sort kiirja a Latex-hez - feltételezi,
% hogy a LISTA kör.
tikzKorKiir([Fej|Mar]) :-
    % meret megallapítása
    length([Fej|Mar],N2),N is ceiling(sqrt(N2)),
    writeln('\%'),
    writePre(N),
    drawkezd(Fej),
    writeDraw(Mar),
    writeln('    \\draw (start) -- (stop);'),
    writePost,!.

% tikzKiir(Lista) - a listaban szereplő teljes lólépés-sort
% kiirja a Latex-hez kompilálásra.
tikzKiir([Fej|Mar]) :-
    % meret megallapítása
    length([Fej|Mar],N2),N is ceiling(sqrt(N2)),
    writeln('\%'),
    writePre(N),
    drawkezd(Fej),
    writeDraw(Mar),
    writeln('    \\node[draw,circle] at (start)  {$\\cdot$};'),
    writeln('    \\node[draw,rectangle] at (stop)  {$\\cdot$};'),
    writePost,!.
    
% Preambulum a TIKZ képhez
writePre(N) :-
    write('\\begin{tikzpicture}[line width=1.5pt,scale='),
    Sc is min(1.5,3.6/N),
    write(Sc),writeln(']'),
    write('  \\draw[step=1cm,gray!25!red!25!,thick] (-0.1,-0.1) grid ('),
    write(N),write('.1,'),write(N),writeln('.1);'),
    writeln('  \\begin{scope}[color=blue!35!green!,minimum size=0.2cm,\%'),
    writeln('      xshift=-0.5cm,yshift=-0.5cm,inner sep=0pt,outer sep=0pt]').

% drawkezd(Fej) - kiirja a kezdopozíciót és kezdi vonalat.
drawkezd(Kx/Ky) :-
    write('    \\coordinate (start) at ('),
    write(Kx),write(','),write(Ky),writeln(');'),
    write('    \\draw[rounded corners=1pt] (start)').

% writeDraw(Lista) - befejezi a vonalkiírást.
writeDraw([Kx/Ky]) :-
    write(' -- ('),write(Kx),write(','),write(Ky),writeln(');'),
    write('    \\coordinate (stop) at ('),
    write(Kx),write(','),write(Ky),writeln(');').
writeDraw([Kx/Ky|Marad]) :-
    write(' -- ('),write(Kx),write(','),write(Ky),write(')'),
    writeDraw(Marad).

writePost :-  % vége - nincs paraméter
    writeln('  \\end{scope}\n\\end{tikzpicture}').
