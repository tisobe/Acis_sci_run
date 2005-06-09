#!/usr/bin/perl

#################################################################################
#										#
#	print_html.perl: print a html page for acis science run web page	#
#										#
#	Author:	Takashi Isobe (tisobe@cfa.harvard.edu)				#
#										#
#	Jun 07, 2005:	Last update  						#
#										#
#################################################################################


#######	checking today's date #######


($usec, $umin, $uhour, $umday, $umon, $uyear, $uwday, $uyday, $uisdst)= localtime(time);

if($uyear < 1900) {
        $uyear = 1900 + $uyear;
}
$month = $umon + 1;

if ($uyear == 1999) {
        $dom = $uyday - 202;
}elsif($uyear >= 2000){
        $dom = $uyday + 163 + 365*($uyear - 2000);
        if($uyear > 2000) {
                $dom++;
        }
        if($uyear > 2004) {
                $dom++;
        }
        if($uyear > 2008) {
                $dom++;
        }
        if($uyear > 2012) {
                $dom++;
        }
}

#############################################
#---------- set directries-------------

$root_dir     = '/data/mta/www/mta_acis_sci_run/';      #--- acis sci run main directory

$bin_dir      = '/data/mta4/MTA/bin/';                  #--- a directory which holds scripts

$bin_data_dir = '/data/mta4/MTA/data/Acis_sci_run';     #--- a directory which holds bin data

$current_dir  = 'Year'."$uyear";                        #--- seting a current output directory

$http_dir     = 'http://asc.harvard.edu/mta_days/mta_acis_sci_run/';
#
#############################################

###### creating a main page #######

open(OUT, ">$root_dir/science_run.html");

print OUT '<HTML>';

print OUT '<BODY TEXT="#FFFFFF" BGCOLOR="#000000" LINK="#00CCFF" VLINK="#B6FFFF" ALINK="#FF0000", background="./stars.jpg">',"\n";

print OUT '<title> ACIS Science Run </title>',"\n";

print OUT '<CENTER><H2>ACIS Science Run</H2> </CENTER>',"\n";

print OUT '<CENTER><H2>Updated ';
print OUT "$uyear-$month-$umday  ";
print OUT "\n";
print OUT "<br>";
print OUT "DAY OF YEAR: $uyday ";
print OUT "\n";
print OUT "<br>";
print OUT "DAY OF MISSION: $dom ";
print OUT '</H2></CENTER>';
print OUT "\n";
print OUT '<P>';
print OUT "\n";

print OUT '<HR>';


print OUT '<P>';
print OUT 'Data plotted here are taken from psi processing log ',"\n";
print OUT '(http://acis.mit.edu/acs). There are three plots in',"\n";
print OUT 'each Fep mode:',"\n";
print OUT '<br>',"\n";
print OUT '</P>';
print OUT '<P>';
print OUT 'Top: evnets per second for each science run',"\n";
print OUT '<br>',"\n";
print OUT 'Middle: numbers of errors reported by psi per ksec for each science run',"\n";
print OUT '<br>',"\n";
print OUT 'Bottom: Percentage of exposures dropped for each science run',"\n";
print OUT '<br>',"\n";
print OUT '</P>';
print OUT '<P>';
print OUT 'For the details, plese go to mit web site.',"\n";


print OUT '<H2> Plots by Fep Mode </H2>',"\n";

print OUT '<table border = 0 cellspacing=10 cellpadding=10>',"\n";
print OUT '<tr>',"\n";
print OUT '<th>This Year</th>',"\n";
print OUT '<td><A HREF=',"$http_dir/$current_dir",'/te3_3.html> Te 3X3 </A></td>',"\n";
print OUT '<td><A HREF=',"$http_dir/$current_dir",'/te5_5.html> Te 5X5 </A></td>',"\n";
print OUT '<td><A HREF=',"$http_dir/$current_dir",'/te_raw.html> Te Raw </A></td>',"\n";
print OUT '<td><A HREF=',"$http_dir/$current_dir",'/cc3_3.html> Cc 3X3 </A></td>',"\n";
print OUT '</tr>',"\n";
print OUT '<th>Entire Period</th>',"\n";
print OUT '<td><A HREF=',"$http_dir",'/Long_term/te3_3.html> Te 3X3 </A></td>',"\n";
print OUT '<td><A HREF=',"$http_dir",'/Long_term/te5_5.html> Te 5X5 </A></td>',"\n";
print OUT '<td><A HREF=',"$http_dir",'/Long_term/te_raw.html> Te Raw </A></td>',"\n";
print OUT '<td><A HREF=',"$http_dir",'/Long_term/cc3_3.html> Cc 3X3 </A></td>',"\n";
print OUT '</tr></table>',"\n";

