#!/usr/bin/env php
<?php
if (php_sapi_name() == 'cli' && empty($_SERVER['REMOTE_ADDR'])) {
  require('make-fpdf-fonts/makefont.php');

  $usage = <<<EOD
  Usage:    
  makefont /path/to/fonts/root
EOD;
  
  if ($argc < 2) {
    exit($usage);
  }

  $fonts_path = realpath($argv[1]);

  if (!is_dir($fonts_path)) {
    exit ($fonts_path. ' does not appear to be a directory');
  }
  
  $save_path = $fonts_path.'/metrics';

  if (!is_dir($save_path)) {
    mkdir($save_path);
  }

  foreach (glob($fonts_path.'/*/*ttf') as $font){
    system(implode(' ', array(
                     'ttf2pt1 -a',
                     escapeshellarg($font),
                     escapeshellarg(pathinfo($font, PATHINFO_FILENAME))
                   )));
    // no control over output directories is provided by these files by default, so we
    // get to do a rename dance!
    rename(
      pathinfo($font, PATHINFO_FILENAME).'.afm',
      pathinfo($font, PATHINFO_DIRNAME).'/'.pathinfo($font, PATHINFO_FILENAME).'.afm'
    );
      
    rename(
      pathinfo($font, PATHINFO_FILENAME).'.t1a',
      pathinfo($font, PATHINFO_DIRNAME).'/'.pathinfo($font, PATHINFO_FILENAME).'.t1a'
    );

    MakeFont(
      $font,
      str_replace('ttf', 'afm', $font),
      'ISO-8859-1'
    );

    rename(
      pathinfo($font, PATHINFO_FILENAME).'.php',
      $save_path.'/'.pathinfo($font, PATHINFO_FILENAME).'.php'
    );

    rename(
      pathinfo($font, PATHINFO_FILENAME).'.z',
      $save_path.'/'.pathinfo($font, PATHINFO_FILENAME).'.z'
    );
  }
}
?>
