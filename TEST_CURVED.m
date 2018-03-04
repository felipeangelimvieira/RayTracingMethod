import SYSTEM
close all
%%
Sys = SYSTEM();

R = 0.01;
area = pi*R^2;
rho = 7.86e3;
S = pi*R^2;
E = 210e9;
G =(210e9)/2.6;
IIn =  pi/4*R^4;
IOut =  pi/4*R^4;

%Material and Section
Sys.AddMaterial( 1 , E , .3 , rho ); %Steel
Sys.AddSection( 1 , area , IIn , IOut , IIn+IOut ); %Round 1mm

%Nodes
Sys.AddNode( 0 , [ 0.5 ; 0 ; 0 ] ); %center
Sys.AddNode( 1 , [ 0 ; 0 ; 0 ] );
Sys.AddNode( 2 , [ 1 ; 0 ; 0 ] );
Sys.AddNode( 3 , [ 0.5 ; 1 ; 0 ] );%nodeRef
Sys.AddNode( 4 , [ 0.5 ; -1 ; 0 ] );%nodeRef

%Elements
Sys.AddCurvedElement( 1 , 1 , 2 , 0 , 1 , 1, 3 );
Sys.AddCurvedElement( 2 , 2 , 1 , 0 , 1 , 1, 4 );

%Limit Conditions
%Sys.BlockAll(1);

%Solving
Sys.InitializeMatrix();

figure();
F = [];
Y = [];

v = Sys.RandomWave();
for f = 4:1:200
    
    M = (Sys.ProblemMatrix(f*2*pi));
    Y = [Y abs(det(M))];
    
    F = [F f];
end

fList = Sys.FindModalFreqs(120,.01,125);

plot(F,Y);

for f = fList
    w = f*2*pi;
    W = Sys.AssociatedMode(w);
    Sys.ShowDeformatedStructure(W,w);
end

% -R <Ansys workbench script file>
%http://www.mechanicsandmachines.com/?p=306