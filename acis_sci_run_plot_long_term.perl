#!/usr/bin/perl
use PGPLOT;

#########################################################################
#									#
#	plot_long_term.perl: this version plots data for sicence run	#
#			   for a entire period	         		#
#	Input file form:						#
#	date  sim ccd mode&# fep mode bep mode ksec evts errors drop	#
#									#
#	Author: Takashi Isobe (tisobe@cfa.harvard.edu)			#
#									#
#	Jun 06, 2005: first version					#
#									#
#########################################################################


($usec, $umin, $uhour, $umday, $umon, $uyear, $uwday, $uyday, $uisdst)= localtime(time);
$uyear = $uyear + 1900;
$last_year = $uyear - 1;

#############################################
#---------- set directries-------------

$root_dir     = '/data/mta/www/mta_acis_sci_run/';      #--- acis sci run main directory

$bin_dir      = '/data/mta4/MTA/bin/';                  #--- a directory which holds scripts

$bin_data_dir = '/data/mta4/MTA/data/Acis_sci_run';     #--- a directory which holds bin data

$current_dir  = 'Year'."$uyear";                        #--- seting a current output directory
#
#############################################

$list = `ls -d $root_dir`;
if($list =~ /$$current_dir/){
}else{
	system("mkdir $root_dir/$current_dir");
}

foreach $mode ('cc3_3', 'te3_3', 'te5_5', 'te_raw'){
	@col = ();
	@date_list = ();
	@count_list = ();
	@err_list = ();
	@drop_list = ();
	$count  = 0;
	for($year = 1999; $year <= $uyear; $year++){
		$y_dir = 'Year'."$year";
		$file = "$root_dir/$y_dir".'/'."$mode".'_out';
		open(FH, "$file");
		while(<FH>) {
			chomp $_;
			@col = split(/\s+/, $_);
			@atemp = split(/:/,$col[1]);
			$date = $atemp[0] + $atemp[1]/86400.0;
			if($col[6] > 0) {
				$evt = $col[7]/$col[6]/1000.0;
				$err = $col[8]/$col[6];
				push(@date_list,$date);
				push(@count_list, $evt);
				push(@err_list, $err);
				push(@drop_list,$col[9]);
				$count++;
			}
		}
		close(FH);
	}

	pgbegin(0, "/ps",1,1);			# setting environment for plots
	pgsubp(1,3);				# 3 plot per a panel
	pgsch(2);
	pgslw(2);
	
	@xbin = @date_list;			#### evnts plot starts here
	@ybin = @count_list;
	
	x_min_max();				# find min & max of x
	
	y_min_max();				# find min & max of y
	
	$xt_axis = 'Time (Day of Year)';
	$yt_axis = 'Events/sec';
	$title = 'Events per Second (Science Run)';
	if($file eq 'te_raw_out'){		# special case for te_raw
			$ymin = 0;		# this does not have any events
			$ymax = 10;		# so we need to set min and max
	}
	
	if($ymax > $ymin){
		plot_fig();				# here is the plot
	}
	
	@ybin = @err_list;			#### error plot starts here
	$sum = 0;
	$ycnt = 0;
	foreach $ent (@ybin){
		$sum += $ent;
		$ycnt++;
	}
	$avg = $sum/$ycnt;
	$ymax = 3.0 * $avg;
	y_min_max();
	
	$yt_axis = "Errors/ksec";
	$title = 'Errors (Science Run)';
	
	if($ymax > $ymin){
		plot_fig();
	}
	
	@ybin = @drop_list;			#### drop frame plots start here
	
	y_min_max();
	
	$yt_axis = "Percent";
	$title = 'Percentage of Exposures Dropped (Science Run)';
	
	if($ymax > $ymin){
		plot_fig();
	}
	
	pgclos;


	$out_name = "$root_dir".'Long_term/long_term_'."$mode".'.gif';

	system("echo ''|gs -sDEVICE=ppmraw  -r100x100 -q -NOPAUSE -sOutputFile=- ./pgplot.ps|/data/mta4/MTA/bin/pnmflip -r270 |/data/mta4/MTA/bin/ppmtogif > $out_name");
	system("rm pgplot.ps");
}


########################################################
###    plot_fig: plot figure from a give data      #####
########################################################

sub plot_fig {

        pgenv($xmin, $xmax, $ymin, $ymax, 0, 0);
	if($file eq 'te_raw_out' && $yt_axis eq 'Events/sec'){
		pgtext($xmin+50, 5, "NO DATA");
	}

        pgpt(1, $xbin[0], $ybin[0], -1);                # plot a point (x, y)
        for($m = 1; $m < $count-1; $m++) {
                unless($ybin[$m] eq '*****' || $ybin[$m] eq ''){
                        pgpt(1,$xbin[$m], $ybin[$m], 3);
                }
                unless($yerr[$m] eq '*****' || $yerr[$m] eq ''){
                        $yb = $ybin[$m] - $yerr[$m];
                        $yt = $ybin[$m] + $yerr[$m];
                        pgpt(1,$xbin[$m], $yb,-2);
                        pgdraw($xbin[$m],$yt);
                }
        }
        pgslw(1);
        pgpt(1,$xmin,0,-1);
        pgdraw($xmax,0);
        pglabel("$xt_axis","$yt_axis", "$title");       # write labels
}

########################################################
###   x_min_max: find min and max of y values      #####
########################################################

sub x_min_max {

        @xtrim = ();
        $subt = 0;
        foreach $xent (@xbin) {

                if($xent =~ /\d/) {
                        push(@xtrim, $xent);
                } else {
                        $subt++;
                }
        }
        @xtemp = sort { $a<=> $b }  @xtrim;
        $xmin = $xtemp[0];

        if($xmin < 0.0) {
                $xmin = $xmin*1.02;
        } else {
                $xmin = $xmin*0.98;
        }

        $xmax = @xtemp[$count -1 -$subt];
        if($xmax < 0.0) {
                $xmax = $xmax*0.99;
        }else{
                $xmax = $xmax*1.02;
        }
}

########################################################
###   y_min_max: find min and max of y values      #####
########################################################

sub y_min_max {
        @ytrim = ();
        $subt = 0;
        foreach $yent (@ybin) {
                if($yent =~ /\d/) {
                        push(@ytrim, $yent);
                } else {
                        $subt++;
                }
        }
        @ytemp = sort { $a <=> $b }  @ytrim;
        $ymin = @ytemp[0];
        if($ymin < 0.0) {
                $ymin = $ymin*1.02;
        } else {
                $ymin = $ymin*0.98;
        }

        $ymax = @ytemp[$count -1 - $subt];
        if($ymax < 0.0) {
                $ymax = $ymax*0.99;
        }else{
                $ymax = $ymax*1.02;
        }
}


