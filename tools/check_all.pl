# Barcha tekshiruvlarni ketma-ket yuritadi.
#
#   perl check_all.pl

use strict;
use warnings;
use FindBin;
require "$FindBin::Bin/paths.pl";
our ($TOOLS, $MOD);

my $failed = 0;

for my $check (qw(check_xml.pl check_lang.pl check_chars.pl)) {
    print "== $check ==\n";
    $failed++ if system($^X, "$TOOLS/$check") != 0;
    print "\n";
}

print $failed ? "$failed ta tekshiruv xato berdi.\n" : "Hammasi joyida.\n";
exit($failed ? 1 : 0);
