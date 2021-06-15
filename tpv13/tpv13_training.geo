DefineConstant[ h_domain = {5e3, Min 0, Max 500e3, Name "Mesh spacing in domain" } ];
DefineConstant[ h_fault = {1000.0, Min 0, Max 30e3, Name "Mesh spacing on fault" } ];
DefineConstant[ h_nucl = {500.0, Min 0, Max 3e3, Name "Mesh spacing on nucleation patch" } ];
DefineConstant[ dip = {60.0, Min 0, Max 90, Name "Fault dip" } ];

SetFactory("OpenCASCADE");

l_f = 30e3;
w_f = 15e3;
dip_rad = dip*Pi/180.;

// Square nucleation patch in local coordinates
x_n = 0e3;
z_n = -12e3;
l_n = 3e3;
w_n = 3e3;

// Domain size: 3-4 times of the fault’s dimension
X0 = -45e3;
X1 = -X0;
Y0 = -36e3;
Y1 = -Y0;
Z0 = -42e3;

// Create the domain
domain = newv; Box(domain) = {X0, Y0, Z0, X1-X0, Y1-Y0, -Z0};

// Create the fault
fault = news; Rectangle(fault) = {-l_f/2, -w_f, 0, l_f, w_f};

// Create nucleation patch
nucl = news; Rectangle(nucl) = {x_n - l_n/2, z_n - w_n/2, 0, l_n, w_n};

// Rotate the fault
Rotate{ {1, 0, 0}, {0, 0, 0}, dip_rad } { Surface{fault, nucl}; }

// Intersect domain with fault
v() = BooleanFragments{ Volume{domain}; Delete; }{ Surface{fault, nucl}; Delete; };

// Recover surfaces
eps = 1e-3;
fault_final[] = Surface In BoundingBox{-l_f/2-eps, -w_f-eps, -w_f-eps, l_f/2+eps, w_f+eps, w_f+eps};
top[] = Surface In BoundingBox{X0-eps, Y0-eps, -eps, X1+eps, Y1+eps, eps};
other[] = Surface{:};
other[] -= fault_final[];
other[] -= top[];

// Set mesh spacing
MeshSize{ PointsOf{Volume{domain};} } = h_domain;
MeshSize{ PointsOf{Surface{fault_final[]};} } = h_fault;
MeshSize{ PointsOf{Surface{nucl};} } = h_nucl;

// Define boundary conditions
// free surface
Physical Surface(1) = {top[]};
// fault boundaries
Physical Surface(3) = {fault_final[]};
// absorbing boundaries
Physical Surface(5) = {other[]};

Physical Volume(1) = {domain};
Mesh.MshFileVersion = 2.2;
