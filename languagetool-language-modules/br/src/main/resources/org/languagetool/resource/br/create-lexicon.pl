#!/usr/bin/perl -w
#
# Convert the Breton lexicon from Apertium into a lexicon suitable for
# the LanguageTool grammar checker.
#
# LanguageTool POS tags for Breton are more or less similar to French tags to
# keep it simple.  This makes it easier to maintain grammar for both French
# and Breton without too much to remember.
#
# POS tags for LanguageTool simplify POS tags present in Apertium.
# Simpler POS tags make it easier to write regular expression in
# LanguageTool, but information can be lost in the conversion.
#
# How to use this script:
#
# 1) Download the Apertium Breton dictionary:
#    $ svn co https://apertium.svn.sourceforge.net/svnroot/apertium/trunk/apertium-br-fr
#    $ cd apertium-br-fr/
# 2) Install Apertium tools:
#    $ sudo apt-get install lttoolbox
# 3) Download morfologik-stemming-1.4.0.zip from
#    http://sourceforge.net/projects/morfologik/files/morfologik-stemming/1.4.0/
#    $ unzip morfologik-stemming-1.4.0.zip
#    This creates morfologik-stemming-nodict-1.4.0.jar
# 4) Run the script:
#    $ ./create-lexicon.pl
#
# Author: Dominique Pelle <dominique.pelle@gmail.com>
#
# Patches received from:
# - Fulup Jakez <fulup.jakez@ofis-bzh.org>
# - Thierry Vignaud <thierry.vignaud@gmail.com>

use strict;

my $dic_in  = 'apertium-br-fr.br.dix';
my $dic_out = "$dic_in-LT.txt";
my $dic_err = "$dic_in-LT.err";

my %soft = (
    'B' => 'V', 'D' => 'Z',
    'G' => 'C’h', # Gw => W, Gou[ei] => Ou[ei]
    'K' => 'G', 'M' => 'V', 'P' => 'B', 'T' => 'D',

    'b' => 'v', 'd' => 'z',
    'g' => 'c’h', # Gw => W, gou[ei] => ou[ei]
    'k' => 'g', 'm' => 'v', 'p' => 'b', 't' => 'd'
    );

my %hard = (
    'B' => 'P', 'D' => 'T', 'G' => 'K',
    'b' => 'p', 'd' => 't', 'g' => 'k');

my %spirant = (
    'K' => 'C’h', 'P' => 'F', 'T' => 'Z',
    'k' => 'c’h', 'p' => 'f', 't' => 'z');

