import SYSTEM
%close all

%%
Sys = SYSTEM();

R = 0.00001;
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

Sys.AddNode( 0 , [ 0.5 ; 0 ; 0] ); %center
Sys.AddNode( 1 , [ 0 ; 0 ; 0 ] );
Sys.AddNode( 2 , [ 0.5 ; -.5 ; 0 ] );
Sys.AddNode( 3 , [ 1; 0 ; 0 ] );
Sys.AddNode( 4 , [ 0.1614 ; .3679 ; 0 ] );
Sys.AddNode( 5 , [ 0.5 ; -1 ; 0 ] );%nodeRef
Sys.AddNode( 6 , [ 0.5 ; 1 ; 0 ] );%nodeRef

%Elements
Sys.AddCurvedElement( 1 , 1 , 3, 0 , 1 , 1, 5 );
%Sys.AddCurvedElement( 2 , 3, 1, 0 , 1 , 1, 6 );
%Sys.AddCurvedElement( 3 , 3 , 4 , 0 , 1 , 1, 5 );
%Sys.AddCurvedElement( 2 , 1 , 3 , 0 , 1 , 1, 5 );


format long
%Limit Conditions
Sys.BlockAll(1);
%Sys.BlockAll(3);
%Sys.BlockAllRotation(2)

%Sys.BlockTranslationDirection(1,[0;1;0])
%Sys.BlockTranslationDirection(1,[0;0;1])
%Sys.BlockTranslationDirection(3,[0;0;1])
%Sys.BlockTranslationDirection(3,[1;0;0])
%Sys.BlockAllTranslation(1)
%Sys.BlockAllTranslation(3)

%Sys.BlockRotationDirection(1,[0;0;1])
%Sys.BlockRotationDirection(1,[0;1;0])
%Sys.BlockRotationDirection(3,[1;0;0])
%Sys.BlockRotationDirection(3,[0;1;0])
%Sys.BlockAllRotation(1)
%Sys.BlockAllRotation(3)
%Sys.BlockTranslationDirection(1,[0;0;1])
%Sys.BlockTranslationDirection(3,[0;0;1])

%Sys.BlockAll(3)
%Solving
Sys.InitializeMatrix();

figure();
F = [];
Y = [];

Sys.ModalAnalysis(5,0.001)

if 0
for f = 0.01:0.0001:.5    
    M = (Sys.ProblemMatrix(f*2*pi));
    Y = [Y abs(det(M))];
    
    F = [F f];
end
plot(F,Y);


el1 =  Sys.elementList{1};
%el2 = Sys.elementList {2};
end
pl = 0 ;
if pl
fList = Sys.FindModalFreqs2(0.8,0.1,9);

for f = fList
    w = f*2*pi;
    W = Sys.AssociatedMode(w);
    Sys.ShowDeformatedStructure(W,w);
end
end

test = 0
if test
ko = [];
ki = [];
Xi = [];
Xo = [];
fqs = 1:100:2000000;
el1 = Sys.elementList{1};
for f = 1:20:10000
    w = f*2*pi;
    k_temp = [el1.ko(w,1);el1.ko(w,2);el1.ko(w,3)];
    ko = [ko k_temp];
    k_temp = [el1.ki(w,1);el1.ki(w,2);el1.ki(w,3)];
    ki = [ki k_temp];
    
    x_temp = [el1.Xo(w,1);el1.Xo(w,2);el1.Xo(w,3)];
    Xo = [Xo x_temp];
    x_temp = [el1.Xi(w,1);el1.Xi(w,2);el1.Xi(w,3)];
    Xi = [Xi x_temp];
    
end
    
figure, subplot(1,3,1), plot(fqs,abs(ki(1,:))), subplot(1,3,2),plot(fqs,abs(ki(2,:))),subplot(1,3,3),plot(fqs,abs(ki(3,:)))
figure, subplot(1,3,1), plot(fqs,abs(ko(1,:))), subplot(1,3,2),plot(fqs,abs(ko(2,:))),subplot(1,3,3),plot(fqs,abs(ko(3,:)))

figure, subplot(1,3,1), plot(fqs,abs(Xi(1,:))), subplot(1,3,2),plot(fqs,abs(Xi(2,:))),subplot(1,3,3),plot(fqs,abs(Xi(3,:)))
figure, subplot(1,3,1), plot(fqs,abs(Xo(1,:))), subplot(1,3,2),plot(fqs,abs(Xo(2,:))),subplot(1,3,3),plot(fqs,abs(Xo(3,:)))
end

% -R <Ansys workbench script file>
%http://www.mechanicsandmachines.com/?p=306