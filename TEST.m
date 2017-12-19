import SYSTEM

Sys = SYSTEM();

Sys.addNode(1,[0;0;0]);
Sys.addNode(2,[1;0;0]);
Sys.addNode(3,[0;1;0]);

Sys.addElement(1,1,3,1,1,1,1,1,1);
Sys.addElement(2,1,2,1,1,1,1,1,1);
Sys.addElement(3,2,3,1,1,1,1,1,1);

Sys.showStructure();