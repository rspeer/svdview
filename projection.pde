class Projection {
  Projection(int K, float auto_rotation_rate) {
    this.K = K;
    vec1 = new float[K];
    vec2 = new float[K];
    transform = new float[K][K];
    set_auto_rotation_rate(auto_rotation_rate);
    
    reset_view();
    set_axis_names();
  }

  final boolean show_vectors = false;
  
  int K;
  
  void reset_view() {
    // Initialize the view to show axes 0 and 1.
    for (int i=0; i<K; i++) {
      vec1[i] = vec2[i] = 0;
    }
    vec1[0] = vec2[1] = 1;
    //vec1[2] = -1;
    //vec2[2] = -1;
    
    center_on_origin();
  }
  
  /* Generate a random matrix close to the identity, which will rotate the
  view at each step. */
  void set_auto_rotation_rate(float auto_rotation_rate) {
    this.auto_rotation_rate = auto_rotation_rate;
    for (int i=0; i<K; i++) {
      for (int j=0; j<K; j++) {
        transform[i][j] = random(auto_rotation_rate) - auto_rotation_rate/2;
        if (i==j) transform[i][j] += 1;
      }
    }
  }
  
  // Let the transform drift gradually
  void drift_transform() {
    for (int i=0; i<K; i++) {
      for (int j=0; j<K; j++) {
        transform[i][j] += random(auto_rotation_rate/100) - auto_rotation_rate/200;
      }
    }
  }
  
  /* vec1 and vec2 are two orthogonal unit vectors, defining how the k-dimensional
  space is projected onto the screen. */
  float[] vec1, vec2;

  float[] old_vec1, old_vec2;
  
  // This matrix defines the direction that the view rotates in.
  float[][] transform;
  
  String[] axis_names;
  
  // These variables define the viewport of the screen.
  float screenTop;
  float screenBottom;
  float screenLeft;
  float screenRight;
  
  float auto_rotation_rate;
  
  /* There are "projection coordinates" and "screen coordinates", and we need
  to convert between them. The origin is always at (0, 0) in projection
  coordinates, but in screen coordinates it starts at (400, 400) --
  the middle of the window. 
  
  Both of these are different from the K-dimensional coordinates where the points
  are conceptually located. That's why they need to be projected onto the
  2-dimensional projection coordinates using vec1 and vec2.
  */
  
  /* Convert an x-coordinate from projection coordinates to screen coordinates. */
  float screenX(float x) {
    return (x-screenLeft) / (screenRight-screenLeft) * width;
  }
  
  /* Convert a y-coordinate from projection coordinates to screen coordinates. */
  float screenY(float y) {
    return height - (y-screenTop) / (screenBottom-screenTop) * height;
  }
  
  /* Convert an x-coordinate from screen coordinates to projection coordinates. */
  float unscreenX(float x) {
    return screenLeft + (x/width) * (screenRight-screenLeft);
  }
  
  /* Convert a y-coordinate from screen coordinates to projection coordinates. */
  float unscreenY(float y) {
    return screenTop + ((height-y)/height) * (screenBottom-screenTop);
  }
  
  int projected_x(float[] pt) {
    return (int) screenX(dot(vec1, pt));
  }

  int projected_y(float[] pt) {
    return (int) screenY(dot(vec2, pt));
  }
  
  void center_on_origin() {
    screenTop = -4.0;
    screenBottom = 4.0;
    screenLeft = -4.0*width/height;
    screenRight = 4.0*width/height;
  }
  
  void move_towards(float[] vec) {
  //    vadd_inplace(vec1, vec);
    move_towards(vec, screenRight, screenBottom);
  //    vadd_inplace(vec2, vec);
  }
  
  void move_towards_axis(int whichaxis, float inc) {
    vec1[whichaxis] += inc;
    vec2[whichaxis+1] += inc;
    //vec1[whichaxis+2] -= 0.5;
    //vec2[whichaxis+2] -= 0.5;
  }
  
  /*
   * Shift the projection such that vec moves towards (x, y).
   */
  void move_towards(float[] vec, float x, float y) {
    if (show_vectors) {
      show_vector(vec, color(255,0,0), 3);
      pushStyle(); fill(color(255,0,255)); ellipse(screenX(x), screenY(y), 10, 10); popStyle();
    }
    float hx = dot(vec1, vec);
    float hy = dot(vec2, vec);
    float vec_mag = dot(vec, vec);
    vadd_inplace(vec1, vscale(vec, (x-hx)/vec_mag));
    vadd_inplace(vec2, vscale(vec, (y-hy)/vec_mag));
  }
  
  void show_vector(float[] vec) {
    line(screenX(0), screenY(0), projected_x(vec), projected_y(vec));
  }
  
  void show_vector(float[] vec, int col, int weight) {
    pushStyle();
    stroke(col); strokeWeight(weight); show_vector(vec);
    popStyle();
  }
  
  void updateFollowingMouse() {
    /* If a mouse button is being held, rotate the view so that the selected
    concept moves toward the mouse. We do this just by adding that concept's
    vector to the x and y vectors a lot. With Gram-Schmidt, this will eventually
    converge on doing the right thing. */
    if (leftMouse) {
      move_towards(heldvec, unscreenX(mouseX), unscreenY(mouseY));
    }
    /* If the mouse isn't pressed, then use the random rotation. */
    for (int i=0; i<K; i++) {
      vec1[i] = dot(vec1, transform[i]);
      vec2[i] = dot(vec2, transform[i]);
    }
    if (rightMouse) {
      /* rightPtX starts out at rightX. You want it to move to mouseX.
         You can tell you're done when screenX(rightPtX) = mouseX.
      */
      float deltaX = rightPtX - unscreenX(mouseX);
      float deltaY = rightPtY - unscreenY(mouseY);
      screenLeft += deltaX;
      screenRight += deltaX;
      screenTop += deltaY;
      screenBottom += deltaY;
    }
  
    old_vec1 = vscale(vec1, 1.0);
    old_vec2 = vscale(vec2, 1.0);
  
    /* Fix everything with Gram-Schmidt. */  
    normalize_inplace(vec1);
    normalize_inplace(vec2);
    vec2 = orthogonalize(vec1, vec2);
    if (show_vectors) {
      show_vector(old_vec1, color(255,255,0), 4);
      show_vector(old_vec2, color(0,255,255), 4);
    }
  }
  
  void zoom(float x, float y, float increment) {
    screenLeft += (x-screenLeft) * increment;
    screenRight += (x-screenRight) * increment;
    screenTop += (y-screenTop) * increment;
    screenBottom += (y-screenBottom) * increment;    
  }
  
  void zoom(float increment) {
    float mx = unscreenX(mouseX);
    float my = unscreenY(mouseY);
    zoom(mx, my, increment);
  }
  
  void drawAxes() {
    for (int j=0; j<K; j++) {
      stroke(255);
      line(screenX(vec1[j]*0), screenY(vec2[j]*0), screenX(vec1[j]*4), screenY(vec2[j]*4));
      noStroke();
      fill(255, 200);
      text(axis_names[j], screenX(vec1[j]*4), screenY(vec2[j]*4));    
    }
  }
  
  
  void set_axis_names() {
    axis_names = new String[K];
    for (int i=0; i<K; i++) {
      axis_names[i] = ""+i;
    }
  }
  

}

