# ©Santiago Sanchez-Ramirez, University of Toronto

use Time::HiRes qw(gettimeofday tv_interval);
my $indir;
my $pattern;
my $outdir;
my $addlab=0;
my @files=();
my @genlist=();
my %spp=();

if (grep { /^-he{0,1}l{0,1}p{0,1}$/ } @ARGV){
	die "
Try:
perl OrderFromSamtools.pl -indir /path/to/fastq/files
                          -pattern fastq     [ or anything else present in all files ]
                          -outdir alignments [ or anything else, your outfiles will be stored here ]
                          -seqlist list.txt  [ a file with a list of sequence/gene names ]
                          -addlab            [ optional, you can add some label tu your sequences by editing \%spp ]\n\n";
}

if (my ($indInDir) = grep { $ARGV[$_] =~ /^-indir$/ } 0 .. $#ARGV){
	$indir = $ARGV[$indInDir+1];
} else {
	die "-indir flag not found.\n";
}

if (my ($indPat) = grep { $ARGV[$_] =~ /^-pattern$/ } 0 .. $#ARGV){
	$pattern = $ARGV[$indPat+1];
	@files = `cd $indir && ls | grep "$pattern"`;
	foreach(@files){ chomp($_) }
} else {
	die "-pattern flag not found.\n";
}

if (my ($indOutDir) = grep { $ARGV[$_] =~ /^-outdir$/ } 0 .. $#ARGV){
	$outdir = $ARGV[$indOutDir+1];
} else {
	die "-outdir flag not found.\n";
}

if (my ($indGenL) = grep { $ARGV[$_] =~ /^-seqlist$/ } 0 .. $#ARGV){
	$gene_list = $ARGV[$indGenL+1];
	open(LIST, "<", $gene_list) or die "$gene_list not found\n";
	while(<LIST>){
		chomp($_);
		push @genlist, $_;
	}
	close LIST;
} else {
	die "-seqlist flag not found.\n";
}

if (grep { /^-addlab$/ } @ARGV){
	$addlab = 1;
	print "Adding lables according to \%spp\n";
	%spp = ( # Modify the delimiter in line 177, the default is '_', and is translating numbers to labels
1=>'Amanita_jacksonii',
2=>'Amanita_jacksonii',
3=>'Amanita_jacksonii',
4=>'Amanita_jacksonii',
5=>'Amanita_jacksonii',
6=>'Amanita_jacksonii',
7=>'Amanita_jacksonii',
8=>'Amanita_jacksonii',
9=>'Amanita_jacksonii',
10=>'Amanita_jacksonii',
11=>'Amanita_jacksonii',
12=>'Amanita_jacksonii',
13=>'Amanita_jacksonii',
14=>'Amanita_jacksonii',
15=>'Amanita_jacksonii',
16=>'Amanita_jacksonii',
17=>'Amanita_sp_F11',
18=>'Amanita_sp_F11',
19=>'Amanita_sp_F11',
20=>'Amanita_sp_jack1',
21=>'Amanita_sp_jack1',
22=>'Amanita_sp_jack1',
23=>'Amanita_sp_jack2',
24=>'Amanita_sp_jack2',
25=>'Amanita_sp_jack2',
26=>'Amanita_sp_jack2',
27=>'Amanita_sp_jack2',
28=>'Amanita_sp_jack2',
29=>'Amanita_sp_jack2',
30=>'Amanita_sp_jack2',
31=>'Amanita_sp_jack2',
32=>'Amanita_sp_jack2',
33=>'Amanita_sp_jack3',
34=>'Amanita_sp_jack3',
35=>'Amanita_sp_jack3',
36=>'Amanita_sp_jack3',
37=>'Amanita_sp_jack3',
38=>'Amanita_sp_T31',
39=>'Amanita_sp_T31',
40=>'Amanita_sp_T31',
41=>'Amanita_sp_T31',
42=>'Amanita_sp_jack5',
43=>'Amanita_sp_jack5',
44=>'Amanita_sp_jack5',
45=>'Amanita_sp_jack5',
46=>'Amanita_sp_jack5',
47=>'Amanita_sp_jack5',
48=>'Amanita_sp_jack5',
49=>'Amanita_sp_jack6',
50=>'Amanita_sp_jack6',
51=>'Amanita_sp_jack6',
52=>'Amanita_sp_jack6',
53=>'Amanita_sp_jack6',
54=>'Amanita_sp_jack6',
55=>'Amanita_sp_jack6',
56=>'Amanita_sp_T31',
57=>'Amanita_jacksonii',
58=>'Amanita_jacksonii',
59=>'Amanita_jacksonii',
60=>'Amanita_jacksonii',
61=>'Amanita_jacksonii',
62=>'Amanita_jacksonii',
63=>'Amanita_jacksonii',
64=>'Amanita_jacksonii',
65=>'Amanita_sp_jack3',
66=>'Amanita_sp_jack3',
67=>'Amanita_sp_jack3',
68=>'Amanita_sp_jack3',
69=>'Amanita_sp_jack6',
70=>'Amanita_sp_jack6',
71=>'Amanita_sp_jack6',
72=>'Amanita_sp_F11',
73=>'Amanita_sp_jack1'
);

}

