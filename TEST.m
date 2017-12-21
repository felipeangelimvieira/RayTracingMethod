import SYSTEM

%%
Sys = SYSTEM();

Sys.addNode(1,[0;0;0]);
Sys.addNode(2,[.5;0;0]);
Sys.addNode(3,[1;0;0]);

Sys.addElement(1,1,2,7.86e3,.01,210e9,(210e9)/2.6,8.3e-6,8.3e-6);
Sys.addElement(2,2,3,7.86e3,.01,210e9,(210e9)/2.6,8.3e-6,8.3e-6);

%Sys.addElement(1,1,2,1,1,1,1,1,1);
%Sys.addElement(2,2,3,1,1,1,1,1,1);

a = Sys.findElementById(1);
b = Sys.findElementById(2);

a.setElementPlane([0;0;1]);
b.setElementPlane([0;0;1]);

A = Sys.findNodeById(1);
B = Sys.findNodeById(2);
C = Sys.findNodeById(3);

A.DeltaFree = zeros(6);

%%
Sys.showStructure();

%%
Sys.InitializeMatrix();

figure;
R = [];
Freq = [];
for freq = 10:10:3000
    r = Sys.Determinant(2*pi*freq);
    R = [R r];
    Freq = [Freq freq];
end
plot(Freq,abs(R));