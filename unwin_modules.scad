module hbone(nteeth, ht) {
  // twist is one tooth (360/nteeth) per half-height
  linear_extrude(height=ht/2, twist=360/nteeth)
  children();
  
  rotate([0, 0, -360/nteeth])
  translate([0, 0, ht/2])
  linear_extrude(height=ht/2, twist=-360/nteeth)
  children();
  
}

module gp1(nteeth1, nteeth2, centerdist, add1, add2, clearance) {
  // pitchr1 / pitchr2 = nteeth1 / nteeth2
  // and pitchr1+pitchr2 = centerdist
  // pitchr1 = pitchr2 * nteeth1 / nteeth2
  // pitchr2*(nteeth1/nteeth2) + pitchr2 = centerdist
  pitchr2 = centerdist / (1 + nteeth1/nteeth2);
  pitchr1 = centerdist - pitchr2;
  gear(pitchr1*2, add1, nteeth1, (pitchr1-add2-clearance)*2);
}

module gp2(nteeth1, nteeth2, centerdist, add1, add2, clearance) {
  // pitchr1 / pitchr2 = nteeth1 / nteeth2
  // and pitchr1+pitchr2 = centerdist
  // pitchr1 = pitchr2 * nteeth1 / nteeth2
  // pitchr2*(nteeth1/nteeth2) + pitchr2 = centerdist
  pitchr2 = centerdist / (1 + nteeth1/nteeth2);
  pitchr1 = centerdist - pitchr2;
  gear(pitchr2*2, add2, nteeth2, (pitchr2-add1-clearance)*2);
}


module gearpair(nteeth1, nteeth2, centerdist, add1, add2, clearance) {
  gp1(nteeth1, nteeth2, centerdist, add1, add2, clearance);
  
  translate([0, centerdist, 0])
  mirror([0, 1, 0])
  rotate([0, 0, 360/(2*nteeth2)])
  gp2(nteeth1, nteeth2, centerdist, add1, add2, clearance);
}


module gear(pitchd, addendum, nteeth, rootd) {
  intersection() {
  for (i=[0:nteeth-1]) {
    rotate([0, 0, i*360/nteeth])
    unwin_tooth(pitchd, addendum, nteeth);
  }
  circle(d=pitchd+2*addendum);
  }
  circle(d=rootd);
}


// dedendum not used, teeth are defined independent and can be cropped later
// Unwin uses addendum to optimize curve to middle of tooth
module unwin_tooth(pitchd, addendum, nteeth) {
  pitchrad = pitchd/2;
  pa = 20;  // pressure angle is 20 degrees
  
  based = pitchd * cos(pa);  // base circle diameter
  baserad = based/2;
  od = pitchd+2*addendum;    // outside diameter

  // circle through point C
  circ_c = (od + od + based) / 3;

  // x/y coordinates of point C
  ptc_x = 0;
  ptc_y = circ_c/2;
  
  // point D is on base circle such that O->D and D->C is right angle
  // O->D is of length based/2
  // O->C is of length circ_c/2 (or ptc_y)
  // so cosine of angle (at O) is O->D / O->C
  // nevermine arc cosine, similar triangle has:
  // y component of D is based/2 * based/2 / ptc_y
  // x component of D is -sqrt(based/2^2 - y component ^2)
  
  // x/y coordinates of point D
  ptd_y = based*based/4/ptc_y;
  ptd_x = -sqrt(based*based/4 - ptd_y*ptd_y);

  // x/y coordinates of point E, between C and D
  pte_x = ptd_x * 0.75 + ptc_x * 0.25;
  pte_y = ptd_y * 0.75 + ptc_y * 0.25;

  // distance from E to C, which is radius of tooth flank  
  ecrad = sqrt((pte_x-ptc_x)*(pte_x-ptc_x) + (pte_y-ptc_y)*(pte_y-ptc_y));

  // ** here we diverge a bit from Unwin's construction
  // find point H, which is where the tooth flank intersects the pitch circle
  // first precalculate radius from origin to E as eorad
  eorad = sqrt(pte_x*pte_x + pte_y*pte_y);
  // projection of H onto EO lands at distance x from E
  x = (ecrad*ecrad + eorad*eorad - pitchrad*pitchrad)/(2*eorad);
  // distance of H from projected point (perpendicular to EO) is
  h = sqrt(ecrad*ecrad - x*x);
  // compute unit vector in the direction of E (from O to E)
  eou_x = pte_x / eorad;
  eou_y = pte_y / eorad;
  
  pth_x = pte_x - eou_x*x + eou_y*h;
  pth_y = pte_y - eou_y*x - eou_x*h;
  ang_to_h = atan2(pth_x, pth_y);  // clockwise angle from vertical to point H
  
  // angular width of tooth
  angw = 360/(2*nteeth);
  
  // right flank should be rotated this much to be in the right place
  rang = angw/2 - ang_to_h;

  intersection() {
  mirror([1, 0, 0])
  rotate([0, 0, -rang])
  translate([pte_x, pte_y, 0])
  circle(r=ecrad);
  
  rotate([0, 0, -rang])
  translate([pte_x, pte_y, 0])
  circle(r=ecrad);
  }
}