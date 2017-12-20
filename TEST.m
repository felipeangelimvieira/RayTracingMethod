import SYSTEM

Sys = SYSTEM();

Sys.addNode(1,[0;0;0]);
Sys.addNode(2,[20;0;0]);

Sys.addElement(1,1,2,1,1,1,1,1,1);

a = Sys.findElementById(1);

a.setElementPlane([0;0;1]);

A = Sys.findNodeById(1);
A.DeltaFree = zeros(6);

Sys.InitializeMatrix();

R = [];
Freq = [];
for freq = 1:1000
    r = Sys.Determinant(freq*2*pi);
    R = [R r]
    Freq = [Freq freq];
end
plot(abs(Freq),R);