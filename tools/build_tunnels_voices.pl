# src/voices/07-tunnels.part ni quradi.
#
#   perl build_tunnels_voices.pl
#
# Toussaint sheʼrining bandlari oʻyinda beshta kayfiyat uchun soʻzma-soʻz takrorlanadi (161 yozuvdan 130 tasi aynan bir xil), shuning uchun tarjima qoʻlda emas, moslik jadvali orqali qoʻyiladi. Tarjimasi topilmagan qator qolsa, skript toʻxtaydi.

use utf8;
use strict;
use warnings;
use FindBin;
require "$FindBin::Bin/paths.pl";
our ($SRC, $GAME);

binmode(STDOUT, ':encoding(UTF-8)');

my %uz = (
    # Sheʼr
    "We whirl the world, the world we whirl..."               => "Dunyoni aylantiramiz, aylantiramiz dunyoni...",
    "The world we whirl..."                                   => "Aylantiramiz dunyoni...",
    "It all gets lost in a terrible twirl..."                 => "Bari dahshatli girdobda yoʻqolar...",
    "It all gets lost, lost in a terrible twirl..."           => "Bari yoʻqolar, dahshatli girdobda yoʻqolar...",
    "It all gets lost, lost in a blinding twirl..."           => "Bari yoʻqolar, koʻr qiladigan girdobda yoʻqolar...",
    "It all gets lost, lost in a bloody twirl..."             => "Bari yoʻqolar, qonli girdobda yoʻqolar...",
    "It all gets lost and still we twirl."                    => "Bari yoʻqolar, biz esa hamon aylanamiz.",
    "Can&apos;t see the sun for all the black smoke..."       => "Quyoshni koʻrmayman — qora tutun qalin...",
    "Can&apos;t see the dirt for all the dead folk..."        => "Yerni koʻrmayman — oʻliklar bosgan...",
    "Can&apos;t see the ocean, can&apos;t see the trees..."   => "Dengizni koʻrmayman, daraxtni koʻrmayman...",
    "So here I stay, down on my knees..."                     => "Shu bois tiz choʻkib shu yerda qolaman...",
    "Singing and singing..."                                  => "Kuylayman, kuylayman...",
    "A snarl in the dark..."                                  => "Zulmatdagi bir irillash...",
    "A sad day in the park..."                                => "Bogʻdagi bir gʻamgin kun...",
    "A stone reminder..."                                     => "Toshga oʻyilgan esdalik...",
    "A horse&apos;s dirty blinder..."                         => "Otning kir koʻzpanasi...",
    "A child&apos;s empty hand..."                            => "Bolaning boʻsh kafti...",
    "A friend&apos;s stained armband..."                      => "Doʻstning dogʻ boʻlgan qoʻlbogʻi...",
    "The news of the day still on the stand..."               => "Rastada hamon turgan kunlik xabar...",
    "What&apos;ll come next around the bend?"                 => "Burilishdan keyin nima chiqar?",
    "Maybe some kind end..."                                  => "Balki qandaydir bir tugash boʻlar...",
    "More likely another whistle..."                          => "Ehtimolrogʻi — yana bir hushtak...",
    "Magic! That turns men into gristle."                     => "Sehr! Odamni goʻshtga aylantirgan sehr.",
    "What can we do but sing and sing..."                     => "Kuylashdan boshqa nima qoʻlimizdan kelar...",

    # Tovush eshitganda
    "Huh?!"                                                   => "A?!",
    "What&apos;s that?"                                       => "Bu nima?",
    "Who&apos;s there?"                                       => "Kim u?",
    "I hear you!"                                             => "Seni eshityapman!",
    "My vision&apos;s gone but my ears are true... And I hear you..."
        => "Koʻzim koʻrmaydi, ammo qulogʻim aldamaydi... Seni eshityapman...",
    "I heeeeear you!"                                         => "Seni eshityaaaapman!",

    # Qidirayotganda
    "Hide and seek is over..."                                => "Bekinmachoq tugadi...",
    "Come out, come out wherever you are!"                    => "Chiq, chiq, qayerda boʻlsang ham!",
    "You can&apos;t escape, no no no no no, it&apos;s all around us..."
        => "Qocha olmaysan, yoʻq yoʻq yoʻq yoʻq yoʻq, u atrofimizni oʻrab olgan...",
    "Come here, let me show you what I have seen."            => "Bu yoqqa kel, nima koʻrganimni senga koʻrsatay.",
    "These are their tunnels. How dare you trespass here."    => "Bu tunnellar ularniki. Bu yerga bostirib kirishga qanday jurʼat etding.",
    "Vision&apos;s gone and gone&apos;s the vision. Vision&apos;s gone and gone&apos;s the vision..."
        => "Koʻrish ketdi, ketdi koʻrish. Koʻrish ketdi, ketdi koʻrish...",

    # Oʻyinchi ketayotganda
    "Come back! Come back! Please, come back!"                => "Qaytib kel! Qaytib kel! Iltimos, qaytib kel!",
    "Don&apos;t leave me!"                                    => "Meni tashlab ketma!",
    "Please! Please! Help me! Help me, please!"               => "Iltimos! Iltimos! Yordam ber! Yordam ber, iltimos!",
    "Don&apos;t leave me! Please don&apos;t leave me!"        => "Meni tashlab ketma! Iltimos, tashlab ketma!",
    "I&apos;m not finished with you! Come back here!"         => "Sen bilan ishim tugagani yoʻq! Qaytib kel!",
    "I&apos;ll find you! I promise! I&apos;ll find you!"      => "Seni topaman! Vaʼda beraman! Topaman!",
    "Come back here, you coward!"                             => "Qaytib kel, qoʻrqoq!",

    # Zarba yeganda
    "Curse you!"                                              => "Laʼnat senga!",
    "You think pain will stay my hand? No no no."             => "Ogʻriq qoʻlimni ushlab qoladi deb oʻyladingmi? Yoʻq, yoʻq, yoʻq.",
    "Blood and blood and blood. I&apos;ve given my share... Now your turn..."
        => "Qon, qon va yana qon. Men oʻz ulushimni berdim... Endi sening navbating...",
    "[Grunting]"                                              => "[Xirillaydi]",
    "[Coughing] You can&apos;t hide in the gas! [Wheezing]"   => "[Yoʻtaladi] Gaz ichida yashirina olmaysan! [Xirillaydi]",
    "[Coughing] I hear you...  [Wheezing] I hear you still!"  => "[Yoʻtaladi] Seni eshityapman... [Xirillaydi] Hamon eshityapman!",
    "It burns! AHHH!"                                         => "Kuydiryapti! AAAH!",
    "[Screaming]"                                             => "[Qichqiradi]",
    "[Coughing and gasping]"                                  => "[Yoʻtaladi va boʻgʻiladi]",
);

