use warnings;
use strict;
use ExtUtils::MakeMaker;

my $env_inc   = 'include.sh';
my $mod_start = 'lib/Env/Sourced.pm-orig';
my $mod_final = 'lib/Env/Sourced.pm';

#--> Create a temporary file to source
open(FILE,">$env_inc")
  or die("Unable to create file ($env_inc): $!");
close FILE;

#--> Try to determine the source program without having to bother the user
my $src_prog = '';
for ('source', '.') {
  `$_ $env_inc;`;
  if($? == 0) {
    $src_prog = $_;
    last;
  }
}

#--> Prompt for a source program or blank to quit
while($src_prog eq '') {
  print "Unable to determine your shells source program, typically 'source' or '.'\n";
  $src_prog = prompt("What is your shells source program? (blank to quit)");

  exit unless($src_prog =~ /\S/);

  `$src_prog $env_inc;`;
  if($? != 0) {
    print "That didn't seem to be correct\n";
    $src_prog = '';
  }
}

unlink $env_inc;

print "It looks like your source program is ($src_prog)\n";

#--> Enter the source program into the module
open(FILE, "<$mod_start")
  or die("Unable to open file ($mod_start) for reading: $!") ;
my @file = <FILE>;
close (FILE);

open(FILE, ">$mod_final")
  or die("Unable to open file ($mod_final) for writing: $!") ;
for (@file) {
  s/'##SOURCE_PROGRAM##'/'$src_prog'/ if(/'##SOURCE_PROGRAM##'/);
  print FILE;
}
close (FILE);

WriteMakefile(
  'NAME'         => 'Env::Sourced'
, 'VERSION_FROM' => 'lib/Env/Sourced.pm'
, 'ABSTRACT'     => 'Merges environments of shell scripts'
, 'AUTHOR'       => 'Josh McAdams <joshua.mcadams@gmail.com>'
);

