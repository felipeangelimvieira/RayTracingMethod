Sys = SYSTEM();

%Material and Section
Sys.addMaterial( 1 , 210e9 , .3 , 7.86e3 ); %Steel
Sys.addSection( 1 , 3.1416e-06 , 7.8540e-13 , 7.8540e-13 , 1.5708e-12 ); %Round 1mm

%Nodes
Sys.addNode( 1 , [ 0 ; 0 ; 0 ] );
Sys.addNode( 2 , [ 1 ; 0 ; 0 ] );
Sys.addNode( 3 , [ 1 ; 1 ; 0 ] );
Sys.addNode( 4 , [ 0 ; 1 ; 0 ] );

Sys.addNode( 5 , [ 0 ; 0 ; 1 ] );
Sys.addNode( 6 , [ 1 ; 0 ; 1 ] );
Sys.addNode( 7 , [ 1 ; 1 ; 1 ] );
Sys.addNode( 8 , [ 0 ; 1 ; 1 ] );

Sys.addNode( 9  , [ 0 ; 0 ; 2 ] );
Sys.addNode( 10 , [ 1 ; 0 ; 2 ] );
Sys.addNode( 11 , [ 1 ; 1 ; 2 ] );
Sys.addNode( 12 , [ 0 ; 1 ; 2 ] );

Sys.addNode( 100 , [ 100 ; 100 ; 100 ] );

%Elements
Sys.addElement( 1 , 1 , 5 , 100 , 1 , 1 );
Sys.addElement( 2 , 2 , 6 , 100 , 1 , 1 );
Sys.addElement( 3 , 3 , 7 , 100 , 1 , 1 );
Sys.addElement( 4 , 4 , 8 , 100 , 1 , 1 );

Sys.addElement( 11 , 5 ,  9 , 100 , 1 , 1 );
Sys.addElement( 12 , 6 , 10 , 100 , 1 , 1 );
Sys.addElement( 13 , 7 , 11 , 100 , 1 , 1 );
Sys.addElement( 14 , 8 , 12 , 100 , 1 , 1 );

Sys.addElement( 21 , 5 , 6 , 100 , 1 , 1 );
Sys.addElement( 22 , 6 , 7 , 100 , 1 , 1 );
Sys.addElement( 23 , 7 , 8 , 100 , 1 , 1 );
Sys.addElement( 24 , 8 , 5 , 100 , 1 , 1 );

Sys.addElement( 31 , 9 , 10 , 100 , 1 , 1 );
Sys.addElement( 32 , 10 , 11 , 100 , 1 , 1 );
Sys.addElement( 33 , 11 , 12 , 100 , 1 , 1 );
Sys.addElement( 34 , 12 , 9 , 100 , 1 , 1 );

%Limit Conditions
A = Sys.findNodeById(1);
A.DeltaFree = zeros(6);
B = Sys.findNodeById(2);
B.DeltaFree = zeros(6);
C = Sys.findNodeById(3);
C.DeltaFree = zeros(6);
D = Sys.findNodeById(4);
D.DeltaFree = zeros(6);

%Solving
Sys.InitializeMatrix();
%Sys.showStructure();


figure();
F = [];
Y = [];
for f = 0.01:.01:3
    Y = [Y Sys.Determinant(f*2*pi)];
    F = [F f];
end
plot(F,Y);
