import SYSTEM

%%

Sys = SYSTEM();

Sys.addNode(1,[0;0;0]);
%Sys.addNode(2,[0.5;0.5;0]);
Sys.addNode(2,[1;0;0]);
%Sys.addNode(4,[0.5;-0.5;0]);

Radius = 0.5;
R = 0.01;
rho = 7.86e3;
S = pi*R^2;
E = 210e9;
G =(210e9)/2.6;
IIn =  pi/4*R^4;
IOut =  pi/4*R^4;



Sys.addCurvedElement(1,1,2,rho,S,E,G,IIn,IOut,[0.5;0;0],[0;0;1]);
%Sys.addCurvedElement(2,2,3,rho,S,E,G,IIn,IOut,[0.5;0;0],[0;0;1]);
Sys.addCurvedElement(2,2,1,rho,S,E,G,IIn,IOut,[0.5;0;0],[0;0;1]);
%Sys.addCurvedElement(2,4,1,rho,S,E,G,IIn,IOut,[0.5;0;0],[0;0;1]);



A = Sys.findNodeById(1);
B = Sys.findNodeById(2);

%A.DeltaFree = zeros(6);

Sys.InitializeMatrix();

figure;
R = [];
Freq = [];
for freq = 40:0.001:45
    r = Sys.Determinant(2*pi*freq);
    R = [R r];
    Freq = [Freq freq];
end
plot(Freq,abs(R));
