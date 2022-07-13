use <core_parts.scad>  // for ministrap


module primary_crosshairs() {
  wall = 1.6;
  gap = 0.3;
  
  difference() {
    cylinder(d=tube_od+2*gap+2*wall, h=5, $fn=120);
    tz(-0.5) cylinder(d=tube_od+2*gap, h=6, $fn=120);
  }

  // second ring on mirror OD doesn't make a difference with alignment but may be handy
  // for locating the center of the primary.
  difference() {
    cylinder(d=mirror_od+2*gap+2*wall, h=5, $fn=120);
    tz(-0.5) cylinder(d=mirror_od+2*gap, h=6, $fn=120);
  }
  
  for (a=[0, 90]) rotate([0, 0, a])
  tz(0.6) cube([tube_od+1*gap+wall, 1, 1.2], center=true);
}


// secondary crosshairs not really necessary
module secondary_crosshairs() {
  sec_od = 1.25*25.4;
  
  wall = 1.6;
  gap = 0.3;
  
  difference() {
    cylinder(d=sec_od+2*gap+2*wall, h=5, $fn=120);
    tz(-0.5) cylinder(d=sec_od+2*gap, h=6, $fn=120);
  }
  
  for (a=[0, 90]) rotate([0, 0, a])
  tz(0.4) cube([sec_od+1*gap+wall, 1, 0.8], center=true);
}


module EF_mount(clamph=8, mount_depth=ef_mount_depth) {
  efraised = mount_depth-44 - 1;
  // focus is 44.0 mm behind the flange of the mount
  // make it slightly short to allow it to move 1mm closer
  
  // strap
  ministrap(strap_w=clamph);
  // legs
  for (a=[-90, 0, 90]) rotate([0, 0, a]) translate([-32, -1.5, 0]) cube([14, 3, clamph]);

  // ef mount, raised, with a hole for screw access
  difference() {
    EF_mount_raised(h=efraised);
    translate([22, -9, clamph/2]) rotate([90, 0, 0]) cylinder(d=7, h=100, $fn=24);
  }
}


module EF_mount_raised(h=5) {
  wall = 2;
  translate([0, 0, h]) import("Canon_EF_mount_by_thenickdude.stl");

  // slope downward from x=24.3, y=h-1.05 by y=-x+24.3+h-1.05 at x=32.3-wall
  vy = max(0, -32.3+wall+24.3+h-1.05);
  
  difference() {
    union() {
      // %cylinder(d=64.6, h=h-0.95, $fn=120);
      rotate_extrude($fn=200)
      polygon([[32.3-wall, 0], [32.3, 0], [32.3, h-1.05], [24.3, h-1.05], [32.3-wall, vy]]);
    }
    translate([0, 0, -0.5]) cylinder(d=48.6, h=h, $fn=120);
  }
}


module focus_estimator(ht=(mount_length-13)*2/3) {
  w = 0.8;  // thinner than strap so they clamp independently
  tube_d = 25.4*1.25;  // base and eyepiece are same diameter
  
  difference() {
    union() {
      translate([-25, -25, 0]) cube([50, 50, 2]);
      cylinder(d=tube_d, h=ht, $fn=60);
    }
    translate([0, 0, -0.5]) cylinder(d=tube_d-2*w, h=ht+5+1, $fn=60);
  }
}



// work in progress, not ready for release
module eyepiece_fine_adjust(ht=flange_to_focus) {
  // ht is the height above the base where the focus is located
  w = 1.6;  // thinner than strap so they clamp independently
  tube_d = 25.4*1.25;  // base and eyepiece are same diameter
  
  wing_w = 15;
  wing_l = 60+tube_d/2;
  wing_th = 0.6;
  neutral = 6;
  
