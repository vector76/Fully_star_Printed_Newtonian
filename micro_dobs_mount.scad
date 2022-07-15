include <unwin_modules.scad>

// four bolts are on a circle this big
bolt_d = 75;
gear_od = 150;
sm_gear_od = 22;
pitch_d = gear_od/2-1.5;
sm_pitch_d = 20/2;
gear_center_dist = pitch_d+sm_pitch_d;
ntbig = floor(pitch_d*PI/3);
ntsm = floor(sm_pitch_d*PI/3);


module micro_dobs_assembled() {
  swing_vis();  
  
  tz(-65/2) dob_strap();
  arm_small();
  arm_big();
  translate([0, tube_od/2+10]) rotate([-90, 0, 0]) mini_pivot();
  translate([0, -tube_od/2-10]) rotate([90, 0, 0]) mega_pivot();
  
  translate([0, -tube_od/2-10, -gear_center_dist]) rotate([90, 0, 0]) tz(-4)
  gear_small();
  translate([0, -tube_od/2-10, -gear_center_dist]) rotate([90, 0, 0]) tz(22-1)
  gear_small_cap();  
}


module micro_dobs_print_layout() {
  dob_strap();
  translate([0, tube_od/2+40, 0]) {
    gear_small();
    translate([50, 0, 0]) gear_small_cap(); 
  }

  translate([0, tube_od/2+90, 0]) rotate([-90, 0, 0]) 
  translate([0, -(tube_od/2+10+5+15), 0]) arm_small();
  
  translate([0, -tube_od/2-130, 0]) rotate([90, 0, 0]) 
  translate([0, tube_od/2+10+18, 0]) arm_big();
  
  mini_pivot();
  translate([tube_od/2+150/2+30, 0, 0]) mega_pivot();
}

module gear_small_cap() {
  cap_th = 7;
  arm_th = 5;
  arm_w = 25;
  arm_l = 150;
  
  difference() {
    union() {
      cylinder(d=sm_gear_od+10, h=cap_th, $fn=60);
      translate([0, -arm_w/2, 0]) cube([arm_l, arm_w, arm_th]);
      translate([arm_l, 0, 0]) cylinder(d=arm_w, h=arm_th, $fn=60);
      translate([arm_l, 0, 0]) cylinder(d=15, h=30, $fn=60);
    }
    tz(-1) cylinder(d=14.2, h=6, $fn=6);
    tz(-1) cylinder(d=3.5, h=10, $fn=12);
  }
}

module gear_small() {
  gear_w = 22;
  
  difference() {
    union() {
      // flange
      cylinder(d=sm_gear_od+10, h=3, $fn=60);  
      // extruded gear shape
      tz(2.5) linear_extrude(height=gear_w+0.5) rotate([0, 0, 18]) 
      intersection() {
        // gear
        gp2(ntbig, ntsm, gear_center_dist, 1.5, 1.5, 0.1, $fn=120);
        // crop to circular OD
        circle(d=sm_gear_od, $fn=120);
      }
      // hex on end
      tz(gear_w+3) cylinder(d=14, h=5, $fn=6);
    }
    
    // hole for screw
    tz(3+gear_w+5-11) cylinder(d=2.9, h=12, $fn=12);
  }
  
}

module arm_big() {
  ys = -tube_od/2-10-15;  // y location of outer surface of large gear
  bard = 3;
  barr = bard/2;
  
  // two pads for gear to slide on
  for (a=[45, 135]) rotate([0, a, 0])
  difference() {
    translate([gear_od/2-5, ys-3, -30]) cube([10, 18, 60]);
    translate([0, ys, 0]) rotate([-90, 0, 0]) cylinder(d=gear_od, h=16, $fn=120);
  }
  
  xz1 = [78, -36];  // far 1
  xz2 = [36, -78];  // far 2
  xz3 = [57, -95];  // near below
  
