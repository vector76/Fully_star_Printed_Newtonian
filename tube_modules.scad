module tube_bot(length=section_effective_length) {
  difference() {
    union() {
      segment(id=tube_id, wall=tube_wall, el=length, 
        topex=joint_overlap, botex=0);
    }
  }
}

module tube_mid(length=section_effective_length) {
  difference() {
    union() {
      segment(id=tube_id, wall=tube_wall, el=length, 
        topex=joint_overlap, botex=joint_overlap);
    }
  }
}


// values are based on external globals (customizer modified)
module tube_top(length=section_effective_length) {
  hole_zpos_last_seg = length - hole_from_end;
  difference() {
    union() {
      segment(id=tube_id, wall=tube_wall, el=length, 
        topex=0, botex=joint_overlap);
      // reinforce area near hole
      intersection() {
        tz(hole_zpos_last_seg) rotate([90, 0, 0])
        cylinder(d=hole_size+2*tube_wall, h=(tube_id+3*tube_wall)/2);
        cylinder(d=tube_od, h=length, $fn=p);
      }
    }
    
    // punch hole if this is the last segment
    tz(hole_zpos_last_seg) rotate([90, 0, 0])
    cylinder(d=hole_size, h=(tube_id+3*tube_wall)/2);
    
    // and also carve out inside of tube again
    cylinder(d=tube_id, h=length, $fn=p);
  }
}


module segment(id, wall, el, topex=0, botex=0) {
  clr=0.2;  // radial clearance between successive sections
  od = id+2*wall;
  
  // straight section
  difference() {
    tubeslice(h=el, id1=id, id2=id, od1=od, od2=od, p=p, botth=4+botex, topth=3);
    if (botex) hull() {
      tz(-0.1) cylinder(d=id+wall+clr, h=botex+0.1, $fn=p);
      tz((wall+clr)/2) cylinder(d=id, h=botex, $fn=p);
    }
  }
  if (topex) {
      //tz(el) cylinder(d=id+wall-clr, h=topex+0.1, $fn=p);
    difference() {
      tz(el-0.1) cylinder(d=id+wall-clr, h=topex+0.1, $fn=p);
      tz(el-0.5) cylinder(d=id, h=topex+1, $fn=p);
    }
  }
}


module tubeslice(h=10, od1=120, od2=120, id1=110, id2=110, p = 70, topth=0, botth=0) {
  // p = number of polygon sides
  owt = 0.8; // outer wall thickness
  iwt = 0.4; // inner wall thickness
  stt = 0.4; // thickness of struts (approx)
  ra = 0.03; // radial adjustment to ensure truss intersects with walls
  
  // outer wall
  difference() {
    cylinder(d1=od1, d2=od2, h=h, $fn=p);
    difference() {
      cylinder(d1=od1-2*owt, d2=od2-2*owt, h=h, $fn=p);
      if (topth > 0) { // remove top of part we are removing
        tz(h-topth) cylinder(d=max(od1, od2)+1, h=topth+1, $fn=p);
      }
      if (botth > 0) { // bottom of part we are removing
        tz(-1) cylinder(d=max(od1, od2)+1, h=botth+1, $fn=p);
      }
    }
    if (topth > 0 || botth > 0) { // need to remove inside
      cylinder(d1=id1, d2=id2, h=h, $fn=p);
    }
    // remove crap for visualization purposes
    tz(-0.05) cylinder(d1=id1-0.1, d2=id2-0.1, h=h+0.1, $fn=p);
  }

  // inner wall
  difference() {
    cylinder(d1=id1+2*iwt, d2=id2+2*iwt, h=h, $fn=p);
    cylinder(d1=id1, d2=id2, h=h, $fn=p);
    // remove crap for visualization purposes
    tz(-0.05) cylinder(d1=id1-0.1, d2=id2-0.1, h=h+0.1, $fn=p);
  }
  
  pth = 0.001;
  // strut (slightly twisted)
  xzalist = [ [ id1/2+iwt+stt/2-ra, 0, 0 ], [id2/2+iwt+stt/2-ra, h-pth, 0],
    [ od1/2-owt-stt/2+ra, 0, 360/p ], [ od2/2-owt-stt/2+ra, h-pth, 360/p] ];
  
  for (pa=[1:p/2]) rotate([0, 0, 2*pa*360/p])
  for (m=[0,1]) mirror([0, m, 0])
  for (ir=[[0, 1, 2], [1, 2, 3 ]]) hull() for (i=ir)
  rotate([0, 0, xzalist[i][2]]) translate([xzalist[i][0], 0, xzalist[i][1]])
  cylinder(d=stt, h=pth, $fn=16);
}


module tz(z) {
  translate([0, 0, z]) children();
}
