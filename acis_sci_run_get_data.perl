#!/usr/bin/perl

#########################################################################################
#											#
#	acis_sci_run_get_data.perl: obtain data from MIT and plot acis science run	#
#											#
#	Author: Takashi Isobe (tisobe@cfa.harvard.edu)					#
#	Last update: Mar 21, 2005							#
#											#
#########################################################################################


($usec, $umin, $uhour, $umday, $umon, $uyear, $uwday, $uyday, $uisdst)= localtime(time);

if($uyear < 1900) {
       	$uyear = 1900 + $uyear;
}

#############################################
#---------- set directries-------------

$root_dir     = '/data/mta/www/mta_acis_sci_run/';	#--- acis sci run main directory

$bin_dir      = '/data/mta4/MTA/bin/';			#--- a directory which holds scripts

$bin_data_dir = '/data/mta4/MTA/data/';			#--- a directory which holds bin data

$current_dir  = 'Year'."$uyear";			#--- seting a current output directory
#
#############################################

$list = `ls -d *`;
if($list =~ /Working_dir/){
	system("rm ./Working_dir/*");
}else{
	system("mkdir ./Working_dir");
}

if($list =~ /param/){
	system("rm -rf ./param");
}
system("mkdir ./param");

get_mit_data();						##### obtain data from MIT

open(FH, './Working_dir/zdata_out');			####  new data obtained from MIT data
@data = ();
$cnt = 0;
$chk = 0;
$ind = 0;
while(<FH>){
	chomp $_;
	@atemp = split(/\s+/, $_);
	@btemp = split(/:/, $atemp[1]);
	if($btemp[0] == 1 && $chk == 0){		#### check whether data are from a new year
		$chk++;					#### if it is "1", it means Jan 1 of the year
		$ind = $cnt;
	}
	push(@data, $_);
	$cnt++;
}
close(FH);

if($chk > 0){
#
### for the case the year changed
#
### here is the last year's data
#
	$last_year = $uyear - 1;
	open(OUT, '>./Working_dir/adding_data');
	for($i = 0; $i < $ind; $i++){
		print OUT "data[$i]\n";
	}
	close(OUT);
	$name = "$root_dir".'/Year'."$last_year".'/data'."$last_year";
	system("cat ./Working_dir/adding_data >> $name");
	system("rm  ./Working_dir/adding_data");
	system("perl $bin_dir/acis_sci_run_rm_dupl.perl $name");

	$file = $name;
	separate_data();	##### sub to separate data depending on mode
	$print_ind = 'yes';	##### make different header for the main html page
	plot_script();		##### sub to plot figures

#
### here is the new year's data
#
	system("mkdir $root_dir/$current_dir");
	$name = "$root_dir/$current_dir".'/data'."$uyear";
	open(OUT, ">./$name");
	for($i = $ind; $i < $cnt; $i++){
		print OUT "$data[$i]\n";
	}
	close(OUT);
	system("perl $bin_dir/acis_sci_run_rm_dupl.perl $name");

	$file = $name;
	separate_data();
	$print_ind = 'no';
	plot_script();
}else{
#
### there is no change of year; business as usual
#
	$name = "$root_dir/$current_dir".'/data'."$uyear";
	system("cat ./Working_dir/zdata_out >> $name");
	system("perl $bin_dir/acis_sci_run_rm_dupl.perl $name");

	$file = $name;
	separate_data();
	$print_ind = 'no';
	plot_script();
}

###############################################################################
### separate_data: separate data depending on acid mode                     ###
###############################################################################

sub separate_data{

	open(FH, "$file");
	open(OUT1, ">$root_dir/$current_dir/te1_3_out");
	open(OUT2, ">$root_dir/$current_dir/te3_3_out");
	open(OUT3, ">$root_dir/$current_dir/te5_5_out");
	open(OUT4, ">$root_dir/$current_dir/te_raw_out");
	open(OUT5, ">$root_dir/$current_dir/te_hist_out");
	open(OUT6, ">$root_dir/$current_dir/cc1_3_out");
	open(OUT7, ">$root_dir/$current_dir/cc3_3_out");
	open(OUT8, ">$root_dir/$current_dir/cc5_5_out");
	open(OUT9, ">$root_dir/$current_dir/cc_raw_out");
	open(OUT10,">$root_dir/$current_dir/cc_hist_out");
	
	while(<FH>) {
		chomp $_;
		@col = split(/\s+/,$_);
		if($col[2] eq 'ACIS-I' || $col[2] eq 'ACIS-S'){
			if($col[4] eq 'Te1x3'){
				print OUT1 "$_\n";
			}elsif($col[4] eq 'Te3x3'){
				print OUT2 "$_\n";
			}elsif($col[4] eq 'Te5x5'){
				print OUT3 "$_\n";
			}elsif($col[4] eq 'TeRaw'){
				print OUT4 "$_\n";
			}elsif($col[4] eq 'TeHist'){
				print OUT5 "$_\n";
			}elsif($col[4] eq 'Cc1x3'){
				print OUT6 "$_\n";
			}elsif($col[4] eq 'Cc3x3'){
				print OUT7 "$_\n";
			}elsif($col[4] eq 'Cc5x5'){
				print OUT8 "$_\n";
			}elsif($col[4] eq 'CcRaw'){
				print OUT9 "$_\n";
			}elsif($col[4] eq 'CcHist'){
				print OUT10 "$_\n";
			}
		}
	}
	close(FH);
	close(OUT1);
	close(OUT2);
	close(OUT3);
	close(OUT4);
	close(OUT5);
	close(OUT6);
	close(OUT7);
	close(OUT8);
	close(OUT9);
	close(OUT10);
}

