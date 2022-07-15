

module assembled() {
  %cylinder(d=tube_od, h=tube_length);
  primary_mount();
  
  translate([0, 0, tube_length/2]) rotate([0, 0, 180]) tripod_strap();
  
  tz(tube_length) rotate([180, 0, 0]) spider();
  
  tz(secondary_distance-7.5-primary_setback) image_base_strap();
  
  for (z=[tube_length*0.1, tube_length*0.7])
  tz(z) rotate([0, 0, 140]) test_strap_aiming();
}


module all_part_layout() {
  layout = tube_od+15;

  translate([0, 0, mirror_thickness+7])
  r45() primary_mount();

  translate([0, layout, 5]) r45() spider();

  translate([-layout, 0, 12.5]) r45() tripod_strap();

  // for testing strap design and fit with OD
  // translate([layout, 0, 0]) r45() test_strap_aiming();

  translate([-layout, layout, 0]) r45() image_base_strap();

  translate([-layout, layout, 0]) eyepiece_tube();
}


module eyepiece_tube(ht=flange_to_focus, extra=0) {
  // ht is the height above the base where the focus is located
  w = 1.6;  // thinner than strap so they clamp independently
  tube_d = 25.4*1.25;  // base and eyepiece are same diameter
  
  // two straps
  ministrap(id=tube_d);
  translate([0, 0, ht-5]) ministrap(id=tube_d, feetht=support_free ? ht-15 : 0);
  
  // tube to connect them
  difference() {
    cylinder(d=tube_d+2*w, h=ht+5+extra, $fn=60);
    translate([0, 0, -0.5]) cylinder(d=tube_d, h=ht+5+extra+1, $fn=60);
    strap_slice(ht=ht+5+extra+1);
  }
  
}


module ministrap(id=25.4*1.25, wall=3, strap_w=10, slice_w=2, feetht=0) {
  feetw = 0.8;
  difference() {
    union() {
      cylinder(d=id+2*wall, h=strap_w, $fn=60);
      
      difference() {
        // block for clamping
        translate([id/2+wall-2, -5, -feetht])
          cube([10, 13, strap_w+feetht]);
        
        // remove feetht from bottom but only from the clamping block
        if (feetht > 0) {
          hull() for (dy=[0, 10])
          translate([id/2+wall-2.5, slice_w/2+feetw+dy, -feetht-dy-20])
          cube([13, 1, feetht+2*dy-7+20]);
          
          mirror([0, 1, 0]) hull() for (dy=[0, 10])
          translate([id/2+wall-2.5, slice_w/2+feetw+dy, -feetht-dy-20])
          cube([13, 1, feetht+2*dy-4+20]);
        }
      }
    }
    
    // bore
    translate([0, 0, -0.5]) cylinder(d=id, h=strap_w+1, $fn=60);
    
    // slice for clamping
    strap_slice(ht=strap_w+1+feetht, slice_w=slice_w);
    
    // screw holes for clamping
    translate([id/2+wall+3, 0, strap_w/2]) {
      rotate([90, 0, 0]) cylinder(d=3.6, h=12, $fn=12);
      rotate([-90, 0, 0]) cylinder(d=3, h=12, $fn=12);
      translate([0, -5.1, 0]) rotate([90, 0, 0]) cylinder(d=8, h=12, $fn=24);
    }    
  }
  
}


module r45() {
  rotate([0, 0, 45]) children();
}


module image_base_strap() {
  //sw = 15;  // width of thick part of strap
  //tw = 6;  // extra thin width added top and bottom
  sw = 28;
  tw = 0;
  st = 3;  // strap thickness (thick part)
  tl = 10;  // part of tube for grabbing
  
  difference() {
    union() {
      strap(wall=st, strap_w=sw, thinbot=tw, feetht=support_free ? tw : 0);
  
      translate([-tube_od/2-10-st, 0, sw/2])
      rotate([0, 90, 0]) {
        cylinder(d=31.75, h=tl+st, $fn=60);
        // flange provides decent flat surface rather than relying on tube od
        translate([0, 0, tl]) cylinder(d=41.75, h=st+5, $fn=60);
      }
    }
    
    // inside tube bore
    translate([0, 0, -tw-0.5]) cylinder(d=tube_od, h=sw+2*tw+1, $fn=120);
    
    // bore in tube
    translate([-tube_od/2-10-4, 0, sw/2]) 
    rotate([0, 90, 0])  cylinder(d=25, h=20, $fn=60);
    
    // cut off top and bottom
    for (z=[sw+tw, -50-tw]) translate([0,0,z]) cylinder(d=tube_od+2*tl+2*st+10, h=50);
  }
  
