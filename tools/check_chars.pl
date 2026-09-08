# Tarjima matnidagi belgilarni oʻyin shriftlari bilan solishtiradi.
#
#   perl check_chars.pl
#
# Toʻrt xil muammoni topadi:
#   KIRILL        — lotin matniga tasodifan kirib qolgan kirill harfi (и, а, р ...); oʻzbekcha shriftlarda umuman chizilmaydi
#   IKKI MARTA    — ikki marta kodlangan UTF-8 («Ê»» kabi)
#   TUTUQ         — tutuq belgisi oʻrniga oddiy ASCII apostrof
#   SHRIFTDA YOʻQ — belgi work/special_elite shriftlarida yoʻq

use utf8;
use strict;
use warnings;
use FindBin;
require "$FindBin::Bin/paths.pl";
our ($SRC, $GAME);

binmode(STDOUT, ':encoding(UTF-8)');

# FontHandler.hps oʻzbek tiliga default tarmoqni beradi: menyu — special_elite, matn — work.
my %glyph;
for my $font (qw(work_56 special_elite_56)) {
    my $fnt = "$GAME/fonts/$font.fnt";
    next unless -e $fnt;
    my $data = slurp($fnt);
    $glyph{$font}{$1} = 1 while $data =~ /char id="(\d+)"/g;
}

my $problems = 0;

for my $file (glob(qq{"$SRC/*/*.part"})) {
    my $text = slurp($file);
    utf8::decode($text);
    my $short = $file; $short =~ s{.*/src/}{};

    my (%cyr, %noglyph, @apos, @moji);
    my $line = 0;
    for my $l (split /\n/, $text) {
        $line++;
        # $Input{...} va $GLayout{...} oʻrinbosarlari matn emas.
        (my $body = $l) =~ s/\$\w+\{[^}]*\}//g;
        next unless $body =~ /<Entry[^>]*>(.*)<\/Entry>/ or $body =~ /^\s*[^<]/;

        $cyr{$line} = $l          if $body =~ /[\x{0400}-\x{04FF}]/;
        push @apos, $line         if $body =~ /\w'\w/;

        # Perl skripti matnni :encoding(UTF-8) qatlamiga allaqachon kodlangan holda yozsa, ʻ (CA BB) «Ê»» boʻlib qoladi va koʻzga tashlanmaydi, chunki Ê va » shriftlarda bor.
        push @moji, $line         if $body =~ /[\x{00C2}\x{00C3}\x{00CA}][\x{0080}-\x{00BF}]/;

        for my $ch (split //, $body) {
            my $cp = ord($ch);
            next if $cp < 128;
            next if $cp == 0x2019 || $cp == 0x2014 || $cp == 0x2026;

            # Qurish paytida tutuq belgilari atlasda mavjud kodlarga oʻtkaziladi (build_lang.pl -> to_game_glyphs), shuning uchun shrift qamrovi oʻsha kodlar boʻyicha tekshiriladi.
            $cp = 0x2018 if $cp == 0x02BB;
            $cp = 0x2019 if $cp == 0x02BC;
            next if $cp == 0x2019;
            for my $font (keys %glyph) {
                $noglyph{$cp}{$font} = 1 unless $glyph{$font}{$cp};
            }
        }
    }

    next unless %cyr || @apos || @moji || %noglyph;
    print "$short\n";
    for my $l (sort { $a <=> $b } keys %cyr) {
        my ($bad) = $cyr{$l} =~ /([\x{0400}-\x{04FF}]+)/;
        print "  $l: KIRILL «$bad»\n";
        $problems++;
    }
    for my $l (@moji) {
        print "  $l: IKKI MARTA KODLANGAN (Ê» kabi)\n";
        $problems++;
    }
    for my $l (@apos) {
        print "  $l: TUTUQ — ASCII apostrof\n";
        $problems++;
    }
    for my $cp (sort { $a <=> $b } keys %noglyph) {
        my @fonts = sort keys %{$noglyph{$cp}};
        printf "  U+%04X '%s' SHRIFTDA YOʻQ: %s\n", $cp, chr($cp), join(', ', @fonts);
        $problems++;
    }
}

print $problems ? "\n$problems ta belgi muammosi.\n" : "Belgilar toza.\n";
exit($problems ? 1 : 0);