################################################################################
### get_mit_data: obtain acis science run data from mit web site             ###
################################################################################

sub get_mit_data{
	system("mv $root_dir/$current_dir/input_data  $root_dir/$current_dir/input_data~");
	
	open(FH, "$root_dir/$current_dir/input_data~");		#### read the past data list
	@old_data = ();
	while(<FH>){
		chomp $_;
		push(@old_data, $_);
	}
	close(FH);
	
#
### first find out the latest version of phase by reading main html page 
### here is the lnyx script to obtain web page data
#
		system("/opt/local/bin/lynx -source http://acis.mit.edu/asc/ >./Working_dir/phase_check");
		system("cat ./Working_dir/phase_check|grep Phase > ./Working_dir/phase_check2");
		open(IN, './Working_dir/phase_check2');
		@phase_list = ();
		$p_cnt = 0;
		while(<IN>){
			chomp $_;
			@atemp = split(/Phase /, $_);
			@btemp = split(/\</, $atemp[1]);
			if($btemp[0] =~ /\d/){
				push(@phase_list, $btemp[0]);
				$p_cnt++;
			}
		}
		close(IN);
		system("rm ./Working_dir/phase_check*");
		@p_temp      = sort{$a<=>$b} @phase_list;
		$last_phase  = $p_temp[$p_cnt -1];
		$first_phase = $last_phase - 3;	
		
	OUTER:
	for($version = $first_phase; $version <= $last_phase; $version++){
		$file = 'http://acis.mit.edu/asc/acisproc'."$version".'/acis'."$version".'.xs3';
	print "$file\n";
		system("/opt/local/bin/lynx -source $file > ./Working_dir/input_data"); 
		system("cp ./Working_dir/input_data $root_dir/$current_dir/");
		
#
#### extract new part of data
#
		open(FH, "./Working_dir/input_data");
		@checkdata = ();
		$cnt = 0;
		while(<FH>){
			chomp $_;
			if($_ =~ /Multiple Choices/
				|| $_ =~ /not found/i
				|| $_ =~ /Object not found!/
				|| $_ =~ /was not found/){
				
				last OUTER;
			}
			push(@checkdata, $_);
			$cnt++;
		}
		close(FH);
		@new_data = @checkdata;	       			#### if it pass the test, we proceed
	}
	
	$col_names = "$bin_data_dir".'/col_list2004';		##### list of columns to extract
	
	$col_list = ();
	open(FH, "$col_names");
	while(<FH>){
		chomp $_;
		$upper = uc ($_);
		push(@col_list, $upper);	#### column list
	}
	close(FH);
	
	for($i = 0; $i < 400; $i++){		### set a hash table
		%{data.$i}= (A =>[""],
		     	B =>[""],
		     	C =>[""],
		     	D =>[""],
		     	E =>[""],
		     	F =>[""],
		     	G =>[""],
		     	H =>[""],
		     	I =>[""],
		     	J =>[""],
		     	K =>[""],
		     	L =>[""],
		     	M =>[""],
		     	N =>[""],
		     	O =>[""],
		     	P =>[""],
		     	Q =>[""],
		     	R =>[""],
		     	S =>[""],
		     	T =>[""],
		     	U =>[""],
		     	V =>[""],
		     	W =>[""],
		     	X =>[""],
		     	Y =>[""],
		     	Z =>[""],
	             	AA =>[""],
		     	AB =>[""],
		     	AC =>[""],
		     	AD =>[""],
		     	AE =>[""],
		     	AF =>[""],
		     	AG =>[""],
		     	AH =>[""],
		     	AI =>[""],
		     	AJ =>[""],
		     	AK =>[""],
		     	AL =>[""],
		     	AM =>[""],
		     	AN =>[""],
		     	AO =>[""],
		     	AP =>[""],
		     	AQ =>[""],
		     	AR =>[""],
		     	AS =>[""],
		     	AT =>[""],
		     	AU =>[""],
		     	AV =>[""],
		     	AW =>[""],
		     	AX =>[""],
		     	AY =>[""],
		     	AZ =>[""],
		     	BA =>[""],
			);
	}
	
	@seq_list = ();
	foreach $indata (@new_data){
		@atemp = split(//, $indata);
		if($atemp[0] eq 'C'){			# if the line starts from C, it contains the data
			@btemp = split(/\@/, $indata);
			@ctemp = split(/\:/, $btemp[1]);
			@dtemp = split(//, $ctemp[0]);
			$seq    = '';
			$pos_id = '';
			$value  = 'NA';
			foreach $ent (@dtemp){
				if($ent =~/\d/){
					$seq = "$seq"."$ent";
				}else{
					$pos_id = "$pos_id"."$ent";	#this is A... BA
				}
			}
			@etemp = split(/=/, $ctemp[2]);
			if($pos_id eq 'I' || $pos_id eq 'J'){	#### time entries need a special care
				@gtemp = split(/\"/, $indata);
				$value = $gtemp[1];
			}else{
				if($etemp[1] eq ''){
					@ftemp = split(/\"/, $ctemp[2]);
					$value = $ftemp[1];
				}else{
					$value = $etemp[1];
				}
			}
			${data.$seq}{$pos_id }[0] = $value;		# hash table of the data
			push(@seq_list,$seq);
		}
	}
	close(FH);
#
### find how many data the file has
#
		@temp = sort{$a<=>$b}@seq_list;
		$cnt = 0;
		foreach(@temp){
			$cnt++;
		}
		$max = @temp[$cnt -1];		#---- drop the last one since it is usually on process.
		$max--;
	
	@new_data_save = ();
	for($i = 1; $i <= $max ; $i++){
#
#--- extract values needed and make a table
#
		$line = '';
		foreach $col (@col_list){
			$line = "$line"."${data.$i}{$col}[0]\t";
		}
		push(@new_data_save, $line);
	}
	@new_data_save = sort{$a<=>$b} @new_data_save;
#
#---- read in the past data recoreded
#
	$name = "$root_dir/$current_dir/".'data'."$uyear";
	open(FH, "$name");
	$old_cnt = 0;
	@old_data = ();
	while(<FH>){
		chomp $_;
		@dtemp = split(/\s+/, $_);
		$etemp = split(/:/,$dtemp[1]);
		$last_date = $etemp[0];
		push(@old_data, $_);
		$old_cnt++;
	}
	close(FH);

#
#---- the past data could be modified as an analysis progress; therefore, compare
#---- new data, and cut off the modified part and save as "old_data". the modified
#---- part and new part will be saved in zdata_out for the further processes.
#
	open(OUT1, '>./Working_dir/old_data');
	open(OUT2, '>./Working_dir/zdata_out');
	$chk_ent = $new_data_save[1];
	@save_old = ();
	$old_pos  = 0;
	OUTER:
	for $ent (@old_data){
		if($ent eq $chk_ent){
			last OUTER;
		}
		print OUT1 "$ent\n";
		push(@save_old, $ent);
		$old_pos++;
	}
		
	OUTER:
	foreach $ent (@new_data_save){
		for($j = $old_pos; $j < $old_cnt; $j++){
			$comp = $old_data[$j];
			@atemp = split(/\s+/, $ent);
			@btemp = split(/\s+/, $comp);
			if($atemp[0] eq $btemp[0]){
				if($ent eq $comp){
					print OUT1 "$ent\n";
				}else{
					print OUT2 "$ent\n";
				}
				next OUTER;
			}
		}	
		print OUT2 "$ent\n";
	}
	close(OUT1);
	close(OUT2);

#
#----- clean up old and new data files just created
#
	cleanup();

	$name2 = "$name".'~';
	system("mv $name $name2");
	system("mv ./Working_dir/old_data $name");
}

########################################################################
### plot_script: calling perl scripts for plotting                   ###
########################################################################

sub plot_script{
	system("perl $bin_dir/acis_sci_run_print_html.perl $print_ind");	#### print html pages

#
#---- calling plotting script
#
	system("perl $bin_dir/acis_sci_run_plot.perl $root_dir/$current_dir/cc3_3_out");	
	system("mv pgplot.ps ./Working_dir/cc3_3_out.ps");

	system("perl $bin_dir/acis_sci_run_plot.perl $root_dir/$current_dir/te3_3_out");
	system("mv pgplot.ps ./Working_dir/te3_3_out.ps");

	system("perl $bin_dir/acis_sci_run_plot.perl $root_dir/$current_dir/te5_5_out");
	system("mv pgplot.ps ./Working_dir/te5_5_out.ps");

	system("perl $bin_dir/acis_sci_run_plot.perl $root_dir/$current_dir/te_raw_out");
	system("mv pgplot.ps ./Working_dir/te_raw_out.ps");


#
### find data exceeding warning level
#
	system("perl $bin_dir/acis_sci_run_te3x3.perl      	$name");
	system("perl $bin_dir/acis_sci_run_te5x5.perl      	$name");
	system("perl $bin_dir/acis_sci_run_err3x3.perl     	$name");
	system("perl $bin_dir/acis_sci_run_err5x5.perl     	$name");
	system("perl $bin_dir/acis_sci_run_high_evnt3x3.perl    $name");
	system("perl $bin_dir/acis_sci_run_high_evnt5x5.perl    $name");

#
### change ps file to gif file
#
	system("echo ''|gs -sDEVICE=ppmraw  -r100x100 -q -NOPAUSE -sOutputFile=- ./Working_dir/cc3_3_out.ps|/data/mta4/MTA/bin/pnmflip -r270 |/data/mta4/MTA/bin/ppmtogif > $root_dir/$current_dir/cc3_3_out.gif");

	system("echo ''|gs -sDEVICE=ppmraw  -r100x100 -q -NOPAUSE -sOutputFile=- ./Working_dir/te3_3_out.ps|/data/mta4/MTA/bin/pnmflip -r270 |/data/mta4/MTA/bin/ppmtogif > $root_dir/$current_dir/te3_3_out.gif");

	system("echo ''|gs -sDEVICE=ppmraw  -r100x100 -q -NOPAUSE -sOutputFile=- ./Working_dir/te5_5_out.ps|/data/mta4/MTA/bin/pnmflip -r270 |/data/mta4/MTA/bin/ppmtogif > $root_dir/$current_dir/te5_5_out.gif");

	system("echo ''|gs -sDEVICE=ppmraw  -r100x100 -q -NOPAUSE -sOutputFile=- ./Working_dir/te_raw_out.ps|/data/mta4/MTA/bin/pnmflip -r270 |/data/mta4/MTA/bin/ppmtogif > $root_dir/$current_dir/te_raw_out.gif");

#	system("rm ./Working_dir/*ps");
}

################################################################################
### cleanup: make files time ordered, and remove duplicates                  ###
################################################################################

sub cleanup{

#
#---- clean up the older data
#

	open(FH, './Working_dir/old_data');
	@date = ();
	while(<FH>){
		chomp $_;
		@atemp = split(/\t/, $_);
		%{data.$atemp[1]}= (data =>["$_"]);
		push(@date, $atemp[1]);
	}
	close(FH);
	@ordered_date = sort{$a<=> $b} @date;
	
	@ordered_data = ();
	foreach $ent (@ordered_date){
		push(@ordered_data, ${data.$ent}{data}[0]);
	}
	
	$first = shift(@ordered_data);
	@new = ($first);
	open(OUT, ">./Working_dir/temp_old");
	print OUT  "$first\n";
	OUTER:
	foreach $ent (@ordered_data){
		@atemp = split(/\t/, $ent);
		foreach $comp (@new){
			@btemp = split(/\t/, $comp);
			if($atemp[0] == $btemp[0]){
				next OUTER;
			}
		}
		push(@new, $ent);
		print OUT  "$ent\n";
	}
	close(OUT);
	system("mv ./Working_dir/temp_old ./Working_dir/old_data");
	
#
#---- new data set
#

	open(FH, './Working_dir/zdata_out');
	@date = ();
	while(<FH>){
		chomp $_;
		@atemp = split(/\t/, $_);
		%{data.$atemp[1]}= (data =>["$_"]);
		push(@date, $atemp[1]);
	}
	close(FH);
	@ordered_date = sort{$a<=> $b} @date;
	
	@ordered_data = ();
	foreach $ent (@ordered_date){
		push(@ordered_data, ${data.$ent}{data}[0]);
	}
	
	$first = shift(@ordered_data);
	@new = ($first);
	open(OUT, '>./Working_dir/temp_new');
	print OUT  "$first\n";
	OUTER:
	foreach $ent (@ordered_data){
		@atemp = split(/\t/, $ent);
		foreach $comp (@new){
			@btemp = split(/\t/, $comp);
			if($atemp[0] == $btemp[0]){
				next OUTER;
			}
		}
		push(@new, $ent);
		print OUT  "$ent\n";
	}
	close(OUT);
	system("mv ./Working_dir/temp_new ./Working_dir/zdata_out");
}
