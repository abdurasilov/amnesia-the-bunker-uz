# Amnesia: The Bunker — oʻzbek tili

Oʻyinni toʻliq oʻzbek tiliga tarjima qiladigan AddOn modining manbasi: menyu va sozlamalar, barcha qaydlar, xatlar va hujjatlar, ovozli sahnalarning subtitrlari — jami 1938 ta yozuv.

Steam Workshop: https://steamcommunity.com/sharedfiles/filedetails/?id=3797682713

## Oʻrnatish

Workshop sahifasida **Subscribe** ni bosing, soʻng oʻyinda **Custom Stories** -> yuqoridagi **Add Ons** boʻlimi -> «Oʻzbek tili» ni belgilang -> **Launch**. Menyudan til tanlash shart emas: mod yoqilgan holda ishga tushirilsa, interfeys darrov oʻzbekcha chiqadi.

## Papkalar

```
src/     tarjima manbasi — boʻlak (.part) fayllar, asosiy ish shu yerda
mod/     qurilgan mod; deploy shu papkani oʻyinning mods/ iga koʻchiradi
tools/   qurish va tekshirish skriptlari (Perl)
art/     yuklagich rasmining manbasi
```

`src/` uchta guruhga boʻlingan:

| Papka | Nima | Yozuv |
|---|---|---|
| `src/base/` | menyu, sozlamalar, tugma nomlari, statistika | 872 |
| `src/main/` | HUD, maslahatlar, inventar, xarita, 201 ta qayd | 638 |
| `src/voices/` | ovozli sahnalar subtitri | 428 |

## Qurish

Perl kerak, oʻyin ham oʻrnatilgan boʻlishi shart: skriptlar matn kalitlarini va patch qilinadigan `.hps` fayllarni oʻyin papkasidan oʻqiydi.

```bash
cd tools
perl build_lang.pl    # src/ dan mod/ ni quradi
perl check_all.pl     # XML, kalitlar, belgilar
perl deploy.pl        # qurish + tekshirish + oʻyinga koʻchirish
```

Oʻyin boshqa papkada boʻlsa, yoʻlni `BUNKER_DIR` orqali bering:

```bash
export BUNKER_DIR="E:/Steam/steamapps/common/Amnesia The Bunker"
```

Tarjimani `mod/` da emas, `src/*/*.part` da tahrirlang — `mod/` va oʻyin papkasidagi nusxa har qurishda qaytadan yoziladi.

## Mod qanday ishlaydi

Mod menyuga yangi til qoʻsha olmaydi. `MenuHandler.hps:12163` dagi `array<tString> mvLangFiles` da `[nosave]` yoʻq, shuning uchun roʻyxat modul holati bilan birga saqlanadi va eski profildan tiklanadi; `MenuHandler.hps:1092` dagi `if(mvLangFiles.size() == 0)` sharti esa hech qachon bajarilmaydi, yaʼni modning roʻyxatga qoʻshgani ishga tushmaydi.

Shuning uchun mod oʻyinning **inglizcha til slotini** oʻzbekchasi bilan almashtiradi:

```
config/base_english.lang        menyu va tizim matni
config/lang_main/english.lang   oʻyin ichidagi matn
maps/global_voice.lang          ovozli sahnalar
maps/<sath>/<sath>.lang    x6   ovozli sahnalar
```

Fayl nomlari oʻyinnikidek boʻlishi shart: dvigatel til faylini nomi boʻyicha qidiradi va resurs tizimi faqat mavjud nomni ustidan yozishga ruxsat beradi. Til roʻyxatida `english` yozuvi «Oʻzbekcha» deb nomlanadi.

Tili boshqa boʻlgan oʻyinchi uchun modning `FontHandler` patchi birinchi kadrda `StartLanguage` ni `"english.lang"` ga oʻtkazadi va `cLux_ApplyUserConfig()` bilan qayta yuklatadi. **Bu oʻyinchining sozlamasini haqiqatdan oʻzgartiradi**: mod oʻchirilgandan keyin oʻyin inglizcha holatda qoladi va tilni Sozlamalardan qaytarib qoʻyish kerak boʻladi.

Shu sababli Sozlamalardagi til qatori kulrang va oʻzgarmas qilib qoʻyilgan (`helper_imgui_options.hps` patchi, `Languages` toifasi bilan cheklangan).

Ikkinchi patch `GetFont` ning boshida `msLanguage` ni `"english"` ga qoʻyadi. `FontHandler` shriftni tanlangan tilga qarab beradi — rus tilida merryweather + roboto-medium, xitoychada noto_sans_sc — oʻzbekcha matn esa hamma oʻyinchida oʻyinning asl special_elite / work / macondo shriftlari bilan chizilishi kerak.

