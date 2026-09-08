# Umumiy yoʻllar va yordamchi funksiyalar. Har bir qurish/tekshirish skripti shu faylni "require" qiladi.

use strict;
use warnings;
use File::Basename;
use File::Spec;

our $TOOLS = dirname(File::Spec->rel2abs(__FILE__));
our $PROJ  = "$TOOLS/..";
our $MOD   = "$PROJ/mod/UzbekPatch";
our $SRC   = "$PROJ/src";

our $GAME = $ENV{BUNKER_DIR}
         || "D:/Games/Steam/steamapps/common/Amnesia The Bunker";
$GAME =~ tr{\\}{/};
$GAME =~ s{/+$}{};

die "Oʻyin papkasi topilmadi: $GAME\nBUNKER_DIR oʻzgaruvchisini toʻgʻrilang.\n"
    unless -d "$GAME/config";

sub slurp { local $/; open my $f, '<:raw', $_[0] or die "$_[0]: $!"; my $d = <$f>; close $f; return $d; }
sub spew  { open my $f, '>:raw', $_[0] or die "$_[0]: $!"; print $f $_[1]; close $f; }

# Kalitlar "Toifa/Kalit" koʻrinishida.
sub parse_lang {
    my ($text) = @_;
    my (%map, @order);
    my $cat = '';
    for my $line (split /\r?\n/, $text) {
        if ($line =~ /<CATEGORY\s+Name="([^"]+)"/) { $cat = $1 }
        if ($line =~ /<Entry\s+Name="([^"]+)">(.*?)<\/Entry>/) {
            my $key = "$cat/$1";
            push @order, $key unless exists $map{$key};
            $map{$key} = $2;
        }
    }
    return (\%map, \@order);
}

1;
