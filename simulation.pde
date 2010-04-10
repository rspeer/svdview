int step=0;

int FRAMES = 60;    // how many frames in the user simulation

float[] simulation_x = new float[FRAMES];
float[] simulation_y = new float[FRAMES];
float[] simulation_z = new float[FRAMES];
int simz_current=20;

void start_simulation() {
  simulation = true;
  for (int i=0; i<FRAMES; i++) {
    simulation_x[i] = mouseX;
    simulation_y[i] = mouseY;
    simulation_z[i] = 20;
  }
  simz_current=20;
}

void stop_simulation() {
  simulation = false;
}

void render_simulation() {
  color simcolor;
  int frame;
  for (int i=0; i<FRAMES; i++) {
    frame = (step + i) % FRAMES;
    simcolor = color(i*256/FRAMES, i*256/FRAMES, 0);
    fill(simcolor);
    ellipse(simulation_x[frame], simulation_y[frame],
    simulation_z[frame], simulation_z[frame]);
  }
  int prevstep = step-1;
  if (prevstep < 0) prevstep = FRAMES-1;
  simulation_x[step] = simulation_x[prevstep]*0.9 + mouseX*0.1;
  simulation_y[step] = simulation_y[prevstep]*0.9 + mouseY*0.1;
  simulation_z[step] = simz_current;
  step++;
  if (step >= FRAMES) step=0;
}

