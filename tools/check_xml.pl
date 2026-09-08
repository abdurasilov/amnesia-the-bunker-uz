# Qurilgan .lang fayllarining XML tuzilishini tekshiradi.
#
#   perl check_xml.pl
#
# HPL3 tahlilchisi xatolikda tilni jimgina tashlab ketadi — ekranda hech narsa chiqmaydi, shuning uchun bu tekshiruv deployʼdan oldin majburiy.

use strict;
use warnings;
use FindBin;
require "$FindBin::Bin/paths.pl";
our ($MOD);

my $errors = 0;

for my $file (glob(qq{"$MOD/config/*.lang"}), glob(qq{"$MOD/config/lang_main/*.lang"}),
              glob(qq{"$MOD/maps/*.lang"}),   glob(qq{"$MOD/maps/*/*.lang"})) {
    my $text = slurp($file);
    utf8::decode($text);
    my $short = $file; $short =~ s{.*/mod/}{};

    my @bad;
    my $open  = () = $text =~ /<LANGUAGE>/g;
    my $close = () = $text =~ m{</LANGUAGE>}g;
    push @bad, "<LANGUAGE> tegi $open ta, </LANGUAGE> $close ta" unless $open == 1 && $close == 1;

    my $cat_open  = () = $text =~ /<CATEGORY[^>]*[^\/]>/g;
    my $cat_close = () = $text =~ m{</CATEGORY>}g;
    push @bad, "CATEGORY ochilishi $cat_open, yopilishi $cat_close" unless $cat_open == $cat_close;

    my $e_open  = () = $text =~ /<Entry\b/g;
    my $e_close = () = $text =~ m{</Entry>}g;
    push @bad, "Entry ochilishi $e_open, yopilishi $e_close" unless $e_open == $e_close;

    # &amp; &lt; &gt; &quot; &apos; va &#NN; dan boshqasi qochirilmagan hisoblanadi.
    my $line = 0;
    for my $l (split /\n/, $text) {
        $line++;
        push @bad, "$line-qator: qochirilmagan &"
            if $l =~ /&(?!amp;|lt;|gt;|quot;|apos;|#\d+;)/;
    }

    # Bir toifa ichida takrorlangan kalit — keyingisi oldingisini yeb qoʻyadi.
    my (%seen, $cat);
    $line = 0;
    for my $l (split /\n/, $text) {
        $line++;
        $cat = $1 if $l =~ /<CATEGORY\s+Name="([^"]+)"/;
        next unless $l =~ /<Entry\s+Name="([^"]+)"/;
        my $key = ($cat // '') . "/$1";
        push @bad, "$line-qator: takrorlangan kalit $key" if $seen{$key}++;
    }

    if (@bad) {
        print "$short\n";
        print "  $_\n" for @bad;
        $errors += @bad;
    } else {
        printf "%-32s joyida (%d ta yozuv)\n", $short, $e_open;
    }
}

print $errors ? "\n$errors ta XML muammosi.\n" : "";
exit($errors ? 1 : 0);