  // bottom part
  translate([wing_l, wing_l+wing_w+15, 0]) {
    ministrap(id=tube_d);
    
    difference() {
      union() {
        // wings
        for (a=[60, 180, -60]) rotate([0, 0, a]) {
          translate([0, -wing_w/2, 0]) cube([wing_l+1, wing_w, wing_th]);
          // block at end
          translate([wing_l, -wing_w/2, 0]) cube([10, wing_w, neutral+2]);
        }
        // block for deflecting flexure
        rotate([0, 0, -120]) translate([0, -5, 0]) cube([tube_d/2+20, 10, 6]);
      }
      
      // bore out id again
      tz(-0.5) cylinder(d=tube_d, h=11, $fn=60);
      for (a=[60, 180, -60]) rotate([0, 0, a]) {
        // holes in wings
        translate([wing_l+5, 0, -0.5]) cylinder(d=2.9, h=neutral+3, $fn=12);
        // 2mm recess for top part
        translate([wing_l, -5, neutral]) cube([11, 10, 10]);
        translate([wing_l+1-10, -wing_w/2-0.5, neutral]) cube([10, wing_w+1, 10]);
      }
    }
  }
    
  // top part
  // upper strap 10mm shorter than fixed eyepiece
  translate([0, 0, ht-5-10]) ministrap(id=tube_d, feetht=support_free ? ht-5-10 : 0);
  
  // wings and 
  difference() {
    union() {
      // tube
      cylinder(d=tube_d+2*w, h=ht+5-10, $fn=60);
      // bottom reinforcement
      cylinder(d=tube_d+6, h=3, $fn=60);
      // wings
      for (a=[60, 180, -60]) rotate([0, 0, a]) {
        // flexure
        translate([0, -wing_w/2, 0]) cube([wing_l+1, wing_w, wing_th]);
        // block at end for attachment
        translate([wing_l, -10/2, 0]) cube([10, 10, 5]);
      }
      // block for deflecting flexure
      rotate([0, 0, -120]) translate([0, -5, 0]) cube([tube_d/2+20, 10, 6]);
    }
    // bore out inside diameter
    translate([0, 0, -0.5]) cylinder(d=tube_d, h=ht+5+1, $fn=60);
    // cut strap
    strap_slice(ht=ht+5+1);
    // holes in wings
    for (a=[60, 180, -60]) rotate([0, 0, a]) translate([wing_l+5, 0, -0.5]) cylinder(d=3.5, h=6, $fn=12);
    // hole for deflecting flexure
    rotate([0, 0, -120]) translate([tube_d/2+15, 0, -0.5]) cylinder(d=2.9, h=10, $fn=12);
  }
}


module esp32_cam_adapter_mount(nominal_ht=mount_length-3) {
  tube_d = 25.4*1.25;  // base diameter
  hole_offset = 8;  // shift holes to the side
  sup_w = 17;
  tower_ht = nominal_ht + 50;
  
  // strap to grab view mount boss
  ministrap(id=tube_d);
  
  // tower and rectangluar light baffle
  difference() {
    union() {
      // tower
      translate([-19-5, -20/2-hole_offset, 0]) {
        cube([5, 20, tower_ht]);  // main tower
        cube([20, 20, 10]); // foot connection to ministrap
        // guides to prevent offset installlation
        for (y=[0, 19]) translate([0, y, 0]) cube([7, 1, tower_ht]);
      }
      // baffle
      for (x=[-20, 40-0.8]) translate([x, -20, 0]) cube([0.8, 40, nominal_ht+15]);
      for (y=[-20, 20-0.8]) translate([-20, y, 0]) cube([60, 0.8, nominal_ht+15]);
    }
    
    // perforations
    for (yi=[-1, 0, 1])
    for (z=[nominal_ht:5:tower_ht-5])
    translate([-19-6, yi*5-hole_offset, z+yi*5/3]) rotate([0, 90, 0]) 
    cylinder(d=3.5, h=12, $fn=12);

    // bore out space for boss again
    translate([0, 0, -0.5]) cylinder(d=tube_d, h=26, $fn=60);
    
    // access hole for screw
    translate([tube_d/2+6, 0, 5]) rotate([90, 0, 0]) cylinder(d=7, h=50, $fn=30);
  }
  
