Sys = SYSTEM();

%Material and Section
Sys.AddMaterial( 1 , 210e9 , .3 , 7.86e3 ); %Steel
Sys.AddSection( 1 , 3.1416e-06 , 7.8540e-13 , 7.8540e-13 , 1.5708e-12 ); %Round 1mm

%Nodes
Sys.AddNode( 1 , [ 0 ; 0 ; 0 ] );
Sys.AddNode( 2 , [ 1 ; 0 ; 0 ] );
Sys.AddNode( 3 , [ 2 ; 1 ; 0 ] );
Sys.AddNode( 4 , [ 2 ; 0 ; 0 ] );
Sys.AddNode( 5 , [ 0 ; 0 ; 1 ] );

%Elements
Sys.AddElement( 1 , 1 , 2 , 5 , 1 , 1 );
Sys.AddElement( 2 , 2 , 3 , 5 , 1 , 1 );
Sys.AddElement( 3 , 2 , 4 , 5 , 1 , 1 );
A = Sys.FindElementById(1);
B = Sys.FindElementById(2);
C = Sys.FindElementById(3);

%Limit Conditions
Sys.BlockAll(1);

%Solving
Sys.InitializeMatrix();


w = 1.44*2*pi;
W = Sys.AssociatedMode(w);
%Sys.ShowDeformatedStructure(W,w)