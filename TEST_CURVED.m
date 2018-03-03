import SYSTEM

%%

Sys = SYSTEM();


Radius = 0.5;
R = 0.01;
rho = 7.86e3;
S = pi*R^2;
E = 210e9;
G =(210e9)/2.6;
IIn =  pi/4*R^4;
IOut =  pi/4*R^4;


%Material and Section
Sys.AddMaterial( 1 , 210e9 , .3 , 7.86e3 ); %Steel
Sys.AddSection( 1 , 3.1416e-06 , 7.8540e-13 , 7.8540e-13 , 1.5708e-12 ); %Round 1mm

%Nodes
Sys.AddNode( 0 , [ 0.5 ; 0 ; 0 ] ); %center
Sys.AddNode( 1 , [ 0 ; 0 ; 0 ] );
Sys.AddNode( 2 , [ 1 ; 0 ; 0 ] );
Sys.AddNode( 3 , [ 1 ; 1 ; 0 ] );%nodeRef

%Elements
Sys.AddCurvedElement( 1 , 1 , 2 , 0 , 1 , 1, 3 );
Sys.AddCurvedElement( 2 , 2 , 1 , 0 , 1 , 1, 3 );

%Limit Conditions
%Sys.BlockAll(1);

%Solving
Sys.InitializeMatrix();

figure();
F = [];
Y = [];

for f = 1:1:500
    
    M = (Sys.ProblemMatrix(f*2*pi));
    Y = [Y abs(det(M))];
    
    F = [F f];
end
plot(F,Y);
% -R <Ansys workbench script file>
%http://www.mechanicsandmachines.com/?p=306