  xz4 = [-78, -36];  // near 1
  xz5 = [-36, -78];  // near 2
  xz6 = [-57, -95];  // near below
  
  xz7 = [-12, -74];  // mid 1
  xz8 = [12, -74];   // mid 2
  xz78 = [ 0, -105];  // halfway and down
  
  // spot for small spur gear to turn within
  difference() {
    triple_fill2([xz7, xz8, xz78, xz3, xz6, xz2, xz5]);

    *translate([-sm_gear_od/2-3, ys-3, -gear_center_dist-sm_gear_od/2-3])
    cube([sm_gear_od+6, 18, sm_gear_od+6]);
    
    translate([0, ys-4, 0]) rotate([-90, 0, 0]) cylinder(d=gear_od+1, h=20, $fn=120);
    
    translate([0, ys-3.5, -gear_center_dist]) rotate([-90, 0, 0])
    cylinder(d=sm_gear_od+0.5, h=19, $fn=60);
  }
  
  triple_fill2([xz1, xz2, xz3]);
  triple_fill2([xz4, xz5, xz6]);
  
  xz9 = [ -tube_od+barr, -tube_od/2+barr ];
  xz9b = [ -tube_od+barr, -tube_od/2+barr+5 ];
  xz10 = [ -tube_od/2+5, -tube_od/2+barr ];
  triple_fill2([xz4, xz9, xz9b, xz10]);
  
  translate([-tube_od, ys-3+5, -tube_od/2]) rotate([0, 0, 180]) foot();

  translate([-tube_od/2-5, ys+15, -tube_od/2]) rotate([0, 0, 90]) foot();
}

module triple_fill2(xzl) {
  hull() for (j=[0:len(xzl)-1]) translate([xzl[j][0], -tube_od/2-10-15-3, xzl[j][1]]) 
  rotate([-90, 0, 0]) cylinder(d=3, h=18, $fn=24);
}

module arm_small() {
  ys = tube_od/2+10+5;  // y location of outer surface of plate
  difference() {
    translate([-9, ys+1, -9]) cube([18, 14, 9]);
    translate([0, ys, 0]) rotate([-90, 0, 0]) cylinder(d=8, h=10, $fn=36);
  }
  
  bard = 3;
  barr = bard/2;
  yz1 = [9-barr, -9];  // forward bottom corner
  yz2 = [-9, -9];  // back bottom corner
  yz3 = [-tube_od/2, -tube_od/2+barr];  // corner of plank
  yz4 = [-9, -barr];  // back top corner
  yz5 = [-tube_od/2, -barr];  // up high at edge of plank
  yz6 = [-tube_od, -tube_od/2+barr];  // back back corner
  
  triple_fill(yz1, yz2, yz3);
  triple_fill(yz4, yz2, yz3);
  triple_fill(yz4, yz5, yz3);
  triple_fill(yz6, yz5, yz3);
  
  translate([-tube_od, ys+10, -tube_od/2]) rotate([0, 0, 180]) foot();
  translate([-tube_od/2-5, ys+5, -tube_od/2]) rotate([0, 0, -90]) foot();
  
  //translate([-tube_od/2-2.4, ys+5-30, -tube_od/2]) cube([2.4, 31, 20]);
  //translate([-tube_od/2-2.4, ys+5-25, -tube_od/2]) rotate([0, 0, 180]) foot();
}

module triple_fill(yz1, yz2, yz3) {
  ys = tube_od/2+10+5;  // y location of outer surface of plate
  bard = 3;
  hull() {
    translate([yz1[0], ys+5, yz1[1]]) rotate([-90, 0, 0]) cylinder(d=bard, h=10, $fn=24);
    translate([yz2[0], ys+5, yz2[1]]) rotate([-90, 0, 0]) cylinder(d=bard, h=10, $fn=24);
    translate([yz3[0], ys+5, yz3[1]]) rotate([-90, 0, 0]) cylinder(d=bard, h=10, $fn=24);
  }
}