print OUT '<br>',"\n";
print OUT '<hr>',"\n";

print OUT '<H2> Past Data </H2>',"\n";
for($iyear = 1999; $iyear < $uyear; $iyear++){
	print OUT '<a href=',"$http_dir",'/Year';
	print OUT "$iyear",'/science_run',"$iyear".'.html>Year ',"$iyear",'</a><br>',"\n";
}

print OUT '<a href=',"$http_dir",'Long_term/science_long_term.html>Entire Period</a><br>',"\n";

print OUT '<hr>',"\n";

print OUT '<H4> DATA Plotted (ASCII format): ',"\n";
print OUT '<A HREF=',"$http_dir/$current_dir",'/data',"$uyear",'>Data</A>',"\n";
print OUT '</H4>',"\n";

print OUT '<H4>  Te3x3 DATA with Dropped Rate > 3 %: ',"\n";
print OUT '<A HREF=',"$http_dir/$current_dir",'/drop_',"$uyear".'>Dropped Data</A>',"\n";
print OUT '</H4>',"\n";

print OUT '<H4>  Te5x5 DATA with Dropped Rate > 3 %: ',"\n";
print OUT '<A HREF=',"$http_dir/$current_dir",'/drop5x5_',"$uyear".'> Dropped Data</A>',"\n";
print OUT '</H4>',"\n";

print OUT '<H4>  Te3x3 DATA with Event Rate > 180 cnt/sec:  ',"\n";
print OUT '<A HREF=',"$http_dir/$current_dir",'/high_event_',"$uyear".'>High Count Data</A>',"\n";
print OUT '</H4>',"\n";

print OUT '<H4>  Te5x5 DATA with Event Rate > 56 cnt/sec:  ',"\n";
print OUT '<A HREF=',"$http_dir/$current_dir",'/high_event5x5_',"$uyear".'>High Count  Data</A>',"\n";
print OUT '</H4>',"\n";

print OUT '<H4>  Te3x3 DATA with Error # > 1 cnt/ksec:  ',"\n";
print OUT '<A HREF=',"$http_dir/$current_dir",'/high_error_',"$uyear".'>High Error Data</A>',"\n";
print OUT '</H4>',"\n";

print OUT '<H4>  Te5x5 DATA with Error # > 1 cnt/ksec:  ',"\n";
print OUT '<A HREF=',"$http_dir/$current_dir",'/high_error5x5_',"$uyear".'>High Error Data</A>',"\n";
print OUT '</H4>',"\n";

print OUT '<hr>',"\n";
print OUT '<A HREF=http://acis.mit.edu/asc>Acis Science Run, MIT site</A>',"\n";
print OUT '<br>',"\n";

print OUT '<A HREF=http://asc.harvard.edu/mta_days/mta_acis_sci_run/science_run.html>Current Year</A>',"\n";
print OUT '<br>',"\n";

print OUT '<A HREF=http://asc.harvard.edu/mta/sot.html>Back to SOT page</A>';
close(OUT);

########################################################
#######------- a similar page as above but for specifically for Year $uyear directory
########################################################

$h_name = "$root_dir/".'Year'."$uyear".'/science_run'."$uyear".'.html';
open(OUT, ">$h_name");

print OUT '<HTML>';

print OUT '<BODY TEXT="#FFFFFF" BGCOLOR="#000000" LINK="#00CCFF" VLINK="#B6FFFF" ALINK="#FF0000", background="./stars.jpg">',"\n";

print OUT '<title> ACIS Science Run </title>',"\n";

print OUT '<CENTER><H2>ACIS Science Run: Year'," $uyear",'</H2> </CENTER>',"\n";

print OUT '<CENTER><H2>Updated ';
print OUT "$uyear-$month-$umday  ";
print OUT "\n";
print OUT "<br>";
print OUT "DAY OF YEAR: $uyday ";
print OUT "\n";
print OUT "<br>";
print OUT "DAY OF MISSION: $dom ";
print OUT '</H2></CENTER>';
print OUT "\n";
print OUT '<P>';
print OUT "\n";

print OUT '<HR>';


