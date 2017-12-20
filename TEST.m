import SYSTEM

Sys = SYSTEM();

Sys.addNode(1,[0;0;0]);
Sys.addNode(2,[20;0;0]);
Sys.addNode(3,[0;20;0]);

Sys.addElement(1,1,3,1,1,1,1,1,1);
Sys.addElement(2,1,2,1,1,1,1,1,1);
Sys.addElement(3,2,3,1,1,1,1,1,1);

a = Sys.findElementById(1);
b = Sys.findElementById(2);
c = Sys.findElementById(3);

a.setElementPlane([0;0;1]);
b.setElementPlane([0;0;1]);
c.setElementPlane([0;0;1]);

Sys.showStructure();