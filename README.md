# Hyp-test

_Edgar Gonzàlez i Pellicer, 2006-2025_

This tool performs hypothesis testing for statistical comparison of methods over
multiple datasets, using the approaches described in:

*   Janez Demsar \
    _Statistical Comparisons of Classifiers over Multiple   Data Sets_ \
    Journal of Machine Learning Research, 7, pp. 1–30, 2006

*   Salvador García, Francisco Herrera \
    _An Extension on 'Statistical Comparisons of Classifiers over Multiple Data
    Sets' for All Pairwise Comparisons_ \
    Journal of Machine Learning Research, 9, pp. 2677–2694, 2008

# Usage

## Requirements

The tools depend on the mathematical library of the
[R language](https://www.r-project.org/), which on Debian/Ubuntu distributions
can be installed from the `r-mathlib` package:

```sh
sudo apt install r-mathlib
```

Even though the library is wrapped using [SWIG](http://swig.org/), the tool is
not needed unless [`lib/Math/R.i`](lib/Math/R.i) is updated and the files
generated from it need to be updated.

## Building and installation

The tool can be built with:

```sh
perl Makefile.PL
make
```

Optionally, it can be installed system-wide using:

```sh
sudo make install
```

However, that last step is not needed if the `blib` module is used (see below).

## Input format

Input data is expected to be provided as space-separated columns:

```
            <method_1>  <method_2>  ...
[dataset_1] <metric_11> <metric_12> ...
[dataset_2] <metric_21> <metric_22> ...
...
```

The `[dataset_i]` names are optional, as controlled by the `--named` flag (see
below).

## Invocation

The tool can be invoked once installed as:

```sh
hyp-test [options] [input.dat] ... > <output.svg>
```

If multiple input files are provided, they will be concatenated (but only the
first one will be assumed to contain the method names). If none is provided,
standard input will be used. This follows the convention of the [`ARGV` file
handler](https://perldoc.perl.org/variables/ARGV) in Perl.

If system-wide installation is not desired, it can be invoked after building
from the source folder using the `blib` module:

```sh
perl -Mblib blib/script/hyp-test [options] [input.dat] > <output.svg>
```

A sample dataset is included for testing, taken from García and Herrera (2008),
and can be used by providing the `--test` option, e.g.:

```sh
perl -Mblib blib/script/hyp-test --test > /tmp/test.svg
```

## Output format

Output is generated as an SVG document on standard output. The document page
does not match the location of its contents, but that can be fixed for instance
using [Inkscape](http://inkscape.org/):

```sh
perl -Mblib blib/script/hyp-test --test \
    | inkscape --pipe --export-area-drawing --export-filename=- \
    > /tmp/test.svg
```

## Options

The following options control the tool:

*   `--bergmann / --hommel` \
    `--bonferroni / --dunn` \
    `--hochberg` \
    `--holm` \
    `--nemenyi` \
    `--schaffer`

    Selects the test to be applied (default is **Nemenyi**). See the
    publications for details.

*   `--against <name>` \
    `--all`

    Selects a single method to make the comparison (using its name as provided
    in the input file), or all-vs-all (default is **all-vs-all**).

*   `--alpha <level>`

    Sets the test significance level (default is **0.10**).

*   `--bh-exhaustive` \
    `--bh-online`

    Use exhaustive set generation or online strategy for the Bergmann-Hommel
    test (default is **online**).

*   `--bh-perl` \
    `--bh-xs`

    Use the Perl or XS code for exhaustive set generation for the
    Bergmann-Hommel test (default is **XS**).

*   `--named` \
    `--no-named`

    Specifies if row names are included as first field in the input (default is
    **not**)

*   `--reverse` \
    `--no-reverse`

    Sets the reversal of the scale (highest values first) (default is **not**).

*   `--title <title>` \
    `--no-title`

    Sets the title for the plot (default is **none**).

*   `--verbose` \
    `--no-verbose`

    Sets the verbosity mode (default is **not**).

*   `--test` \
    `--no-test`

    Uses the sample test data from García and Herrera (2008) (default is
    **not**).

This information can also be obtained with the `--help` option.
