#!/usr/bin/perl

#################################################################################
#										#
#	acis_sci_run_err3x3.perl: extract Te3x3 data and if there is high	#
#				  error (error ratio > 1.0), take a note and	#
#			          send out email notice				#
#										#
#	author: t. isobe (tisobe@cfa.harvard.edu)				#
#										#
#	last update: Jun 8, 2005						#
#										#
#################################################################################

($usec, $umin, $uhour, $umday, $umon, $uyear, $uwday, $uyday, $uisdst)= localtime(time);

if($uyear < 1900) {
        $uyear = 1900 + $uyear;
}

#############################################
#---------- set directries-------------

$root_dir     = '/data/mta/www/mta_acis_sci_run/';      #--- acis sci run main directory
$root_dir     = '/data/mta/www/mta_acis_sci_run_test/';      #--- acis sci run main directory

$bin_dir      = '/data/mta4/MTA/bin/';                  #--- a directory which holds scripts

$bin_data_dir = '/data/mta4/MTA/data/';                 #--- a directory which holds bin data

$current_dir  = 'Year'."$uyear";                        #--- seting a current output directory
#
#############################################

$input = "$root_dir/$current_dir".'/data'."$uyear";

#
#----- read the past record of high error records
#

@old_list = ();
open(FH, "$root_dir/$current_dir/high_error_$uyear");
while(<FH>){
        chomp $_;
        @atemp = split(//, $_);
        if($atemp[0] =~ /\d/){
                push(@old_list, $_);
        }
}
close(FH);

@new_list = ();
open(FH, "$input");						#------ read data in
open(OUT, ">$root_dir/$current_dir/high_error_$uyear");		#------ print out record

print OUT "obsid   target                  start time  int time        inst    ccd     grat    err/ksec    \n";
print OUT "----------------------------------------------------------------------------------------------------\n";
while(<FH>){
	chomp $_;
	@atemp = split(/\t/, $_);
	if($atemp[6] > 0){
		$ratio = $atemp[8]/$atemp[6];
#
#------ here is the selection criteria
#
		if($atemp[2] =~ /ACIS/ && $atemp[4] =~ /Te3x3/ && $ratio > 1.0){
			@etemp = split(//, $ratio);
			$ztemp = "$etemp[0]"."$etemp[1]"."$etemp[2]"."$etemp[3]"."$etemp[4]"."$etemp[5]"."$etemp[6]";
                        $ratio = $ztemp;
			$cnt = 0;
			@btemp = split(//, $atemp[11]);
			foreach (@btemp){
				$cnt++;
			}
			if($cnt < 20){
				for($i= $cnt; $i < 20; $i++){
					$atemp[11] = "$atemp[11]"." ";
				}
			}else{
				$temp ='';
				for($i = 0; $i < 20; $i++){
					$temp = "$temp"."$btemp[$i]";
				}
				$atemp[11] = $temp;
			}

                        print OUT "$atemp[0]\t$atemp[11]\t$atemp[1]\t$atemp[6]\t\t$atemp[2]\t$atemp[3]\t$atemp[10]\t$ratio\n";
                        $line = "$atemp[0]\t$atemp[11]\t$atemp[1]\t$atemp[6]\t\t$atemp[2]\t$atemp[3]\t$atemp[10]\t$ratio";
                        push(@new_list, $line);
		}
	}
}
close(FH);
close(OUT);

#
#------- this part prints out high error record to the entire period and keeps the record in Long_term section
#
open(OUT, '>./Working_dir/temp_warning');
print OUT "obsid   target                  start time  int time        inst    ccd     grat    err/ksec    \n";
print OUT "----------------------------------------------------------------------------------------------------\n";
for($year = 1999; $year <= $uyear; $year++){
	$f_name = "$root_dir".'/Year'."$year".'/high_error_'."$year";
	open(FH, "$f_name");
	print OUT "\nYear $year\n";
	print OUT "----------\n";
	while(<FH>){
		chomp $_;
		@atemp = split(/\s+/, $_);
		if($atemp[0] =~ /\d/){
			print OUT "$_\n";
		}
	}
	close(FH);
}
close(OUT);
system("mv ./Working_dir/temp_warning $root_dir/Long_term/high_error");

#
#----- check whether any entries are new
#

$chk = 0;
@alart = ();
OUTER:
for $ent (@new_list){
	@ntemp = split(/\s+/, $ent);
        for $comp (@old_list){
		@otemp = split(/\S+/, $comp);
                if($ent eq $comp || $ntemp[0] == $otemp[0]){
                        next OUTER;
                }
        }
        $chk++;
        push(@alart, $ent);
}

#
#----- if the record is new, send out email
#

if($chk > 0){
        open(OUT, '>../Working_dir/alart.tmp');
	print OUT "ACIS Science Run issued the following warning(s)\n\n";
        print OUT "The following observation has a high Te3x3 Error Rate in today's science run\n\n";
	print OUT "obsid   target                  start time  int time        inst    ccd     grat    err/ksec    \n";
        print OUT "----------------------------------------------------------------------------------------------------\n";
        foreach $ent (@alart){
                print OUT "$ent\n";
        }
	print OUT "\n",' Plese check: http://asc.harvard.edu/mta_days/mta_acis_sci_run/science_run.html',"\n";
	print OUT "\n",' or MIT ACIS Site: http://acis.mit.edu/asc/',"\n";
        close(OUT);

        system("cat ./Working_dir/alart.tmp |mailx -s \"Subject: ACIS Science Run Alert<> High Te3x3 Error Rate\n\" -r  isobe\@head-cfa.harvard.edu -c isobe\@head-cfa.harvard.edu swolk\@head.cfa.harvard.edu cus\@head.cfa.harvard.edu");
###        system("cat ./Working_dir/alart.tmp |mailx -s \"Subject: High Te3x3 Error Rate---Test\n\" -r  isobe\@head-cfa.harvard.edu isobe\@head-cfa.harvard.edu ");
}