print OUT '<P>';
print OUT 'Data plotted here are taken from psi processing log ',"\n";
print OUT '(http://acis.mit.edu/acs). There are three plots in',"\n";
print OUT 'each Fep mode:',"\n";
print OUT '<br>',"\n";
print OUT '</P>';
print OUT '<P>';
print OUT 'Top: evnets per second for each science run',"\n";
print OUT '<br>',"\n";
print OUT 'Middle: numbers of errors reported by psi per ksec for each science run',"\n";
print OUT '<br>',"\n";
print OUT 'Bottom: Percentage of exposures dropped for each science run',"\n";
print OUT '<br>',"\n";
print OUT '</P>';
print OUT '<P>';
print OUT 'For the details, plese go to mit web site.',"\n";


print OUT '<H2> Plots by Fep Mode </H2>',"\n";

print OUT '<table border = 0 cellspacing=10 cellpadding=10>',"\n";
print OUT '<tr>',"\n";
print OUT '<td><A HREF=',"$http_dir/$current_dir",'/te3_3.html> Te 3X3 </A></td>',"\n";
print OUT '</tr><tr>',"\n";
print OUT '<td><A HREF=',"$http_dir/$current_dir",'/te5_5.html> Te 5X5 </A></td>',"\n";
print OUT '</tr><tr>',"\n";
print OUT '<td><A HREF=',"$http_dir/$current_dir",'/te_raw.html> Te Raw </A></td>',"\n";
print OUT '</tr><tr>',"\n";
print OUT '<td><A HREF=',"$http_dir/$current_dir",'/cc3_3.html> Cc 3X3 </A></td>',"\n";
print OUT '</tr></table>',"\n";

print OUT '<br>',"\n";

print OUT '<hr>',"\n";

print OUT '<H4> DATA Plotted (ASCII format): ',"\n";
print OUT '<A HREF=',"$http_dir/$current_dir",'/data',"$uyear",'>Data</A>',"\n";
print OUT '</H4>',"\n";

print OUT '<H4>  Te3x3 DATA with Dropped Rate > 3 %: ',"\n";
print OUT '<A HREF=',"$http_dir/$current_dir",'/drop_',"$uyear".'>Dropped Data</A>',"\n";
print OUT '</H4>',"\n";

print OUT '<H4>  Te5x5 DATA with Dropped Rate > 3 %: ',"\n";
print OUT '<A HREF=',"$http_dir/$current_dir",'/drop5x5_',"$uyear".'>Data</A>',"\n";
print OUT '</H4>',"\n";

print OUT '<H4>  Te3x3 DATA with Event Rate > 180 cnt/sec:  ',"\n";
print OUT '<A HREF=',"$http_dir/$current_dir",'/high_event_',"$uyear".'>High Count Data</A>',"\n";
print OUT '</H4>',"\n";

print OUT '<H4>  Te5x5 DATA with Event Rate > 56 cnt/sec:  ',"\n";
print OUT '<A HREF=',"$http_dir/$current_dir",'/high_event5x5_',"$uyear".'>High Count  Data</A>',"\n";
print OUT '</H4>',"\n";

print OUT '<H4>  Te3x3 DATA with Error # > 1 cnt/ksec:  ',"\n";
print OUT '<A HREF=',"$http_dir/$current_dir",'/high_error_',"$uyear".'>High Error Data</A>',"\n";
print OUT '</H4>',"\n";

print OUT '<H4>  Te5x5 DATA with Error # > 1 cnt/ksec:  ',"\n";
print OUT '<A HREF=',"$http_dir/$current_dir",'/high_error5x5_',"$uyear".'>High Error Data</A>',"\n";
print OUT '</H4><br>',"\n";


print OUT '<hr>',"\n";
print OUT '<A HREF=http://acis.mit.edu/asc>Acis Science Run, MIT site</A>',"\n";
print OUT '<br>',"\n";
print OUT '<A HREF=',"$http_dir",'/science_run.html>Current Year</A>',"\n";
print OUT '<br>',"\n";

print OUT '<A HREF=http://asc.harvard.edu/mta/sot.html>Back to SOT page</A>';
close(OUT);


########################################################
#######------- a similar page as above but for specifically for Long term directory
########################################################

$h_name = "$root_dir".'/Long_term/science_long_term.html';
open(OUT, ">$h_name");

print OUT '<HTML>';

print OUT '<BODY TEXT="#FFFFFF" BGCOLOR="#000000" LINK="#00CCFF" VLINK="#B6FFFF" ALINK="#FF0000", background="./stars.jpg">',"\n";

