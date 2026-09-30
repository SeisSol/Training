
// Define a variable. This will be used as the target cell size in the mesh
h_min = 1e-2;

// Define points
Point(1) = {0, 0, 0, h_min};
Point(2) = {.3, 0,  0, h_min};
Point(3) = {.3, .2, 0, h_min};
Point(4) = {0,  .2, 0, h_min};

// Define lines, a type of curve, which is one of GMSH's elementary entities.
// Lines are directed, from the start point to the end point. 
Line(1) = {1, 2};
Line(2) = {3, 2};
Line(3) = {3, 4};
Line(4) = {4, 1};

// The third elementary entity is the surface
// In order to define a surface (the third elementary entity), 
// we must first define a curve loop. The curve loop is sensitive 
// to the directionality of the lines.
Curve Loop(1) = {4, 1, -2, 3};

// We can then define the surface as a list of curve loops 
Plane Surface(1) = {1};

// Elementary geometrical entities can be assigned to physically meaningful groups
// To do this, we define "physical groups", such as physical points, physical curves, 
// physical surfaces, or physical volumes. 

Physical Curve(5) = {1, 2, 4};
Physical Surface(66) = {1};