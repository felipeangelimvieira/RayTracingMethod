import SYSTEM

%%

Sys = SYSTEM();

Sys.addNode(1,[0;0;0]);
Sys.addNode(2,[1;0;0]);

rho = 7.86e3;
S = 0.01;
E = 210e9;
G =(210e9)/2.6;
IIn =  8.3e-6;
IOut = 8.3e-6;
Radius = 0.5;


Sys.addCurvedElement(1,1,2,7.86e3,.01,210e9,(210e9)/2.6,8.3e-6,8.3e-6,[0.5;0;0],[0;0;1]);
Sys.addCurvedElement(2,2,1,7.86e3,.01,210e9,(210e9)/2.6,8.3e-6,8.3e-6,[0.5;0;0],[0;0;1]);


A = Sys.findNodeById(1);
B = Sys.findNodeById(2);

%A.DeltaFree = zeros(6);

Sys.InitializeMatrix();

figure;
R = [];
Freq = [];
for freq = 10:20:3000
    r = Sys.Determinant(2*pi*freq);
    R = [R r];
    Freq = [Freq freq];
end
plot(Freq,abs(R));

n = 0:10;

phi=  (IIn/(S*Radius^2)*(n.^2)  + 1).*(n.^2+1);
psi = 4*IIn/(S*Radius^2)*(n.^2).*((n.^2-1).^2);
wn =  sqrt(E/(2*rho*Radius^2).*phi.*(1 - sqrt(1 - psi./(phi.^2))));