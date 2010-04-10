/* vadd returns the sum of two vectors. */
float[] vadd(float[] v1, float[] v2) {
  float[] result = new float[v2.length];
  for (int i=0; i<v1.length; i++) result[i] = v1[i]+v2[i];
  return result;
}
float[] vadd_inplace(float[] v1, float[] v2) {
  for (int i=0; i<v1.length; i++) v1[i] += v2[i];
  return v1;
}

/* dot product of two vectors */
float dot(float[] v1, float[] v2) {
  float tot=0.0;
  for (int i=0; i<v1.length; i++) tot += v1[i]*v2[i];
  return tot;
}

/* vscale multiplies a vector by a scalar. */
float[] vscale(float[] vec, float scale) {
  float[] result = new float[vec.length];
  for (int i=0; i<vec.length; i++) result[i] = vec[i]*scale;
  return result;  
}
float[] vscale_inplace(float[] vec, float scale) {
  for (int i=0; i<vec.length; i++) vec[i] *= scale;
  return vec;  
}

/* normalize scales a vector down to a unit vector. */
float[] normalize(float[] vec) {
  float norm = sqrt(dot(vec, vec));
  return vscale(vec, 1/norm);
} 
float[] normalize_inplace(float[] vec) {
  float norm = sqrt(dot(vec, vec));
  return vscale_inplace(vec, 1/norm);
} 

/* orthogonalize takes in twe vectors (the first of which is already
normalized). It returns the second vector adjusted to be normalized and
orthogonal to the first.

This is basically Gram-Schmidt orthogonalization,
and I do it all the time so that I don't have to worry about my operations
actually making mathematical sense. */

float[] orthogonalize(float[] vec1, float[] vec2) {
  float[] result = new float[vec2.length];
  float dot_product = dot(vec1, vec2);
  for (int i=0; i<vec2.length; i++) {
    result[i] = vec2[i] - vec1[i] * dot_product;
  }
  return normalize_inplace(result);
}

void printVector(float[] vec) {
  for (int i=0; i<vec.length; i++) {
    System.out.print(vec[i]);
    System.out.print(", ");
  }
  System.out.println();
}

