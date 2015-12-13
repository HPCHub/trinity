#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use Getopt::Long qw(:config no_ignore_case bundling pass_through);

my $usage = <<__EOUSAGE__;

####################################################################################
#
#  usage: $0 --reads_list_file <string> [Trinity params]
#
# Required:
#
# --reads_list_file <string>      file containing list of filenames corresponding 
#                                  to the reads.fasta
#
# Optional:
#
# --assembly_temp_directory <string>
#                                path for temporary output directories
#                                 of Trinity runs
#
#
#####################################################################################


__EOUSAGE__

    ;


my $reads_file;
my $help_flag;

my $assembly_temp_directory;

&GetOptions (
             'reads_list_file=s' => \$reads_file,
             'h' => \$help_flag,

             'assembly_temp_directory=s' => \$assembly_temp_directory,

             );

my @TRIN_ARGS = @ARGV;

if ($help_flag) {
    die $usage;
}

unless ($reads_file && -s $reads_file) {
    die $usage;
}


my $trin_args = "";
while (@TRIN_ARGS) {
    my $arg = shift @TRIN_ARGS;
    
    if ($arg =~ /bfly_opts/) {
        my $val = shift @TRIN_ARGS;
        # retain quotes around multiparams
        
        $trin_args .= "$arg \"$val\"";
    }
    else {
        $trin_args .= "$arg ";
    }
}


open (my $fh, $reads_file) or die "Error, cannot open file $reads_file";
while (<$fh>) {
	chomp;
    my @x = split(/\s+/);
    
    my $file = pop @x;

    my $output_directory = $file;
    my $butterfly_output_filename = "";

    if($assembly_temp_directory)
    {
      my @path = split('/', $file);
      $output_directory = "$assembly_temp_directory/" . pop @path;
      $butterfly_output_filename = "--butterfly_output_filename \"$file.out.Trinity.fasta\"";
    }    

    my $cmd = "$FindBin::Bin/../../Trinity --single \"$file\" --output \"$output_directory.out\" $butterfly_output_filename $trin_args ";
    
    print "$cmd\n";
}

exit(0);


