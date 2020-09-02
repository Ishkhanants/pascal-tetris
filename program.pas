program tetris;

uses crt, graph;

type figure = array[ 1..4, 1..4 ] of integer;
const size : array[ 1..7 ] of integer =( 2, 4, 3, 3, 3, 3, 3 );
label newgame, gamover;
var block, nextblock : figure;
    field : array[ 0..30, 0..60 ] of integer;
    d, m, i, j, k, x, y, e, time, count, score, next : integer;
    a : char;

procedure gameinterface;
begin
    clearviewport;
    settextstyle(0,0,0);                 { Default }
    setfillstyle( solidfill, white );
    bar( 195, 1, 452, 480 );
    bar( 560, 170, 640, 300);
    moveto( 500, 200 );
    outtext( 'Next =' );
    moveto(70, 225);
    outtext( 'Score:' );
    moveto(70, 200);
    outtext( 'N - New Game' );
    moveto(70, 250);
    outtext( 'Esc - Menu' );
    setfillstyle( solidfill, black );
    bar( 565, 175, 635, 295 );
end;

procedure build( k : integer; var b : figure );
var i, j : integer;
begin
    for i := 1 to 4 do
    for j := 1 to 4 do
        b[ i, j ] := 0;
    case k of
        1 :
        begin
            for i := 1 to 2 do       {cube}
            for j := 1 to 2 do
                b[ i, j ] := 1
        end;
        2 :
        begin
            for j := 1 to 4 do       {straight}
                b[ 2, j ] := 2
        end;
        3 :
        begin                           { [][] }
            b[ 1, 1 ] := 3;             {   [] }
            for i := 1 to 3 do          {   [] }
                b[ i, 2 ] := 3
        end;
        4 :
        begin                         {  [][]  }
            b[ 1, 3 ] := 4;           {  []    }
            for i := 1 to 3 do        {  []    }
                b[ i, 2 ] := 4
        end;
        5 :
        begin
            for i := 1 to 2 do
            begin                      {    []  }
                b[ i + 1, 1 ] := 5;    {  [][]  }
                b[ i, 2 ] := 5         {  []    }
            end;
        end;
        6 :
        begin
            for i := 1 to 2 do         {   []    }
            begin                      {   [][]  }
                b[ i + 1, 2 ] := 6;    {     []  }
                b[ i, 1 ] := 6
            end;
        end;
        7 :
        begin
            for i := 1 to 3 do               {   []   }
                b[ i, 2 ] := 14;             { [][]   }
            b[ 2, 1 ] := 14                  {   []   }
        end;
    end;
end;

procedure updatescore;
var s : string;
begin
    setfillstyle( solidfill, black );
    bar( 140, 220, 160, 240 );
    str( score, s );
    moveto( 140, 225 );
    outtext(s);
end;

procedure drawfield;
var i, j, a : integer;
begin
    setfillstyle( solidfill, black );
    bar( 219, 1, 428, 457 );
    for i := 1 to 11 do
    for j := 1 to 23 do
    for a := 1 to 6 do
    if field[ i, j ]=a then
    begin
        setfillstyle( solidfill, black );
        bar( 19 * i + 201, 19 * j + 1, 19 *( i + 1 )+200, 19 *( j + 1 ));
        setfillstyle( solidfill, a );
        bar( 19 * i + 202, 19 * j + 2, 19 *( i + 1 )+199, 19 *( j + 1 )-1);
    end
    else if field[ i, j ]=14 then
    begin
        setfillstyle( solidfill, black );
        bar( 19 * i + 201, 19 * j + 1, 19 *( i + 1 )+200, 19 *( j + 1 ));
        setfillstyle( solidfill, 14 );
        bar( 19 * i + 202, 19 * j + 2, 19 *( i + 1 )+199, 19 *( j + 1 )-1);
    end;
    setfillstyle( solidfill, black );
    bar( 565, 175, 635, 295 );
    for i := 1 to size[ next ] do
    for j := 1 to size[ next ] do
    for a := 1 to 6 do
    if nextblock[ i, j ]=a then
    begin
        setfillstyle( solidfill, black );
        bar( 19 * i + 551, 19 * j + 181, 19 *( i + 1 ) + 550, 19 *( j + 1 ) + 180);
        setfillstyle( solidfill, a );
        bar( 19 * i + 552, 19 * j + 182, 19 *( i + 1 ) + 549, 19 *( j + 1 ) + 179);
    end
    else if nextblock[ i, j ]=14 then
    begin
        setfillstyle( solidfill, black );
        bar( 19 * i + 551, 19 * j + 181, 19 *( i + 1 ) + 550, 19 *( j + 1 ) + 180);
        setfillstyle( solidfill, 14 );
        bar( 19 * i + 552, 19 * j + 182, 19 *( i + 1 ) + 549, 19 *( j + 1 ) + 179);
    end
