Sys = SYSTEM();

%Material and Section
Sys.AddMaterial( 1 , 210e9 , .3 , 7.86e3 ); %Steel
Sys.AddSection( 1 , 3.1416e-06 , 7.8540e-13 , 7.8540e-13 , 1.5708e-12 ); %Round 1mm

%Nodes
Sys.AddNode( 1 , [ 0 ; 0 ; 0 ] );
Sys.AddNode( 2 , [ 1 ; 0 ; 0 ] );
Sys.AddNode( 3 , [ 2 ; 1 ; 0 ] );
Sys.AddNode( 4 , [ 0 ; 1 ; 0 ] );

%Elements
Sys.AddElement( 1 , 1 , 2 , 4 , 1 , 1 );
%Sys.addElement( 2 , 2 , 3 , 4 , 1 , 1 );

%Limit Conditions
A = Sys.FindNodeById(1);
A.DeltaFree = zeros(6);
a = Sys.FindElementById(1);
%b = Sys.findElementById(2);

%Solving
Sys.InitializeMatrix();
Sys.ShowStructure();

figure();
F = [];
Y = [];
for f = 0.1:.1:2
    y = Sys.Determinant(f*2*pi);
    Y = [Y y];
    F = [F f];
end
plot(F,Y);
w = 1.44*2*pi;
W = Sys.AssociatedMode(w);
Sys.ShowDeformatedStructure(W,w)