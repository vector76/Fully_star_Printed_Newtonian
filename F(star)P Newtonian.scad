// Which part(s) to show
part = "Assembled";  // [ "Primary Mount", "Spider", "View Mount", "Tripod Strap", "Assembled", "Parts Flat", "Primary Aligner", "Aiming Reticle", "Eyepiece Mount", "Canon EF Mount", "Focus Estimator", "ESP32-Cam Mount", "Tube Bottom", "Tube Middle", "Tube Top", "Tube Demonstration", "Micro Dobs Assembled", "Micro Dobs Print Layout" ]
// Diameter of primary mirror (mm)
mirror_od = 114;
// Focal length (mm)
mirror_focal_length = 900;
// Thickness of primary mirror (mm)
mirror_thickness = 14; // 0.1
// Minor diameter of secondary mirror (mm)
secondary_size = 25;
// Thickness of secondary mirror (mm)
secondary_thickness = 5; // 0.1
// Purchased tube or printed?
tube_source = "Printed"; // [ Printed, Purchased ]
// Adjust model so supports are mostly unnecessary?
support_free = true;

/* [Printed Tube Options] */
// Maximum Z height of tube segments (mm)
max_print_ht = 210;

/* [Purchased Tube Parameters] */
// Inside diameter of purchased tube (mm)
purchased_tube_id = 89.2;
// Outside diameter of purchased tube (mm)
purchased_tube_od = 76.3;

module customizer_stop() {}

/* [Accessory Parameters] */
// Flange to focal distance
ef_mount_depth = 71; // 0.1

// Common variables for both tube and parts
part2 = "";
part_ = part2 == "" ? part : part2;  // override part with part2

// intended size of output projected image (magnification depends on focal length)
fov_size = 15;
// tube must be larger than mirror or it will block some of field of view
tube_id = tube_source == "Purchased" ? purchased_tube_id : mirror_od + fov_size;
// outer diameter
tube_od = tube_source == "Purchased" ? purchased_tube_od : tube_id + 2*5;
// thickness of tube wall
tube_wall = (tube_od-tube_id)/2;
// front of primary is this far back from end of tube (for length purposes)
primary_setback = 2;
// the strap for attaching stuff is this wide
mount_strap_width = 35;
// in front of mount strap, leave this much for the spider to grab onto
spider_clip_allowance = 20;
// center of side hole distance from tube front end
hole_from_end = spider_clip_allowance + mount_strap_width/2;
// size of hole matches mount strap
hole_size = 25;
// focus is this radial distance from outside of tube
mount_length = 75;
// focus is this distance from center of tube
focus_total_radius = mount_length + tube_wall + tube_id/2;
// distance from primary mirror to center of secondary
secondary_distance = mirror_focal_length - focus_total_radius;
// total tube length after assembly
tube_length = secondary_distance - primary_setback + mount_strap_width/2 + spider_clip_allowance;
// distance from mounting flange to focal plane (3 is thickness of flange)
flange_to_focus = mount_length - 3;

// These items are specific to the tube generation:

// joint between tubes overlaps by this much (tiny bit needed just for alignment)
joint_overlap = 3;
// number of tube sections given maximum printable Z
tube_sections = ceil(tube_length / (max_print_ht-joint_overlap));
// section effective length (excludes overlap)
section_effective_length = tube_length/tube_sections;
// number of facets (and internal corrugations)
p = floor(tube_id*PI/(tube_wall-1.2)*sqrt(2)/2)*2;

// Guidance for the user, printed or purchased:

echo("###########################################");
if (tube_source == "Purchased") {
  echo(str(" Cut tube to length: ", str(tube_length), " mm"));
  echo(str(" Hole center this far from end: ", str(mount_strap_width/2+spider_clip_allowance), " mm"));
  echo(str(" Hole diameter: ", str(hole_size), " mm"));
}
else {
  echo(str(" Printed tube total length: ", tube_length, " mm"));
  echo(str(" Printed tube outside diameter: ", tube_od, " mm"));
  echo(str(" Printed tube section height (excluding top lip):", section_effective_length, " mm"));
  echo(str(" Total number of tube segments: ", tube_sections));
}
echo("###########################################");

// Implementation below here
include <tube_modules.scad>
include <core_parts.scad>
include <accessories.scad>
include <micro_dobs_mount.scad>

// Core parts
if (part_ == "Primary Mount") { primary_mount(); }
if (part_ == "Spider") { spider(); }
if (part_ == "View Mount") { image_base_strap(); }
// Additional parts for main tube
if (part_ == "Tripod Strap") { tripod_strap(); }
if (part_ == "Alignment Guide") { test_strap_aiming(); }
// Some layouts/visualization?
if (part_ == "Assembled") { rotate([0, 45, 0]) tz(-tube_length/2) assembled(); }
if (part_ == "Parts Flat") { all_part_layout(); }
// Accessories
if (part_ == "Primary Aligner") { primary_crosshairs(); }
if (part_ == "Aiming Reticle") { test_strap_aiming(); }
// if (part == "Secondary Aligner") { secondary_crosshairs(); }
if (part_ == "Focus Estimator") { translate([0, 50, 0]) eyepiece_tube(ht=mount_length*2/3);  
    focus_estimator(); }
if (part_ == "Eyepiece Mount") { eyepiece_tube(); }
//if (part == "Eyepiece Mount w/ Fine Adjustment") { eyepiece_fine_adjust(); }
if (part_ == "Canon EF Mount") { EF_mount(); }
if (part_ == "ESP32-Cam Mount") { esp32_cam_adapter_mount(); 
  translate([60, 0, 0]) esp32_cam_adapter_flexure(); }
// Printed tubes
if (part_ == "Tube Top") { tube_top(); }
if (part_ == "Tube Middle") { tube_mid(); }
if (part_ == "Tube Bottom") { tube_bot(); }
if (part_ == "Tube Demonstration") { difference() { tube_bot(50); tz(25) cylinder(d=500, h=500); } }
// "Micro Dobsonian" mount
if (part_ == "Micro Dobs Assembled") { micro_dobs_assembled(); }
if (part_ == "Micro Dobs Print Layout") { micro_dobs_print_layout(); }