print OUT '<title> ACIS Science Run </title>',"\n";

print OUT '<CENTER><H2>ACIS Science Run: Entire Period</H2> </CENTER>',"\n";

print OUT '<CENTER><H2>Updated ';
print OUT "$uyear-$month-$umday  ";
print OUT "\n";
print OUT "<br>";
print OUT "DAY OF YEAR: $uyday ";
print OUT "\n";
print OUT "<br>";
print OUT "DAY OF MISSION: $dom ";
print OUT '</H2></CENTER>';
print OUT "\n";
print OUT '<P>';
print OUT "\n";

print OUT '<HR>';


print OUT '<P>';
print OUT 'Data plotted here are taken from psi processing log ',"\n";
print OUT '(http://acis.mit.edu/acs). There are three plots in',"\n";
print OUT 'each Fep mode:',"\n";
print OUT '<br>',"\n";
print OUT '</P>';
print OUT '<P>';
print OUT 'Top: evnets per second for each science run',"\n";
print OUT '<br>',"\n";
print OUT 'Middle: numbers of errors reported by psi per ksec for each science run',"\n";
print OUT '<br>',"\n";
print OUT 'Bottom: Percentage of exposures dropped for each science run',"\n";
print OUT '<br>',"\n";
print OUT '</P>';
print OUT '<P>';
print OUT 'For the details, plese go to mit web site.',"\n";


print OUT '<H2> Plots by Fep Mode </H2>',"\n";

print OUT '<table border = 0 cellspacing=10 cellpadding=10>',"\n";
print OUT '<tr>',"\n";
print OUT '<td><A HREF=',"$http_dir",'/Long_term/te3_3.html> Te 3X3 </A></td>',"\n";
print OUT '</tr><tr>',"\n";
print OUT '<td><A HREF=',"$http_dir",'/Long_term/te5_5.html> Te 5X5 </A></td>',"\n";
print OUT '</tr><tr>',"\n";
print OUT '<td><A HREF=',"$http_dir",'/Long_term/te_raw.html> Te Raw </A></td>',"\n";
print OUT '</tr><tr>',"\n";
print OUT '<td><A HREF=',"$http_dir",'/Long_term/cc3_3.html> Cc 3X3 </A></td>',"\n";
print OUT '</tr></table>',"\n";

print OUT '<br>',"\n";

print OUT '<hr>',"\n";

print OUT '<H4>  Te3x3 DATA with Dropped Rate > 3 %: ',"\n";
print OUT '<A HREF=',"$http_dir",'/Long_term/drop>Dropped Data</A>',"\n";
print OUT '</H4>',"\n";

print OUT '<H4>  Te5x5 DATA with Dropped Rate > 3 %: ',"\n";
print OUT '<A HREF=',"$http_dir",'/Long_term/drop5x5>Dropped Data</A>',"\n";
print OUT '</H4>',"\n";

print OUT '<H4>  Te3x3 DATA with Event Rate > 180 cnt/sec:  ',"\n";
print OUT '<A HREF=',"$http_dir",'/Long_term/high_event>High Count Data</A>',"\n";
print OUT '</H4>',"\n";

print OUT '<H4>  Te5x5 DATA with Event Rate > 56 cnt/sec:  ',"\n";
print OUT '<A HREF=',"$http_dir",'/Long_term/high_event5x5>High Count  Data</A>',"\n";
print OUT '</H4>',"\n";

print OUT '<H4>  Te3x3 DATA with Error # > 1 cnt/ksec:  ',"\n";
print OUT '<A HREF=',"$http_dir",'/Long_term/high_error>High Error Data</A>',"\n";
print OUT '</H4>',"\n";

print OUT '<H4>  Te5x5 DATA with Error # > 1 cnt/ksec:  ',"\n";
print OUT '<A HREF=',"$http_dir",'/Long_term/high_error5x5>High Error Data</A>',"\n";
print OUT '</H4><br>',"\n";


print OUT '<hr>',"\n";
print OUT '<A HREF=http://acis.mit.edu/asc>Acis Science Run, MIT site</A>',"\n";
print OUT '<br>',"\n";
print OUT '<A HREF=',"$http_dir",'/science_run.html>Current Year</A>',"\n";
print OUT '<br>',"\n";

print OUT '<A HREF=http://asc.harvard.edu/mta/sot.html>Back to SOT page</A>';
close(OUT);



