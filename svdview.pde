import java.util.Arrays;
import java.io.DataInputStream;
//import processing.video.*;
import processing.pdf.*;
import processing.opengl.*;
String progname = "svdview 0.6";

// name of the configuration file in the "data" directory
String config_file = "config";

/*
Set K to be the number of dimensions to use in your projection. You cannot use
more dimensions than there are in your input file.
*/
int K = 20;

int FRAMERATE=15;    // the applet will get clunky if you set this too high
int num_labeled=100;

boolean movie_mode=false;
boolean simulation=false;
boolean pdfrecord=false;

//MovieMaker mm;

boolean showConcepts=true;
float rightX, rightY, rightPtX, rightPtY;

void initializeArrays() {
  showConcepts = true;
  heldvec = new float[K];
  labelmask = new boolean[width][height];
}

Layer[] layers;
int curLayer = 0;
Projection proj;

PFont nonbold, bold;

String searchStr = null;

boolean[][] labelmask;

void setup() {
  /* Set up Processing parameters. */
  size(screen.width, screen.height, P2D); // apparently this needs to be the first thing called, with constant parameters.
  //hint(ENABLE_NATIVE_FONTS);
  frameRate(FRAMERATE);
  noStroke();

  // Set up text.  
  //noSmooth();
  nonbold = loadFont("Tahoma-12.vlw");
  bold = loadFont("Tahoma-Bold-12.vlw");
  textMode(SCREEN);

  /* Zoom in or out on mouse wheel events. */
  addMouseWheelListener(new java.awt.event.MouseWheelListener() {
    public void mouseWheelMoved(java.awt.event.MouseWheelEvent evt) {
      mouse_wheel(evt.getWheelRotation());
    }
  });

  setup_data();
}

void setup_data() {
  float auto_rotation_rate = 0.0003;
  /* Ask for the data file name. */
  Dataset dataset;
  String name;
  if (false && args.length > 0) {
    name = args[0];
  } else {
    name = OptionDialog.prompt_for_file(frame);
  }
  dataset = new Dataset(name, K);
  
  layers = new Layer[1];
  layers[0] = new DataView(dataset);

  // Create the projection
  proj = new Projection(K, auto_rotation_rate);

  initializeArrays();
}

/* We used to have PDF recording code:
 if (pdfrecord) {
 background(255);
 dataview.darkenColors();
 beginRecord(PDF, "frame-####.pdf");
 textMode(SHAPE);
 } else {
 background(0);
 }
 */

/* We used to not draw this stuff in movie mode. */

void draw() {
  // Draw the status/help line.
  background(0);
  fill(64);
  rect(0, height-20, width, 20);
  fill(255);
  if (searchStr == null) {
    textFont(nonbold);
    text("Drag left button to rotate. Use mouse wheel to zoom.", width-300, height-5);
    textFont(bold);
  }
  text(progname, 2, height-5);
  textFont(bold);

  proj.updateFollowingMouse();

  proj.drawAxes();
  for (int layer=0; layer<layers.length; layer++)
    layers[layer].draw();

  if (simulation) render_simulation();

  if (searchStr != null && searchStr.length() > 1) {
    /* Create a category vector of all the concepts matching the search string */
    float[] vec = new float[K];
    int matchCount = layers[curLayer].search(searchStr, vec);
    if (matchCount > 0) {
      normalize_inplace(vec);
      //vscale_inplace(vec, .25);

      stroke(color(0,255,0));
      proj.show_vector(vec);
      noStroke();

      // Move us in the direction of the vector.
      proj.move_towards(vec);
    }
  }
  else {
    // not search mode
    for (int i=0; i<layers.length; i++)
      layers[i].label_around_mouse_pointer();
  }

  if (searchStr != null) {
    fill(255);
    textFont(bold);
    text("Search: ", 250, height-5);
    textFont(nonbold);
    text(searchStr, 300, height-5);
  }
  
  proj.drift_transform();
  
//  if (movie_mode) mm.addFrame();
//  if (pdfrecord) {
//    endRecord();
//    dataview.resetColors();
//    pdfrecord=false;
//  }
}

void keyPressed() {
  /* Do things with key presses. */
  if (searchStr == null) {
    handle_keypress_normal();
  } else {
     handle_keypress_search(); 
  }
}

void handle_keypress_normal() {
  /* 'r' resets the entire visualization. */
  if (key == 'r') {
    setup();
  }
  
  /* 0-9 project everything onto two axes:
     0 => 0 vs. 1
     1 => 1 vs. 2
     etc.
  */
  else if (key >= '0' && key <= '9' && key-'0'-2 < K) {
    int whichaxis = key-'0';
    proj.move_towards_axis(whichaxis, 0.5);
  }
  
  /* 'c' centers the view on the origin. */
  else if (key == 'c') {
    proj.center_on_origin();
  }
  
  else if (key == '/') {
    // Enter search mode
    if (searchStr == null) searchStr = "";
  }
    
  else if (key == 'b') {
    showConcepts = !showConcepts;
  }
  
  else if (key == 'm') {
    if (!movie_mode) start_recording();
    else stop_recording();
  }
  
  //else if (key == 'o') {
  //  if (simulation) stop_simulation();
  //  else start_simulation();
 //}
 
  else if (key == 'p' || key == 's') {
    proj.set_auto_rotation_rate(0.0);
  }
  
  else if (key == 'g') {
    proj.set_auto_rotation_rate(0.004);
  }
  //else if (key == 's') {
  //  pdfrecord = true;
  //}
}

void handle_keypress_search() {
  if (key == '\n') {
    searchStr = null;
  } else if (key == ' ' || Character.isLetter(key) || Character.isDigit(key) || key == '\'') {
    searchStr += key;
  }
  else if (key == BACKSPACE && searchStr.length() > 0) {
    searchStr = searchStr.substring(0, searchStr.length()-1);
  }
}
    

void start_recording() {
//  mm = new MovieMaker(this, width, height, "svdview.mov", 12, MovieMaker.RAW,
//                      MovieMaker.LOSSLESS);
//  movie_mode = true;
//  System.out.println("woot");
//  mm.addFrame();
}

void stop_recording() {
//  mm.finish();
//  movie_mode = false;
}

