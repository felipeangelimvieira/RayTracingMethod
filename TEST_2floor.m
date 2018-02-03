import SYSTEM

%%
Sys = SYSTEM();

Sys.addNode(1,[0;0;0]);
Sys.addNode(2,[1;0;0]);
Sys.addNode(3,[1;1;0]);
Sys.addNode(4,[0;1;0]);

Sys.addNode(5,[0;0;1]);
Sys.addNode(6,[1;0;1]);
Sys.addNode(7,[1;1;1]);
Sys.addNode(8,[0;1;1]);

E = 210e9;
G = (210e9)/2.6;
S = 0.0314;
I = 7.854e-05;
rho = 7.86e3;

Sys.addElement(1,1,5,rho,S,E,G,I,I);
Sys.addElement(2,2,6,rho,S,E,G,I,I);
Sys.addElement(3,3,7,rho,S,E,G,I,I);
Sys.addElement(4,4,8,rho,S,E,G,I,I);

Sys.addElement(5,5,6,rho,S,E,G,I,I);
Sys.addElement(6,6,7,rho,S,E,G,I,I);
Sys.addElement(7,7,8,rho,S,E,G,I,I);
Sys.addElement(8,8,5,rho,S,E,G,I,I);

a = Sys.findElementById(1);
b = Sys.findElementById(2);
c = Sys.findElementById(3);
d = Sys.findElementById(4);

a.setElementPlane([0;1;0]);
b.setElementPlane([0;1;0]);
c.setElementPlane([0;1;0]);
d.setElementPlane([0;1;0]);

e = Sys.findElementById(5);
f = Sys.findElementById(6);
g = Sys.findElementById(7);
h = Sys.findElementById(8);

e.setElementPlane([0;0;1]);
f.setElementPlane([0;0;1]);
g.setElementPlane([0;0;1]);
h.setElementPlane([0;0;1]);

A = Sys.findNodeById(1);
B = Sys.findNodeById(2);
C = Sys.findNodeById(3);
D = Sys.findNodeById(4);

A.DeltaFree = zeros(6);
B.DeltaFree = zeros(6);
C.DeltaFree = zeros(6);
D.DeltaFree = zeros(6);

root = fsolve(@Sys.Determinant,2*pi*150)/(2*pi)
W = Sys.associatedMode(root*2*pi)
Sys.showDeformatedStructure(W,root*2*pi,10);