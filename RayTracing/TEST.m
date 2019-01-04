
clear
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
%Sys.AddElement( 3 , 2 , 4 , 5 , 1 , 1 );

%Limit Conditions
Sys.BlockAll(1);

%Sys.BlockAllTranslation(3);
%Sys.BlockRotationDirection(3,[1;0;0]);
%Sys.BlockRotationDirection(3,[0;1;0]);

%Solving
Sys.InitializeMatrix();


 fList = Sys.FindModalFreqs2(10,0.01);
 for f = fList
     w = f*2*pi;
     W = Sys.AssociatedMode(w);
     Sys.ShowDeformatedStructure(W,w);
end