end;

procedure delblock;
var i, j : integer;
begin
    setfillstyle( solidfill, black );
    for i := 1 to size[ k ] do
    for j := 1 to size[ k ] do
    if block[ i, j ]<>0 then
    bar( 19 * x + 19 * i + 201, 19 * y + 19 * j + 1,
    19 * x + 19 *( i + 1 )+200, 19 * y + 19 *( j + 1 )-1);
end;

procedure delline( h : integer );
var i, j, k, c : integer;
begin
    c := 0;
    for j := h to h + 3 do
    begin
        if j > 23 then break;
        i := 1;
        while( field[ i, j ]<>0 ) and( i < 11 ) do
            inc( i );
        if( field[ i, j ]<>0 ) and( i = 11 ) then
        begin
            inc( c );
            score := score + 1;
            for i := 1 to 11 do
            for k := j downto 2 do
                field[ i, k ] := field[ i, k - 1 ];
        end;
    end;
    drawfield;
    updatescore;
end;

procedure drawblock;
var i, j, a : integer;
begin
    for i := 1 to size[ k ] do
    for j := 1 to size[ k ] do
    for a := 1 to 6 do
    if block[ i, j ]=a then
    begin
        setfillstyle( solidfill, black );
        bar( 19 * x + 19 * i + 201, 19 * y + 19 * j + 2,
             19 * x + 19 *( i + 1 )+200, 19 * y + 19 *( j + 1 ));
        setfillstyle( solidfill, a );
        bar( 19 * x + 19 * i + 202, 19 * y + 19 * j + 2,
             19 * x + 19 *( i + 1 )+199, 19 * y + 19 *( j + 1 )-1);
    end
    else if block[ i, j ]=14 then
    begin
        setfillstyle( solidfill, black );
        bar( 19 * x + 19 * i + 201, 19 * y + 19 * j + 2,
             19 * x + 19 *( i + 1 )+200, 19 * y + 19 *( j + 1 ));
        setfillstyle( solidfill, 14 );
        bar( 19 * x + 19 * i + 202, 19 * y + 19 * j + 2,
             19 * x + 19 *( i + 1 )+199, 19 * y + 19 *( j + 1 )-1);
    end
end;

procedure move( m : integer );
var i, j : integer;
begin
    for i := 1 to size[ k ] do
    for j := 1 to size[ k ] do
    if( block[ i, j ]<>0 ) and(( i + x + m > 11 ) or( i + x + m < 1 )
                        or( field[ x + i + m, y + j ] <>0 ) )then exit;
    delblock;
    if m = 1 then inc( x ) else dec( x );
    drawblock;
end;

procedure movedown;
var i, j, i1, j1, a : integer;
begin
    for i := 1 to size[ k ] do
    for j := 1 to size[ k ] do
    if( block[ i, j ]<>0 ) and(( field[ i + x, j + 1 + y ] <>0)
     or( j + y >= 23 ) )
    then
    begin
        if y = 0 then
        for i1 := 1 to size[ k ] do
        if block[ i1, 1 ]<>0 then
        begin
            k := 8;
            exit
        end;
        for i1 := 1 to size[ k ] do
        for j1 := 1 to size[ k ] do
        for a := 1 to 6 do
        if block[ i1, j1 ]=a  then
        field[ i1 + x, j1 + y ] := a
        else if block[ i1, j1 ]=14  then
        field[ i1 + x, j1 + y ] := 14;
        block := nextblock;
        k := next;
        next := random( 7 ) + 1;
        build( next, nextblock );
        delline( y + 1 );
        x := 6;
        y := 0;
        exit;
    end;
    delblock;
    inc( y );
    drawblock;
end;

