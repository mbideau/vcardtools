# vcardtools
Automatically fix, convert, split, normalize, group, merge, deduplicate vCard and VCF files (even large ones).

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

Optional, recommanded (to get phone numbers normalization and matching), library :
```
pip3 install phonenumbers
```

## Usage

Run `python3 vcardtools.py --help`.

```
usage: vcardtools.py [-h] [-g] [-m] [-x] [-c] [-n] [-f] [-a MATCH_ATTRIBUTES]
                     [-t MATCH_RATIO] [-i MATCH_MIN_LENGTH]
                     [-d MATCH_MAX_DISTANCE] [-1] [-s]
                     [--move-name-extra-info-to-note]
                     [--no-remove-name-in-email] [--do-not-force-escape-comas]
                     [-l {DEBUG,INFO,WARNING,ERROR,CRITICAL}]
                     [--no-match-phone] [--no-phone-normalization]
                     [--phone-country-abbrv PHONE_COUNTRY_ABBRV]
                     [--no-phone-invalid-warn]
                     DESTDIR FILES [FILES ...]

Automatically fix / convert / split / normalize / group / merge / deduplicate
vCard and VCF files from version 2.1 to 3.0 (even large ones).

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
                        Use those attributes to match vCards. Two vCards
                        matches when at least one of those attributes match.
                        Specials attributes: 'names' is an alias for 'fn'+'n'
                        and 'mobiles' for 'tel'+filter by phone number.
                        Default is: ['names', 'tel_!work', 'email']. Use the
                        argument multiple times to specify multiple values.
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
  --no-match-phone      Disable matching by phone numbers.
  --no-phone-normalization
                        Disable phone numbers normalization.
  --phone-country-abbrv PHONE_COUNTRY_ABBRV
                        Default phone country localization (when not an
                        international number).
  --no-phone-invalid-warn
                        Disable invalid phone numbers warnings.
```

## Notes

It outputs only vCard 3.0 format (with DOS line breaks), but accept 2.1 and 3.0 vCard format (even mixed).

It uses logging as output, so adjust verbosity by adjusting the log level.

It was made and tested on Linux without any knowledge of Windows environment, so it may or may not work on Windows.

It was not unit-tested, but was extensively tested with multiple real cases of all sort of different vCard/VCF files (hence the "fix" ability).


## Tips

If you already have multiple individual vCard/VCF file that you want to group/merge, just re-combine them together before running the tool. They will be re-splitted and grouped/merged.

To combine multiple vCard/VCF file into one, just do :
```
cat *.vcard >> all.vcf
```

## Examples

### Normalization of phone numbers

#### Option `--phone-country-abbrv`

In order for the normalization to function well, **you really should specify a country/region
abbreviation code**. See the
[ISO 3166-1 alpha-2 table code list](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2).  
Else it will default to '_US_' and **treat every non-international number as if it were a _US_
national one**, and being invalid (not normalized) if it is not really a _US_ one.

For example, for someone that mainly have contacts with phone number without international prefix
coming from Bangladesh country/region (like 01910-500002), the option should be specified as:
```
python3 vcardtools.py ... --phone-country-abbrv BD ...
```

### Matching/grouping cards together

#### Option `--no-match-approx`

If you do not specify that option, but you specify `--merge` or `--group`, a fuzzy search/match will always occure on name attributes (fn, n).

So if you only want to match using a single attribute _email_ and not any name attribute: use the following options :
```
python3 vcardtools.py --no-match-approx --merge --match-attributes email ...
```

#### Option `--match-attributes`

That option allow to specify which attributes will be used to consider that two (or more) vCards shoud be grouped/merged.
If one attribute matches, that's it, the vCards will be grouped/merged.

So, if you want that vCards that have same email, and same organisation to be grouped/merged, use the following options :
```
python3 vcardtools.py --no-match-approx --merge --match-attributes email --match-attributes org ...
```

## Testing

A very basic mechanism of functional testing was implemented.
To run the tests, just use :
```
test/run_some_tests.sh
```
Or to get more info :

```
DEBUG=true test/run_some_tests.sh
```

This script will do a run and compare process for every directory in the `test/cases` folder.  
It runs the _vcardtools.py_ with the sources files contained in the directory `src` of the current test case,
and output the result to a temporary directory.  
Then it compares each files in the `expected` directory of the current test case, with the files in the resulting folder.  
If files differs, the test fails.  
If the _vcardtools.py_ is supposed to fail/error, a single file name `FAILURE` should be put into the `expected` directory, containing the error message (output of the command to _stderr_).