  %translate([-tube_od/2-3, 0, sw/2]) rotate([0, -90, 0]) eyepiece_tube();
}


module test_strap_aiming() {
  dist = 50;  // distance from OD of tube
  rib_w = 1.6;
  ring_od = 30;
  ring_r = ring_od/2;
  ring_th = 1.6;
  
  rotate([0, 0, 180]) strap(wall=2);
  
  difference() {
    union() {
      // three ribs support the ring
      for (a=[0, 15, -15]) hull() {
        rotate([0, 0, a]) 
        translate([tube_od/2+1, 0, 0]) cylinder(d=rib_w, h=10, $fn=24);
        translate([tube_od/2+dist-ring_r+1, a/6, 0]) cylinder(d=rib_w, h=10, $fn=24);
      }
      
      translate([tube_od/2+dist, 0, 0])
      cylinder(d=ring_od, h=10, $fn=60);
    }
    
    translate([tube_od/2+dist, 0, -0.5])
    cylinder(d=ring_od-2*ring_th, h=11, $fn=60);
  }
  
  // crosshairs
  translate([tube_od/2+dist, 0, 0]) for (a=[-45, 45]) rotate([0, 0, a])
  translate([-ring_r, -0.4, 0]) cube([ring_od, 0.8, 3]);
}

module strap_slice(ht=11, slice_w=2) {
  // slice ring and maybe other stuff
  translate([0, -slice_w/2, -ht]) cube([300/2+21, slice_w, 2*ht]);
}


module strap(wall=3, strap_w=10, clamp_extra=0, slice_w=2, extrabot=0, thinbot=0, feetht=0) {
  strap_mid = strap_w/2;
  thinw = 0.8;
  feetw = 0.8;
  
  // main strap
  difference() {
    union() {
      // main ring grips outside of tube
      hull() {
        translate([0, 0, -extrabot])
        cylinder(d=tube_od+2*wall, h=strap_w+extrabot, $fn=120);
      
        if (thinbot > 0) translate([0, 0, -extrabot-wall])
        cylinder(d=tube_od+2*thinw, h=strap_w+extrabot+2*wall, $fn=120);
      }
      
      if (thinbot > 0)
        translate([0, 0, -thinbot])
        cylinder(d=tube_od+2*thinw, h=strap_w+2*thinbot, $fn=120);
      
      difference() {
        // block for clamping, 5 one side, 8 other side, not counting slice
        translate([tube_od/2+wall-1, -5-clamp_extra, -feetht]) 
          cube([11, 13+clamp_extra, strap_w+feetht]);

        // remove feetht from bottom but only from the clamping block
        if (feetht > 0) {
          hull() for (dy=[0, 10])
          translate([tube_od/2+wall-1.5, slice_w/2+feetw+dy, -feetht-dy-20])
          cube([12, 1, feetht+2*dy-7+20]);
          
          mirror([0, 1, 0]) hull() for (dy=[0, 10])
          translate([tube_od/2+wall-1.5, slice_w/2+feetw+dy, -feetht-dy-20])
          cube([12, 1, feetht+2*dy-4+20]);
        }
      }
      
      if (feetht > 0) {
        translate([tube_od/2+wall-1, -5, -feetht]) 
        cube([11, 13, 1]);
      }
    }

    // bore for tube
    translate([0, 0, strap_mid-extrabot/2]) {
      cylinder(d=tube_od, h=strap_w+extrabot+2*thinbot+1, center=true, $fn=120);
    }

    // slice for clamping
    strap_slice(ht=strap_w+1+thinbot+extrabot+feetht, slice_w=slice_w);

    // screw holes for clamping
    translate([tube_od/2+wall+4, 0, strap_mid]) {
      rotate([90, 0, 0]) cylinder(d=3.6, h=12, $fn=12);
      rotate([-90, 0, 0]) cylinder(d=3, h=12, $fn=12);
      translate([0, -5.1, 0]) rotate([90, 0, 0]) cylinder(d=8, h=12, $fn=24);
    }
    
  }
}


module tripod_strap() {
  wall = 3;
  strap_w = 15;
  strap_mid = strap_w/2;
  block_len = 40;
  block_w = 39;
  block_th = 6.8;  // about 1.2 mm thick behind nut
  clamp_extra = 2;
  
  botamt = (block_len-strap_w)/2;
  
