interface Layer {
  /** Draw this layer.
  */
  void draw();
  
  /** Search for a string. Add all results to vec.
   *
   * Return the number of matches.
   */
  int search(String searchStr, float[] vec);
  
  void label_around_mouse_pointer();
  
  void mouseDown();
  void mouseUp();
}
