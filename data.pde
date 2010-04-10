import java.io.File;
import javax.swing.*;
import javax.swing.filechooser.*;

class Dataset {
  String filename;
  
  Dataset(String filename, int num_dimensions) {
    this.filename = filename;
    this.num_dimensions = num_dimensions;
    loadData();
    transformPoints();
    calcSizes();
    make_sort_array();
  }
  
  /*
  data_name: the name of the dataset containing your SVD matrix. Format:
   data_name+'.names': a list of labels, one per line
   data_name+'.coords': a binary file format:
  
    Everything is stored in big-endian (network) byte order.
    Header:
      4 bytes: number of dimensions (integer)
      4 bytes: number of items (integer)
    Body: a sequence of items (no separator)
      each item has a coordinate for each dimension (specified in the header)
      each coordinate is an IEEE float (32-bit) in big-endian order.
  */

  int N; // number of points
  int num_dimensions;
  String[] names;
  float[][] points;
  Integer[] sortOrder;
  float[] sizes;


  void loadData() {
    int num_dimensions_in_file;

    names = loadStrings(filename+".names");
    String coords_file = filename+".coords";
    DataInputStream coords = new DataInputStream(createInput(coords_file));
    try {
      num_dimensions_in_file = coords.readInt();
      N = coords.readInt();
    
      // Allocate memory
      points = new float[N][num_dimensions];
  
      // Read in coordinates into the points[][] array.
      for (int i=0; i<N; i++) {
        for (int j=0; j<num_dimensions_in_file; j++) {
          // Read all the coordinates, but only store num_dimensions.
          float pt = coords.readFloat();
          if (j < num_dimensions) points[i][j] = pt;
        }
      }
    } catch (IOException e) {
      System.err.println("IO Error while reading coords");
      exit(); //need both exit() and return.
      return;
    }
    
    System.out.println("Read "+num_dimensions+" dimensions of "+N+" concepts.");
  }
  
  void loadTsvData(String filename) {
    String[] lines = loadStrings(filename);
    Arrays.sort(lines);
    N = lines.length;
    initializeArrays();
    /* Read in the data from the input file. The coordinates will be stored in
    the points[] array. */
    for (int i=0; i<N; i++) {
      String[] pieces = split(lines[i], '\t');
      if (pieces.length < K) continue;
      names[i] = pieces[0];
      if (names[i].length() < 1) continue;
      if (names[i].charAt(0) == ' ') continue;
      for (int j=0; j<K; j++) {
        points[i][j] = float(pieces[j+1]);
      }
    }
  }
    
  void transformPoints() {
      // The area of points should be proportional to the magnitude of their
      // concept. 
    float[] rms = new float[num_dimensions];
    for (int i=0; i<N; i++) {
      float[] pt = points[i];
      float sqrtdist = sqrt(sqrt(dot(pt, pt)));
      if (sqrtdist == 0.0) {
        System.out.println("Warning: zero-magnitude concept: "+names[i]);
      } else {
        //sizes[i] = sqrtdist*4;
        for (int j=0; j<K; j++) {
          // an interesting projection, but makes similarity less obvious
          //points[i][j] /= (sqrtdist);
          rms[j] += pt[j] * pt[j];
          
          /*
          Add up the squares of all these values. Eventually, we're going to be
          dividing them all by their root mean square, so that most of the useful
          points fall between -1 and 1 on each axis.
          */
          //rms[j] += 1;
        }
      }
    }
    
    /* Calculate the root mean squares and divide coordinates by them. */
    System.out.print("RMS: ");
    for (int i=0; i<K; i++) {
      rms[i] = sqrt(rms[i]/N);
      System.out.print(rms[i]+", ");
    }
    System.out.println();
    for (int i=0; i<N; i++) {
      float[] pt = points[i];
      for (int j=0; j<num_dimensions; j++) {
        pt[j] /= rms[j];
      }
    }
  }
  
  void calcSizes() {
    sizes = new float[N];
    for (int i=0; i<N; i++) {
      sizes[i] = sqrt(dot(points[i], points[i]))*4;
    }
    System.out.println("Size of point 0 ("+points[0][0]+","+points[0][1]+",...) is "+sizes[0]);
  }

  public class ConceptSizeComparator implements Comparator {
    public int compare(Object a, Object b) {
      int ai = ((Integer) a).intValue();
      int bi = ((Integer) b).intValue();
      if (sizes[ai] < sizes[bi]) return 1;
      else if (sizes[ai] > sizes[bi]) return -1;
      else return 0;
    }
  }

  void make_sort_array() {
    sortOrder = new Integer[N];
    for (int i=0; i<N; i++) sortOrder[i] = new Integer(i);
    Arrays.sort(sortOrder, new ConceptSizeComparator());
  }
}

