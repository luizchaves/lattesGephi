//http://forum.processing.org/one/topic/animation-with-curve.html

PImage map;
float lon1 = -180.0;
float lat1 = -85.0;
float lon2 = 180.0;
float lat2 = 85.0;

MercatorMap mercatorMap;

float distY;
float distX;
int increment=0;
int resolution=200;
int step = 60;
Table table;

void setup(){
  size( 1200, 1000, P3D );
  
  map = loadImage("data/ui/mapbox.light.world.png");
  
  table = loadTable("../data-latlon/lattes-flows-country-1950.csv", "header");
  float x,y;
  for (TableRow row : table.rows()) {
    x = row.getFloat("oX");
    y = row.getFloat("oY");
    PVector p = new PVector(x, y);
//    println(p.x+" "+p.y);
    mercatorMap.getScreenLocation(p);
//    float latitudeInDegrees = p.x;
//    print
//    PVector firstpoint = mercatorMap.getScreenLocation(p);
    x = row.getFloat("dX");
    y = row.getFloat("dY");
    p = new PVector(x, y);
//    println(p.x+" "+p.y);
//    PVector secondpoint = mercatorMap.getScreenLocation(p);
    int trips = row.getInt("trips");
//    println(row.getFloat("oX")+", "+row.getFloat("oY"));
  }
  
  mercatorMap = new MercatorMap(1200, 1000, lat2, lat1, lon1, lon2);
}

void draw(){
  image(map, 0 ,0);
  myCurve(
    mercatorMap.getScreenLocation(new PVector(-15.7833f, -47.8667f)),
    mercatorMap.getScreenLocation(new PVector(38.7f, -9.1833f))
  );
}

void myCurve(PVector firstpoint, PVector secondpoint) {
  float beginX = firstpoint.x;
  float beginY = firstpoint.y;
  float endX = secondpoint.x;
  float endY = secondpoint.y;
  
  distX = endX - beginX;
  distY = endY - beginY;
  
  stroke(0);
  if (increment<=resolution+step){
    increment++;
    int endValue = (increment > resolution)? resolution : increment;
    int startValue = (increment-step)<0 ? 0 : increment-step; 
    
    //curve
    for (int i=startValue; i<endValue;i++){ //0..increment
      float t1 = i / (float)resolution;
      float t2 = (i+1)/ (float)resolution;
      float x1 = curvePoint(beginX-640, beginX, endX, endX-640, t1);
      float y1 = curvePoint(beginY-140, beginY, endY, endY-40, t1);
      float x2 = curvePoint(beginX-640, beginX, endX, endX-640, t2);
      float y2 = curvePoint(beginY-140, beginY, endY, endY-40, t2);
      line(x1+6, y1, x2+6, y2);
    }
    
    //point
//    float t1 = increment / (float)resolution;
//    float t2 = (increment+1)/ (float)resolution;
//    float x1 = curvePoint(beginX-40, beginX, endX, endX-40, t1);
//    float y1 = curvePoint(beginY-40, beginY, endY, endY-40, t1);
//    float x2 = curvePoint(beginX-40, beginX, endX, endX-40, t2);
//    float y2 = curvePoint(beginY-40, beginY, endY, endY-40, t2);
//    line(x1, y1, x2, y2);
  }
}