# List of plural masculine nouns of persons for which it matters to know
# whether they are persons or not for the mutation after article "ar".
# Those are unfortunately not tagged in the Apertium dictionary.
# So we enhance tagging here to be able to detect some incorrect mutations
# after the article ar/an/al.
#
# The tag "N m p t" (N masculine plural tud) is used not only for mutation
# after ar/an/al (such as *Ar Kelted* -> "Ar Gelted") but also for
# mutations of adjective after noun such as:
# *Ar studierien pinvidik* -> "Ar studierien binvidik"
#
# This list is far from being complete. The more words the more
# mutation errors can be detected. But missing words should not
# cause false positives.
# Case matters!
my @anv_lies_tud = (
  map {
    my ($soft, $hard, $spirant);
    $spirant = s/^([ktp])/$spirant{$1}/ier if /^[ktp]/i;
    $hard    = s/^([bdg])/$hard{$1}/ier    if /^[bdg]/i;
    if (/^[bdgkmpt]/i) {
      $soft = $_;
      if (/^gou[ei]/i) {
        $soft =~ s/^g[oO]/o/;
        $soft =~ s/^G[oO]/O/;
      } else {
        # prevent 'Ghanaianed' => 'C’hhanaianed' (instead of 'C’hanaianed').
        $soft =~ s/^(g)h/$1/i;
        # special cases for 'Gw.*' & 'Gou[ei].*' roots.
        $soft =~ s/^g[wW]/w/;
        $soft =~ s/^G[wW]/W/;
      }
      $soft =~ s/^([bdgkmpt])/$soft{$1}/ie;
    }
    grep { $_ } $_, $soft, $hard, $spirant;
  }
  "Abkhazianed",
  "Afrikaned",
  "Akadianed",
  "Aljerianed",
  "Alamaned",
  "Amerikaned",
  "Andoraned",
  "Angled",
  "Aostralianed",
  "Aostrianed",
  "Arabed",
  "Asturianed",
  "Barbared",
  "Bachkired",
  "Bahameaned",
  "Barbadianed",
  "Belarusianed",
  "Belizeaned",
  "Berbered",
  "Bermudaned",
  "Bolivianed",
  "Brazilianed",
  "Bretoned",
  "Brezhoned",
  "Bruneianed",
  "Bulgared",
  "Chileaned",
  "Daned",
  "Dominikaned",
  "Eskimoed",
  "Fidjianed",
  "Finned",
  "Flamanked",
  "Franked",
  "Frañsizien",
  "Frioulaned",
  "Frizianed",
  "Gallaoued",
  "Gambianed",
  "Germaned",
  "Ghanaianed",
  "Gineaned",
  "Grenadianed",
  "Gwenedourien",
  "Gwenedourion",
  "Gresianed",
  "Hindoued",
  "Honduraned",
  "Indianed",
  "Italianed",
  "Jamaikaned",
  "Jordanianed",
  "Kabiled",
  "Kanadianed",
  "Kanaked",
  "Karnuted",
  "Kastilhaned",
  "Katalaned",
  "Kazaked",
  "Kelted",
  "Kenyaned",
  "Kolombianed",
  "Komorianed",
  "Koreaned",
  "Kostarikaned",
  "Kreizafrikaned",
  "Kroated",
  "Kubaned",
  "Kurded",
  "Kuriosolited",
  "Laponed",
  "Makedonianed",
  "Malgached",
  "Malianed",
  "Maouritanianed",
  "Marokaned",
  "Mec’hikaned",
  "Mongoled",
  "Muzulmaned",
  "Namibianed",
  "Navajoed",
  "Nevezkaledonianed",
  "Nigerianed",
  "Okitaned",
  "Ouzbeked",
  "Palestinianed",
  "Panameaned",
  "Papoued",
  "Parizianed",
  "Polinezianed",
  "Romaned",
  "Rusianed",
  "Salvadorianed",
  "Samoaned",
  "Saozon",
  "Sarded",
  "Savoazianed",
  "Serbed",
  "Sikilianed",
  "Sirianed",
  "Slovaked",
  "Slovened",
  "Spagnoled",
  "Suafrikaned",
  "Suised",
  "Tadjiked",
  "Tanzanianed",
  "Tatared",
  "Tibetaned",
  "Tonganed",
  "Tunizianed",
  "Turked",
  "Turkmened",
  "Tuvaluaned",
  "Vikinged",
  "Yakouted",
  "Zambianed",
  "Zouloued",
  "abostoled",
  "addiorroerien",
  "addiorroerion",
  "adeiladourien",
  "adeiladourion",
  "advibien",
  "advibion",
  "akademiidi",
  "aktorien",
  "aktorion",
  "aktourien",
  "aktourion",
  "alamanegerien",
  "alamanegerion",
  "alc'hwezerien",
  "alierien",
  "alierion",
  "alkimiourien",
  "alkimiourion",
  "alouberien",
  "alouberion",
  "alpaerien",
  "alpaerion",
  "aluzenerien",
  "aluzenerion",
  "alvokaded",
  "alvokaded-enor",
  "amaezhierien",
  "amaezhierion",
  "amatourien",
  "amatourion",
  "ambrougerien",
  "ambrougerion",
  "ambulañserien",
  "ambulañserion",
  "ambulañsourien",
  "ambulañsourion",
  "amiegourien",
  "amiegourion",
  "amiraled",
  "amezeien",
  "amezeion",
  "amourouzien",
  "amourouzion",
  "amprevanoniourien",
  "amprevanoniourion",
  "animatourien",
  "animatourion",
  "annezerien",
  "annezerion",
  "annezidi",
  "antropologourien",
  "antropologourion",
  "aotrouien",
  "aotrounez",
  "aozerien",
  "aozerion",
  "aozourien",
  "aozourion",
  "apotikerien",
  "apotikerion",
  "arbennigourien",
  "arbennigourion",
  "arboellerien",
  "arboellerion",
  "archerien",
  "archerion",
  "arc’hwilierien",
  "arc’hwilierion",
  "ardivikerien",
  "ardivikerion",
  "ardivinkerien",
  "ardivinkerion",
  "arerien",
  "arerion",
  "argaderien",
  "argaderion",
  "arkeologourien",
  "arkeologourion",
  "armdiourien",
  "armdiourion",
  "armeourien",
  "armeourion",
  "armerzhourien",
  "armerzhourion",
  "arsellerien",
  "arsellerion",
  "artizaded",
  "arvalien",
  "arvalion",
  "arvesterien",
  "arvesterion",
  "arvestourien",
  "arvestourion",
  "arzourien",
  "arzourion",
  "askellerien",
  "askellerion",
  "astraerien",
  "astraerion",
  "astrofizikourien",
  "astrofizikourion",
  "asurerien",
  "asurerion",
  "aterserien",
  "aterserion",
  "atletourien",
  "atletourion",
  "avielerien",
  "avielerion",
  "avielourien",
  "avielourion",
  "bachelourien",
  "bachelourion",
  "bac’herien",
  "bac’herion",
  "bagsavourien",
  "bagsavourion",
  "bagsturierien",
  "bagsturierion",
  "baleerien",
  "baleerion",
  "bamerien",
  "bamerion",
  "bangounellerien",
  "bangounellerion",
  "bannerien",
  "bannerion",
  "bannikerien",
  "bannikerion",
  "banvezerien",
  "banvezerion",
  "baraerien",
  "baraerion",
  "barbared",
  "bargederien",
  "bargederion",
  "barnerien",
  "barnerion",
  "baroned",
  "barverien",
  "barverion",
  "barzhed",
  "barzhonegourien",
  "barzhonegourion",
  "barzhoniezhourien",
  "barzhoniezhourion",
  "bastrouilherien",
  "bastrouilherion",
  "beajourien",
  "beajourion",
  "bedoniourien",
  "bedoniourion",
  "begeged",
  "begennelourien",
  "begennelourion",
  "beleien",
  "beleion",
  "beliourien",
  "beliourion",
  "bellerien",
  "bellerion",
  "benerien",
  "benerion",
  "berranaleien",
  "berrskriverien",
  "berrskriverion",
  "bes-sekretourien",
  "bes-sekretourion",
  "bes-teñzorerien",
  "bes-teñzorerion",
  "besrektorien",
  "besrektorion",
  "besrenerien",
  "besrenerion",
  "bessekretourien",
  "bessekretourion",
  "besteñzorerien",
  "besteñzorerion",
  "beulkeed",
  "bevezerien",
  "bevezerion",
  "bevgimiourien",
  "bevgimiourion",
  "bevoniourien",
  "bevoniourion",
  "bezhinaerien",
  "bezhinaerion",
  "bezhinerien",
  "bezhinerion",
  "bezierien",
  "bezierion",
  "bidanellerien",
  "bidanellerion",
  "bigrierien",
  "bigrierion",
  "biniaouerien",
  "biniaouerion",
  "biolinourien",
  "biolinourion",
  "bisamiraled",
  "bizaouierien",
  "bizaouierion",
  "bleinerien",
  "bleinerion",
  "blenierien",
  "blenierion",
  "boloñjerien",
  "boloñjerion",
  "bombarderien",
  "bombarderion",
  "bonelourien",
  "bonelourion",
  "boseien",
  "boserien",
  "boserion",
  "botaouerien",
  "botaouerion",
  "botaouerion",
  "botaouerien-koad",
  "botaouerion-koad",
  "botaouerien-lêr",
  "botaouerion-lêr",
  "bouedourien",
  "bouedourion",
  "bouloñjerien",
  "bouloñjerion",
  "bourc’hizien",
  "bourevien",
  "boutellerien",
  "boutellerion",
  "boutinelerien",
  "boutinelerion",
  "bouzared",
  "brabañserien",
  "brabañserion",
  "brammerien",
  "brammerion",
  "braventiourien",
  "braventiourion",
  "bravigourien",
  "bravigourion",
  "bredelfennerien",
  "bredelfennerion",
  "bredklañvourien",
  "bredklañvourion",
  "bredoniourien",
  "bredoniourion",
  "bredourien",
  "bredourion",
  "bredvezeien",
  "bredvezeion",
  "brellien",
  "brellion",
  "breolimerien",
  "breolimerion",
  "breserien",
  "breserion",
  "bresourien",
  "bresourion",
  "bretorien",
  "bretorion",
  "breudeur",
  "breutaerien",
  "breutaerion",
  "brezelourien",
  "brezelourion",
  "brezhonegerien",
  "brezhonegerion",
  "brientinien",
  "brigadennourien",
  "brigadennourion",
  "brigadierien",
  "brigadierion",
  "brikerien",
  "brikerion",
  "brizhkeltiegourien",
  "brizhkeltiegourion",
  "brizhkredennourien",
  "brizhkredennourion",
  "brizhouizieien",
  "broadelourien",
  "broadelourion",
  "brogarourien",
  "brogarourion",
  "brorenerien",
  "brorenerion",
  "brozennourien",
  "brozennourion",
  "brudourien",
  "brudourion",
  "bugale",
  "bugale-vihan",
  "bugaleigoù",
  "bugaligoù",
  "bugelien",
  "bugelion",
  "bugulien",
  "bugulion",
  "buhezegezhourien",
  "buhezegezhourion",
  "buhezoniourien",
  "buhezoniourion",
  "buhezourien",
  "buhezourion",
  "buhezskridourien",
  "buhezskridourion",
  "buhezskriverien",
  "buhezskriverion",
  "burutellerien",
  "burutellerion",
  "butunerien",
  "butunerion",
  "chakerien",
  "chakerion",
  "chalboterien",
  "chalboterion",
  "chaokerien",
  "chaokerion",
  "charreerien",
  "charreerion",
  "charretourien",
  "charretourion",
  "chaseourien",
  "chaseourion",
  "cherifed",
  "chikanerien",
  "chikanerion",
  "cow-boyed",
  "c’hoarierien",
  "c’hoarierion",
  "c’hoarzherien",
  "c’hoarzherion",
  "c’hwennerien",
  "c’hwennerion",
  "c’hwiblaerien",
  "c’hwiblaerion",
  "c’hwiletaerien",
  "c’hwiletaerion",
  "c’hwilierien",
  "c’hwilierion",
  "c’hwisterien",
  "c’hwisterion",
  "dafarerien",
  "dafarerion",
  "dalc’hourien",
  "dalc’hourion",
  "damesaerien",
  "damesaerion",
  "damkanourien",
  "damkanourion",
  "danevellerien",
  "danevellerion",
  "danevellourien",
  "danevellourion",
  "dantourien",
  "dantourion",
  "daranverien",
  "daranverion",
  "darbarerien",
  "darbarerion",
  "daremprederien",
  "daremprederion",
  "dastumerien",
  "dastumerion",
  "dañserien",
  "deaned",
  "debarzhadourien",
  "debrerien",
  "debrerion",
  "demokrated",
  "dengarourien",
  "dengarourion",
  "denoniourien",
  "denoniourion",
  "dentourien",
  "dentourion",
  "deraouidi",
  "deroerien",
  "deroerion",
  "deskadourien",
  "deskadourion",
  "deskarded",
  "deskerien",
  "deskerion",
  "deskidi",
  "deuñved",
  "deuñvien",
  "dezougerien",
  "dezougerion",
  "dezvarnourien",
  "dezvarnourion",
  "diaraogerien",
  "diaraogerion",
  "diazezerien",
  "diazezerion",
  "diazezourien",
  "diazezourion",
  "dibaberien",
  "dibaberion",
  "dibennerien",
  "dibennerion",
  "dibunerien",
  "dibunerion",
  "dielfennerien",
  "dielfennerion",
  "diellourien",
  "diellourion",
  "difennerien",
  "difennerion",
  "difankerien",
  "difankerion",
  "difraosterien",
  "difraosterion",
  "diktatourien",
  "diktatourion",
  "dilennidi",
  "dileuridi",
  "diorroerien",
  "diorroerion",
  "diouganerien",
  "diouganerion",
  "diplomated",
  "disivouderien",
  "disivouderion",
  "diskibien",
  "diskibion",
  "diskouezerien",
  "diskouezerion",
  "diskouezerien-c’hiz",
  "diskouezerion-c’hiz",
  "dispac’herien",
  "dispac’herion",
  "displegadegerien",
  "displegadegerion",
  "displegerien",
  "displegerion",
  "disrannerien",
  "disrannerion",
  "diveliourien",
  "diveliourion",
  "divizourien",
  "divizourion",
  "dizalc’hourien",
  "dizalc’hourion",
  "dizertourien",
  "dizertourion",
  "doktored",
  "dorloerien",
  "dorloerion",
  "dorloerien-leuñvourien",
  "dorloerion-leuñvourion",
  "dorloerion",
  "dornlabourerien",
  "dornlabourerion",
  "dornvicherourien",
  "dornvicherourion",
  "dornwezhourien",
  "dornwezhourion",
  "douarourien",
  "douarourion",
  "doueoniourien",
  "doueoniourion",
  "dougerien",
  "dougerion",
  "dourgimiourien",
  "dourgimiourion",
  "dramaourien",
  "dramaourion",
  "dreistwelourien",
  "dreistwelourion",
  "drouized",
  "drouklazherien",
  "drouklazherion",
  "duged",
  "ebenourien",
  "ebenourion",
  "ebestel",
  "egoraerien",
  "egoraerion",
  "eil-sekretourien",
  "eil-sekretourion",
  "eil-teñzorerien",
  "eil-teñzorerion",
  "eilbanerien",
  "eilbanerion",
  "eilc’hoarierien",
  "eilc’hoarierion",
  "eilerien",
  "eilerion",
  "eiloberierien",
  "eiloberierion",
  "eilrenerien",
  "eilrenerion",
  "eilsekretourien",
  "eilsekretourion",
  "eilteñzorerien",
  "eilteñzorerion",
  "ekografourien",
  "ekografourion",
  "ekologourien",
  "ekologourion",
  "eksibien",
  "embannerien",
  "embannerion",
  "embregourien",
  "embregourion",
  "emgannerien",
  "emgannerion",
  "emrenerien",
  "emrenerion",
  "emsaverien",
  "emsaverion",
  "emstriverien",
  "emstriverion",
  "emzivaded",
  "enaouerien",
  "enaouerion",
  "enbroerien",
  "enbroerion",
  "enbroidi",
  "eneberien",
  "eneberion",
  "enebourien",
  "enebourion",
  "eneoniourien",
  "eneoniourion",
  "engraverien",
  "engraverion",
  "enklaskerien",
  "enklaskerion",
  "enporzhierien",
  "enporzhierion",
  "ensellerien",
  "ensellerion",
  "eontred",
  "eontred-kozh",
  "eosterien",
  "eosterion",
  "erbederien",
  "erbederion",
  "erlec’hidi",
  "ergerzherien",
  "ergerzherion",
  "estlammerien",
  "estlammerion",
  "estrañjourien",
  "estrañjourion",
  "etnolouzawourien",
  "etnolouzawourion",
  "etrebroadelourien",
  "etrebroadelourion",
  "etrevroadelourien",
  "etrevroadelourion",
  "eveshaerien",
  "eveshaerion",
  "evezhierien",
  "evezhierion",
  "evnoniourien",
  "evnoniourion",
  "ezporzhierien",
  "ezporzhierion",
  "faezherien",
  "faezherion",
  "faktorien",
  "faktorion",
  "falc’herien",
  "falc’herion",
  "falserien",
  "falserion",
  "faragouellerien",
  "faragouellerion",
  "farderien",
  "farderion",
  "farserien",
  "farserion",
  "faskourien",
  "faskourion",
  "feizidi",
  "fellerien",
  "fellerion",
  "fentourien",
  "fentourion",
  "feurmerien",
  "feurmerion",
  "ficherien-vlev",
  "ficherion-vlev",
  "filhored",
  "filmaozerien",
  "filmaozerion",
  "filozofed",
  "filozoferien",
  "filozoferion",
  "fistoulerien",
  "fistoulerion",
  "fizikourien",
  "fizikourion",
  "flatrerien",
  "flatrerion",
  "fleüterien",
  "fleüterion",
  "foeterien-bro",
  "foeterion-bro",
  "fougaserien",
  "fougaserion",
  "fourmajerien",
  "fourmajerion",
  "frankizourien",
  "frankizourion",
  "fungorollerien",
  "fungorollerion",
  "furcherien",
  "furcherion",
  "furien",
  "furion",
  "furlukined",
  "gallaouegerien",
  "gallaouegerion",
  "gallegerien",
  "gallegerion",
  "gaoperien",
  "gaoperion",
  "gaouidi",
  "gastaouerien",
  "gastaouerion",
  "genaoueien",
  "genaoueion",
  "genetikourien",
  "genetikourion",
  "geriadurourien",
  "geriadurourion",
  "gevelled",
  "ginekologourien",
  "ginekologourion",
  "gitarourien",
  "gitarourion",
  "golferien",
  "golferion",
  "gouarnerien",
  "gouarnerion",
  "gouarnourien",
  "gouarnourion",
  "gouarnourien-veur",
  "gouarnourion-veur",
  "gouennelourien",
  "gouennelourion",
  "gopraerion",
  "gopraerien",
  "goprerien",
  "goprerion",
  "gopridi",
  "gouarnourien",
  "gouarnourion",
  "gouerien",
  "gouerion",
  "gouizieien",
  "goulawourien",
  "goulawourion",
  "goulennerien",
  "goulennerion",
  "goulevierien",
  "goulevierion",
  "gounezerien",
  "gounezerion",
  "gourdonerien",
  "gourdonerion",
  "gourenerien",
  "gourenerion",
  "gouroned",
  "gouzañverien",
  "gouzañverion",
  "goved",
  "grafourien",
  "grafourion",
  "greferien",
  "greferion",
  "groserien",
  "groserion",
  "gwallerien",
  "gwallerion",
  "gwarded",
  "gwaregerien",
  "gwaregerion",
  "gwastadourien",
  "gwastadourion",
  "gwazed",
  "gwazedoù",
  "gwazhwelerien",
  "gwazhwelerion",
  "gwizien",
  "gwazourien",
  "gwazourion",
  "gweladennerien",
  "gweladennerion",
  "gweledvaourien",
  "gweledvaourion",
  "gwellwelerien",
  "gwellwelerion",
  "gwenanerien",
  "gwenanerion",
  "gwerzherien",
  "gwerzherion",
  "gwerzherien-red",
  "gwerzherion-red",
  "gwiaderien",
  "gwiaderion",
  "gwiniegourien",
  "gwiniegourion",
  "gwiraourien",
  "gwiraourion",
  "haderien",
  "haderion",
  "hailhoned",
  "hanterourien",
  "hanterourion",
  "harozed",
  "harperien",
  "harperion",
  "harzlammerien",
  "harzlammerion",
  "hañvourien",
  "hañvourion",
  "heforzhourien",
  "heforzhourion",
  "hegazerien",
  "hegazerion",
  "helavarourien",
  "helavarourion",
  "hellenegourien",
  "hellenegourion",
  "hemolc’herien",
  "hemolc’herion",
  "henaourien",
  "henaourion",
  "hendraourien",
  "hendraourion",
  "henoniourien",
  "henoniourion",
  "herperien",
  "herperion",
  "hevlezourien",
  "hevlezourion",
  "heñcherien",
  "heñcherion",
  "hêred",
  "hidrokimiourien",
  "hidrokimiourion",
  "hollveliourien",
  "hollveliourion",
  "hollwashaourien",
  "hollwashaourion",
  "horolajerien",
  "horolajerion",
  "houlierien",
  "houlierion",
  "hudourien",
  "hudourion",
  "hudsteredourien",
  "hudsteredourion",
  "hudstrilhourien",
  "hudstrilhourion",
  "hunerien",
  "hunerion",
  "ijinadennourien",
  "ijinadennourion",
  "ijinourien",
  "ijinourion",
  "imbourc’herien",
  "imbourc’herion",
  "imbrouderien",
  "imbrouderion",
  "impalaerien",
  "impalaerion",
  "implijerien",
  "implijerion",
  "implijidi",
  "inosanted",
  "intañvien",
  "intañvion",
  "irrinnerien",
  "irrinnerion",
  "iskrimerien",
  "iskrimerion",
  "ispiserien",
  "ispiserion",
  "isprefeded",
  "isrenerien",
  "isrenerion",
  "istorourien",
  "istorourion",
  "jahinerien",
  "jahinerion",
  "jakerien",
  "jakerion",
  "jedoniourien",
  "jedoniourion",
  "jiboesaourien",
  "jokeed",
  "jiboesaourion",
  "jubennourien",
  "jubennourion",
  "junterien",
  "junterion",
  "kabitened",
  "kadoniourien",
  "kadoniourion",
  "kadourien",
  "kadourion",
  "kalonourien",
  "kalonourion",
  "kalvezourien",
  "kalvezourion",
  "kamaladed",
  "kamaraded",
  "kameraourien",
  "kameraourion",
  "kanaouennerien",
  "kanaouennerion",
  "kanerien",
  "kanerion",
  "kannaded",
  "kannaderien",
  "kannaderion",
  "kannadourien",
  "kannadourion",
  "kannerien",
  "kannerion",
  "kanolierien",
  "kanolierion",
  "kantennerien",
  "kantennerion",
  "kantonierien",
  "kantonierion",
  "kantreerien",
  "kantreerion",
  "kapitalourien",
  "kapitalourion",
  "karidi",
  "kargiaded",
  "kargidi",
  "kariaded",
  "karngerzherien",
  "karngerzherion",
  "karourien",
  "karourion",
  "karrdiourien",
  "karrdiourion",
  "karrellerien",
  "karrellerion",
  "karrerien",
  "karrerion",
  "kartennourien",
  "kartennourion",
  "kasedourien",
  "kasedourion",
  "kaserien",
  "kaserion",
  "kasourien",
  "kasourion",
  "katoliked",
  "kavadennerien",
  "kavadennerion",
  "kavalierien",
  "kavalierion",
  "kazetennerien",
  "kazetennerion",
  "kañfarded",
  "kañsellerien",
  "kañsellerion",
  "kefierien",
  "kefierion",
  "kefredourien",
  "kefredourion",
  "kefridierien",
  "keginerien",
  "keginerion",
  "kelaouennerien",
  "kelaouennerion",
  "kelaouerien",
  "kelaouerion",
  "kelennerien",
  "kelennerien-enklasker",
  "kelennerion-enklasker",
  "kelennerien-enklaskerien",
  "kelennerien-enklaskerion",
  "kelennerion",
  "kelennerien-klaskerien",
  "kelennerion-klaskerion",
  "kembraegerien",
  "kembraegerion",
  "kemenerien",
  "kemenerion",
  "kempouezerien",
  "kempouezerion",
  "kenaozerien",
  "kenaozerion",
  "kenbrezegerien",
  "kenbrezegerion",
  "kenderc’herien",
  "kenderc’herion",
  "kendirvi",
  "kendiskulierien",
  "kendivizerien",
  "kendivizerion",
  "kenedourien",
  "kenedourion",
  "keneiled",
  "kengourenerien",
  "kengourenerion",
  "kenlabourerien",
  "kenlabourerion",
  "kenoberourien",
  "kenoberourion",
  "kensanterien",
  "kensanterion",
  "kenseurted",
  "kenskriverien",
  "kenskriverion",
  "kenstriverien",
  "kenstriverion",
  "kenurzhierien",
  "kenurzhierion",
  "kenvroidi",
  "kenwallerien",
  "kenwallerion",
  "kenwerzherien",
  "kenwerzherion",
  "keodedourien",
  "kereon",
  "kereourien",
  "kereourion",
  "kerzherien",
  "kerzherion",
  "kevalaourien",
  "kevalaourion",
  "kevelerien",
  "kevelerion",
  "kevezerien",
  "kevezerion",
  "kevrinourien",
  "kevrinourion",
  "kigerien",
  "kigerion",
  "kilstourmerien",
  "kilstourmerion",
  "kilvizien",
  "kilvizion",
  "kimiourien",
  "kimiourion",
  "kinkailherien",
  "kinkailherion",
  "kinnigerien",
  "kiropraktored",
  "kivijerien",
  "kivijerion",
  "kizellerien",
  "kizellerion",
  "klapezeien",
  "klaskerien",
  "klaskerion",
  "klaskerien-vara",
  "klaskerion-vara",
  "klañvdiourien",
  "klañvdiourion",
  "klañvourien",
  "klañvourion",
  "kleiziaded",
  "kleizidi",
  "kleiziourien",
  "kleiziourion",
  "klerinellourien",
  "klerinellourion",
  "kleuzierien",
  "kleuzierion",
  "klezeourien",
  "klezeourion",
  "kloareged",
  "kloareien",
  "kloareion",
  "kloer",
  "koataerien",
  "koataerion",
  "kollerien",
  "kollerion",
  "komandanted",
  "komedianed",
  "komiserien",
  "komiserion",
  "komisien",
  "kompezourien",
  "kompezourion",
  "komunourien",
  "komunourion",
  "komzerien",
  "komzerion",
  "konterien",
  "konterion",
  "kontourien",
  "kontourion",
  "korollerien",
  "korollerion",
  "korollourien",
  "korollourion",
  "korporaled",
  "kouerien",
  "kouerion",
  "koumananterien",
  "koumananterion",
  "kouraterien",
  "kouraterion",
  "kouronkerien",
  "kouronkerion",
  "kourserien",
  "kourserion",
  "kourvibien",
  "kozhidi",
  "koñversanted",
  "krakaotrouien",
  "krampouezherien",
  "krampouezherion",
  "kravazherien",
  "kravazherion",
  "kreaterien",
  "kreaterion",
  "kredennourien",
  "kredennourion",
  "kreizourien",
  "krennarded",
  "kretadennerien",
  "kretadennerion",
  "kristenien",
  "kristenion",
  "krouadurien",
  "krouadurion",
  "krouerien",
  "krouerion",
  "krougerien",
  "krougerion",
  "kulatorien",
  "kulatorion",
  "kunduerien",
  "kunduerion",
  "kureed",
  "kuzulierien",
  "kuzulierion",
  "kuzulierien-departamant",
  "kuzulierion-departamant",
  "kuzulierien-kêr",
  "kuzulierien-rannvro",
  "kuzulierion-rannvro",
  "kêraozourien",
  "kêraozourion",
  "labourerien",
  "labourerien-douar",
  "labourerion",
  "labourerion-douar",
  "laeron",
  "laezherien",
  "laezherion",
  "lagadourien",
  "lagadourion",
  "lakizien",
  "lakizion",
  "lammerien",
  "lammerion",
  "lamponed",
  "lavarerien",
  "lavarerion",
  "lazherien",
  "lazherion",
  "leaned",
  "legumajerien",
  "legumajerion",
  "lemmerien",
  "lemmerion",
  "lenneien",
  "lenneion",
  "lennerien",
  "lennerion",
  "lennourien",
  "lennourion",
  "lestrsavourien",
  "lestrsavourion",
  "letiourien",
  "letiourion",
  "leurennerien",
  "leurennerion",
  "levraouaerien",
  "levraouaerion",
  "levraouegerien",
  "levraouegerion",
  "levraouerien",
  "levraouerion",
  "levrierien",
  "levrierion",
  "lezvibien",
  "liorzherien",
  "liorzherion",
  "liorzhourien",
  "liorzhourion",
  "liperien",
  "liperion",
  "lipouzerien",
  "lipouzerion",
  "liseidi",
  "liverien",
  "liverion",
  "livourien",
  "livourion",
  "lizheregourien",
  "lizheregourion",
  "lizherennerien",
  "lizherennerion",
  "loenoniourien",
  "loenoniourion",
  "lomaned",
  "lonkerien",
  "lonkerion",
  "loreidi",
  "louzaouerien",
  "louzaouerion",
  "louzawourien",
  "louzawourion",
  "lubanerien",
  "lubanerion",
  "luc’hengraverien",
  "luc’hengraverion",
  "luc’hskeudennerien",
  "luc’hskeudennerion",
  "luc’hvannerien",
  "luc’hvannerion",
  "luderien",
  "luderion",
  "lunederien",
  "lunederion",
  "lunedourien",
  "lunedourion",
  "luskerien",
  "luskerion",
  "mibien-gaer",
  "madoberourien",
  "madoberourion",
  "maendreserien",
  "maendreserion",
  "maengizellerien",
  "maengizellerion",
  "maered",
  "maesaerien",
  "maesaerion",
  "magerien",
  "magerion",
  "mailhed",
  "maketennourien",
  "maketennourion",
  "maltouterien",
  "maltouterion",
  "manifesterien",
  "manifesterion",
  "maodierned",
  "marc’hadourien",
  "marc’hadourion",
  "marc’hegerien",
  "marc’hegerion",
  "marc’heien",
  "marc’hekaerien",
  "marc’hekaerion",
  "marc’hergerien",
  "marc’hergerion",
  "marc’hhouarnerien",
  "marc’hhouarnerion",
  "marc’homerien",
  "marc’homerion",
  "marichaled",
  "margodennerien",
  "margodennerion",
  "markizien",
  "marokinerien",
  "marokinerion",
  "martoloded",
  "marvailherien",
  "marvailherion",
  "mañsonerien",
  "mañsonerion",
  "marc’heien",
  "marc’heion",
  "merdeidi",
  "mederien",
  "medisined",
  "medisinourien",
  "medisinourion",
  "meingimiourien",
  "meingimiourion",
  "mekanikerien",
  "mekanikerion",
  "melestrourien",
  "melestrourion",
  "melldroaderien",
  "melldroaderion",
  "mendemerien",
  "mendemerion",
  "menec’h",
  "mengleuzierien",
  "mengleuzierion",
  "merc’hetaerien",
  "merc’hetaerion",
  "merdeerien",
  "merdeerion",
  "mererien",
  "mererion",
  "merourien",
  "merourion",
  "merserien",
  "merserion",
  "merzherien",
  "merzherierien",
  "merzherierion",
  "merzherion",
  "mesaerien",
  "mesaerion",
  "mestroù-pastezer",
  "metalourien",
  "metalourion",
  "meveled",
  "mevelien",
  "mevelion",
  "mezeien",
  "mezvierien",
  "mezvierion",
  "mibien",
  "mibien-gaer",
  "mibien-vihan",
  "micherelourien",
  "micherelourion",
  "micherourien",
  "micherourion",
  "mic’hieien",
  "mignoned",
  "milinerien",
  "milinerion",
  "milourien",
  "milourion",
  "milvezeien",
  "milvezeion",
  "minerien",
  "minerion",
  "ministred",
  "minored",
  "minterien",
  "minterion",
  "mirerien",
  "mirerion",
  "mirourien",
  "mirourion",
  "misionerien",
  "misionerion",
  "mistri",
  "mistri-pastezer",
  "mistri-prezegennerien",
  "mistri-prezegennerion",
  "mistri-skol",
  "mistri-vicherour",
  "mogned",
  "monitourien",
  "monitourion",
  "moraerien",
  "moraerion",
  "morianed",
  "morianetaerien",
  "morianetaerion",
  "morlaeron",
  "moruteaerien",
  "moruteaerion",
  "mouezhierien",
  "mouezhierion",
  "moullerien",
  "moullerion",
  "moused",
  "mouskederien",
  "mouskederion",
  "mouzherien",
  "mouzherion",
  "mudien",
  "muntrerien",
  "muntrerion",
  "munuzerien",
  "munuzerion",
  "muzikerien",
  "muzikerion",
  "muzulierien",
  "muzulierion",
  "naetaerien",
  "naetaerion",
  "naturoniourien",
  "naturoniourion",
  "naturourien",
  "naturourion",
  "nervourien",
  "nervourion",
  "neurologourion",
  "neurologourien",
  "neurologourion",
  "neurosurjianed",
  "neuñverien",
  "neuñverion",
  "nijerien",
  "nijerion",
  "nized",
  "nizien",
  "nizion",
  "notered",
  "noterien",
  "noterion",
  "nozourien",
  "nozourion",
  "oadourien",
  "oadourion",
  "oberataourien",
  "oberataourion",
  "obererien",
  "obererion",
  "oberiataerien",
  "oberiataerion",
  "oberierien",
  "oberierion",
  "oberourien",
  "oberourion",
  "ofiserien",
  "ofiserion",
  "ograouerien",
  "ograouerion",
  "optometrourien",
  "optometrourion",
  "orfebourien",
  "orfebourion",
  "oueskerien",
  "oueskerion",
  "paeerien",
  "paeerion",
  "paeroned",
  "palerien",
  "palerion",
  "palforserien",
  "palforserion",
  "paluderien",
  "paluderion",
  "pantierien",
  "pantierion",
  "paotred",
  "paotredoù",
  "paotredigoù",
  "paramantourien",
  "paramantourion",
  "pardonerien",
  "pardonerion",
  "pareourien",
  "pareourion",
  "pastezerien",
  "pastezerion",
  "pastored",
  "pec’herien",
  "pec’herion",
  "peizanted",
  "pellenndroaderien",
  "pellenndroaderion",
  "pellskriverien",
  "pellskriverion",
  "pennijinourien",
  "pennijinourion",
  "penngorporaled",
  "pennprokulored",
  "pennprokulorien",
  "pennprokulorion",
  "pennsekretourien",
  "pennsekretourion",
  "pennsellerien",
  "pennsellerion",
  "pennskridaozerien",
  "pennskridaozerion",
  "pennskrivagnerien",
  "pennskrivagnerion",
  "pennsonerien",
  "pennsonerion",
  "pennvekanikerien",
  "pennvekanikerion",
  "penterien",
  "penterion",
  "peoc’hgarourien",
  "peoc’hgarourion",
  "peorien",
  "peorion",
  "perc’henned",
  "perc’herined",
  "personed",
  "perukennerien",
  "perukennerion",
  "perzhidi",
  "peskedoniourien",
  "peskedoniourion",
  "peskerien",
  "peskerion",
  "pesketaerien",
  "pesketaerion",
  "pianoourien",
  "pianoourion",
  "piaouerien",
  "piaouerion",
  "pibien",
  "pikerien",
  "pikerion",
  "pilhaouaerien",
  "pilhaouaerion",
  "pinvidien",
  "pinvidion",
  "plastrerien",
  "plastrerion",
  "pleustrerien",
  "pleustrerion",
  "plomerien",
  "plomerion",
  "poberien",
  "poberion",
  "poderien",
  "poderion",
  "poliserien",
  "poliserion",
  "politikacherien",
  "politikacherion",
  "politikerien",
  "politikerion",
  "poltredourien",
  "poltredourion",
  "pomperien",
  "pomperion",
  "porfumerien",
  "porfumerion",
  "porzhierien",
  "porzhierion",
  "posterien",
  "posterion",
  "pourchaserien",
  "pourchaserion",
  "pourvezerien",
  "pourvezerion",
  "prederourien",
  "prederourion",
  "prefeded",
  "preizherien",
  "preizherion",
  "prenerien",
  "prenerion",
  "prestaouerien",
  "prestaouerion",
  "prezegennerien",
  "prezegennerion",
  "prezidanted",
  "priourien",
  "priourion",
  "prizachourien",
  "prizachourion",
  "prizonidi",
  "prizonierien",
  "prizonierion",
  "priñsed",
  "produerien",
  "produerion",
  "prokulored",
  "prokulorien",
  "prokulorion",
  "psikiatrourien",
  "psikiatrourion",
  "psikologourien",
  "psikologourion",
  "rakprenerien",
  "rakprenerion",
  "randonerien",
  "randonerion",
  "ratouzed",
  "rebecherien",
  "rebecherion",
  "rederien",
  "rederien-vor",
  "rederien-vro",
  "rederion",
  "rederion-vor",
  "rederion-vro",
  "reizhaouerien",
  "reizhaouerion",
  "reizherien",
  "reizherion",
  "rektorien",
  "rektorion",
  "renerien",
  "renerion",
  "republikaned",
  "repuidi",
  "reuzeudien",
  "reuzeudion",
  "reveulzierien",
  "reveulzierion",
  "riblerien",
  "riblerion",
  "riboderien",
  "riboderion",
  "riboulerien",
  "riboulerion",
  "roberien",
  "roberion",
  "roerien",
  "roerion",
  "romanterien",
  "romanterion",
  "rugbierien",
  "rugbierion",
  "ruzarded",
  "ruzerien",
  "ruzerion",
  "ruzikerien",
  "ruzikerion",
  "salverien",
  "salverion",
  "saoznegerien",
  "saoznegerion",
  "savadennerien",
  "savadennerion",
  "saverien",
  "saverion",
  "saveteerien",
  "saveteerion",
  "savourien",
  "savourion",
  "sekretourien",
  "sekretourien-kontour",
  "sekretourion-kontour",
  "sekretourien-kontourien",
  "sekretourion",
  "sekretourion-kontourion",
  "selaouerien",
  "selaouerion",
  "sellerien",
  "sellerion",
  "sellourien",
  "sellourion",
  "senedourien",
  "senedourion",
  "servijerien",
  "servijerion",
  "sevenerien",
  "sevenerion",
  "sikourerien",
  "sikourerion",
  "sinerien",
  "sinerion",
  "skarzherien",
  "skarzherion",
  "skeudennaouerien",
  "skeudennaouerion",
  "skeudennourien",
  "skeudennourion",
  "skiantourien",
  "skiantourion",
  "skignerien",
  "skignerion",
  "sklavourien",
  "sklavourion",
  "skoazellerien",
  "skoazellerion",
  "skolaerien",
  "skolaerion",
  "skolajidi",
  "skolidi",
  "skolveuridi",
  "skorerien",
  "skorerion",
  "skraperien",
  "skraperion",
  "skridaozerien",
  "skridaozerion",
  "skridvarnourien",
  "skridvarnourion",
  "skrivagnerien",
  "skrivagnerion",
  "skuberien",
  "skuberion",
  "skultourien",
  "skultourion",
  "sodien",
  "sokialourien",
  "sokialourion",
  "sokiologourien",
  "sokiologourion",
  "sokioyezhoniourien",
  "sokioyezhoniourion",
  "sonaozourien",
  "sonaozourion",
  "sonerien",
  "sonerion",
  "soniawourien",
  "soniawourion",
  "sonourien",
  "sonourion",
  "soroc’horien",
  "soroc’horion",
  "sorserien",
  "sorserion",
  "soudarded",
  "soñjerien",
  "soñjerion",
  "sperederien",
  "sperederion",
  "spierien",
  "spierion",
  "splujerien",
  "splujerion",
  "sponsorien",
  "sponsorion",
  "sponterien",
  "sponterion",
  "sporterien",
  "sporterion",
  "sportourien",
  "sportourion",
  "stadrenerien",
  "stadrenerion",
  "stajidi",
  "stalierien",
  "stalierion",
  "sterdeidi",
  "steredoniourien",
  "steredoniourion",
  "steredourien",
  "steredourion",
  "stlejerien",
  "stlejerion",
  "stlenngraferien",
  "stlenngraferion",
  "stolierien",
  "stolierion",
  "stomogourien",
  "stomogourion",
  "stourmerien",
  "stourmerion",
  "stranerien",
  "stranerion",
  "steredourien",
  "steredourion",
  "strinkerien",
  "strinkerion",
  "strobinellerien",
  "strobinellerion",
  "studierien",
  "studierion",
  "stummerien",
  "stummerion",
  "sturierien",
  "sturierion",
  "surjianed",
  "taboulinerien",
  "taboulinerion",
  "tagerien",
  "tagerion",
  "tailhanterien",
  "tailhanterion",
  "talabarderien",
  "talabarderion",
  "tanerien",
  "tanerion",
  "taolerien",
  "taolerion",
  "tavarnerien",
  "tavarnerion",
  "tavarnourien",
  "tavarnourion",
  "teknikourien",
  "teknikourion",
  "telennourien",
  "telennourion",
  "tennerien",
  "tennerion",
  "teogerien",
  "teogerion",
  "teozofourien",
  "teozofourion",
  "teñzorerien",
  "teñzorerion",
  "tinellerien",
  "tinellerion",
  "tisavourien",
  "tisavourion",
  "titourerien",
  "titourerion",
  "toerien",
  "toerion",
  "togerien",
  "togerion",
  "tommerien",
  "tommerion",
  "tontoned",
  "torfedourien",
  "torfedourion",
  "toucherien",
  "toucherion",
  "touellerien",
  "touellerion",
  "toullerien",
  "toullerien-buñsoù",
  "toullerien-vezioù",
  "toullerion",
  "toullerion-buñsoù",
  "toullerion-vezioù",
  "touristed",
  "trafikerien",
  "trafikerion",
  "trapezerien",
  "trapezerion",
  "trec’hourien",
  "trec’hourion",
  "tredeidi",
  "tredanerien",
  "tredanerion",
  "tredeeged",
  "tredeoged",
  "treitourien",
  "treitourion",
  "treizherien",
  "treizherion",
  "tremenerien",
  "tremenerion",
  "tresourien",
  "tresourion",
  "trevadennerien",
  "trevadennerion",
  "trevourien",
  "trevourion",
  "troadeien",
  "troadeion",
  "troazhadourien",
  "troazhadourion",
  "troergerzherien",
  "troergerzherion",
  "troerien",
  "troerien-douar",
  "troerion",
  "troerion-douar",
  "troiadourien",
  "troiadourion",
  "trompilherien",
  "trompilherion",
  "trubarded",
  "trucherien",
  "trucherion",
  "truilhenned",
  "tud",
  "tudigoù",
  "tudjentil",
  "tudoniourien",
  "tudonourien",
  "tudonourion",
  "turgnerien",
  "turgnerion",
  "unyezherien",
  "urcherien",
  "urcherion",
  "uzurerien",
  "uzurerion",
  "voterien",
  "voterion",
  "wikipedourien",
  "wikipedourion",
  "yalc’hadourien",
  "yalc’hadourion",
  "yezhadurourien",
  "yezhadurourion",
  "yezherien",
  "yezherion",
  "yezhoniourien",
  "yezhoniourion",
  "yezhourien",
  "yezhourion",
  "yunerien",
  "yunerion",
);
my %anv_lies_tud = map { $_ => 0 } @anv_lies_tud;

