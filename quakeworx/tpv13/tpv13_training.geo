// definition of the default mesh discretisation and dip of the fault. The fault and nucleation patch here are set to require smaller elements 
// than the volume. This will lead to a statically refined mesh. The mesh discretisation can be changed within Min and Max values using the Gmsh GUI
DefineConstant[ h_domain = {5e3, Min 0, Max 500e3, Name "Mesh spacing within model domain" } ];
DefineConstant[ h_fault = {1000.0, Min 0, Max 30e3, Name "Mesh spacing on the fault" } ];
DefineConstant[ h_nucl = {500.0, Min 0, Max 3e3, Name "Refined mesh spacing within the fault nucleation patch" } ];
DefineConstant[ dip = {60.0, Min 0, Max 90, Name "Fault dip" } ];

// specifies the back-end of the CAD engine
SetFactory("OpenCASCADE");

// Length of the fault
l_f = 30e3;
// Width of the fault (along-dip)
w_f = 15e3;
dip_rad = dip*Pi/180.;

// Explicitly mesh the square nucleation patch, defined here in fault local coordinates 
// Hypocenter, z_n is here the depth along-dip
x_n = 0e3;
z_n = -12e3;
// Dimensions of the nucleation patch
l_n = 3e3;
w_n = 3e3;

// Domain size: 3-4 times of the fault’s dimension
X0 = -45e3;
X1 = -X0;
Y0 = -36e3;
Y1 = -Y0;
Z0 = -42e3;

// Create the domain as a box
domain = newv; Box(domain) = {X0, Y0, Z0, X1-X0, Y1-Y0, -Z0};

// Create the fault as a rectangle in the x-y plane, centered in x at the hypocenter
fault = news; Rectangle(fault) = {-l_f/2, -w_f, 0, l_f, w_f};

// Create the nucleation patch as a smaller rectangle
nucl = news; Rectangle(nucl) = {x_n - l_n/2, z_n - w_n/2, 0, l_n, w_n};

// Rotate the fault, according to its dip
Rotate{ {1, 0, 0}, {0, 0, 0}, dip_rad } { Surface{fault, nucl}; }

// Intersect the domain box with the fault rectangle at the free surface
v() = BooleanFragments{ Volume{domain}; Delete; }{ Surface{fault, nucl}; Delete; };

// Extract surfaces within the mesh for defining boundary conditions
eps = 1e-3;
fault_final[] = Surface In BoundingBox{-l_f/2-eps, -w_f-eps, -w_f-eps, l_f/2+eps, w_f+eps, w_f+eps};
top[] = Surface In BoundingBox{X0-eps, Y0-eps, -eps, X1+eps, Y1+eps, eps};
other[] = Surface{:};
other[] -= fault_final[];
other[] -= top[];

// Set mesh spacing of the domain, the fault and the nucleation patch
MeshSize{ PointsOf{Volume{domain};} } = h_domain;
MeshSize{ PointsOf{Surface{fault_final[]};} } = h_fault;
MeshSize{ PointsOf{Surface{nucl};} } = h_nucl;

// Define boundary conditions, note the SeisSol specific meaning of 1 = free surface, 3= dynamic rupture, 5 = absorbing boundary conditions
// free surface
Physical Surface(1) = {top[]};
// dynamic rupture
Physical Surface(3) = {fault_final[]};
// absorbing boundaries
Physical Surface(5) = {other[]};

Physical Volume(1) = {domain};
