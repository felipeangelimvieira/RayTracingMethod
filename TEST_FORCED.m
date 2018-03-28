Sys = SYSTEM();

%Material and Section
Sys.AddMaterial( 1 , 210e9 , .3 , 7.86e3 ); %Steel
Sys.AddSection( 1 , 3.1416e-06 , 7.8540e-13 , 7.8540e-13 , 1.5708e-12 ); %Round 1mm

%Nodes
Sys.AddNode( 1 , [ 0 ; 0 ; 0 ] );
Sys.AddNode( 2 , [ 1 ; 0 ; 0 ] );
Sys.AddNode( 3 , [ 1 ; 1 ; 0 ] );
Sys.AddNode( 4 , [ 0 ; 1 ; 0 ] );

Sys.AddNode( 5 , [ 0 ; 0 ; 1 ] );
Sys.AddNode( 6 , [ 1 ; 0 ; 1 ] );
Sys.AddNode( 7 , [ 1 ; 1 ; 1 ] );
Sys.AddNode( 8 , [ 0 ; 1 ; 1 ] );

Sys.AddNode( 9  , [ 0 ; 0 ; 2 ] );
Sys.AddNode( 10 , [ 1 ; 0 ; 2 ] );
Sys.AddNode( 11 , [ 1 ; 1 ; 2 ] );
Sys.AddNode( 12 , [ 0 ; 1 ; 2 ] );

Sys.AddNode( 13 , [ .5 ; .5 ; 2.5 ] );

Sys.AddNode( 100 , [ 100 ; 100 ; 100 ] );

%Elements
Sys.AddElement( 1 , 1 , 5 , 100 , 1 , 1 );
Sys.AddElement( 2 , 2 , 6 , 100 , 1 , 1 );
Sys.AddElement( 3 , 3 , 7 , 100 , 1 , 1 );
Sys.AddElement( 4 , 4 , 8 , 100 , 1 , 1 );

Sys.AddElement( 11 , 5 ,  9 , 100 , 1 , 1 );
Sys.AddElement( 12 , 6 , 10 , 100 , 1 , 1 );
Sys.AddElement( 13 , 7 , 11 , 100 , 1 , 1 );
Sys.AddElement( 14 , 8 , 12 , 100 , 1 , 1 );

Sys.AddElement( 21 , 5 , 6 , 100 , 1 , 1 );
Sys.AddElement( 22 , 6 , 7 , 100 , 1 , 1 );
Sys.AddElement( 23 , 7 , 8 , 100 , 1 , 1 );
Sys.AddElement( 24 , 8 , 5 , 100 , 1 , 1 );

Sys.AddElement( 31 , 9 , 10 , 100 , 1 , 1 );
Sys.AddElement( 32 , 10 , 11 , 100 , 1 , 1 );
Sys.AddElement( 33 , 11 , 12 , 100 , 1 , 1 );
Sys.AddElement( 34 , 12 , 9 , 100 , 1 , 1 );

Sys.AddElement( 41 , 9 , 13 , 100 , 1 , 1 );
Sys.AddElement( 42 , 10 , 13 , 100 , 1 , 1 );
Sys.AddElement( 43 , 11 , 13 , 100 , 1 , 1 );
Sys.AddElement( 44 , 12 , 13 , 100 , 1 , 1 );

%Limit Conditions
Sys.BlockAll(1);
Sys.BlockAll(2);
Sys.BlockAll(3);
Sys.BlockAll(4);

%Ressorts, Dampers...


%External excitation
Sys.AddExternalForce(13,[0;0;0;0;0;10]);
Sys.AddExternalForce(6,[0;0;0;0;0;10]);
Sys.AddExternalForce(8,[0;0;0;0;0;10]);


%Solving
Sys.InitializeMatrix();

F = 0.01:.01:5;
Y = Sys.FrequencyResponse(F,41,.5);
plot(F,Y);
