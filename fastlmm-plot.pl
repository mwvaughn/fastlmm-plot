#!/usr/bin/env perl

use Getopt::Long;

use constant kMarkerName => 0;
use constant kChromosome => 1;
use constant kGeneticPosition => 2;
use constant kPosition => 3;
use constant kPvalue => 4;

# Defaults
my ($file, $graph_title, $position, $log, $output) = ("", "FastLMM Result Plot", 2, "false", "fastlmm-plot.html");

GetOptions( "file=s" => \$file,
			"title=s" => \$graph_title,
			"position=i" => \$position,
			"log=s" => \$log,
			"output=s" => \$output);
			
my %pvals;
my %names;
my @chromosomes;
my %maxval;
my $positionField = $position;

open (INFILE, $file) or die;
open (OUTFILE, ">$output") or die;

while (my $line = <INFILE>) {
	
	unless ($line =~ /^SNP/) {
		chomp($line);
		my @fields = split(/\t/, $line);
		$pvals{ $fields[kChromosome] }->{ $fields[$positionField] }->{'pvalue'} = $fields[kPvalue];
		$pvals{ $fields[kChromosome] }->{ $fields[$positionField] }->{'marker'} = $fields[kMarkerName];	
		
		if ( $fields[$positionField] > $maxval{ $fields[kChromosome] } ) {
			$maxval{ $fields[kChromosome] } = $fields[$positionField]
		}

	}
}

@chromosomes = sort {$a <=> $b} keys %pvals;

# Header
print OUTFILE "<html>
<title>$graph_title</title>
<head>
<script type=\"text/javascript\"
  src=\"https://foundation.iplantcollaborative.org/io-v1/io/download/vaughn/public/dygraph-combined.js\"></script>
</head>
<body><h1>$graph_title</h1>\n";

# Create graphs
for my $chrom (@chromosomes) {
	# Create div and data object
	print OUTFILE "<div id=\"graphdiv", $chrom, "\" style=\"width:768px; height:300px;\"></div>\n"
}

print OUTFILE "<script type=\"text/javascript\">\n";

for my $chrom (@chromosomes) {

print OUTFILE "	g$chrom = new Dygraph(

    // containing div
    document.getElementById(\"graphdiv", $chrom, "\"), \n";


my $count_positions = keys %{ $pvals{ $chrom } };
my $count = 0;
print OUTFILE "[\n";
foreach my $p (sort {$a <=> $b} keys %{ $pvals{ $chrom } } ) {
	
	$count++;
	print OUTFILE "[", $p, ",", $pvals{ $chrom }->{$p}->{'pvalue'}, ",\"" ,$pvals{ $chrom }->{$p}->{'marker'}, "\"]";
	
	if ($count < $count_positions) {
		print OUTFILE ",\n"
	} else {
		print OUTFILE "\n"
	}
}

print OUTFILE "],\n{ labels: [ \"Genetic Distance\", \"P-value\", \"Marker\"], valueRange: [1e-10,1], logscale : $log, title:'Chromsome $chrom', showRangeSelector: true, labelsDivStyles: { 'textAlign': 'right' }});\n";

}

print OUTFILE "</script>
</body>
</html>
\n";