module swing_vis() {
  // must keep out of this zone
  %for (a=[0, -45, -90]) rotate([0, a, 0]) 
    cylinder(d=tube_od, h=500, center=true, $fn=120);
  
  // board is about here
  %translate([-300-tube_od/2, -150, -tube_od/2-13]) cube([300, 300, 13]);
}


module foot() {
  difference() {
    translate([-1, -5, 0]) cube([11, 10, 5]);
    translate([5, 0, -0.5]) cylinder(d=3.5, h=6, $fn=12);
  }
}

module dob_strap(w=65) {
  strapw = 10;
  delta = w-strapw;
  bolt_d2 = bolt_d/sqrt(2);
  
  for (z=[0, delta]) tz(z) strap(strap_w=strapw, feetht=(z > 0) ? w-2*strapw+1 : 0);
 
  difference() {
    tz(strapw/2) cylinder(d=tube_od+1.6, h=delta, $fn=120);
    cylinder(d=tube_od, h=w, $fn=120);
    strap_slice(ht=w);
  }
  
  for (yi=[0,1]) mirror([0, yi, 0])
  difference() {
    // bars for attaching wheels (10mm from OD surface)
    for (x=[bolt_d2/2-5, -bolt_d2/2-5]) translate([x, -tube_od/2-10, 0]) cube([10, 25, w]);
  
    translate([0, -tube_od/2-11, w/2]) rotate([-90, 0, 0])
    for (a=[0, 90, 180, 270]) rotate([0, 0, 45+a])
    translate([bolt_d/2, 0, 0]) cylinder(d=2.9, h=12, $fn=12);
    
    // carve out interior bore
    tz(-0.5) cylinder(d=tube_od, h=w+1, $fn=120);
  }
  
  // %translate([0, tube_od/2+10, w/2]) rotate([-90, 0, 0]) mini_pivot();
  // %translate([0, -tube_od/2-10, w/2]) rotate([90, 0, 0]) mega_pivot();
}


module mini_pivot() {
  plate_th = 5;
  cbore = 2;
  
  difference() {
    cylinder(d=bolt_d+10, h=5, $fn=120);
    for (a=[0, 90, 180, 270]) rotate([0, 0, 45+a]) {
      translate([bolt_d/2, 0, -0.5]) cylinder(d=3.5, h=6, $fn=12);
      translate([bolt_d/2, 0, plate_th-cbore]) cylinder(d=7, h=cbore+1, $fn=24);
    }
  }
  
  cylinder(d=8, h=plate_th+10, $fn=60);
}


module mega_pivot() {
  gear_w = 15;
  cbore = 1;
  plate_th = 3;
    
  *translate([0, -gear_center_dist, 0])
  linear_extrude(height=gear_w)
  rotate([0, 0, 18]) 
  intersection() {
    gp2(ntbig, ntsm, gear_center_dist, 1.5, 1.5, 0.1, $fn=120);
    circle(d=sm_gear_od, $fn=120);
  }
  
  difference() {
    linear_extrude(height=gear_w)
    intersection() {
      gp1(ntbig, ntsm, gear_center_dist, 1.5, 1.5, 0.1, $fn=120);
      circle(d=gear_od, $fn=120);
    }
    
    tz(plate_th) cylinder(d=gear_od-10, h=gear_w, $fn=120);
    
    for (a=[0, 90, 180, 270]) rotate([0, 0, 45+a]) {
      translate([bolt_d/2, 0, -0.5]) cylinder(d=3.5, h=6, $fn=12);
      translate([bolt_d/2, 0, plate_th-cbore]) cylinder(d=7, h=cbore+1, $fn=24);
    }
  }
  
  // rib across center
  for (a=[0, 45, 90, 135, 180, -45, -90, -135]) rotate([0, 0, a])
  translate([0, 10, 0]) tz(gear_w/2) cube([gear_od-5, 0.8, gear_w], center=true);
}