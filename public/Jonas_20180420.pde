class Settings {
  public static final String[] COLORS  =new String[] { "FF30C39E", "FF037Ef3", "FFF48924", "FF0A8EA0", "FFFFC845", "FFF85A40"};
  
  
  /* Input Data start */
  
  // crowdedness of particles. 0 = min | 100 = max 
  public static final int CROWDEDNESS = 60;
  // number and diameter of orbits. 
  public static final int[] DIAMETERS = {600, 900, 1200, 900, 750};
  // color to use as base color for particles. 
  public static final int  COLOR = 5;//(int) random(0, COLORS.length - 1);
  // random color deviation to be used for each particle. 0 = min | 100 = max 
  public static final double  COLOR_DEVIATION = 10;
  // size of particles. 0 = min | 100 = max 
  public static final int  PARTICLE_SIZE = 100;
  // perpendicular rotation of orbits. 0 = min | 100 = max 
  public static final int  PERPENDICULAR_ROTATION = 100;
  // type of particles. 0 = chip | 1 = triangle | 2 = pear  | 3 = peanut  | 4 = hexagon | 5 = sphere | 6 = star 
  public static final int PARTICLE_TYPE = 0;
  // type of particles. 0 = min | 100 = max 
  public static final int WAVE_MOVEMENT = 100;
  
  /* Input Data end */
  
  
  public static Particle createParticle(int type) {
    
    Shape shape;
    if (type == 0){
        shape = new Chip();
    } else if (type == 1) {
        shape = new Triangle();
    } else if (type == 2) {
        shape = new Pear();
    } else if (type == 3) {
        shape = new Peanut();
    } else if (type == 4) {
        shape = new Hexagon();
    } else if (type == 5) {
        shape = new Sphere();
    } else if (type == 6) {
        shape = new Star();
    } else {
        shape = new Chip();
    }  
    return new Particle(shape);
  }
} 
 
 
 
 PVector[][] allParticles;

int numParticles = (int)(3 + 0.3 * Settings.CROWDEDNESS);
boolean cameraOrtho = true;
boolean whiteLines = false;
boolean lightBackground = true;
int c = 255;
int d=255;
int init=0;

float maxSize = 1800;
float threshold = maxSize * 2 - maxSize/4;
float lightDist = maxSize + maxSize/4;

int scalingInterval = 20;
int minScale = 100;
int maxScale = 100;
int lowerVisibilityTreshold = 100;
int upperVisibilityTreshold = 150;
int instanceSpacing = 100;
int[][] auslenkungen;
final double sizeFactor;

void setup()
{
  sizeFactor = Settings.PARTICLE_SIZE / 100;
  auslenkungen = new int[Settings.DIAMETERS.length][2];
  for (int i = 0; i < Settings.DIAMETERS.length; i++) {
    auslenkungen[i][0] = (int) random(-175, 175);
    auslenkungen[i][1] = (int) random(-175, 175);
  }
  allParticles = new PVector[Settings.DIAMETERS.length][];
  for (int k = 0; k < Settings.DIAMETERS.length; k++){
     allParticles[k] = new PVector[numParticles];
  }
  size( 1600, 750, OPENGL);
  smooth(8);
  colorMode(RGB);
  createParticles();
}
float camX = 0f;
float camY = 0f;
float camZ = 2000f;
double iteration = 0;
void draw()
{
  iteration+=0.5;
  if (lightBackground) background(255);
  else background(50);

  if (cameraOrtho) ortho(-width, width, -height, height, -10000, 10000);
  else perspective();
  
  camera(camX, camY, 2000, 0, 0, 0, 0.0, 1.0, 0.0);
  directionalLight(c+10, d+10, d+10, 0, 0, -1);
  ambientLight(c+10, d+10, d+10);
  pointLight(51, 102, 126, mouseX, mouseY, lightDist);
   
  pushMatrix();
  rotateY(radians(iteration/200 * Settings.PERPENDICULAR_ROTATION)); // iteration
  for (int k = 0; k < Settings.DIAMETERS.length; k++){
    
    translate(auslenkungen[k][0], auslenkungen[k][1]);
    rotateX(radians((auslenkungen[k][0] + auslenkungen[k][1]) / 10));
    rotateY(radians((auslenkungen[k][0] + auslenkungen[k][1]) / 10));
    rotateX(sin(radians(-iteration/4)));
    rotateY(radians(90));
      
    for (int i=0; i<numParticles; i++) {
      Particle particle = allParticles[k][i];
      
      pushMatrix();
      rotate(radians(360*i/numParticles));
      
      translate(0, 0, 50*getWaveFactor(i* 360 + (iteration / 6 % 360) )); //     radians(360*(i/numParticles)*100)
        
      double progressPercentage = i * 100 / numParticles;
        
      pushMatrix();
      translate(Settings.DIAMETERS[k]/2, 0);
      rotateX(radians(particle.rotationStep()));
      rotateY(radians(-45));
      rotateZ(radians(particle.rotationStep()));
      particle.draw();
      popMatrix();
      popMatrix();
    }
    popMatrix();
  }
  popMatrix();
  init++;
}