my %fastqlab = ();
map { $fastqlab{'@'.$_."\n"} = "" } @genlist;

`mkdir $outdir`;

my @data=();
my @headers=();

print "Storring DATA ...\nTime elapsed:\n";
my $t0 = [gettimeofday];

for my $i (0 .. $#files){
	my $samp = $files[$i];
	open(FILE, "<", "$indir/$samp") or die "$indir/$samp nor found\n";
	my @rawfq = <FILE>;
	close FILE;
	my @indPlus = grep { $rawfq[$_] =~ /^\+$/ } 0 .. $#rawfq;
	my @indHd = grep { exists($fastqlab{$rawfq[$_]}) } 0 .. $#rawfq;
	my %array=();
	if (scalar(@indHd) != scalar(@indPlus)){
		die "Problem reading $files[$i].. Check the fastq file and the -seqlist file, names must match in both\n";
	} else {
		for my $k (0 .. $#indHd){
			@rawfq[$indHd[$k]] =~ s/\n//;
			@rawfq[$indHd[$k]] =~ s/\@/>/;
			$end = getcloser(\$indHd[$k],\@indPlus);
			$seq = join('',@rawfq[$indHd[$k]+1 .. $end-1]);
			$seq =~ s/[\n\s]//g;
			$seq =~ tr/a-z/A-Z/;
			$array{@rawfq[$indHd[$k]]} = $seq;
		}
	}
	push @data, { %array };
	my @hd=();
	my $head;
	if ($samp =~ m/\.fastq/i){
		$head = substr($samp,0,index($samp,${^MATCH}));
	} elsif ($samp =~ m/\.fq/i){
		$head = substr($samp,0,index($samp,${^MATCH}));
	} else {
		$head = $samp;
	}
	if ($addlab == 1){
		@hd = split /_/, $head;
		$head = $spp{$hd[0]} . "__" . join('_', @hd);
	}
	push @headers, ">$head";	
	my $t1 = [gettimeofday];
	my $ti = tv_interval $t0, $t1;	
	$time = sprintf("%.3f", $ti);
	print "$time seconds\n";
}

print "Printing temporary files ... \n";

for my $genName (@genlist){
	open(OUT, ">>", "$outdir/temp$genName");
	print "Printing for gene $genName\n";
	for my $i (0..$#data){
		if (exists $data[$i]{">$genName"}){
			print OUT $headers[$i] . "\n" . $data[$i]{">$genName"} . "\n";
		} else {
			next;
		}
	}
	close OUT;
}

print "Reading TEMP files ...\n";

print "Printing FASTA alignment files ... \n";

for my $genName (@genlist){
	my %final=();
	my $h;
	open(TMP, "<", "$outdir/temp$genName");
	while(<TMP>){
		chomp($_);
		if (/^>/){
			$h = $_;
		} else {
			$final{$h} = $_;
		}
	}
	close TMP;
	open(FASTA, ">", "$outdir/$genName.fasta");
	my $m = max(values %final);
	print "Printing FASTA alignment for $genName ... ";
	
	foreach(sort {$a cmp $b} keys %final){
		print FASTA $_ . "\n";
		if (length($final{$_}) < $m){
			my $diff = $m-length($final{$_});
			my $add = 'N' x $diff;
			print FASTA $final{$_} . $add . "\n";
		} else {
			print FASTA $final{$_} . "\n";
		}
	}
	close FASTA;
	print "done\n";
}
	
print "Deleting temporary files ... \n";
`rm $outdir/temp*`;

sub max {
	my @res=();
	foreach(@_){
		push @res, length($_);
	}
	my @res2 = sort {$b <=> $a} @res; 
	return(@res2[0]);
}

sub getcloser {
	my ($val,$list) = @_;
	my %diff=();
	foreach(@$list){
		next if ($_ < $$val);
		$diff{$_-$$val} = $_;
	}
	my ($min) = sort {$a <=> $b} keys %diff;
	return($diff{$min});
}