my $text = slurp("$GAME/maps/tunnels/tunnels.lang");
utf8::decode($text);
$text =~ s/\r\n/\n/g;

my ($cat) = $text =~ m{(<CATEGORY Name="Voices_tunnels">.*?</CATEGORY>)}s;
die "Voices_tunnels topilmadi\n" unless $cat;

my @missing;
$cat =~ s{<Entry Name="([^"]+)">(.*?)</Entry>}{
    my ($key, $val) = ($1, $2);
    (my $trim = $val) =~ s/^\s+|\s+$//g;
    if (exists $uz{$trim}) { $val = $uz{$trim} }
    else                   { push @missing, $trim }
    qq{<Entry Name="$key">$val</Entry>};
}ge;

if (@missing) {
    print "Tarjimasi yoʻq qatorlar:\n";
    my %seen;
    for (@missing) { print "  $_\n" unless $seen{$_}++ }
    exit 1;
}

$cat =~ s/^        /    /gm;
$cat =~ s/^    <CATEGORY/  <CATEGORY/m;
$cat =~ s{^    </CATEGORY>}{  </CATEGORY>}m;

my $out = "$SRC/voices/07-tunnels.part";
open my $fh, '>:encoding(UTF-8)', $out or die "$out: $!";
print $fh "$cat\n";
close $fh;

my $n = () = $cat =~ /<Entry/g;
print "07-tunnels.part: $n ta yozuv\n";
