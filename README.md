# vcardtools
Automatically fix, split, normalize, group and merge/deduplicate vCard and VCF files (even large ones).

## Use case

### Splitting

You want to split multiple vCard/VCF files (address books) into individual vCards with the vCard name as the filename.

### Grouping

Identical to splitting, but it will group matching vCards (duplicates) into a directory with the most relevant name (the longest name found).

### Merging/Deduplicating

Identical to grouping, but instead of grouping matching vCards (duplicates) into a directory it will merge them into one unique vCard file with the most relevant name (the longest name found).


## Installation

Requires python 3 (tested with 3.4, may work with 3.2).


Clone the sources :
```
git clone https://github.com/mbideau/vcardtools.git vcardtools
```

Install packages requirements:
```
apt install --no-install-recommends python3-pip python3-venv python3-setuptools
```

Create a python virtual environment and activate it:
```
python3 -m venv vcardtools
cd vcardtools
. bin/activate
```

Install required python dependencies :
```
pip3 install wheel
pip3 install vobject
pip3 install fuzzywuzzy
```

## Usage

Run `python3 vcardtools.py`.

```
usage: vcardtools.py [-h] [-g] [-m] [-x] [-c] [-n] [-f] [-a MATCH_ATTRIBUTES]
               [-t MATCH_RATIO] [-i MATCH_MIN_LENGTH] [-d MATCH_MAX_DISTANCE]
               [-1] [-s] [--move-name-extra-info-to-note]
               [--no-remove-name-in-email]
               [-l {DEBUG,INFO,WARNING,ERROR,CRITICAL}]
               DESTDIR FILES [FILES ...]

Automatically fix, split, normalize, group and merge/deduplicate vCard and VCF files (even large ones).

positional arguments:
  DESTDIR               The directory that will contains VCF (vCard) files
                        merged. It MUST not exists already.
  FILES                 The vcf/vcard files that contains vCards.

optional arguments:
  -h, --help            show this help message and exit
  -g, --group           Group vcards that match into a directory.
  -m, --merge           Merge vcards that match into a single file.
  -x, --no-match-approx
                        Disable using approximate matching on names (note:
                        names/words order will count).
  -c, --no-fix-and-convert
                        Disable fixing invalid lines, and broken multilines
                        value, and converting from vCard 2.1 to 3.0
  -n, --no-overwrite-names
                        Do not overwrite names in the vCard, i.e.: keep 'fn'
                        and 'n' attributes untouched
  -f, --french-tweaks   Enable french tweaks (phone number '+33' converted to
                        '0', handling of the name particule ' De ').
  -a MATCH_ATTRIBUTES, --match-attributes MATCH_ATTRIBUTES
                        Use those attributes to match vCards. Specials
                        attributes: 'names' is an alias for 'fn'+'n' and
                        'mobiles' for 'tel'+filter by phone number
  -t MATCH_RATIO, --match-ratio MATCH_RATIO
                        The ratio score to match the names (see fuzzywuzzy
                        documentation). Default is: 100 (safe).
  -i MATCH_MIN_LENGTH, --match-min-length MATCH_MIN_LENGTH
                        The minimum length of string to allow an approximate
                        match. Default is: 5.
  -d MATCH_MAX_DISTANCE, --match-max-distance MATCH_MAX_DISTANCE
                        The number of character between to length of names
                        that matches. Default is: 3.
  -1, --no-match-same-first-letter
                        Do not ensure that name's first letter match when
                        doing approximate matching
  -s, --match-startswith
                        Use the startswith comparizon (using --match-max-
                        distance) when doing approximate matching
  --move-name-extra-info-to-note
                        Move name's charaecters between parentheses or braces
                        to note attribute
  --no-remove-name-in-email
                        Do not removes name in email, i.e.: keep email like
                        the following untouched: "John Doe" <john@doe.com>
  --do-not-force-escape-comas
                        Disable automatically escaping comas.
  -l {DEBUG,INFO,WARNING,ERROR,CRITICAL}, --log-level {DEBUG,INFO,WARNING,ERROR,CRITICAL}
                        the logging level in (DEBUG,INFO,WARNING,ERROR),
                        default is: INFO
```

## Notes

It outputs only vCard 3.0 format, but accept 2.1 and 3.0 vCard format (even mixed).

It uses logging as output, so adjust verbosity by adjusting the log level.

It was made and tested on Linux without any knowledge of Windows environment, so it may or may not work on Windows.

It was not unit-tested, but was extensively tested with multiple real cases of all sort of different vCard/VCF files (hence the "fix" ability).


## Tips

If you already have multiple individual vCard/VCF file that you want to group/merge, just re-combine them together before running the tool. They will be re-splitted and grouped/merged.

To combine multiple vCard/VCF file into one, just do :
```
cat *.vcard >> all.vcf
```

