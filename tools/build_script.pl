# Oʻyin skriptlariga tuzatish kiritib, modga koʻchiradi.
#
#   perl build_script.pl
#
# Fayllar har safar oʻyinnikidan qayta oʻqiladi — oʻyin yangilangandan keyin qaytadan qurish yetarli. Frictional shu joylarni oʻzgartirsa, skript toʻxtaydi va topilmagan parchani koʻrsatadi. Tuzatishlarning mazmuni README dagi «Mod qanday ishlaydi» boʻlimida.

use strict;
use warnings;
use FindBin;
use File::Path qw(make_path remove_tree);
require "$FindBin::Bin/paths.pl";
our ($MOD, $GAME);

# Tuzatishlar Update va GetFont ichida boʻlishi shart, LoadUserConfig da emas: AddOn ulanganda dvigatel skriptlarni qayta kompilyatsiya qiladi (hpl.log: "RECOMPILE SCRIPT"), lekin modul obyekti saqlanib qoladi va LoadUserConfig boshqa chaqirilmaydi.
my @files = (
    ['script/custom/modules/FontHandler.hps', [
        [
            qq~\tvoid Update(float afTimeStep)\n\t{\n\t\t//cLux_AddDebugMessage(msLanguage);\n\t}\n~,
            qq~\tvoid Update(float afTimeStep)\n\t{\n~
          . qq~\t\t// Uzbek translation mod: the add-on only replaces the english language slot, so move the game over to it once, on the first frame after the add-on was mounted.\n~
          . qq~\t\tif (mbUzbekLanguageForced) return;\n~
          . qq~\t\tmbUzbekLanguageForced = true;\n~
          . qq~\t\t\n~
          . qq~\t\tcConfigFile\@ pConfig = cLux_GetUserConfig();\n~
          . qq~\t\tif (pConfig.GetString("Main", "StartLanguage", "english.lang") == "english.lang") return;\n~
          . qq~\t\t\n~
          . qq~\t\tpConfig.SetString("Main", "StartLanguage", "english.lang");\n~
          . qq~\t\tpConfig.Save();\n~
          . qq~\t\tcLux_ApplyUserConfig();\n~
          . qq~\t}\n~,
        ],
        [
            qq~\ttString GetFont(eFontType aFontType, int alSize)\n\t{\n\t\ttString sFont = "";\n~,
            qq~\ttString GetFont(eFontType aFontType, int alSize)\n\t{\n~
          . qq~\t\t// Uzbek translation mod: always use the game's original fonts. The module object survives the script recompile that mounting an add-on triggers, so LoadUserConfig() never runs again and msLanguage can still hold the language the player picked.\n~
          . qq~\t\tmsLanguage = "english";\n\t\t\n\t\ttString sFont = "";\n~,
        ],
        [
            qq~\t[nosave] tString msLanguage;\n~,
            qq~\t[nosave] tString msLanguage;\n\t[nosave] bool mbUzbekLanguageForced;\n~,
        ],
    ]],

    # abActive=false tarmogʻidan foydalanib boʻlmaydi: u erta qaytadi va qatorning qiymatini umuman chizmaydi, natijada «Oʻzbekcha» yozuvi yoʻqoladi.
    ['script/custom/helpers/helper_imgui_options.hps', [
        [
            qq~\tif (abActive==false) afAlpha*=0.5f;\n\tbool bSelected = asSelected == asName;\n~,
            qq~\t// Uzbek translation mod: the add-on ships the Uzbek text only, so the language row is drawn greyed out and cannot be changed.\n~
          . qq~\tbool bUzbekLockedLanguage = asCategory == "Languages";\n~
          . qq~\tif (bUzbekLockedLanguage)\n\t{\n~
          . qq~\t\tafAlpha *= 0.5f;\n~
          . qq~\t\talUIActionHorizontal = 0;\n~
          . qq~\t\tabSkipAccept = true;\n~
          . qq~\t}\n\t\n~
          . qq~\tif (abActive==false) afAlpha*=0.5f;\n\tbool bSelected = asSelected == asName;\n~,
        ],
        [
            qq~\t/////////////\n\t// Wrap data\n\tif(lDirection != 0)\n~,
            qq~\tif (bUzbekLockedLanguage) lDirection = 0;\n\t\n~
          . qq~\t/////////////\n\t// Wrap data\n\tif(lDirection != 0)\n~,
        ],
    ]],
);

remove_tree("$MOD/script") if -d "$MOD/script";

for my $entry (@files) {
    my ($rel, $patches) = @$entry;
    my $text = slurp("$GAME/$rel");

    # Oʻyin skriptlari CRLF bilan yozilgan; solishtirish LF ustida boradi.
    my $crlf = $text =~ s/\r\n/\n/g;

    for my $p (@$patches) {
        my ($from, $to) = @$p;
        my $n = ($text =~ s/\Q$from\E/$to/g);
        die "$rel oʻzgargan, bu parcha bir marta topilmadi ($n ta):\n$from" unless $n == 1;
    }

    $text =~ s/\n/\r\n/g if $crlf;

    (my $dir = "$MOD/$rel") =~ s{/[^/]+$}{};
    make_path($dir);
    spew("$MOD/$rel", $text);
    print "$rel patch qilindi\n";
}