####### printing an acis plot html page   ########

	open(OUT,">$root_dir/$current_dir/te5_5.html");
	print OUT '<HTML>';
	print OUT '<BODY TEXT="#FFFFFF" BGCOLOR="#000000" LINK="#00CCFF" VLINK="#B6FFFF" ALINK="#FF0000">',"\n";
	print OUT '<title> Te 5x5 mode </title>',"\n";
	print OUT '<CENTER><H2>Te 5x5 mode</H2> </CENTER>',"\n";
	print OUT '<CENTER><H2>Updated ';
	print OUT "$uyear-$month-$umday  ";
	print OUT "\n";
	print OUT "<br>";
	print OUT "DAY OF YEAR: $uyday ";
	print OUT "\n";
	print OUT "<br>";
	print OUT "DAY OF MISSION: $dom ";
	print OUT '</H2></CENTER>';
	print OUT "\n";
	print OUT '<P>';
	print OUT "\n";
	print OUT '<HR>',"\n";
	print OUT '<IMG SRC="',"$http_dir/$current_dir",'/te5_5_out.gif">',"\n";
	close(OUT);

	open(OUT,">$root_dir/$current_dir/te3_3.html");
	print OUT '<HTML>';
	print OUT '<BODY TEXT="#FFFFFF" BGCOLOR="#000000" LINK="#00CCFF" VLINK="#B6FFFF" ALINK="#FF0000">',"\n";
	print OUT '<title> Te 3x3 mode </title>',"\n";
	print OUT '<CENTER><H2>Te 3x3 mode</H2> </CENTER>',"\n";
	print OUT '<CENTER><H2>Updated ';
	print OUT "$uyear-$month-$umday  ";
	print OUT "\n";
	print OUT "<br>";
	print OUT "DAY OF YEAR: $uyday ";
	print OUT "\n";
	print OUT "<br>";
	print OUT "DAY OF MISSION: $dom ";
	print OUT '</H2></CENTER>';
	print OUT "\n";
	print OUT '<P>';
	print OUT "\n";
	print OUT '<HR>',"\n";
	print OUT '<IMG SRC="',"$http_dir/$current_dir",'/te3_3_out.gif">',"\n";
	close(OUT);

	open(OUT,">$root_dir/$current_dir/te_raw.html");
	print OUT '<HTML>';
	print OUT '<BODY TEXT="#FFFFFF" BGCOLOR="#000000" LINK="#00CCFF" VLINK="#B6FFFF" ALINK="#FF0000">',"\n";
	print OUT '<title> Te Raw mode </title>',"\n";
	print OUT '<CENTER><H2>Te Raw mode</H2> </CENTER>',"\n";
	print OUT '<CENTER><H2>Updated ';
	print OUT "$uyear-$month-$umday  ";
	print OUT "\n";
	print OUT "<br>";
	print OUT "DAY OF YEAR: $uyday ";
	print OUT "\n";
	print OUT "<br>";
	print OUT "DAY OF MISSION: $dom ";
	print OUT '</H2></CENTER>';
	print OUT "\n";
	print OUT '<P>';
	print OUT "\n";
	print OUT '<HR>',"\n";
	print OUT '<IMG SRC="',"$http_dir/$current_dir",'/te_raw_out.gif">',"\n";
	close(OUT);

	open(OUT,">$root_dir/$current_dir/cc3_3.html");
	print OUT '<HTML>';
	print OUT '<BODY TEXT="#FFFFFF" BGCOLOR="#000000" LINK="#00CCFF" VLINK="#B6FFFF" ALINK="#FF0000">',"\n";
	print OUT '<title> Cc 3x3 mode </title>',"\n";
	print OUT '<CENTER><H2>Cc 3x3 mode</H2> </CENTER>',"\n";
	print OUT '<CENTER><H2>Updated ';
	print OUT "$uyear-$month-$umday  ";
	print OUT "\n";
	print OUT "<br>";
	print OUT "DAY OF YEAR: $uyday ";
	print OUT "\n";
	print OUT "<br>";
	print OUT "DAY OF MISSION: $dom ";
	print OUT '</H2></CENTER>';
	print OUT "\n";
	print OUT '<P>';
	print OUT "\n";
	print OUT '<HR>',"\n";
	print OUT '<IMG SRC="',"$http_dir/$current_dir",'/cc3_3_out.gif">',"\n";
	close(OUT);
