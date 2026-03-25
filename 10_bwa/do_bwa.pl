#!/usr/bin/perl -w

use strict;
use warnings ;

my $usage = "Usage: $0 <reference sequence>";

my $ref_file = shift or die "$usage\n";


my $bwa_path = 'bwa';

### Index the reference sequence
my $ref_prefix = index_reference_genome($ref_file);

### Get pairs of fastQ files
my %fastq_pairs = %{ get_pairs_of_fastq_files('.') };
    
   
foreach my $lane_name (sort keys %fastq_pairs) {
    my ($first_fq_file, $second_fq_file) = @{ $fastq_pairs{$lane_name} };
    my @commands;
    warn "considering $first_fq_file\n";
    
    ### Propose names for outputfiles
    my $aln_outfile = "$lane_name.versus.$ref_prefix.aln.sam";
    my $bam_outfile = "$lane_name.versus.$ref_prefix.aln.bam";
    my $sorted_bam_file_prefix = "$bam_outfile.sorted";
    my $sorted_bam_file = "$sorted_bam_file_prefix.bam";
    my $rmdup_bam_file = "$lane_name.versus.$ref_prefix.aln.sorted.rmdup.bam";
    my $indexed_bam_file = "$sorted_bam_file.bam.bai"; 
    my $indexed_rmdup_bam_file = "$rmdup_bam_file.bai"; 
    my $pileup_file = "$lane_name.versus.$ref_prefix.rmdup.pileup";	

    my $done_bwa_mem = 0;
    my $done_sam_to_bam = 0;
    my $done_sort_bam = 0;
    my $done_index_bam = 0;
    my $done_rmdup = 0;
    my $done_index_rmdup_bam = 0;
    
    ### Check which steps are already done
    if (-s $aln_outfile ) {
	$done_bwa_mem = 1;
	warn "Already done BWA mem step: $aln_outfile exists\n";
    }
    if (-s $bam_outfile) {
	$done_sam_to_bam = 1;
	$done_bwa_mem = 1;
	warn "Already converted SAM to BAM: $bam_outfile exists\n";
    }
    if (-s $sorted_bam_file) {
	$done_sort_bam = 1;
	$done_sam_to_bam = 1;
	$done_bwa_mem = 1;
	warn "already sorted BAM file: $sorted_bam_file exists\n";
    }
    if (-s $indexed_bam_file) {
	$done_index_bam = 1;
	$done_sam_to_bam = 1;
	$done_sort_bam = 1;
	$done_bwa_mem = 1;
	warn "already sorted BAM file: $indexed_bam_file exists\n";
    }
    if (-s $rmdup_bam_file ) {
	$done_rmdup = 1;
	$done_sam_to_bam = 1;
	$done_sort_bam = 1;
	$done_index_bam = 1;
	$done_bwa_mem = 1;
	warn "Already done rmdup step\n";
    }
    if (-s $indexed_rmdup_bam_file) {
	$done_rmdup = 1;
	$done_sam_to_bam = 1;
	$done_sort_bam = 1;
	$done_index_bam = 1;
	$done_bwa_mem = 1;
	$done_index_rmdup_bam = 1;
	warn "Already done index rmdup step\n";
    }
	
    ### Perform BWA mem alignment to generate SAM file
    push @commands, 
    "$bwa_path mem $ref_file $first_fq_file $second_fq_file > $aln_outfile.$$~ && mv $aln_outfile.$$~ $aln_outfile" 
	unless $done_bwa_mem; 
    
    ### Convert SAM to BAM
    my $sam_to_bam_command;
    my $only_uniquely_mapping_reads = 1;
    if ($only_uniquely_mapping_reads) {
	$sam_to_bam_command =
	    "samtools view -bS -q 1 -T $ref_file $aln_outfile > $bam_outfile.$$~ && mv $bam_outfile.$$~ $bam_outfile";
    } else {
	$sam_to_bam_command =
	    "samtools view -bS -T $ref_file $aln_outfile > $bam_outfile.$$~ && mv $bam_outfile.$$~ $bam_outfile";
    }
    push @commands, $sam_to_bam_command unless $done_sam_to_bam;
    
    
    ### Sort the BAM files
    push @commands, "samtools sort $bam_outfile > $sorted_bam_file" unless $done_sort_bam;
    
    ### Remove duplicates from sorted BAM files
    push @commands, "samtools rmdup -s $sorted_bam_file  $rmdup_bam_file.$$~ && mv $rmdup_bam_file.$$~ $rmdup_bam_file" unless $done_rmdup;
    
    ### Index the BAM files
    push @commands, "samtools index $sorted_bam_file" unless $done_index_bam;
    push @commands, "samtools index $rmdup_bam_file" unless $done_index_rmdup_bam;
    
        
    ### Clean-up unnecessary files
    foreach my $file ($aln_outfile,
		      $bam_outfile,
		      $sorted_bam_file,
		      $indexed_bam_file,
	) {
	push @commands, "rm $file" if -e $file and $done_index_rmdup_bam;
	
    }


    ### Create batch files containing commands
    create_batch_submission_file($lane_name, \@commands) if scalar (@commands);

    ### Execute the commands
    foreach my $cmd (@commands) {
	warn "\n$cmd\n";
	my $execute = `$cmd`;
	warn "$execute\n\n";
    }
    
}



exit;


