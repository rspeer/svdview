import java.io.File;
import java.awt.Frame;
import javax.swing.*;
import javax.swing.filechooser.*;

class OptionDialog {
  static class BinaryFileFilter extends FileFilter {
      public boolean accept(File f) {
        return f.isDirectory() || f.getName().endsWith(".coords");
      }
  
      public String getDescription() {
          return "Binary files";
      }
  }
  static String prompt_for_file(Frame frame) {
    JFileChooser chooser = new JFileChooser();
    chooser.setCurrentDirectory(new File(chooser.getCurrentDirectory(), "Documents/Processing/svdview/data"));
    chooser.setFileFilter(new OptionDialog.BinaryFileFilter());
    int returnVal = chooser.showOpenDialog(frame);
    if (returnVal != JFileChooser.APPROVE_OPTION) System.exit(1);
    String chosen = chooser.getSelectedFile().getName();

    if (chosen == null) System.exit(1);

    // determine the basename
    String basename = null;
    if (chosen.endsWith(".names")) {
      basename = chosen.substring(0, chosen.length()-6);
    } else if (chosen.endsWith(".coords")) {
      basename = chosen.substring(0, chosen.length()-7);
    } else {
      System.err.println("The file you chose ("+chosen+") isn't a data file.");
      System.exit(1);
    }
    System.out.println("Using data: "+basename);
    return basename;
  }

}