double getWaveFactor(int i) {
  return 2*sin(i/numParticles*4*PI) * (Settings.WAVE_MOVEMENT / 100);
}

double getScaleFactor (int progressPercentage) {
  double progressWithinScalingInterval = progressPercentage % scalingInterval;
  double result;
  if (progressWithinScalingInterval < (scalingInterval / 2)) {
    result = progressWithinScalingInterval / (scalingInterval / 2);
  } else {
    result = (scalingInterval - progressWithinScalingInterval) / (scalingInterval / 2);
  }
  return result;
}

void createParticles() {
  for (int k=0; k < Settings.DIAMETERS.length; k++) { 
    for (int i=0; i<numParticles; i++) { 
      Particle particle = Settings.createParticle(Settings.PARTICLE_TYPE);
      allParticles[k][i] = particle;
    }
  }
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      c = abs(c+10);
    } 
                         
    if (keyCode == DOWN) {
      c = abs(c-10);
    } 
                                                      
                                                     
    if (keyCode == LEFT) {
      d = abs(d+10);
    } 
                         
    if (keyCode == RIGHT) {
      d = abs(d-10);
    }
  }
  if (key == 'p') cameraOrtho = !cameraOrtho;
  if (key == 'l') whiteLines = !whiteLines;
  if (key == 'b') lightBackground = !lightBackground;
  if (key == 't') saveFrame("kurt, robot.tif");   
}

class Particle
{
  float hue, sat, bright;
  float targetSize = 1.0;
  static int globalIndex = 0;
  private Shape shape;
  private double currentRotation;
  private double rotation;
  private static final int[] possibleRotations = new int[] {1, 2, 4, 8};
  private int col;
  private int size = (int) random(0, 75);

  public Particle(Shape shape) {
    this.col = unhex(Settings.COLORS[Settings.COLOR]) + random(-Settings.COLOR_DEVIATION*10000, Settings.COLOR_DEVIATION*10000);
    this.shape = shape;
    globalIndex++;
  
    this.currentRotation = 0;
    this.rotation = (Particle.possibleRotations[(int)random(0, Particle.possibleRotations.length-1)]);
  }
  
  double rotationStep() {
    this.currentRotation += this.rotation / 4;
    return this.currentRotation;
  }
  
  void draw() {
    
    if (whiteLines) stroke(hue, sat, bright);
    else noStroke();
    fill(color(this.col));
    beginShape();
    this.shape.draw();
    endShape();
  }
}

class Shape {
  
  protected int[][] coordinates;
  public int[][] getCoordinates() {
    return coordinates;
  }
  public abstract int getBoxDiameter();
  public abstract void draw();
}

class Chip extends Shape {
  
  public void draw () {
    ellipse(0, 0, 55 * sizeFactor, 55 * sizeFactor);
  }
}

class Triangle extends Shape {
  
  public void draw () {
    triangle(0, 0, -43 * sizeFactor, -75 * sizeFactor, 43 * sizeFactor, -75 * sizeFactor);
  }
}

class Pear extends Shape {
  
  public void draw () {
    ellipse(-25 * sizeFactor, 0, 75 * sizeFactor, 75 * sizeFactor);
    ellipse(0, 0, 45 * sizeFactor, 45 * sizeFactor);
    ellipse(25 * sizeFactor, 0, 45 * sizeFactor, 45 * sizeFactor);
  }
}

class Peanut extends Shape {
  
  public void draw () {
    ellipse(-25 * sizeFactor, 0, 75 * sizeFactor, 75 * sizeFactor);
    ellipse(0, 0, 45 * sizeFactor, 45 * sizeFactor);
    ellipse(25 * sizeFactor, 0, 75 * sizeFactor, 75 * sizeFactor);
  }
}

class Hexagon extends Shape {
  
  public void draw () {
    triangle(0, 1, -44 * sizeFactor, -75 * sizeFactor, 44 * sizeFactor, -75 * sizeFactor);
    triangle(0, 0, -44 * sizeFactor, 75 * sizeFactor, 44 * sizeFactor, 75 * sizeFactor);
    pushMatrix();
    rotate(radians(120));
    triangle(0, 1, -44 * sizeFactor, -75 * sizeFactor, 44 * sizeFactor, -75 * sizeFactor);
    triangle(0, 0, -44 * sizeFactor, 75 * sizeFactor, 44 * sizeFactor, 75 * sizeFactor);
    rotate(radians(120));
    triangle(0, 1, -44 * sizeFactor, -75 * sizeFactor, 44 * sizeFactor, -75 * sizeFactor);
    triangle(0, 0, -44 * sizeFactor, 75 * sizeFactor, 44 * sizeFactor, 75 * sizeFactor);
    popMatrix();
  }
}

class Sphere extends Shape {
  
  public void draw () {
    sphere(50 * sizeFactor);
  }
}

class Star extends Shape {
  
  public void draw () {
    pushMatrix();
    box(60 * sizeFactor);
    rotate(radians(60));
    box(60 * sizeFactor);
    popMatrix();
  }
}

