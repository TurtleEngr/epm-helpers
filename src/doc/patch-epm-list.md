(c) Copyright 2006

# NAME

patch-epm-list - patch up generated epm lists

# SYNOPSIS

        patch-epm-list -f[ile] PATCH-FILE [-h[elp]] [-d[ebug] N]
                <EPMFILE >NEW-EPMFILE

# DESCRIPTION

Process the EPMFILE, from stdin, and output the results to stdout.
The PATCH-FILE is a perl file that defines the files that need
special processing.  See the FILE section for the syntax details.

'\\$' in the file are replaced with '$$'.

# OPTIONS

- **-file FILE**

    This is the config file for the patch-epm-list script.  It should
    be executable.  See the FILE section for the syntax details.

- **-help**

    This help.

- **-debug**

    If the debug level is set to 5 or more, debug text will be output to
    stderr.

# EXAMPLES

    File: epm.patch contains:
           $pConf{"/etc/hosts"} = 1;
           $pConf{"/etc/php.ini"} = 1;
           $pDel{"/usr"} = 1;
           $pDel{"/usr/local"} = 1;
           $pOwner{"/var/www/html"} = "apache apache";
           $pPerm{"/etc/php.ini"} = "310";
           $pNoStrip{"/usr/lib/libacl.a"} = 1;
    chmod a+rx epm.patch

    mkepmlist -u root -g root --prefix / dist | \
      patch-epm-list -f ./epm.patch >epm.list

# FILES

Config File:

- **$pConf{"FILE"} = 1;**

    If the fifth field matches any of the FILE keys, then these lines will
    have the leading 'f' changed to a 'c'.

- **$pDel{"FILE"} = 1;**

    If the fifth field matches any of the FILE keys, then these lines will
    not be output (i.e. they will be deleted).

- **$pNoStrip{"FILE"} = 1;**

    If the fifth field matches any of the FILE keys, then those lines will
    have "nostrip()" appended.

- B$pOwner{"/var/www/html"} = "USER GROUP";>

    If the fifth field matches a FILE key, then the user and group will be
    changed for that line.

- **$pPerm{"FILE"} = "MODE";**

    If the fifth field matches a FILE key, then the permissions will be
    changed for that line.  MODE is the octal format.

# SEE ALSO

mkver.pl(1), epm(1), epminstall(1), mkepmlist(1), epm.list(5)

mkepmlist, epm

# Notes

This isn't the only way to filter the epm.list file. awk is maybe a
more more direct way to filter the epm list file.

For exmaple:

    mkepmlist -u root -g root --prefix / dist | \
        awk '
            $1 == 'd' && $5 == "/usr"  { next } 
            $1 == 'd' && $5 == "/usr/local"  { next } 
            $1 == 'd' && $5 == "/usr/local/bin"  { next } 
            { print $0 }
        ' >epm.list

# AUTHOR

TurtleEngr

# HISTORY

(c) Copyright 2006
