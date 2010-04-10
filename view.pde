class DataView implements Layer {
  Dataset dataset;
  int[] concept_screenX, concept_screenY;
  
  color[] ptcolors_bright;
  color[] ptcolors;
  
  DataView(Dataset dataset) {
    this.dataset = dataset;
    int N = dataset.N;
    concept_screenX = new int[N];
    concept_screenY = new int[N];
    ptcolors = new color[N];
    ptcolors_bright = new color[N];
    resetColors();
  }
  
  void updateLocations() {
    /* render all point locations */
    for (int i=0; i<dataset.N; i++) {
      float[] pt = dataset.points[i];
      concept_screenX[i] = proj.projected_x(pt);
      concept_screenY[i] = proj.projected_y(pt);
    }
  }
  
  void draw() {
    // Draw all points. */
    updateLocations();
    loadPixels();
    for (int i=dataset.N-1; i>=0; i--) {
      int x = concept_screenX[i];
      int y = concept_screenY[i];
      if (x >= 0 && x < width && y >= 0 && y < height) {
        pixels[x+width*y] = ptcolors[i];
      }
    }
    updatePixels();
    
    // Draw ellipses for larger points.
    int shown=0;
    float screenWidth = proj.screenRight-proj.screenLeft;
    for (int order=0; order<dataset.N; order++) {
      if (shown >= num_labeled*2) break;
      int i = dataset.sortOrder[order].intValue();
      fill(ptcolors[i]);
      int x = concept_screenX[i];
      int y = concept_screenY[i];
      float thesize = dataset.sizes[i] / screenWidth;
      if ((thesize > 1 || pdfrecord) && x >= 0 && x < width && y >= 0 && y < height) {
        shown++;
        ellipse(x, y, thesize, thesize);
      }
    }
  }
  
  void setupColors(int bright_delta) {
    /* Set the default colors for each point, which are defined by their positions
    on the first three axes. */
    int[] rgb = new int[3];
    for (int i=0; i<dataset.N; i++) {
      float[] pt = dataset.points[i];
      for (int j=0; j<3; j++) {
        // FIXME: Why j and j+3?
        rgb[j] = constrain((int) ((pt[j] + pt[(j+3)]) * 50 + 128), 50, 255);
      }
      ptcolors[i] = color(rgb[0], rgb[1], rgb[2]);
      ptcolors_bright[i] = color(rgb[0]+bright_delta, rgb[1]+bright_delta, rgb[2]+bright_delta);
    }
  }
  
  void resetColors() { setupColors(100); }
  void darkenColors() { setupColors(-80); }
  
  int search(String searchStr, float[] vec) {
    int matchCount = 0;
    int i = java.util.Arrays.binarySearch(dataset.names, searchStr);
    if (i < 0) i=-(i+1);
    
    // Show the full match as a hint.
    fill(128);
    if (dataset.names[i].startsWith(searchStr)) {
      textFont(nonbold);
      text(dataset.names[i], 300, height-5);
    }

    // Labels are bold.
    textFont(bold);
    
    while (i<dataset.N && dataset.names[i].startsWith(searchStr)) {
      matchCount++;
      // Add this point to the category vector
      for (int j=0; j<K; j++) {
        vec[j] += dataset.points[i][j];
      }
      
      // Make sure the concept is on the screen.
      int sx = concept_screenX[i];
      int sy = concept_screenY[i];
      if (sx < 10 || sx > height-10 || sy < 10 || sy > height-10) {
        // zoom out slightly.
        proj.zoom(0, 0, -0.05);
      }
      label_point(i);
      i++;
    }
    return matchCount;
  }
    
  void label_point(int i) {
    int x = concept_screenX[i];
    int y = concept_screenY[i];
    label_point(i, x, y);
  }
  
  void label_point(int i, int x, int y) {
    fill(ptcolors_bright[i]);
    text(dataset.names[i], x, y);
  }
  
  
  void label_around_mouse_pointer() {
    /* Label some of the points. Putting text on the screen takes an
    unfortunately long time, so we do this for at most 100 concepts around
    the mouse pointer. We'll increase the radius until we've labeled enough.
    */
    for (int i=0; i<width; i++) {
      for (int j=0; j<height; j++) {
        labelmask[i][j] = false;
      }
    }
    int shown=0;
    for (int order=0; order<dataset.N; order++) {
      if (shown >= num_labeled) break;
      int i = dataset.sortOrder[order].intValue();
      /* Find the point's location on the screen. */
      int x = concept_screenX[i];
      int y = concept_screenY[i];
      if (x < 0 || x >= width || y < 0 || y >= height) continue;
      if (labelmask[x][y]) continue;
      label_point(i, x, y);
      
      // Mask out the region around the just-labeled point.
      int xdist = abs(x-mouseX)/4 + abs(y-mouseY)/4 + 4;
      int ydist = xdist/4 + 1;
      for (int px = max(x-xdist, 0); px < min(x+xdist, width); px++) {
        for (int py = max(y-ydist, 0); py < min(y+ydist, height); py++) {
          labelmask[px][py] = true;
        }
      }
      shown++;
    }
    label_point(heldIdx);
  }

  void mouseDown() {
    /* When the mouse button is pressed, select the nearest concept. */
    heldIdx = 0;           // will hold the index of the concept
    float helddist = 99999; // the distance to be closer than
    for (int i=0; i<dataset.N; i++) {
      int x = concept_screenX[i];
      int y = concept_screenY[i];
      int dist = abs(x-mouseX) + abs(y-mouseY);
      if (dist<helddist) {
        helddist = dist;
        heldIdx=i;
      }
    }
    heldvec = dataset.points[heldIdx];
    leftMouse = true;
    
    /* Now color all the points by their similarity to the held point. */
    float sim;
    int colorval;
    for (int i=0; i<dataset.N; i++) {
      sim = dot(heldvec, dataset.points[i])/sqrt(dot(heldvec, heldvec));
      colorval = (int) (sim*32+128);
      if (colorval < 0) colorval = 0;
      if (colorval > 255) colorval = 255;
      ptcolors[i] = color(255-colorval, colorval, 100);
      ptcolors_bright[i] = color(305-colorval, colorval+100, 150);
    }
    
    /* Color the held point itself in yellow and white. */
    ptcolors[heldIdx] = color(255, 255, 0);
    ptcolors_bright[heldIdx] = color(255);
  }
  
  void mouseUp() {
    resetColors();
  }
}

