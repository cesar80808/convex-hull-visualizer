// #################### LIBRARIES ####################

import grafica.*;  // plotting library
import java.util.Collections;
import java.util.Comparator;

// #################### VARIABLES AND GLOBAL OBJECTS ####################

ArrayList<PVector> P;
GPointsArray points;
GPointsArray hull;
GPlot plot;

int t = 0;  // index to the first element of lower/upper hull
int curr = 0;  // index to current point
int dir = 1;  // +1 if building upper hull, -1 if lower hull
boolean done = false;
boolean add = false;
boolean ans = false;

// #################### FUNCIONES ####################

void setup() {
  size(600, 600);  // Window size

  loadInput();
  
  // Sort P in lexicographical order
  Collections.sort(P, new Comparator<PVector>() {
    public int compare(PVector a, PVector b) {
      if (a.x != b.x)
        return Float.compare(a.x, b.x);
      else
        return Float.compare(a.y, b.y);
    }
  });
  
  points = new GPointsArray(P);
  hull = new GPointsArray();
  plot = new GPlot(this);
  plot.setPoints(points);
  plot.setDim(500, 500); 
}

// --------------------------------------------------------------------------------

void loadInput() {
  P = new ArrayList();
  String inPath = sketchPath("../Shared/input.txt");
  String[] input = loadStrings(inPath);
  
  // If input file is empty, fill with random points
  if (input.length == 0) {
      
    int nPoints = int(random(10, 20)); // Random amount of points
    for (int i = 0; i < nPoints; i++)
      P.add( new PVector( int(random(-100, 100)), int(random(-100, 100)) ) );
      
  } else {
    
    int nPoints = Integer.parseInt(input[0]);
    for (int i = 1; i <= nPoints; i++) {
      String[] S = input[i].split(" ");
      float x = Float.parseFloat(S[0]);
      float y = Float.parseFloat(S[1]);
      P.add(new PVector(x, y));
    }
    
  }  
}

// --------------------------------------------------------------------------------

// Print output in text file
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

void iteration() {
  
  if (!add) {
    int h = hull.getNPoints();
    if ( h >= t + 2 && !isRightTurn(hull.get(h - 2), hull.get(h - 1), points.get(curr)) )
      hull.remove(h - 1);
     else 
       add = true;
  }
  

  if (add) {
     hull.add(points.get(curr));
     curr += dir;
     
     // If we're done building the upper hull...
     if (curr == P.size()) {
        dir = -1;
        t = hull.getNPoints() - 1;
        curr = points.getNPoints() - 2;
     }
     
     // If we're done building the lower hull...
     if (curr == -1) {
       curr = 0;
       done = true;
       return;
     }
           
     add = false;
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
    
    // CH points
    plot.drawPoint(hull.get(i), 0, 7.5);
    
    // Segment between consecutive points in the CH
    if (i < h - 1)
      plot.drawLine(hull.get(i), hull.get(i+1), 0, 1);
  }
  
}

// --------------------------------------------------------------------------------

void drawAction() {
    int h = hull.getNPoints();
    
    // Segment between the last two points in the CH
    if (h >= 2)
      plot.drawLine(hull.get(h-2), hull.get(h-1), 0, 4);
    
    // Segment between last point in CH and current point to add
    if (h >= 1)
      plot.drawLine(hull.get(h-1), points.get(curr), 0, 4);
      
    // Current point to add
    plot.drawPoint(points.get(curr), 125, 10);
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
