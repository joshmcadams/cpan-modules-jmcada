use strict;
use Carp;
use Test::Simple tests => 2;

BEGIN {
    if( $ENV{PERL_CORE} ) {
        chdir 't' if -d 't';
        @INC = ('../lib', 'lib');
    }
    else {
        unshift @INC, 't/lib';
    }
}

$| = 1;

#--> Variables holding the name of the temp file to create for sourcing, 
#--> the environment variable to create and the value to give it.
my $env_inc = 'include.sh';
my $env_var = 'ENV_SOURCED';
my $env_val = 'ABC';

#--> Clean up the environment, just in case the variable already exists
delete $ENV{$env_var} if(defined $ENV{$env_var});

#--> Create a temporary file to source
open(FILE,">$env_inc") 
	or die("Unable to create file ($env_inc): $!");
print FILE "$env_var=$env_val\nexport $env_var\n";
close FILE;

#--> Load the module
eval { use Env::Sourced; return 1; };
ok($@ eq '', 'Include module');
croak if($@);

#--> See if our environment variable was included correctly
ok(
  eval("use Env::Sourced qw($env_inc); return \$ENV{$env_var};") eq $env_val
, 'Source Variable');

#--> Clean up
unlink $env_inc;

