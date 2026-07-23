// #################### LIBRARIES ####################

import grafica.*;  // plotting library

// #################### VARIABLES AND GLOBAL OBJECT ####################

GPointsArray points;
GPointsArray hull;
GPlot plot;

boolean scanning = true;
boolean done = false;
boolean ans = false;
int i = 0;  // index of current point
int endPt = 0;  // index of current best point

// #################### FUNCTIONS ####################

void setup() {
  size(600, 600);  // Window size
  
  hull = new GPointsArray();
  plot = new GPlot(this);
  
  loadInput();
  
  // Find leftmost point (untying by least y coordinate)
  int min_i = 0;
  for (int i = 0; i < points.getNPoints(); i++) {
    GPoint p = points.get(i);
    GPoint pmin = points.get(min_i);
    
    if ( p.getX() < pmin.getX() || (p.getX() == pmin.getX() && p.getY() < pmin.getY()) )
      min_i = i;
  }
  
  plot.setPoints(points);
  plot.setDim(500, 500);
  hull.add(points.get(min_i));
}

// --------------------------------------------------------------------------------

void loadInput() {
  String inPath = sketchPath("../Shared/input.txt");
  String[] input = loadStrings(inPath);
  points = new GPointsArray();
  
  
  // If the file is empty, fill with random points
  if (input.length == 0) {
      
    int n = int(random(10, 20)); // Random number of points
    for (int i = 0; i < n; i++)
      points.add( new GPoint( int(random(-100, 100)), int(random(-100, 100)) ) );
 
  } else {
    
    int nPoints = Integer.parseInt(input[0]);
    for (int i = 1; i <= nPoints; i++) {
      String[] S = input[i].split(" ");
      float x = Float.parseFloat(S[0]);
      float y = Float.parseFloat(S[1]);
      points.add(new GPoint(x, y));
    }
  }  
  
}

// --------------------------------------------------------------------------------

// Print output in a text file
void outputAns() {
  String outPath = sketchPath("../Shared/output.txt");
  PrintWriter output = createWriter(outPath);
  
  for (int i = 0; i < hull.getNPoints() - 1; i++) 
    output.println(hull.get(i).getX() + "\t" + hull.get(i).getY());
    
  output.flush();
  output.close();
}

// --------------------------------------------------------------------------------

boolean isRightTurn(GPoint a, GPoint b, GPoint c) {
  return ((b.getX() - a.getX())*(c.getY() - a.getY()) - (b.getY() - a.getY())*(c.getX() - a.getX())) <= 0;
}

// --------------------------------------------------------------------------------

boolean equals(GPoint a, GPoint b) {
  return ( a.getX() == b.getX() && a.getY() == b.getY() );
}

// --------------------------------------------------------------------------------

void iteration() {
  
   if (scanning) {
     // Compare polar angle (from last point in hull) of current best point (endPt) and 
     // current point (i) and set endPt to be the one with greatest polar angle.
     if ( equals(hull.getLastPoint(), points.get(endPt)) || !isRightTurn(hull.getLastPoint(), points.get(endPt), points.get(i)) ) 
       endPt = i;
       
     if (i == points.getNPoints() - 1) 
       scanning = false;
     else 
       i++;   
   }
   
   
   if (!scanning) {
     hull.add(points.get(endPt));
     
     // The hull is closed
     if ( equals(hull.get(0), hull.getLastPoint()) ) {
       done = true; 
       return;
     }  
       
     i = 0;
     endPt = 0;
     scanning = true;
   }
  
}

// --------------------------------------------------------------------------------

void keyPressed() {
  if (!done)
    iteration();
}

// --------------------------------------------------------------------------------

void drawHull() {
  
  int h = hull.getNPoints();
  for (int i = 0; i < h; i++) {
    // Convex hull points
    plot.drawPoint(hull.get(i), 0, 7.5);
    
    // Líneas between two consecutive points in the CH
    if (i < h - 1)
      plot.drawLine(hull.get(i), hull.get(i+1), 0, 2);
  }
}

// --------------------------------------------------------------------------------

void drawAction() {
  plot.drawPoint(points.get(i), 125, 10);
  plot.drawPoint(points.get(endPt), 125, 10);
  plot.drawLine(hull.getLastPoint(), points.get(i), 0, 4);
  plot.drawLine(hull.getLastPoint(), points.get(endPt), 125, 2);
}

// --------------------------------------------------------------------------------


// #################### MAIN ####################

void draw() {
  background(255);
  
  plot.beginDraw();
  plot.drawXAxis();
  plot.drawYAxis();
  plot.drawPoints();
  
  drawHull();
  
  if (!done) 
    drawAction();
  
  if (!ans && done) {
    outputAns();
    ans = true;
  }
  
  plot.endDraw();
  
}