Ovoz subtitrlari `maps/*.lang` ichida va tilga bogʻlanmagan — bitta nusxa hamma til uchun ishlaydi.

## Tutuq belgilari: `ʻ` va `ʼ`

HPL3 tizim shriftlaridan (TTF) foydalanmaydi — u oldindan pishirilgan bitmap atlaslarni oʻqiydi: `.fnt` (belgilar jadvali, XML) + `.dds` (rasm). Atlasda yoʻq belgi ekranda umuman chizilmaydi, fallback mexanizmi ham yoʻq. Windowsdagi shriftda glif borligi ahamiyatsiz.

`ʻ` (U+02BB) va `ʼ` (U+02BC) oʻyin atlaslarida yoʻq. Ammo ular tipografik jihatdan `‘` (U+2018) va `’` (U+2019) bilan **bir xil shakl**, bu ikkisi esa hamma atlasda chizilgan — masalan `work_56.fnt` da:

```xml
<char id="8216" x="422" y="350" width="10" height="16" ... />
<char id="8217" x="433" y="350" width="10" height="16" ... />
```

Shuning uchun `build_lang.pl` qurish paytida almashtiradi (`to_game_glyphs`): manbada (`src/`) imlo toʻgʻri — U+02BB va U+02BC, qurilgan modda esa U+2018 va U+2019. Natija piksel darajasida bir xil.

Modda `.fnt` ni ustidan yozib boʻlmaydi: oʻyin uning yonidan `.dds` atlasini qidiradi (fayl ichida `file="work_56_0.dds"` deb turadi), topa olmaydi va matnni umuman chizmaydi — `hpl.log` da xato ham chiqmaydi. Buning uchun 22 ta shriftning `.dds` fayllarini ham modga qoʻshish kerak boʻlardi: ~42 MB.

## `entry.hpc` cheklovi

Bu fayl qurish jarayonidan oʻtmaydi (`deploy.pl` uni shundayligicha koʻchiradi) va unda **uch baytli UTF-8 umuman ishlamaydi**. Ikki xil buzilish beradi: `Title` xom baytlar bilan chiziladi (`Oʻzbek` -> `Oâzbek`), `Description_*` esa `.lang` tahlilchisidan oʻtadi va har bir uch baytli belgi oʻzidan keyingi harfni yutadi (`toʻliq oʻzbek` -> `toiq obek`). Shuning uchun bu faylda tutuq belgisi ASCII apostrof (U+0027) boʻlib qoladi; ikki baytli kirill (ruscha tavsif) esa muammosiz ishlaydi.

## Tekshiruvlar

`check_all.pl` uchtasini yuritadi:

- **check_xml.pl** — teglar muvozanati, qochirilmagan `&`, takrorlangan kalit. HPL3 tahlilchisi xatolikda tilni jimgina tashlab ketadi, ekranda hech narsa chiqmaydi — shuning uchun bu tekshiruv deployʼdan oldin majburiy.
- **check_lang.pl** — har bir kalit oʻyinning hozirgi **inglizcha** matni bilan solishtiriladi (boshqa tillarning fayllarida eski versiyalardan qolgan 50-400 ta ishlatilmaydigan kalit bor, ular mezon boʻla olmaydi). Oʻyin yangilanib yangi satr qoʻshsa, shu yerda YETISHMAYDI boʻlib chiqadi.
- **check_chars.pl** — lotin matniga tasodifan kirib qolgan kirill harflari, ikki marta kodlangan UTF-8, ASCII apostrof va shriftda yoʻq belgilar.

`tarjimasiz` ustunidagi sonlar normal: ular ataylab oʻzgartirilmagan qatorlar — tugma nomlari, ismlar, nemis va fransuz nutqi (`prison.lang` da 34 ta, chunki mahbus Karl Springer faqat nemischa gapiradi).


## For English readers

This is the source of an Uzbek translation add-on for Amnesia: The Bunker ([Workshop item 3797682713](https://steamcommunity.com/sharedfiles/filedetails/?id=3797682713)). The documentation, the comments and the build scripts are all in Uzbek. Three HPL3 constraints shape the design and are described above:

- A mod cannot add a language slot: `mvLangFiles` in `MenuHandler.hps` has no `[nosave]`, so the list is restored from an existing profile and a `push_back` from a mod never runs. The add-on replaces the **english** slot instead.
- Text is drawn from prebaked bitmap atlases (`.fnt` + `.dds`) with no fallback, and overriding a `.fnt` from a mod breaks text entirely, so U+02BB and U+02BC are mapped onto U+2018 and U+2019 at build time.
- `entry.hpc` is not parsed as UTF-8, so that file has to stay in ASCII.