open(LT_EXPAND, "lt-expand $dic_in |") or die "can't fork lt-expand: $!\n";
open(OUT, "> $dic_out") or die "can't open $dic_out: $!\n";
open(ERR, "> $dic_err") or die "can't open $dic_err: $!\n";

# Count how many words handled and unhandled.
my ($out_count, $err_count) = (0, 0);
my %all_words;
my %all_lemmas;

while (<LT_EXPAND>) {
  chomp;
  next unless (/^([^: _~]+):(>:)?([^:<]+)([^#]*)(#.*)?/);

  my ($word, $lemma, $tags) = ($1, $3, $4);

  $tags =~ s/(<adj><mf><sp>)\+.*/$1/;
  $tags =~ s/(<vblex><pri><p.><..>)\+.*/$1/;
  $lemma = $word if ($lemma eq 'direct' or $lemma eq 'prpers');

  $all_lemmas{$lemma} = 1;
  $all_words{$word} = 1;

  my $tag = '';

  if    ($tags eq '<det><def><sp>')     { $tag = "D e sp" }    # an, ar, al
  elsif ($tags eq '<det><ind><sp>')     { $tag = "D e sp" }    # un, ur, ul
  elsif ($tags eq '<det><ind><mf><sg>') { $tag = "D e s" }     # bep
  elsif ($tags eq '<det><pos><mf><sp>') { $tag = "D e sp" }    # hon
  elsif ($tags eq '<det><pos><m><sp>')  { $tag = "D m sp" }    # e
  elsif ($tags eq '<det><pos><f><sp>')  { $tag = "D f sp" }    # he

  # Verbal particles.
  elsif ($tags eq '<vpart>')            { $tag = "L a" }       # a
  elsif ($tags eq '<vpart><obj>')       { $tag = "L e" }       # e, ec’h, ez
  elsif ($tags eq '<vpart><ger>')       { $tag = "L o" }       # e, ec’h, ez
  elsif ($tags eq '<vpart><neg>')       { $tag = "L n" }       # na
  elsif ($tags eq '<vpart><opt>')       { $tag = "L r" }       # ra

  elsif ($tags eq '<ij>')               { $tag = "I" }         # ac’hanta

  # Adverbs.
  elsif ($tags eq '<cnjcoo>')           { $tag = "C coor" }    # ha, met
  elsif ($tags eq '<cnjadv>')           { $tag = "C adv" }     # eta, emichañs
  elsif ($tags =~ /<cnjsub>.*/)         { $tag = "C sub" }     # mar, pa

  # Adverbs.
  elsif ($tags eq '<adv>')              { $tag = "A" }         # alies, alese, amañ
  elsif ($tags eq '<adv><neg>')         { $tag = "A neg" }     # ne, ned, n’
  elsif ($tags eq '<adv><itg>')         { $tag = "A itg" }     # perak, penaos
  elsif ($tags eq '<preadv>')           { $tag = "A pre" }     # gwall, ken, pegen

  # Adjectives.
  elsif ($tags eq '<adj><mf><sp>')      { $tag = "J" }     # brav, fur
  elsif ($tags eq '<adj><sint><comp>')  { $tag = "J cmp" } # bravoc’h
  elsif ($tags eq '<adj><sint><sup>')   { $tag = "J sup" } # bravañ
  elsif ($tags eq '<adj><sint><excl>')  { $tag = "J exc" } # bravat
  elsif ($tags eq '<adj><itg><mf><sp>') { $tag = "J itg" } # peseurt, petore
  elsif ($tags eq '<adj><ind><mf><sp>') { $tag = "J ind" } # all, memes

  # Pronouns subject.
  elsif ($tags eq '<prn><subj><p1><mf><sg>') { $tag = "R suj e s 1" } # me
  elsif ($tags eq '<prn><subj><p2><mf><sg>') { $tag = "R suj e s 2" } # te
  elsif ($tags eq '<prn><subj><p3><m><sg>')  { $tag = "R suj m s 3" } # eñ
  elsif ($tags eq '<prn><subj><p3><f><sg>')  { $tag = "R suj f s 3" } # hi
  elsif ($tags eq '<prn><subj><p1><mf><pl>') { $tag = "R suj e p 1" } # ni
  elsif ($tags eq '<prn><subj><p2><mf><pl>') { $tag = "R suj e p 2" } # c’hwi
  elsif ($tags eq '<prn><subj><p3><mf><pl>') { $tag = "R suj e p 3" } # int
  elsif ($tags eq '<prn><subj><p3><mf><pl>') { $tag = "R suj e p 3" } # int
  elsif ($tags eq '<prn><ref><p1><mf><sg>')  { $tag = "R ref e s 1" } # ma-unan
  elsif ($tags eq '<prn><ref><p2><mf><sg>')  { $tag = "R ref e s 2" } # da-unan
  elsif ($tags eq '<prn><ref><p3><f><sg>')   { $tag = "R ref f s 3" } # e-unan
  elsif ($tags eq '<prn><ref><p3><m><sg>')   { $tag = "R ref m s 3" } # he-unan
  elsif ($tags eq '<prn><ref><p1><mf><pl>')  { $tag = "R ref e p 1" } # hon-unan
  elsif ($tags eq '<prn><ref><p2><mf><pl>')  { $tag = "R ref e p 2" } # hoc’h-unan
  elsif ($tags eq '<prn><ref><p3><mf><pl>')  { $tag = "R ref e p 3" } # o-unan
  elsif ($tags eq '<prn><itg><mf><sp>')      { $tag = "R itg e sp" }  # petra, piv
  elsif ($tags eq '<prn><itg><mf><pl>')      { $tag = "R itg e p" }   # pere
  elsif ($tags eq '<prn><dem><m><sg>')       { $tag = "R dem m s" }   # hemañ
  elsif ($tags eq '<prn><dem><f><sg>')       { $tag = "R dem f s" }   # homañ
  elsif ($tags eq '<prn><dem><mf><sg>')      { $tag = "R dem e s" }   # se
  elsif ($tags eq '<prn><ind><mf><sg>')      { $tag = "R ind mf s" }  # hini
  elsif ($tags eq '<prn><ind><mf><pl>')      { $tag = "R ind mf p" }  # re
  elsif ($tags eq '<prn><def><mf><sg>')      { $tag = "R def e s" }   # henn
  elsif ($tags eq '<prn><def><m><sg>')       { $tag = "R def m s" }   # egile
  elsif ($tags eq '<prn><def><f><sg>')       { $tag = "R def f s" }   # eben

  # Pronouns object.
  elsif ($tags eq '<prn><obj><p1><mf><sg>') { $tag = "R e s 1 obj" } # ma, va
  elsif ($tags eq '<prn><obj><p1><mf><pl>') { $tag = "R e p 1 obj" } # hon, hor, hol
  elsif ($tags eq '<prn><obj><p2><mf><sg>') { $tag = "R e s 2 obj" } # az
  elsif ($tags eq '<prn><obj><p2><mf><pl>') { $tag = "R e p 2 obj" } # ho
  elsif ($tags eq '<prn><obj><p3><m><sg>')  { $tag = "R m s 1 obj" } # e
  elsif ($tags eq '<prn><obj><p3><f><sg>')  { $tag = "R f s 1 obj" } # he
  elsif ($tags eq '<prn><obj><p3><mf><pl>') { $tag = "R e p 3 obj" } # o

  # Numbers.
  elsif ($tags eq '<num><mf><sg>') { $tag = "K e s" }
  elsif ($tags eq '<num><m><pl>')  { $tag = "K m p" }
  elsif ($tags eq '<num><f><pl>')  { $tag = "K f p" }
  elsif ($tags eq '<num><mf><pl>') { $tag = "K e p" }

  # Ordinal numbers.
  elsif ($tags eq '<num><ord><mf><sp>')   { $tag = "K e sp o" }
  elsif ($tags eq '<num><ord><mf><sg>')   { $tag = "K e s o" }
  elsif ($tags eq '<num><ord><mf><pl>')   { $tag = "K e p o" }
  elsif ($tags eq '<num><ord><m><pl>')    { $tag = "K m p o" }
  elsif ($tags eq '<num><ord><m><sp>')    { $tag = "K m sp o" }
  elsif ($tags eq '<num><ord><f><pl>')    { $tag = "K f p o" }

  # Indirect preposition.
  elsif ($tags eq '<pr>')                                { $tag = "P" }        # da
  elsif ($tags eq '<pr>+indirect<prn><obj><p1><mf><sg>') { $tag = "P e 1 s" }  # din
  elsif ($tags eq '<pr>+indirect<prn><obj><p2><mf><sg>') { $tag = "P e 2 s" }  # dit
  elsif ($tags eq '<pr>+indirect<prn><obj><p3><m><sg>')  { $tag = "P m 3 s" }  # dezhañ
  elsif ($tags eq '<pr>+indirect<prn><obj><p3><f><sg>')  { $tag = "P f 3 s" }  # dezhi
  elsif ($tags eq '<pr>+indirect<prn><obj><p1><mf><pl>') { $tag = "P e 1 p" }  # dimp
  elsif ($tags eq '<pr>+indirect<prn><obj><p2><mf><pl>') { $tag = "P e 2 p" }  # deoc’h
  elsif ($tags eq '<pr>+indirect<prn><obj><p3><mf><pl>') { $tag = "P e 3 p" }  # dezho
  elsif ($tags =~ /<pr>.*/)                              { $tag = "P" }        # er, ez

  # Nouns.
  elsif ($tags eq '<n><m><sg>')  { $tag = "N m s" }
  elsif ($tags eq '<n><m><pl>')  { $tag = "N m p" }
  elsif ($tags eq '<n><f><sg>')  { $tag = "N f s" }
  elsif ($tags eq '<n><f><pl>')  { $tag = "N f p" }
  elsif ($tags eq '<n><mf><sg>') { $tag = "N e s" }
  elsif ($tags eq '<n><mf><pl>') { $tag = "N e p" }
  elsif ($tags eq '<n><m><sp>')  { $tag = "N m sp" }

  # Proper nouns.
  elsif ($tags eq '<np><top><sg>')     { $tag = "Z e s top" }  # Aostria
  elsif ($tags eq '<np><top><pl>')     { $tag = "Z e p top" }  # Azorez
  elsif ($tags eq '<np><top><m><sg>')  { $tag = "Z m s top" }  # Kreiz-Breizh
  elsif ($tags eq '<np><cog><mf><sg>') { $tag = "Z e s cog" }
  elsif ($tags eq '<np><ant><m><sg>')  { $tag = "Z m s ant" }  # Alan
  elsif ($tags eq '<np><ant><f><sg>')  { $tag = "Z f s ant" }  # Youna
  elsif ($tags eq '<np><al><mf><sg>')  { $tag = "Z e s al" }   # Leclerc
  elsif ($tags eq '<np><al><m><sg>')   { $tag = "Z m s al" }   # Ofis
  elsif ($tags eq '<np><al><f><sg>')   { $tag = "Z f s al" }   # Bibl

  elsif ($tags eq '<n><acr><m><sg>')   { $tag = "S m s" }      # TER

  # Verbs.
  elsif ($tags eq '<vblex><inf>')             { $tag = "V inf" } # komz
  elsif ($tags eq '<vblex><pp>')              { $tag = "V ppa" } # komzet

  # Present
  elsif ($tags eq '<vblex><pri><p1><sg>')     { $tag = "V pres 1 s" }       # komzan
  elsif ($tags eq '<vblex><pri><p2><sg>')     { $tag = "V pres 2 s" }       # komzez
  elsif ($tags eq '<vblex><pri><p3><sg>')     { $tag = "V pres 3 s" }       # komz
  elsif ($tags eq '<vblex><pri><p1><pl>')     { $tag = "V pres 1 p" }       # komzomp
  elsif ($tags eq '<vblex><pri><p2><pl>')     { $tag = "V pres 2 p" }       # komzit
  elsif ($tags eq '<vblex><pri><p3><pl>')     { $tag = "V pres 3 p" }       # komzont
  elsif ($tags eq '<vblex><pri><impers><sp>') { $tag = "V pres impers sp" } # komzer
  elsif ($tags eq '<vblex><pri><impers><pl>') { $tag = "V pres impers p" }  # oad

  # Imperfect.
  elsif ($tags eq '<vblex><pii><p1><sg>')     { $tag = "V impa 1 s" }        # komzen
  elsif ($tags eq '<vblex><pii><p2><sg>')     { $tag = "V impa 2 s" }        # komzes
  elsif ($tags eq '<vblex><pii><p3><sg>')     { $tag = "V impa 3 s" }        # komze
  elsif ($tags eq '<vblex><pii><p1><pl>')     { $tag = "V impa 1 p" }        # komzemp
  elsif ($tags eq '<vblex><pii><p2><pl>')     { $tag = "V impa 2 p" }        # komzec’h
  elsif ($tags eq '<vblex><pii><p3><pl>')     { $tag = "V impa 3 p" }        # komzent
  elsif ($tags eq '<vblex><pii><impers><sp>') { $tag = "V impa impers sp" }  # komzed
  elsif ($tags eq '<vblex><pii><impers><pl>') { $tag = "V impa impers p" }   # oad

  # Past definite.
  elsif ($tags eq '<vblex><past><p1><sg>')    { $tag = "V pass 1 s" }        # komzis
  elsif ($tags eq '<vblex><past><p2><sg>')    { $tag = "V pass 2 s" }        # komzjout
  elsif ($tags eq '<vblex><past><p3><sg>')    { $tag = "V pass 3 s" }        # komzas
  elsif ($tags eq '<vblex><past><p1><pl>')    { $tag = "V pass 1 p" }        # komzjomp
  elsif ($tags eq '<vblex><past><p2><pl>')    { $tag = "V pass 2 p" }        # komzjoc’h
  elsif ($tags eq '<vblex><past><p3><pl>')    { $tag = "V pass 3 p" }        # komzjont
  elsif ($tags eq '<vblex><past><impers><sp>'){ $tag = "V pass impers sp" }  # komzod
  elsif ($tags eq '<vblex><past><impers><pl>'){ $tag = "V pass impers pl" }  # poed

  # Future.
  elsif ($tags eq '<vblex><fti><p1><sg>')     { $tag = "V futu 1 s" }        # komzin
  elsif ($tags eq '<vblex><fti><p2><sg>')     { $tag = "V futu 2 s" }        # komzi
  elsif ($tags eq '<vblex><fti><p3><sg>')     { $tag = "V futu 3 s" }        # komzo
  elsif ($tags eq '<vblex><fti><p1><pl>')     { $tag = "V futu 1 p" }        # komzimp
  elsif ($tags eq '<vblex><fti><p2><pl>')     { $tag = "V futu 2 p" }        # komzot
  elsif ($tags eq '<vblex><fti><p3><pl>')     { $tag = "V futu 3 p" }        # komzint
  elsif ($tags eq '<vblex><fti><impers><sp>') { $tag = "V futu impers sp" }  # komzor
  elsif ($tags eq '<vblex><fti><impers><pl>') { $tag = "V futu impers p" }   # pior

  # Conditional.
  elsif ($tags eq '<vblex><cni><p1><sg>')     { $tag = "V conf 1 s" }        # komzfen
  elsif ($tags eq '<vblex><cni><p2><sg>')     { $tag = "V conf 2 s" }        # komzfes
  elsif ($tags eq '<vblex><cni><p3><sg>')     { $tag = "V conf 3 s" }        # komzfe
  elsif ($tags eq '<vblex><cni><p1><pl>')     { $tag = "V conf 1 p" }        # komzfemp
  elsif ($tags eq '<vblex><cni><p2><pl>')     { $tag = "V conf 2 p" }        # komzfec’h
  elsif ($tags eq '<vblex><cni><p3><pl>')     { $tag = "V conf 3 p" }        # komzfent
  elsif ($tags eq '<vblex><cni><impers><sp>') { $tag = "V conf impers sp" }  # komzfed
  elsif ($tags eq '<vblex><cni><impers><pl>') { $tag = "V conf impers p" }

  # Conditional.
  elsif ($tags eq '<vblex><cip><p1><sg>')     { $tag = "V conj 1 s" }       # komzjen
  elsif ($tags eq '<vblex><cip><p2><sg>')     { $tag = "V conj 2 s" }       # komzjes
  elsif ($tags eq '<vblex><cip><p3><sg>')     { $tag = "V conj 3 s" }       # komzje
  elsif ($tags eq '<vblex><cip><p1><pl>')     { $tag = "V conj 1 p" }       # komzjemp
  elsif ($tags eq '<vblex><cip><p2><pl>')     { $tag = "V conj 2 p" }       # komzjec’h
  elsif ($tags eq '<vblex><cip><p3><pl>')     { $tag = "V conj 3 p" }       # komzjent
  elsif ($tags eq '<vblex><cip><impers><sp>') { $tag = "V conj impers sp" } # komzjed
  elsif ($tags eq '<vblex><cip><impers><pl>') { $tag = "V conj impers p" }  # komzjed

  # Imperative.
  elsif ($tags eq '<vblex><imp><p2><sg>')     { $tag = "V impe 2 s" }     # komz
  elsif ($tags eq '<vblex><imp><p3><sg>')     { $tag = "V impe 3 s" }     # komzet
  elsif ($tags eq '<vblex><imp><p1><pl>')     { $tag = "V impe 1 p" }     # komzomp
  elsif ($tags eq '<vblex><imp><p2><pl>')     { $tag = "V impe 2 p" }     # komzit
  elsif ($tags eq '<vblex><imp><p3><pl>')     { $tag = "V impe 3 p" }     # komzent

  # Present, habitual.
  elsif ($tags eq '<vblex><prh><p1><sg>')     { $tag = "V preh 1 s" }        # pezan
  elsif ($tags eq '<vblex><prh><p2><sg>')     { $tag = "V preh 2 s" }        # pezez
  elsif ($tags eq '<vblex><prh><p3><sg>')     { $tag = "V preh 3 s" }        # pez
  elsif ($tags eq '<vblex><prh><p1><pl>')     { $tag = "V preh 1 p" }        # pezomp
  elsif ($tags eq '<vblex><prh><p2><pl>')     { $tag = "V preh 2 p" }        # pezit
  elsif ($tags eq '<vblex><prh><p3><pl>')     { $tag = "V preh 3 p" }        # pezont
  elsif ($tags eq '<vblex><prh><impers><pl>') { $tag = "V preh impers p" }   # pezer

  # Imperfect, habitual.
  elsif ($tags eq '<vblex><pih><p1><sg>')     { $tag = "V imph 1 s" }     # bezen
  elsif ($tags eq '<vblex><pih><p2><sg>')     { $tag = "V imph 2 s" }     # pezen
  elsif ($tags eq '<vblex><pih><p3><sg>')     { $tag = "V imph 3 s" }     # peze
  elsif ($tags eq '<vblex><pih><p1><pl>')     { $tag = "V imph 1 p" }     # pezemp
  elsif ($tags eq '<vblex><pih><p2><pl>')     { $tag = "V imph 2 p" }     # pezec’h
  elsif ($tags eq '<vblex><pih><p3><pl>')     { $tag = "V imph 3 p" }     # pezent
  elsif ($tags eq '<vblex><pih><impers><pl>') { $tag = "V imph impers" }  # pezed

  # present, locative.
  elsif ($tags eq '<vbloc><pri><p1><sg>')     { $tag = "V prel 1 s" }     # emaoñ
  elsif ($tags eq '<vbloc><pri><p2><sg>')     { $tag = "V prel 2 s" }     # emaout
  elsif ($tags eq '<vbloc><pri><p3><sg>')     { $tag = "V prel 3 s" }     # emañ
  elsif ($tags eq '<vbloc><pri><p1><pl>')     { $tag = "V prel 1 p" }     # emaomp
  elsif ($tags eq '<vbloc><pri><p2><pl>')     { $tag = "V prel 2 p" }     # emaoc’h
  elsif ($tags eq '<vbloc><pri><p3><pl>')     { $tag = "V prel 3 p" }     # emaint
  elsif ($tags eq '<vbloc><pri><impers><sp>') { $tag = "V prel impers" }  # emeur

  # Imperfect, locative.
  elsif ($tags eq '<vbloc><pii><p1><sg>')     { $tag = "V impl 1 s" }     # edon
  elsif ($tags eq '<vbloc><pii><p2><sg>')     { $tag = "V impl 2 s" }     # edos
  elsif ($tags eq '<vbloc><pii><p3><sg>')     { $tag = "V impl 3 s" }     # edo
  elsif ($tags eq '<vbloc><pii><p1><pl>')     { $tag = "V impl 1 p" }     # edomp
  elsif ($tags eq '<vbloc><pii><p2><pl>')     { $tag = "V impl 2 p" }     # edoc’h
  elsif ($tags eq '<vbloc><pii><p3><pl>')     { $tag = "V impl 3 p" }     # edont
  elsif ($tags eq '<vbloc><pii><impers><sp>') { $tag = "V impl impers" }  # emod

  # Words that we tag as "epicene" (both masculine, feminine)
  # even though Apertium does not tag them with both gender.
  # There are probably many other such words that could be added
  # here. I add them one by one as I stumbled upon them.
  if (($lemma eq 'barzhoneg' and $word =~ /^[bpv]arzhoneg(où)?$/)   or
      ($lemma eq 'boaz'      and $word =~ /^[bpv]boaz(ioù)?$/)      or
      ($lemma eq 'breserezh' and $word =~ /^[bpv]reserezh(ioù)?$/)  or
      ($lemma eq 'bruched'   and $word =~ /^[bpv]vruched(où)?$/)    or
      ($lemma eq 'brud'      and $word =~ /^[bpv]brud$/)            or
      ($lemma eq 'froud'     and $word =~ /^froud(où)?$/)           or
      ($lemma eq 'kurun'     and $word =~ /^([kg]|c’h)urun(où)?$/)  or
      ($lemma eq 'ment'      and $word =~ /^[mv]ent$/)              or
      ($lemma eq 'peskerezh' and $word =~ /^[bfp]eskerezh$/)        or
      ($lemma eq 'siminal'   and $word =~ /^siminal(ioù)?$/)        or
      ($lemma eq 'trubuilh'  and $word =~ /^[tdz]rubuilh(où)?$/)) {
    $tag =~ s/^N [fm]/N e/;
  }

  if (exists $anv_lies_tud{$word} or $word =~ /[A-Z].*iz$/) {
    if ($tag =~ /^N m p/) {
      $tag .= ' t';
      ++$anv_lies_tud{$word};
    } elsif ($tag =~ /^N/) {
      print STDERR "Anv-tud lies [$word] a zo [$tag] en Apertium. Fazi?\n";
    }
  }

  my ($first_letter_lemma) = $lemma =~ /^(gw|[ktpgdbm]).*/i;
  $first_letter_lemma = "" unless defined $first_letter_lemma;
  my ($first_letter_word) = $word  =~ /^([kg]w|c’h|[gdbzfktvpw]).*/i;
  $first_letter_word = "" unless defined $first_letter_word;
  $first_letter_lemma = lc $first_letter_lemma;
  $first_letter_word  = lc $first_letter_word;

  if    ($lemma eq 'kaout' and $word !~ /.*aout/) { }
  elsif ($word  eq 'tud')    { }
  elsif ($word  eq 'dud')    { $tag .= " M:1:1a" }
  elsif ($word  eq 'zud')    { $tag .= " M:2:" }
  elsif ($word  eq 'diweuz') { }
  elsif ($word  eq 'tiweuz') { $tag .= " M:3:" }
  elsif ($word  eq 'ziweuz') { $tag .= " M:1:1b:" }
  elsif ($word =~ /^kezeg-?(koad|mor|blein)?$/)   { }
  elsif ($word =~ /^gezeg-?(koad|mor|blein)?$/)   { $tag .= " M:1:1a:" }
  elsif ($word =~ /^c’hezeg-?(koad|mor|blein)?$/) { $tag .= " M:2:" }
  elsif ($word =~ /^daou(ividig|lin|lagad|ufern)$/) { }
  elsif ($word =~ /^taou(ividig|lin|lagad|ufern)$/) { $tag .= " M:3:" }
  elsif ($word =~ /^zaou(ividig|lin|lagad|ufern)$/) { $tag .= " M:1:1b:" }
  elsif ($word =~ /^div(abrant|c’har|esker|lez|rec’h|ronn|orzhed|jod|skoaz|skouarn)$/) { }
  elsif ($word =~ /^tiv(abrant|c’har|esker|lez|rec’h|ronn|orzhed|jod|skoaz|skouarn)$/) { $tag .= " M:3:" }
  elsif ($word =~ /^ziv(abrant|c’har|esker|lez|rec’h|ronn|orzhed|jod|skoaz|skouarn)$/) { $tag .= " M:1:1b:" }
  elsif ($lemma =~ /^gou[ei]/i) {
    if  ($word  =~ /^ou[ei]/i) { $tag .= " M:1:1a:1b:4:" }
    elsif ($first_letter_word  eq 'k')   { $tag .= " M:3:" }
    elsif ($first_letter_word  eq 'c’h') { $tag .= " M:4:" }
  } elsif ($first_letter_lemma and
           $first_letter_word  and
           $first_letter_lemma ne $first_letter_word and
           !($first_letter_lemma eq 'k' and $first_letter_word eq 'kw')) {
    # Add mutation tag.
    if      ($first_letter_lemma eq 'k') {
      if    ($first_letter_word  eq 'c’h')      { $tag .= " M:0a:2:" }
      elsif ($first_letter_word  eq 'g')        { $tag .= " M:1:1a:" }
      elsif ($first_letter_word  eq 'gw')       { $tag .= " M:1:1a:" }
    } elsif ($first_letter_lemma eq 't')        {
      if    ($first_letter_word  eq 'd')        { $tag .= " M:1:1a:" }
      elsif ($first_letter_word  eq 'z')        { $tag .= " M:2:" }
    } elsif ($first_letter_lemma eq 'p')        {
      if    ($first_letter_word  eq 'b')        { $tag .= " M:1:1a:" }
      elsif ($first_letter_word  eq 'f')        { $tag .= " M:2:" }
    } elsif ($first_letter_lemma eq 'gw')       {
      if    ($first_letter_word  eq 'w')        { $tag .= " M:1:1a:1b:4:" }
      elsif ($first_letter_word  eq 'kw')       { $tag .= " M:3:" }
      elsif ($first_letter_word  eq 'c’h')      { $tag .= " M:4:" }
    } elsif ($first_letter_lemma eq 'g')        {
      if    ($first_letter_word  eq 'c’h')      { $tag .= " M:1:1a:1b:4:" }
      elsif ($first_letter_word  eq 'k')        { $tag .= " M:3:" }
    } elsif ($first_letter_lemma eq 'd')        {
      if    ($first_letter_word  eq 'z')        { $tag .= " M:1:1b:4:" }
      elsif ($first_letter_word  eq 't')        { $tag .= " M:3:4:" }
    } elsif ($first_letter_lemma eq 'b')        {
      if    ($first_letter_word  eq 'v')        { $tag .= " M:1:1a:1b:4:" }
      elsif ($first_letter_word  eq 'p')        { $tag .= " M:3:" }
    } elsif ($first_letter_lemma eq 'm')        {
      if    ($first_letter_word  eq 'v')        { $tag .= " M:1:1a:1b:4:" }
    }
    unless ($tag =~ /:$/) {
      print STDERR "*** unexpected mutation [$first_letter_lemma] -> "
                 . "[$first_letter_word] lemma=[$lemma][$first_letter_lemma] "
                 . "-> word=[$word][$first_letter_word] tag=[$tag]\n";
    }
  }
  if ($tag) {
    print OUT "$word\t$lemma\t$tag\n";
    ++$out_count;

    if ($tag =~ /^Z / and $word =~ /^[A-Z]/ and $tag =~ / M:/) {
      if ($word =~ /^G/ and $lemma =~ /^K/) {
        print OUT "g$lemma\t$lemma\t$tag\n"; # add entries such as gKemper.
      } elsif ($word =~ /^C’h/ and $lemma =~ /^(K|G[^w])/) {
        print OUT "c’h$lemma\t$lemma\t$tag\n"; # add entries such as c’hKemper.
      } elsif ($word =~ /^D/ and $lemma =~ /^T/) {
        print OUT "d$lemma\t$lemma\t$tag\n"; # add entries such as dThomas.
      } elsif ($word =~ /^Z/ and $lemma =~ /^[DT]/) {
        print OUT "z$lemma\t$lemma\t$tag\n"; # add entries such as zThomas.
      } elsif ($word =~ /^B/ and $lemma =~ /^P/) {
        print OUT "b$lemma\t$lemma\t$tag\n"; # add entries such as bPariz.
      } elsif ($word =~ /^F/ and $lemma =~ /^P/) {
        print OUT "f$lemma\t$lemma\t$tag\n"; # add entries such as fPariz.
      } elsif ($word =~ /^V/ and $lemma =~ /^[BM]/) {
        print OUT "v$lemma\t$lemma\t$tag\n"; # add entries such as vBrest.
      } elsif ($word =~ /^P/ and $lemma =~ /^B/) {
        print OUT "p$lemma\t$lemma\t$tag\n"; # add entries such as pBrest.
      } elsif ($word =~ /^T/ and $lemma =~ /^D/) {
        print OUT "t$lemma\t$lemma\t$tag\n"; # add entries such as tDakar.
      } elsif ($word =~ /^K/ and $lemma =~ /^G[^w]/) {
        print OUT "k$lemma\t$lemma\t$tag\n"; # add entries such as kGauguin.
      }
    }
  } else {
    print ERR "$_ -> word=$word lemma=$lemma tags=$tags\n";
    ++$err_count;
  }
}
print "handled [$out_count] words, unhandled [$err_count] words\n";

# Adding missing words in dictionary.
# "kiz" exists only in expressions in Apertium (which is OK) but
# for LanguageTool, it's easier to make it a normal word so we
# don't give false positive on "war ho c’hiz", etc.
print OUT "kiz\tkiz\tN f s\n";
print OUT "c’hiz\tkiz\tN f s M:0a:2:\n";
print OUT "giz\tkiz\tN f s M:1:1a:\n";
print OUT "vaerioù\tmaer\tN m p M:1:1a:1b:4:\n";
print OUT "maerioù\tmaer\tN m p\n";
print OUT "vestroù\tmestr\tN m p M:1:1a:1b:4:\n";
print OUT "mestroù\tmestr\tN m p\n";
close(OUT) or die "can't close [$dic_out]\n";

print "Lemma words missing from dictionary:\n";
foreach (sort keys %all_lemmas) { print "$_\n" unless exists $all_words{$_}; }

# Check whether some words in anv_lies_tud have are missing in dictionary.
foreach (sort keys %anv_lies_tud) {
  print STDERR "*** plural noun [$_] is missing in Apertium dictionary.\n" unless $anv_lies_tud{$_};
}

`java -jar morfologik-stemming-nodict-1.4.0.jar tab2morph -i $dic_out -o output.txt`;
`java -jar morfologik-stemming-nodict-1.4.0.jar fsa_build -i output.txt -o breton.dict`;

# Create the list of unique tags.
my %all_tags;
open(OUT, "< $dic_out") or die "can't open $dic_out: $!\n";
while (<OUT>) {
  my $tag = (split('\t', $_))[-1];
  ++$all_tags{$tag};
}
close(OUT) or die "can't close [$dic_out]\n";
open(ALL_TAGS, "> all_tags.txt") or die "can't open [all_tags]: $!\n";
print "# freq  tag\n";
foreach (sort keys %all_tags) {
  print ALL_TAGS $all_tags{$_}, "\t$_";
}
close(ALL_TAGS) or die "can't close [all_tags.txt]\n";

print "Created [$out_count] words, unhandled [$err_count] words\n";
