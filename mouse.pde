/* Keep track of what's being dragged. */
boolean leftMouse=false;
boolean rightMouse=false;
int heldIdx;
float[] heldvec;

void mousePressed() {
  if (mouseButton == LEFT) {
    layers[curLayer].mouseDown();
    leftMouse = true;
  }
  else if (mouseButton == RIGHT) {
    rightMouse = true;
    rightX = mouseX;
    rightY = mouseY;
    rightPtX = proj.unscreenX(mouseX);
    rightPtY = proj.unscreenY(mouseY);
  }
}

void mouseReleased() {
  leftMouse = false;
  rightMouse = false;
  layers[curLayer].mouseUp();
}

void mouse_wheel(int notches) {
  if (simulation) {
    simz_current += notches;
    if (simz_current <= 0) simz_current = 1;
    return;
  }
  
  proj.zoom(-notches / 50.0);
}