  %translate([0, 0, nominal_ht]) rotate([-90, 0, 0]) translate([-9, -4, -27/2]) esp32_cam_adapter_flexure();
}


module esp32_cam_adapter_flexure() {
  ht=30;
  tube_d = 25.4*1.25;  // base diameter
  cam_w = 27;
  cam_l = 40;
  cam_ypos = 9;  // camera center is 9mm from one end, centered along width
  
  cam_th = 1.5;
  slot_depth = 3;
  slot_end = 2;
  slot_end2 = 7;
  flex_th = 0.8;
  
  sup_w = 17;
  flex_ht = sup_w; // cam_w/2;
  flex_x = cam_l-2;
  
  hole_offset = 8;  // shift holes downward
  
  // bottom below camera
  translate([0, -3-10, -3]) cube([cam_l, 10+6+cam_th, 3]);
  
  difference() {
    union() {
      translate([-3, -3, -3]) cube([3+slot_end, 6+cam_th, 3+slot_depth]);
      translate([cam_l-slot_end2,-3,-3]) cube([slot_end2+3, 6+cam_th, 3+slot_depth]);
    }
    cube([cam_l, cam_th, cam_w]);
  }
  
  // vertical stem
  translate([cam_l-3, cam_th, 0]) difference() {
    cube([6, 3, cam_w]);
    // cavity so it doesn't jam in the middle and skew it
    translate([-0.1, -0.5, 3]) cube([4, 1.5, cam_w-8]);
  }
  
  // intermediate
  translate([flex_x, -50-2.5, -3]) cube([5, 35, flex_ht]);
  
  for (y=[-20, -50]) {
    // stage 1 flexures
    hull() {
      translate([flex_x, y, -3]) cylinder(d=flex_th, h=flex_ht, $fn=36);
      translate([-5, y+5, -3]) cylinder(d=flex_th, h=flex_ht, $fn=36);
    }
    
    // stage 2 flexures
    hull() {
      translate([flex_x, y-2, -3]) cylinder(d=flex_th, h=flex_ht, $fn=36);
      translate([0, y-7, -3]) cylinder(d=flex_th, h=flex_ht, $fn=36);
    }
  }
  
  // final stage of flexure?
  difference() {
    translate([-3, -50-10, -3]) cube([3, 58, cam_w+3]);
    for (y=[-20, -50]) translate([-3.5, y-6, -3.1]) cube([6, 12, flex_ht+2.1]);
  }
  
  // support and holes for mounting screw
  difference() {
    translate([-10, -62, -3]) cube([5, 55, sup_w]);
    for (zi=[-1, 0, 1])
    for (y=[-30, -10]) translate([-11, y, cam_w/2+zi*5-hole_offset]) 
      rotate([0, 90, 0]) cylinder(d=2.9, h=12, $fn=12);
  }
  
  // top ledge and spot for focus adjustment screw
  translate([-10, -62-1.5, -3])
  difference() {
    cube([15, 3, sup_w]);
    translate([8.5, -1, flex_ht/2]) rotate([-90, 0, 0]) cylinder(d=2.9, h=10, $fn=12);
  }
  
  
  // top diving board and focus adjustment screw
  *difference() {
    translate([-10, -55-5, -3]) cube([cam_l+10+2+5, 5, cam_w-1]);
  
    translate([cam_l+2+2.5, -61, (cam_w-1)/2-3])
    rotate([-90, 0, 0]) cylinder(d=2.9, h=12, $fn=12);
  }
  
  // visualize board and camera
  %cube([cam_l, cam_th, cam_w]);
  %translate([cam_ypos, cam_th, cam_w/2]) 
  rotate([-90, 0, 0]) cylinder(d=8, h=8, $fn=24);
  
  // from center of camera to surface of support plate is 19 mm.
  // focal plane is about 4mm from back surface
  // so focal plane to mounting hole is about 34 mm
  // with focus about 30mm above base, we need 64 mm from base to mounting hole

}