procedure rotate( k : integer );
var block1 : figure;
i, j : integer;
begin
    delblock;
    for i := 1 to 4 do
    for j := 1 to 4 do
        block1[ i, j ] := 0;
    if k = 2 then
    begin
        if block[ 2, 1 ]<>0 then
        begin
            for i := 1 to 4 do
            begin
                block1[ i, 2 ] := 2;
                if( field[ i + x, 2 + y ]<>0 ) or( i + x > 11 )
                or( i + x < 1 )or( 2 + y > 23 ) or( 2 + y < 1 )
                then
                begin
                    drawblock;
                    exit;
                end;
            end;
            block := block1;
        end
        else
        begin
            for i := 1 to 4 do
                block1[ 2, i ] := 2;
            block := block1;
        end;
    end
    else if k > 2 then
    begin
        for i := 1 to 3 do
        for j := 1 to 3 do
        if block[ 4 - j, i ]<>0 then
        begin
            block1[ i, j ] := block[ 4 - j, i ];
            if(( field[ i + x, j + y ]<>0 ) or( i + x > 11 )
              or( i + x < 1 ) or( j + y > 23 )or( j + y < 1 ) )
              and( block1[ i, j ]<>0 ) then
            begin
                drawblock;
                exit
            end;
        end;
        block := block1;
    end;
    drawblock;
end;

procedure menu;
var c : char;
    q : integer;
begin
 clearviewport;
 SetBkColor(0);
 SETTEXTSTYLE(3,0,10);
 OUTTEXTXY(150,20,'TETRIS');
 SETTEXTSTYLE(3,0,5);
 OUTTEXTXY(260,180,' Continue');
 OUTTEXTXY(260,230,'  About');
 OUTTEXTXY(260,280,'   Exit');
 SetFillStyle(1,4);
 FillEllipse(220,200,10,10);
 SetFillStyle(1,0);
 FillEllipse(220,250,10,10);
 SetFillStyle(1,0);
 FillEllipse(220,300,10,10);
 q:=1;
 repeat
 c:=readkey;
 if c=#0 then c:=readkey;
 if c=#80 then q:=q+1;
 if c=#72 then q:=q-1;
 if q=0 then q:=3;
 if q=4 then q:=1;
 case q of
      1:
      begin
      SetFillStyle(1,4);
      FillEllipse(220,200,10,10);
      SetFillStyle(1,0);
      FillEllipse(220,250,10,10);
      SetFillStyle(1,0);
      FillEllipse(220,300,10,10);
      end;
      2:
      begin
      SetFillStyle(1,0);
      FillEllipse(220,200,10,10);
      SetFillStyle(1,1);
      FillEllipse(220,250,10,10);
      SetFillStyle(1,0);
      FillEllipse(220,300,10,10);
      end;
      3:
      begin
      SetFillStyle(1,0);
      FillEllipse(220,200,10,10);
      SetFillStyle(1,0);
      FillEllipse(220,250,10,10);
      SetFillStyle(1,14);
      FillEllipse(220,300,10,10);
      end;
 end;
 until (c=#13);
 case q of
 1:
 begin
  gameinterface; drawfield;
  drawblock; updatescore;
 end;
 2:
 begin
 clearviewport;
 repeat
 settextstyle(3,0,3);
 outtextxy(180,90,'Basis by Suren Enfiadjian');
 settextstyle(3,0,5);
 outtextxy(30,170,'Developed by Martin Mirzoyan');
 setfillstyle(solidfill,red);
 bar(240,260,390,285);
 setfillstyle(solidfill,blue);
 bar(240,286,390,311);
 setfillstyle(solidfill,yellow);
 bar(240,312,390,337);
 outtextxy(267,380,'2018');
 c:=readkey;
 until (c=#27);
 if c=#27 then menu;
 end;
 3:
 begin
  CloseGraph;
  Halt
 end;
end;
end;

begin  {Main}
    detectgraph( d, m );
    initgraph( d, m, '' );
    gameinterface;
    newgame : score := 0;
    updatescore;
    setfillstyle( solidfill, black );
    bar( 219, 1, 428, 457 );
    x := 6;
    y := 0;
    randomize;
    k := random( 7 ) + 1;
    build( k, block );
    for i := 1 to 11 do
    for j := 1 to 23 do
        field[ i, j ] := 0;
    next := random( 7 ) + 1;
    build( next, nextblock );
    drawfield;
    repeat
        if count = 0 then time := 60 - 2*score;
        for i:=1 to 25-score do
        begin
            if keypressed then
            begin
                a := readkey;
                if a = #0 then a := readkey;
                case a of
                    #75 : move( - 1 );
                    #77 : move( 1 );
                    #72 : rotate( k );
                    #80 :
                    begin
                        count := count + 2 *( 30 - score );
                        time := 0
                    end;
                    'n' : goto newgame;
                    #27 : menu;
                end;
            end;
            while keypressed do
                readkey;
            delay( time );
            if count > 0 then dec( count );
        end;
        movedown;
        if k = 8 then goto gamover;
    until( a = #28 );
    exit;
    gamover : moveto( 290, 15 );
    outtext( 'GAME OVER' );
    repeat
        a := readkey;
    until( a = #27 );
end.
