# Tarjimani oʻyinning hozirgi inglizcha matni bilan solishtiradi.
#
#   perl check_lang.pl          — qisqa hisobot
#   perl check_lang.pl -v       — har bir kalitni sanaydi
#
# Uchta xato turini topadi:
#   YETISHMAYDI  — oʻyinda bor, tarjimada yoʻq (oʻyin yangilangandan keyin chiqadi)
#   ORTIQCHA     — tarjimada bor, oʻyinda yoʻq (kalit nomi xato yozilgan)
#   TARJIMASIZ   — qiymati inglizchasi bilan bir xil

use strict;
use warnings;
use FindBin;
require "$FindBin::Bin/paths.pl";
our ($MOD, $GAME);

my $verbose = grep { $_ eq '-v' } @ARGV;
my $errors  = 0;

# Atayin tarjima qilinmaydigan kalitlar: klaviaturada yozilgan tugma nomlari, tillarning oʻz nomlari, texnik qisqartmalar.
my $keep_english = qr{^(ButtonNames/|Languages/|Menu/(FXAA|SSAO|Anis\d+x|Bilinear|Trilinear|RemotePlay|Ok)$|Global/OK$|LoadGame/Ok$|Launcher/(SSAORes|Parallax)$)};

sub compare {
    my ($eng_file, $uz_file) = @_;
    (my $label = $uz_file) =~ s{.*/mod/UzbekPatch/}{};

    unless (-e $uz_file) { print "$label: tarjima fayli yoʻq\n"; $errors++; return }

    my ($eng) = parse_lang(slurp($eng_file));
    my ($uz)  = parse_lang(slurp($uz_file));

    my @missing = grep { !exists $uz->{$_}  } sort keys %$eng;
    my @extra   = grep { !exists $eng->{$_} } sort keys %$uz;
    my @same    = grep { exists $eng->{$_}
                         && $eng->{$_} eq $uz->{$_}
                         && $eng->{$_} =~ /[A-Za-z]{3}/
                         && $_ !~ $keep_english } sort keys %$uz;

    printf "%-40s %4d kalit   yetishmaydi: %-3d ortiqcha: %-3d tarjimasiz: %d\n",
           $label, scalar(keys %$eng), scalar(@missing), scalar(@extra), scalar(@same);

    $errors += @missing + @extra;

    if ($verbose) {
        print "    YETISHMAYDI: $_\n" for @missing;
        print "    ORTIQCHA:    $_\n" for @extra;
        print "    TARJIMASIZ:  $_ = $uz->{$_}\n" for @same;
    }
}

# Solishtirish inglizcha matn bilan boradi, oʻz tilidagi asli bilan emas: boshqa tillarning fayllarida oʻyinning eski versiyalaridan qolgan ~50-400 ta ishlatilmaydigan kalit bor, inglizchasi esa hozirgi holatni koʻrsatadi.
for my $f (sort glob(qq{"$MOD/config/base_*.lang"})) {
    compare("$GAME/config/base_english.lang", $f);
}
for my $f (sort glob(qq{"$MOD/config/lang_main/*.lang"})) {
    compare("$GAME/config/lang_main/english.lang", $f);
}

for my $eng (glob(qq{"$GAME/maps/*.lang"}), glob(qq{"$GAME/maps/*/*.lang"})) {
    (my $rel = $eng) =~ s{^\Q$GAME\E/}{};
    compare($eng, "$MOD/$rel");
}

print $errors ? "\n$errors ta muammo topildi.\n" : "\nHammasi joyida.\n";
exit($errors ? 1 : 0);
