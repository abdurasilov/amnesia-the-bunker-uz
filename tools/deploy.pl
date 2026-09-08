# Modni loyiha papkasidan oʻyinning mods/ papkasiga koʻchiradi.
#
#   perl deploy.pl          — avval qurib, tekshiradi; xato boʻlsa koʻchirmaydi
#   perl deploy.pl --force  — tekshiruvni oʻtkazib yuboradi
#
# Manba — shu loyiha; oʻyin papkasidagi nusxa har safar qaytadan yoziladi, u yerda tahrir qilmang.

use strict;
use warnings;
use FindBin;
use File::Path qw(make_path remove_tree);
use File::Find;
use File::Basename;
use File::Copy;
require "$FindBin::Bin/paths.pl";
our ($TOOLS, $MOD, $GAME);

my $force = grep { $_ eq '--force' } @ARGV;

unless ($force) {
    print "Qurilmoqda...\n";
    exit 1 if system($^X, "$TOOLS/build_lang.pl") != 0;
    exit 1 if system($^X, "$TOOLS/build_script.pl") != 0;
    print "\nTekshiruv yuritilmoqda...\n";
    if (system($^X, "$TOOLS/check_all.pl") != 0) {
        print "\nTekshiruvda xato topildi — koʻchirilmadi.\n";
        print "Baribir koʻchirish uchun: perl deploy.pl --force\n";
        exit 1;
    }
    print "\n";
}

my $dest = "$GAME/mods/UzbekPatch";

# entry.swd Workshop identifikatorini saqlaydi — uni oʻchirib yubormaslik kerak.
my $swd;
if (-e "$dest/entry.swd") {
    local $/;
    open my $f, '<:raw', "$dest/entry.swd" or die $!;
    $swd = <$f>;
    close $f;
}

remove_tree($dest) if -d $dest;
make_path($dest);

my $count = 0;
find({
    no_chdir => 1,
    wanted   => sub {
        return if -d $_;
        my $rel = $_;
        $rel =~ s{^\Q$MOD\E/?}{};
        my $target = "$dest/$rel";
        make_path(dirname($target));
        copy($_, $target) or die "koʻchirib boʻlmadi $rel: $!";
        $count++;
    },
}, $MOD);

if (defined $swd) {
    open my $f, '>:raw', "$dest/entry.swd" or die $!;
    print $f $swd;
    close $f;
    print "entry.swd saqlab qolindi (Workshop ID).\n";
}

print "$count ta fayl koʻchirildi:\n  $dest\n";
print "\nEndi oʻyinni oching -> Custom Stories -> Add Ons -> «Oʻzbek tili» ni belgilang -> Launch. Interfeys darrov oʻzbekcha chiqadi.\n";