  difference() {
    union() {
      // strap included so bolt can be subtracted also
      rotate([0, 0, 130])
      strap(strap_w=strap_w, clamp_extra=clamp_extra, thinbot=botamt, feetht=support_free ? botamt : 0);
  
      // tripod block (silghtly wide to attach other blocks
      translate([-block_th-tube_od/2, -block_w/2-0.5, -block_len/2+strap_mid])
      cube([block_th+5, block_w+1, block_len]);
      
      *for (i=[0,1]) mirror([0, i, 0])
      translate([-tube_od/2-block_th-4, block_w/2, -block_len/2+strap_mid])
      cube([14, 3, block_len]);
    }
    
    // bore for tube (leaves material at ends of tripod block)
    translate([0, 0, strap_mid]) {
      cylinder(d=tube_od, h=block_len-8, center=true, $fn=120);
      cylinder(d=tube_od-0.6, h=block_len+1, center=true, $fn=120);
    }
    
    // pocket for 1/4-20 nut
    translate([-tube_od/2-5.6, 0, strap_mid]) rotate([0, 90, 0])
    cylinder(d=12.9, h=10, $fn=6);  // plenty tall, reaches inward
    
    // hole for 1/4-20 screw
    translate([-tube_od/2-block_th-0.5, 0, strap_mid]) rotate([0, 90, 0])
    cylinder(d=25.4/4, h=block_th+5, $fn=24);
    
  }
}


// front end holds secondary mirror
module spider() {
  stem_length = hole_from_end-secondary_thickness*sqrt(2);
  stem_d = secondary_size-5;
  spar_w = 0.8;
  base = 5;

  // strap for grabbing tube, extends downward to join with additional ring
  rotate([0, 0, 10])
  tz(5) strap(extrabot=base+5, feetht=support_free ? 5+5 : 0);
  
  difference() {
    translate([0, 0, -base]) cylinder(d=tube_od+1, h=base, $fn=120);

    // bore for primary mirror
    translate([0, 0, -base-0.5]) cylinder(d=tube_id, h=base+1, $fn=120);
    
    rotate([0, 0, 10])
    strap_slice();
    
    // holes for screw adjustments, either M3 or #6 sheet metal
    for (a=[60, 180, -60]) rotate([0, 0, 180+a])
      translate([(tube_od+tube_id)/4, 0, -base-1])
        cylinder(d=2.9, h=base+2, $fn=12);
  }
  
  // straight legs buckle when clamp is tightened.
  // how about some zig-zags for just a bit of compliance?
  xyh = [ [ stem_d/2, 0, 10], [ tube_id/2-10, 0, 10], [ tube_id/2-5, -8, 10], [tube_id/2-2, 0, base-1], [tube_id/2+1, 0, base-1]];
  
  for (a=[60, 180, -60]) rotate([0, 0, 180+a]) for (i=[0:len(xyh)-2]) hull() for (j=[0,1]) 
    translate([xyh[i+j][0], xyh[i+j][1], -base]) cylinder(d=spar_w, h=xyh[i+j][2], $fn=24);
  
  // stem
  difference() {
    union() {
      translate([0, 0, -base])
      cylinder(d=stem_d, h=stem_length+base+stem_d/2, $fn=24);
      
      // ribs for helping center the secondary which can be a bit weird
      translate([-0.4, -stem_d/2-2, -base]) cube([0.8, stem_d+4, stem_length+base-1]);
    }
    
    translate([0, 0, stem_length]) rotate([0, -45, 0])
    translate([-stem_d, -stem_d/2-0.5, 0]) cube([2*stem_d, stem_d+1, stem_d+1]);
    
    // cutout to allow clamping secondary in place for glue to set
    translate([stem_d/2+0.4, 0, stem_length-stem_d*.7]) rotate([90, 0, 0])
    cylinder(d=stem_d, h=stem_d+2, $fn=4, center=true);
  }
}


// Mount for primary mirror, attaches to back end of tube
module primary_mount_no_good() {
  wall = 3;
  // space between primary mirror front and tube end
  // Note: this is the gap if the mount sits flush against the end of the tube and
  // adjustment screws are not used at all to tweak the mirror angle.  The 
  // primary_setback variable describes essentially the same thing, except the 
  // primary_setback is an assumed "typical" value after adjusting alignment.
  // Otherwise, any primary alignment adjustment would pull the image plane back.
  axial_gap = 1;  
  
  plate_th = 4;   // thickness of plate behind mirror
  plate_rim = 2;
  mir_foot_ht = 2;
  mir_radial_gap = 1;
  mbz = -mirror_thickness-axial_gap;  // mirror bottom z coordinate
  arm_zth = 10;  // z thickness of support arms
  
  
  %tz(mbz) cylinder(d=mirror_od, h=mirror_thickness, $fn=120);

  // attachment strap (high to accommodate adjustment)
  tz(5) strap(extrabot=6, strap_w=15, feetht=support_free ? 5-mbz+arm_zth : 0);
  // tz(5) strap(extrabot=6, strap_w=15, feetht=0);
  
