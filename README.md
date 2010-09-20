For generating Raphael fonts, you need to have imagemagick and php installed and in $PATH, and you need to have the cufon source installed,
which you can get [here](http://github.com/sorccu/cufon). 

call it like so: `generate.sh /path/to/fonts /path/to/cufon/convert.php /path/tooutput/directory`

For generating [fpdf](http://www.fpdf.org) fonts, you need to have [ttf2pt1](http://ttf2pt1.sourceforge.net) installed.

Call like so: `php make-fpdf-fonts.php /path/to/fonts` . It will put the files fpdf needs in `/path/to/fonts/metrics`. You can then tell fpdf where to look for them via `define('FPDF_FONTPATH', /path/to/metrics');` wherever is appropriate