sub index_reference_genome {
    my $ref_file = shift or die;
    
    my @commands;
    
    ### BWA index 
    my $ref_prefix =  $ref_file;
    if ($ref_prefix =~ m/(.*)\.(fn{0,1}a)$/) {
	$ref_prefix = $1;
	$ref_file = "$ref_prefix.$2";
    }
    my $bwa_index_file = "$ref_file.bwt";
    if(-s $bwa_index_file) {
	warn "\n$ref_prefix has already been indexed for BWA ($bwa_index_file exists)\n\n";
    } else {
	push @commands, "$bwa_path index $ref_file"; 
    }

    
    ### SAMtools index 
    my $samtools_index_file = "$ref_file.fai";
    if(-s $samtools_index_file) {
	warn "\n$ref_prefix has already been indexed for SAMtools ($samtools_index_file exists)\n\n";
    } else {
	push @commands,
	"samtools faidx $ref_file";
    }

    ### Execute the commands
    foreach my $cmd (@commands) {
	warn "$cmd\n";
	my $execute = `$cmd`;
	warn "$execute\n\n\n";
    }
    return $ref_prefix;
}



sub get_pairs_of_fastq_files {
    my $dirname = shift or die;
    my %fastq_pairs;
    
    ### Iterate over each fastq file, expecting pairs of reads
    opendir(DIR, $dirname) or die "can't opendir $dirname: $!";
    while (defined(my $file = readdir(DIR))) {

	### Get the filenames
	my $lane_name;
	my $first_fq_file;
	my $second_fq_file;
	
	if (  
	    $file =~ m/(astaci_B_Sa_S14)(_R[12]_001_val_)([12])(\.fq)$/ or # astaci_B_Sa_S14_R1_001_val_1.fq or
	    $file =~ m/(\S+)(_R[12]_001_val_)([12])(\.fq)$/ or
	    $file =~ m/(VTP56-4_L00[12])(_R[12]_00[12]_val_)([12])(\.fq)$/ or
	    $file =~ m/(.*)(_[12]_val_)([12])(\.fq)$/i or  # ERR015788_1_val_1.fq
	    $file =~ m/(.*)(\.[12]_val_)([12])(\.fq)$/i or  # Noks.1_val_1.fq
	    $file =~ m/(.*)([\.\_\-])([12])(\.fastq)$/i or
	    $file =~ m/(.*)([\.\_\-]R)([12])(\.fastq)$/i or
	    $file =~ m/(.*)([\.\_\-])([12])(\.fq)$/i or
	    $file =~ m/(.*)([\.\_\-]R)([12])(\.fq)$/i or
	    $file =~ m/(SRR\d+)(_)([12])(\.fastq\.gz)$/ or
	    $file =~ m/(.*)([\.\_\-])([12])(\.fq.gz)$/i
	    
	    ) {
	    #warn "$file\n\$1=$1\n\$2=$2\n\$3=$3\n\$4=$4";
	    
	    if ($3 eq '1') {
		
		### This is the first in a pair
		$lane_name = $1;
		$first_fq_file = $file;
		
		$second_fq_file = $file;
		$second_fq_file =~ s/R1_001_val_1/R2_001_val_2/;
		$second_fq_file =~ s/1_val_1/2_val_2/;
		$second_fq_file =~ s/_1_/_2_/;
		$second_fq_file =~ s/\.1\./\.2\./;
		$second_fq_file =~ s/_R1_/_R2_/;
		$second_fq_file =~ s/\.R1\./\.R2\./;
		$second_fq_file =~ s/trimmed_r1/trimmed_r2/;


		
		### Check whether the second file exists
		if (-s $second_fq_file) {
		    ### The second in the pair exists
		    warn "OK! $first_fq_file and $second_fq_file both exist\n";
		    $fastq_pairs{$lane_name} = [$first_fq_file,$second_fq_file];
		} else {
		    die "Warning: file '$first_fq_file' exists, but file '$second_fq_file' does not exist or is empty";
		}
		
		unless (-e $first_fq_file) {
		    die "File '$first_fq_file' does not exist - this should never happen!";
		}
	    }
	}
    }
    return \%fastq_pairs;
}



sub create_batch_submission_file {
    my $lane_name = shift or die;
    my $commands_ref = shift or die;
    my @commands = @{$commands_ref};
    my $outfile = "do.$lane_name.sh";
    open(OUTFILE, ">$outfile") or die $!;
    
    print OUTFILE
	'#!/bin/bash

#
# Use the following script template to submit scripts running only a single thread (i.e. using a single core on a single node)
#

#The -V switch means that the same environment variables as currently set will be used on the nodes
#The -cwd switch means run in the current directory
#The -q serial.q switch means run in the serial queue

#$ -V -cwd -q parallel.q
#The following line will kill the job automatically after 72 hrs and 10 mins - please contact the sysadmin before changing
#$ -l h_rt=72:10:00

#$ -pe smp 8 -cwd -V -l mem_total=32G

#Uncomment the following line and enter a valid email address to receive email notification of job completion

# #$ -m e -M myemail@myemail.com 
echo Running on ; hostname

#Place your command lines below this

';
    
    ### print the commands
    foreach my $cmd (@commands) {
	warn "\n$cmd\n";
	#my $execute = `$cmd`;
	#warn "$execute\n\n";
	print OUTFILE "\t$cmd\n\n";
    }
    close OUTFILE;
}
