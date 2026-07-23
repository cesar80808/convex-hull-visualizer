// #################### LIBRARIES ####################

import grafica.*;  // plotting library
import java.util.Collections;
import java.util.Comparator;

// #################### VARIABLES AND GLOBAL OBJECTS ####################

ArrayList<PVector> P;
GPointsArray points;
GPointsArray hull;
GPlot plot;

boolean ans = false;
boolean done = false;
boolean add = true;
int i = 0;  // index of current point
int N;

// #################### FUNCTIONS ####################

void setup() {
  size(600, 600);  // Window size
  
  hull = new GPointsArray();
  plot = new GPlot(this);
  
  loadInput();
  N = P.size();
  
  // Find point with least y coordinate. Untie by least x coordinate
  int min_i = 0;
  for (int i = 0; i < N; i++) 
    if (P.get(i).y < P.get(min_i).y || (P.get(i).y == P.get(min_i).y && P.get(i).x < P.get(min_i).x))
       min_i = i;
   
   // P[0] to be the point of least y coordinate
   Collections.swap(P, min_i, 0);
       
   // Sort P according to polar angle with respect to P[0]
   Collections.sort(P, new Comparator<PVector>() {
    public int compare(PVector a, PVector b) {
      if ( cross_prod(P.get(0), a, b) > 0 )
        return -1;
      else if ( cross_prod(P.get(0), a, b) < 0 )
        return 1;
      else {
        if ( a.dist(P.get(0)) < b.dist(P.get(0)) )
          return -1;
         else if ( a.dist(P.get(0)) > b.dist(P.get(0)) )
           return 1;
         else
           return 0;
      }
    }
  });
  
  points = new GPointsArray(P);
  plot.setPoints(points);
  plot.setDim(500, 500);
}

// --------------------------------------------------------------------------------

void loadInput() {
  String inPath = sketchPath("../Shared/input.txt");
  String[] input = loadStrings(inPath);
  P = new ArrayList();
  
  
  // If file is empty, fill with random points
  if (input.length == 0) {
    
    int nPoints = int(random(10, 30));  // Random number of points
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

float cross_prod(PVector a, PVector b, PVector c) {
  return ((b.x - a.x)*(c.y - a.y) - (b.y - a.y)*(c.x - a.x));
}

// --------------------------------------------------------------------------------

float cross_prod(GPoint a, GPoint b, GPoint c) {
  return ((b.getX() - a.getX())*(c.getY() - a.getY()) - (b.getY() - a.getY())*(c.getX() - a.getX()));
}

// --------------------------------------------------------------------------------

void iteration() {
  
  
  if (!add) {
    int h = hull.getNPoints();
    
    // If right turn
    if (h >= 2 && cross_prod(hull.get(h - 2), hull.get(h - 1), points.get(i % N)) <= 0)
      hull.remove(h - 1);
    else
      // Enter "adding" state
      add = true;
  }
  
  if (add) {
    // Add next point to hull
    hull.add(points.get(i % N));
    i++;
    
    // If all points were handled...
    if (i == N+1) {
      done = true;
      return;
    }
    
    // Exit "adding" state
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
    // Cinvex hull points
    plot.drawPoint(hull.get(i), 0, 7.5);
    
    // Segments between consecutive points in the convex hull
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
      
    // Segment between last point in the CH and new point to add
    if (h >= 1)
      plot.drawLine(hull.get(h-1), points.get(i % N), 0, 4);
      
    // Point to add
    plot.drawPoint(points.get(i % N), 125, 10);
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
