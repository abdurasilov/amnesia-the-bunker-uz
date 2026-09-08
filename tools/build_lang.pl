# src/ dagi boʻlaklardan modning .lang fayllarini quradi.
#
#   perl build_lang.pl
#
# Fayl nomlari oʻyinnikidek boʻlishi shart: dvigatel til faylini nomi boʻyicha qidiradi va resurs tizimi faqat mavjud nomni ustidan yozishga ruxsat beradi, yaʼni base_uzbek.lang ishlamaydi.

use strict;
use warnings;
use FindBin;
use File::Path qw(make_path remove_tree);
require "$FindBin::Bin/paths.pl";
our ($MOD, $SRC);

# Ikkita cheklovni chetlab oʻtadi. Birinchisi — atlaslarda ʻ (U+02BB) va ʼ (U+02BC) yoʻq, shakli aynan bir xil ‘ (U+2018) va ’ (U+2019) esa hammasida bor. Ikkinchisi — .lang tahlilchisi 3 baytli UTF-8 ni notoʻgʻri oʻlchaydi va keyingi belgini ham yutib yuboradi ("Oʻyin" -> "Oin"), shuning uchun ular [uNNNN] ga oʻtkaziladi; oʻyinning oʻzi ham base_russian.lang da shu usuldan foydalanadi. Batafsil: README, «Tutuq belgilari».
sub to_game_glyphs {
    my ($text) = @_;
    utf8::decode($text);

    $text =~ s/\x{02BB}/\x{2018}/g;
    $text =~ s/\x{02BC}/\x{2019}/g;

    $text =~ s/([^\x00-\x{07FF}])/sprintf("[u%d]", ord($1))/ge;

    utf8::encode($text);
    return $text;
}

sub write_lang {
    my ($out, $body) = @_;
    $body = to_game_glyphs($body);
    $body =~ s/\r\n/\n/g;
    $body =~ s/\n*$/\n/;

    (my $dir = $out) =~ s{/[^/]+$}{};
    make_path($dir);
    spew($out, "<LANGUAGE>\n$body</LANGUAGE>\n");

    my $n = () = $body =~ /<Entry/g;
    (my $short = $out) =~ s{.*/mod/UzbekPatch/}{};
    printf "%-40s %4d ta yozuv\n", $short, $n;
}

sub join_parts {
    my (@parts) = @_;
    my $body = '';
    $body .= slurp($_) for @parts;
    return $body;
}

my @base = sort glob(qq{"$SRC/base/*.part"});
my @main = sort glob(qq{"$SRC/main/*.part"});
die "src/base yoki src/main boʻsh\n" unless @base && @main;

my $base_body = join_parts(@base);
my $main_body = join_parts(@main);

remove_tree("$MOD/config") if -d "$MOD/config";
remove_tree("$MOD/maps")   if -d "$MOD/maps";

write_lang("$MOD/config/base_english.lang",      $base_body);
write_lang("$MOD/config/lang_main/english.lang", $main_body);

# Manzil toifa nomidan olinadi: Voices_global -> maps/global_voice.lang, qolganlari -> maps/<sath>/<sath>.lang.
for my $part (sort glob(qq{"$SRC/voices/*.part"})) {
    my $body = slurp($part);
    my ($cat) = $body =~ /<CATEGORY\s+Name="Voices_([^"]+)"/;
    die "$part: Voices_* toifasi topilmadi\n" unless $cat;

    my $out = $cat eq 'global' ? "$MOD/maps/global_voice.lang"
                               : "$MOD/maps/$cat/$cat.lang";
    write_lang($out, $body);
}
