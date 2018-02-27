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

%Limit Conditions
Sys.BlockAll(1);
Sys.BlockAll(2);
Sys.BlockAll(3);
Sys.BlockAll(4);

%External excitation
Sys.AddExternalForce(9,[0;0;0;0;0;0]);
Sys.AddExternalForce(11,[0;0;0;0;0;0]);
Sys.AddImposedDisplacement(1,[0;0;0;1;0;0]);


%Solving
Sys.InitializeMatrix();

f = 2;
w = f*2*pi;
W = Sys.ForcedResponse(w);
Sys.ShowDeformatedStructure(W,w);