  // three arms supporting mirror
  for (a=[0, 120, 240]) rotate([0, 0, a]) {
    // main arm block
    translate([0, -5, mbz-arm_zth]) cube([mirror_od/2-2, 10, arm_zth]);
  
    translate([mirror_od/2-3, -5, mbz-arm_zth]) cube([4, 10, 3]);
    
    // finger at end to help center
    difference() {
      translate([mirror_od/2-1, -5, mbz-arm_zth]) cube([3, 10, arm_zth+4]);
      tz(mbz-11) cylinder(d=mirror_od+0.2, h=20, $fn=120);
    }
  }
  // central circle
  tz(mbz-arm_zth) cylinder(d=25, h=arm_zth-1, $fn=60);
  
  // conical support ring
  difference() {
    rotate_extrude($fn=120)
    polygon([[mirror_od/2+4, mbz-arm_zth], [mirror_od/2+4, 0], [tube_od/2+wall, 0], [tube_od/2+wall, -1], [mirror_od/2+6, mbz-arm_zth]]);
    
    strap_slice(ht=30);
    
    // screw hole
    for (a=[60, 180, -60]) rotate([0, 0, a]) {
      translate([tube_od/2-2.5, 0, -14]) {
        cylinder(d=2.9, h=15, $fn=12);
        %cylinder(d=7, h=3, $fn=12);
        %cylinder(d=2.8, h=15, $fn=12);
      }
      hull() for (dr=[0,10]) translate([tube_od/2-2.5+dr, 0, -33]) cylinder(d=8, h=30, $fn=30);
    }
  }
  
  // several thin segments so it's flexible in XY to allow clamp to operate
  for (mi=[0,1]) mirror([0, mi, 0]) r45() tz(mbz-arm_zth) for (dy=[6, 4, 2, 0, -2, -4]) 
    translate([0, -1+dy, 0]) cube([mirror_od/2+5, 1.6, arm_zth-1]);
}


// back end that holds primary mirror adjustment mechanism
module primary_mount() {
  wall = 3;
  axial_gap = 1;  // space between primary mirror front and tube end
  plate_th = 4;   // thickness of plate behind mirror
  plate_rim = 2;
  mir_foot_ht = 2;
  mir_radial_gap = 1;

  %translate([0, 0, -mirror_thickness-axial_gap])
    cylinder(d=mirror_od, h=mirror_thickness, $fn=120);
  
  tz(5) strap(strap_w=15, extrabot=6, feetht=support_free ? -cup_ext_z+5 : 0);
  
  cup_int_z = -mirror_thickness-axial_gap-mir_foot_ht;
  cup_ext_z = -mirror_thickness-axial_gap-mir_foot_ht-plate_th;
  
  // the outside slope goes from radius/Z of (tube_od/2+wall, -1) to (mirror_od/2+1+adj, cup_ext_z)
  // and the delta r should be less or equal to delta z.
  dr = tube_od/2+wall - (mirror_od/2+1);  // not including adjustment, which makes dr smaller
  dz = -cup_ext_z-1;
  
  // chose adjustment so dz >= dr - adj, adj >= dr-dz
  adj = max(0, dr-dz);
  
  difference() {
    rotate_extrude($fn=120)
    polygon([[mirror_od/2-0.5, cup_int_z], [mirror_od/2+adj, cup_int_z], 
      [tube_od/2-4, 0], [tube_od/2+wall, 0],  [tube_od/2+wall, -1], 
      [mirror_od/2+1+adj, cup_ext_z], [mirror_od/2, cup_ext_z]]);
    
    // tilted holes for screw adjustments, either M3 or #6 sheet metal
    for (a=[0, 120, 240]) rotate([0, 0, 180+a]) {
      // screw hole
      translate([tube_od/2-1.5, 0, 0]) rotate([0, -10, 0]) translate([0, 0, -14])  {
        cylinder(d=2.9, h=15, $fn=12);
        tz(-11) cylinder(d=7.5, h=20, $fn=24);
        %cylinder(d=7, h=3, $fn=12);
        %cylinder(d=2.8, h=15, $fn=12);
      }
    }
    
    strap_slice(ht=30);
  }
  
  tz(cup_ext_z) cylinder(d=mirror_od+1, h=plate_th, $fn=120);
  
  // feet for tape or glue
  for (a=[0, 120, 240]) rotate([0, 0, a])
  translate([-mirror_od/2+3, -9, cup_int_z]) cube([mirror_od/4, 18, mir_foot_ht]);
}


module tz(z) {
  translate([0, 0, z]) children();
}