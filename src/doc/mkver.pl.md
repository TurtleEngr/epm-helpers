# NAME

myver.pl

# SYNOPSIS

        mkver.pl [-h] [-d DEF] [-e 'EXT EXT ...']

# DESCRIPTION

mkver.pl is used to create standard include files, to define release
variables, which are used to categorize and version a module or tool.
Its main purpose is to normalized all of names and categorizations
that are related to a product, and to provide one place for updating
this information.

Currently output files are:

        ver.cs - C# constants file
        ver.env - bash shell definitions (use in Makefiles and scripts)
        ver.epm - EPM package include file
        ver.h - C include file
        ver.java - Java include file
        ver.mak - Makefile include file
        ver.pl - Perl include file
        ver.xml - XML file

If the DEF file is not found, a default DEF file, ver.sh, is created.

The generated files will be put in the current directory.  A (EXT)File
variable can be defined for each EXT extention, to define the path and
the name for each of the output files.

Other extention related variable can be defined to specify header and
footer text that should be output for each EXT: (EXT)Header,
(EXT)Footer.

The simplest way to see the default definitions and variable
transformations is to run mkver.pl, and specify a DEF file that
doesn't exist.  You can then look at the DEF file that was created,
and at the generated files.

# OPTIONS

- **-h|-help**

    This help

- **-d|-def DEF**

    Path and name of the master version definition file (DEF).  The
    basename part of the file name will be used for the basename of the
    version include files.

        Default: ./ver.sh
        Default basename: ver

- **-e|-extension EXT**

    A space separated list of extentions, that will be generated.  If no
    \-e option is used, then all files will be generated.

        Default: -e 'cs env epm h java mak pl xml'

- **-v|-verbose**

    Output warnings and notices.  Errors will always be output.

- **-x debug**

    Output debug messages.

# ERRORS

- If "ERROR" appears in an output file or in the default input file,
this is a required variable that has to be manually defined.
- Error: Syntax problem with: VARIABLE

    The named variable has a syntax error.

- Error: Could not find directory: DIR

    The DIR specified for an output file, can not be found.  Fix the
    (EXT)File variable's definition, and create the directory

- Error: mkcver or the definition file needs to be updated.
- Warning: Could not find file: VARIABLE (FILE)"

    Either fix the variable definition, create the file, or clear the
    definition.

# EXAMPLES

How the variables RELEASE and ProdRC affect %packager and %release
values in the "epm" file.

    export RELEASE=0; mkver.pl -d ver.sh -e epm

        %packager [setting in ver.sh]
        %release test.$ProdBuildTime

    export RELEASE=1; mkver.pl -d ver.sh -e epm

        %packager RE
        if $ProdRC is not empty,
            %release rc.$ProdRC
        else
            %release $ProdBuild

# ENVIRONMENT

$RELEASE, $USER

# FILES

Input:
        ver.sh or -d DEF.sh

Output:
        ver.EXT files

# SEE ALSO

patch-emp-list(1), epm(1), epminstall(1), mkepmlist(1), epm.list(5)

# AUTHOR

TurtleEngr

# HISTORY

MkVer=2.2
