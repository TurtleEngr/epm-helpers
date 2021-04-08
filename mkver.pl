#!/usr/bin/perl
use Getopt::Long;
use Env;
use File::Basename;

# -----------------------

=pod

=head1 NAME

myver.pl

=head1 SYNOPSIS

	mkver [-h] [-d DEF] [-e 'EXT EXT ...']

=head1 DESCRIPTION

mkver is used to create standard include files, to define
release variables, which are used to categorize and version a
module or tool.  Its main purpose is to normalized all of
names and categorizations that are related to a product, and
to provide one place for updating this information.

Currently output files are:

 	ver.cs - C# constants file
 	ver.env - bash shell definitions (use in Makefiles and scripts)
 	ver.epm - EPM package include file
 	ver.h - C include file
 	ver.java - Java include file
 	ver.mak - Makefile include file
 	ver.pl - Perl include file
 	ver.xml - XML file

If the DEF file is not found, a default DEF file, ver.sh, is
created.

The generated files will be put in the current directory.  A
(EXT)File variable can be defined for each EXT extention, to
define the path and the name for each of the output files.

Other extention related variable can be defined to specify
header and footer text that should be output for each EXT:
(EXT)Header, (EXT)Footer.

The simplest way to see the default definitions and variable
transformations is to run mkver, and specify a DEF file
that doesn't exist.  You can then look at the DEF file that
was created, and at the generated files.

=head1 OPTIONS

=over 4

=item B<-h elp>

This help

=item B<-d ef DEF>

Path and name of the master version definition file.
The basename part of the file name will be used to for
the basename of the version include files.

 Default: ./ver.sh
 Default basename: ver

=item B<-e xtension EXT>

A space separated list of extentions, that will be
generated.  If no -e option is used, then all files
will be generated.

 Default: -e 'env epm'

=item B<-v erbose>

Output warnings and notices.  Errors will always be output.

=item B<-x debug>

Output debug messages.

=back

=head1 RETURN VALUE

=head1 ERRORS

* If "ERROR" appears in an output file or in the default input file,
this is a required variable that has to be manually defined.


* Error: Syntax problem with: VARIABLE

The named variable has a syntax error.

* Error: Could not find directory: DIR

The DIR specified for an output file, can not be
found.  Fix the (EXT)File variable's definition,
and create the directory

* Error: mkcver or the definition file needs to be updated.

* Warning: Could not find file: VARIABLE (FILE)"

Either fix the variable definition, create the file, or clear the
definition.

=head1 EXAMPLES

=head1 ENVIRONMENT

$HOME, $RELEASED

=head1 FILES

Input:
	ver.sh or DEF.sh

Output:
	ver.EXT files

=head1 SEE ALSO

patch-emp-list(1), epm(1), epminstall(1), mkepmlist(1), epm.list(5)

=head1 NOTES

=head1 CAVEATS

=head1 DIAGNOSTICS

=head1 BUGS

=head1 RESTRICTIONS

=head1 AUTHOR

Bruce Rafnel

=head1 HISTORY

$Revision: 1.5 $

=cut

# --------------------
sub fMsg {
	# Options:
	#	$pLevel
	#		 0 - $cMsgDie, fatal error, die
	#		-1 - $cMsgErr, error
	#		-2 - $cMsgWarn, warning
	#		-3 - $cMsg, notice
	#		-4 - $cMsgV, info. output if $pVerbose
	#		1 or more - output if $pDebug >= $pLevel
	#	$pMsg - message text
	#	[$pProg] - __FILE__ 
	#	[$pLine] - __LINE__
	#	[$pFile] - output $pFile and $. if specified
	# Globals
	#	$gpDebug
	#	$gpVerbose
	# Output:
	#	warn ...
	my $pFile;
	my $pLevel;
	my $pLine;
	my $pMsg;
	my $pProg;
	my $lFile;
	my $lLoc;
	my $lMsg;
	($pLevel, $pMsg, $pProg, $pLine, $pFile) = @_;

	if ($pLevel == 0) {
		$lLevel = "Fatal Error: ";
	} elsif ($pLevel == -1) {
		$lLevel = "Error: ";
	} elsif ($pLevel == -2) {
		$lLevel = "Warning: ";
	} elsif ($pLevel == -3) {
		$lLevel = "Notice: ";
	} elsif ($pLevel == -4 && $gpVerbose) {
		$lLevel = "Info: ";
	} elsif ($pLevel >0 and $gpDebug >= $pLevel) {
		$lLevel = "Debug" . $pLevel . ": ";
	} else {
		return;
	}
	$lLoc = "";
	if ($pProg ne "") {
		$pProg =~ s/.+\///;
		$lLoc = " [" . $pProg . ":" . $pLine . "]";
	}
	$lFile = "";
	if ($pFile ne "") {
		$lFile =  " (" . $pFile . ":" . $. . ")";
	}
	chomp $pMsg;
	$lMsg = $lLevel . $pMsg . $lFile . $lLoc . "\n";
	if ($pLevel != 0) {
		warn $lMsg;
	} else {
		die $lMsg;
	}
	return;
} # fMsg

# --------------------
sub fDefEnv {
	my $pFile;
	($pFile) = @_;
	my $tVar;
	my $tValue;

	open(hFileIn, "<$pFile");
	while (<hFileIn>) {
		if (/^[\t ]*#/) {
			# Skip comments
			next;
		}
		if (/^[\t ]*$/) {
			# Skip blank lines
			next;
		}

		# Only match lines with "export"
		/[\t ]*export[\t ]+(.*)="(.*)"/;
		$tVar = $1;
		$tValue = "\"$2\"";
		$tValue = eval "$tValue";
		$$tVar = "$tValue";
	}
	close(hFileIn);
} # fDefEnv

# --------------------
sub fDefault {
	my $pVar;
	my $pValue;
	my $pDefaut;
	($pVar, $pValue, $pDefault) = @_;

	if ("$pValue" eq "") {
		&fMsg($cMsgV, "Default set: $pVar=\"$pDefault\"", __FILE__, __LINE__);
		return($pDefault);
	}
	return($pValue);
} # fDefault

# ------------------------------------------------------------------
# Main

# Global Config
$cMsgDie = 0;
$cMsgErr = -1;
$cMsgWarn = -2;
$cMsg = -3;
$cMsgV = -4;

($gSec, $gMin, $gHour, $gDay, $gMonth, $gYear, $gWDay, $gYDay, $gIsDST)
= gmtime(time);
$gYear += 1900;
++$gMonth;
if ($gMonth < 10) {
	$gMonth = "0$gMonth";
}
if ($gDay < 10) {
	$gDay = "0$gDay";
}


# Set the base version
$cgMkVerBase = "2.1";

# Set General OS type
$tOSGen = $^O;
$tOSGen =~ tr/[A-Z]/[a-z]/;
# linux
# cygwin
# mswin32
# solaris
# darwin

# Set OS Distribution and Version
if ($tOSGen eq "linux") {
	$tDist = readpipe("head -n 1 /etc/issue.net");
	chomp $tDist;
	@tDist = split(/ +/, $tDist);
	# Red Hat Enterprise Linux WS release 4 (Nahant Update 4)
	# 0   1   2          3     4  5       6 7       8      9
	# Debian GNU/Linux 3.1 %h
	# 0      1         2   3
	# CentOS release 3.3 (final)
	# 0      1       2   3
	# CentOS release 5.2 (Final) 
	# 0      1       2   3
	# Fedora Core release 4 (final)
	# 0      1    2       3 4
	# Ubuntu 14.04.4 LTS
	# 0      1       2
	if ($tDist[0] eq "Red" and $tDist[1] eq "Hat" and $tDist[2] eq "Enterprise") {
		$tOSDist = "rhes";
		$tOSVer = $tDist[6];
	} elsif ($tDist[0] eq "Debian") {
		$tOSDist = "deb";
		$tOSVer = $tDist[2];
	} elsif ($tDist[0] eq "CentOS") {
		$tOSDist = "cent";
		$tOSVer = $tDist[2];
	} elsif ($tDist[0] eq "Fedora") {
		$tOSDist = "fc";
		$tOSVer = $tDist[3];
	} elsif ($tDist[0] eq "Ubuntu") {
		$tOSDist = "ubuntu";
		$tOSVer = $tDist[1];
	} else {
		$tOSDist = $tOSGen;
		$tOSVer = "0";
	}
} elsif ($tOSGen eq "solaris") {
	$tDist = readpipe("head -n 1 /etc/release");
	chomp $tDist;
	$tDist =~ s/^ +//;
	# Solaris 10 1/06 s10x_u1wos_19a X86
	# 0       1  2    3              4
	@tDist = split(/ +/, $tDist);
	$tOSDist = "sun";
	$tOSVer = $tDist[1];
} elsif ($tOSGen eq "darwin") {
	$tOSDist = "mac";
	$tOSVer = readpipe("uname -r");
	chomp $tOSVer;
} elsif ($tOSGen eq "mswin32") {
	$tOSDist = "win";
	$tOSVer = "xp";
} else {
	$tOSDist = $tOSGen;
	$tOSVer = "0";
}
$tOSVer =~ s/\.[\.\d]+//;
$ProdOS = $tOSDist . $tOSVer;

# Set Architecture
if ($tOSDist eq "deb") {
	$tArch = readpipe("uname -m");
} else {
	$tArch = readpipe("uname -p");
}
chomp $tArch;

if ($tArch =~ /86$/) {
	$tArchGen = "i386";
} else {
	$tArchGen = $tArch;
}
$ProdArch = $tArchGen;

# Set gCurDir
if ($tOSGen eq "mswin32") {
	$gCurDir = readpipe 'cd';
	chomp $gCurDir;
	$LOGNAME = $USERNAME;
} else {
	$gCurDir = readpipe 'pwd';
	chomp $gCurDir;
}

$gErr = 0;

# -----------
# Get Options
$tScriptName = "$0";
$tParm = join(" ", @ARGV);

$gpDef = "./ver.sh";
$gpExt = "";
$gpHelp = 0;
$gpVerbose = 0;
$gpDebug = 0;
$gErr = &GetOptions(
	"def:s" => \$gpDef,
	"extension:s" => \$gpExt,
	"help" => \$gpHelp,
	"verbose" => \$gpVerbose,
	"xdebug:i" => \$gpDebug,
);
if ($gpHelp) {
	system("pod2text $0 | more");
	exit 1;
}

$cgBaseName = basename($gpDef);
&fMsg(5, "gpDef=$gpDef cgBaseName=$cgBaseName", __FILE__, __LINE__);
$cgBaseName =~ s/(\.[^.]+){1}$//;
&fMsg(5, "gpDef=$gpDef cgBaseName=$cgBaseName", __FILE__, __LINE__);
if ("$gpExt" eq "") {
	$gpExt = "h pl epm mak env java cs xml";
}
@tExt = split / /, $gpExt;
$gpExt = " " . $gpExt . " ";
$tDefault = " epm env ";
foreach $i (@tExt) {
	if (! $tDefault =~ / $i /) {
		&fMsg($cMsgWarn, "Invalid file extension: $i", __FILE__, __LINE__);
	}
	++$gErr;
}

# ----------
if (! -f $gpDef) {
	&fMsg($cMsgWarn, "Could not find: $gpDef (generating a default)", __FILE__, __LINE__);
	$MkVer = $cgMkVerBase
} else {
	&fDefEnv($gpDef);
}

# ----------
# Check version
if ("$MkVer" eq "") {
	$MkVer = $cgMkVerBase
}
&fMsg($cMsgV, "MkVer=$MkVer", __FILE__, __LINE__);
if ($MkVer > $cgMkVerBase) {
	&fMsg($cMsgDie, "mkver.pl needs to be updated (MkVer difference).", __FILE__, __LINE__);
}

# ----------
if (! -f $gpDef) {
	# Initial default version definition file.
	open(hDefOut, ">$gpDef");
	print hDefOut "
# \$Header\$

# Input file for: mkver.pl.  All variables must have
# \"export \" at the beginning.  No spaces around the
# \"=\".  And all values enclosed with double quotes.
# Variables may include other variables in their
# values.

export ProdName=\"PRODNAME\"
# One word [-_.a-zA-Z0-9]

export ProdAlias=\"PRODALIAS\"
# One word [-_.a-zA-Z0-9]

export ProdVer=\"1.0\"
# [0-9]*.[0-9]*{.[0-9]*}{.[0-9]*}

export ProdBuild=\"1\"
# [0-9]*

export ProdSummary=\"PRODSUMMARY\"
# All on one line (< 80 char)

export ProdDesc=\"PRODDESC\"
# All on one line

export ProdVendor=\"COMPANY\"

export ProdPackager=\"\$LOGNAME\"
export ProdSupport=\"support\\\@COMPANY.com\"
export ProdCopyright=\"\"

export ProdDate=\"\"
# 20[012][0-9]-[01][0-9]-[0123][0-9]

export ProdLicense=\"COPYING\"
# Required

export ProdReadMe=\"README\"
# Required

# Third Party (if any)
export ProdTPVendor=\"\"
export ProdTPVer=\"\"
export ProdTPCopyright=\"\"

# Set this to latest version of mkver.pl
export MkVer=\"$cgMkVerBase\"

export ProdRelServer=\"rel.DOMAIN.com\"
export ProdRelRoot=\"/release/package\"
export ProdRelCategory=\"software/ThirdParty/\$ProdName\"
# Generated: ProdRelDir=ProdRelRoot . /released|development/ . ProdRelCategory
# (if RELEASE=1, then use \"released\", else use \"development\")
# Generated: ProdDevDir=ProdRelRoot/development/ProdRelCategory

# Generated: ProdTag=ProdVer-ProdBuild
# (All \".\" converted to \"-\")

# Generated: ProdOS (DistVer)
#	Dist
#		Ver
# linux
# 	deb
# 	rhes
# 	cent
# 	fc
# cygwin
#	cygwin
# mswin32
#	win
#		xp
# solaris
#	sun
# darwin
#	mac

# Generated: ProdArch
# i386
# x86_64

# Output file control variables.
# The *File vars can include dir. names
# The *Header and *Footer defaults are more complete
# than what is shown here.

export envFile=\"$cgBaseName.env\"
export envHeader=\"\"
export envFooter=\"\"

export epmFile=\"$cgBaseName.epm\"
export epmHeader=\"\"
export epmFooter=\"# %include $cgBaseName.list\"

export hFile=\"$cgBaseName.h\"
export hHeader=\"\"
export hFooter=\"\"

export javaPackage=\"DIR.DIR.DIR\"
export javaInterface=\"$cgBaseName\"
export javaFile=\"$cgBaseName.java\"
export javaHeader=\"\"
export javaFooter=\"\"

export csNamespace=\"Supernode\"
export csClass=\"$cgBaseName\"
export csFile=\"$cgBaseName.cs\"
export csHeader=\"\"
export csFooter=\"\"

export makFile=\"$cgBaseName.mak\"
export makHeader=\"\"
export makFooter=\"\"

export plFile=\"$cgBaseName.pl\"
export plHeader=\"\"
export plFooter=\"\"

export xmlFile=\"$cgBaseName.xml\"
export xmlHeader=\"\"
export xmlFooter=\"\"
";
	close(hDefOut);
	&fDefEnv($gpDef);
}

# -------------------
# Set defaults

$tStr = $gCurDir;
$tStr =~ s!.*/!!;
$ProdName = &fDefault("ProdName", "$ProdName", "$tStr");
$ProdAlias = &fDefault("ProdAlias", "$ProdAlias", "$ProdName");
$ProdSummary = &fDefault("ProdSummary", "$ProdSummary", "$ProdName");
$ProdDesc = &fDefault("ProdDesc", "$ProdDesc", "$ProdName");
$ProdVer = &fDefault("ProdVer", "$ProdVer", "1.0");
$ProdBuild = &fDefault("ProdBuild", "$ProdBuild", "1");
$ProdVendor = &fDefault("ProdVendor", "$ProdVendor", "COMPANY.");
$ProdPackager = &fDefault("ProdPackager", "$ProdPackager", "$LOGNAME");
$ProdSupport = &fDefault("ProdSupport", "$ProdSupport", "support\@COMPANY.com");
$ProdDate = &fDefault("ProdDate", "$ProdDate", "$gYear-$gMonth-$gDay");
$ProdRelServer = &fDefault("ProdRelServer", "$ProdRelServer", "release.COMPANY.com");
$ProdRelRoot = &fDefault("ProdRelRoot", "$ProdRelRoot", "/release/package");

# ---------
# Construct initial values or transform existing values

$tVer = $ProdVer;
$tVer =~ s/\.[.0-9]//;

$ProdCopyright = &fDefault("ProdCopyright", "$ProdCopyright", "Copyright $gYear. All rights reserved.");
$ProdRelCategory = &fDefault("ProdRelCategory", "$ProdRelCategory", "software/ThirdParty/$ProdName");

if ((-d ".svn") or (-d "_svn")) {
	$tVer = readpipe("svnversion \$PWD");
	chomp $tVer;
	if ($tVer =~ /\:/) {
		$tVer =~ /\d+\:(\d+)/;
		$ProdSvnVer = $1;
	} else {
		$tVer =~ /(\d+)/;
		$ProdSvnVer = $1;
	}
} else {
	$ProdSvnVer = "";
}

# -------------------
# Override and set variables, based on RELEASE, and other var.

$ProdDesc .= ($ProdBuild) ? " / Build=$ProdBuild" : "";
$ProdDesc .= ($ProdSvnVer) ? " / SvnVer=$ProdSvnVer" : "";

if ("$ProdTPVer" ne "") {
	$ProdDesc = "$ProdDesc / TPVer=$ProdTPVer";
}

if ("$ProdTPVer" ne "") {
	$ProdTPCopyright = &fDefault("ProdTPCopyright", "$ProdTPCopyright", "Copyright $ProdVendor $gYear. All rights reserved.");
}

if ("$ProdTPCopyright" ne "") {
	$ProdCopyright = $ProdTPCopyright;
}

if ("$ProdTPVendor" ne "") {
	$ProdVendor = "$ProdTPVendor / $ProdVendor";
}

$ProdWinVer = "$ProdVer";

if ("$RELEASE" eq "1") {
	$ProdTag = &fDefault("ProdTag", "$ProdTag", "REL-$ProdVer-$ProdBuild");
	$ProdBuild =~ tr/0123456789./0123456789./cd;
	$ProdPackager = "RE";
	$ProdRelDir = $ProdRelRoot . "/released/" . $ProdRelCategory;
} else {
	$ProdTag = &fDefault("ProdTag", "$ProdTag", "DEV-$ProdVer-$ProdBuild");
	$ProdBuild =~ tr/0123456789./0123456789./cd;
	$ProdRelDir = $ProdRelRoot . "/development/" . $ProdRelCategory;
}
$ProdDevDir = $ProdRelRoot . "/development/" . $ProdRelCategory;

$ProdTag =~ tr/\-\._ :/\-\-\-\-\-/s;
$ProdVer =~ tr/\-_ :/\-\-\-\-/s;

$ProdVendor = "$ProdVendor / $ProdPackager";


# -------------------
# Validate
if (! $ProdName =~ /[-_.a-zA-Z0-9]+/) {
	&fMsg($cMsgWarn, "Invalid ProdName", __FILE__, __LINE__);
}
if (! $ProdAlias =~ /[-_.a-zA-Z0-9]+/) {
	&fMsg($cMsgWarn, "Invalid ProdAlias", __FILE__, __LINE__);
}

# ProdLicense: check for file
# ProdReadMe: check for file
foreach $i ("$ProdLicense", "$ProdReadMe") {
	if ("$i" eq "") {
		next;
	}
	if (! -f $i) {
		&fMsg($cMsgWarn, "Could not find file: $i", __FILE__, __LINE__);
	}
}

# (not implemented)
# ProdSummary: all on one line (< 80 char)
# ProdDesc: all on one line
# ProdVer: {Alpah|Beta}[0-9]*{.[0-9]*}{.[0-9]*}{.[0-9]*}
# ProdBuild: [0-9]* | $Release: [0-9]*{.[0-9]*}* $
# ProdVendor
# ProdPackager: one word [-_.a-zA-Z0-9]
# ProdSupport:  one word [-_.@a-zA-Z0-9], must have '@'
# ProdCopyright
# ProdDate: 20[012][0-9]-[01][0-9]-[0123][0-9]
# ProdRelServer: ping
# ProdRelRoot: check for leading "/"
# ProdRelCategory:
# ProdTag: unset

#-------------------
# Define defaults for the different file types.
# The defaults are only assigned if the variable is not defined.
# (A space char. should be used for "null" values.)

$cgCodeHeader = "
/* File generated by: $tScriptName $tParm
 * Do not version or edit. Change by editing: $gpDef
 */
";

$cgScriptHeader = "
# File generated by: $tScriptName $tParm
# Do not version or edit. Change by editing: $gpDef
";

$cgXMLHeader = "<?xml version=\"1.0\"?>
<!--
File generated by: $tScriptName $tParm
Do not edit. Change by editing: $gpDef
-->
<mkver-var>
";

$cgXMLFooter = "</mkver-var>
";

# ----
$envFile = &fDefault("envFile", "$envFile", "$cgBaseName.env");
$tVar{"envFile"} = "$envFile";

$envHeader = &fDefault("envHeader", "$envHeader", "$cgScriptHeader");
$envFooter = &fDefault("envFooter", "$envFooter", "");

# ----
$epmFile = &fDefault("epmFile", "$epmFile", "$cgBaseName.epm");
$tVar{"epmFile"} = "$epmFile";

$epmHeader = &fDefault("epmHeader", "$epmHeader", "$cgScriptHeader");
$epmFooter = &fDefault("epmFooter", "$epmFooter", "");

# ----
$tStr = $cgBaseName . "_H";
$tStr =~ s/\\/_/g;
$tStr =~ s/:/_/;
$hFile = &fDefault("hFile", "$hFile", "$cgBaseName.h");
$tVar{"hFile"} = "$hFile";

$hHeader = &fDefault("hHeader", "$hHeader", "$cgCodeHeader
#ifndef $tStr
#define $tStr
");

$hFooter = &fDefault("hFooter", "$hFooter", "#endif /* $tStr */");

# ----
$javaPackage = &fDefault("javaPackage", "$javaPackage", "$ProdName");

$javaFile = &fDefault("javaFile", "$javaFile", "$cgBaseName.java");
$tVar{"javaFile"} = "$javaFile";

$tStr = $javaFile;
$tStr =~ s/\.java//;
$javaInterface = &fDefault("javaInterface", "$javaInterface", "$tStr");

$javaHeader = &fDefault("javaHeader", "$javaHeader", "$cgCodeHeader
package $javaPackage;

public interface $javaInterface {
");

$javaFooter = &fDefault("javaFooter", "$javaFooter", '}');

# ----
$csNamespace = &fDefault("csNamespace", "$csNamespace", "Supernode");
                                                                                                                       
$csFile = &fDefault("csFile", "$csFile", "$cgBaseName.cs");
$tVar{"csFile"} = "$csFile";
                                                                                                                       
$tStr = $csFile;
$tStr =~ s/\.cs//;
$tStr =~ s/-//g;
$csClass = &fDefault("csClass", "$csClass", "$tStr");
                                                                                                                       
$csHeader = &fDefault("csHeader", "$csHeader", "$cgCodeHeader
namespace $csNamespace {
                                                                                                                       
public class $csClass {
	private $csClass() {}
	public static string[] versions = {
");
                                                                                                                       
$csFooter = &fDefault("csFooter", "$csFooter", "};\n}\n}");

# ----
$makFile = &fDefault("makFile", "$makFile", "$cgBaseName.mak");
$tVar{"makFile"} = "$makFile";

$makHeader = &fDefault("makHeader", "$makHeader", "$cgScriptHeader");
$makFooter = &fDefault("makFooter", "$makFooter", "");

# ----
$plFile = &fDefault("plFile", "$plFile", "$cgBaseName.pl");
$tVar{"plFile"} = "$plFile";

$plHeader = &fDefault("plHeader", "$plHeader", "$cgScriptHeader");
$plFooter = &fDefault("plFooter", "$plFooter", "");

# ----
$xmlFile = &fDefault("xmlFile", "$xmlFile", "$cgBaseName.xml");
$tVar{"xmlFile"} = "$xmlFile";

$xmlHeader = &fDefault("xmlHeader", "$xmlHeader", "$cgXMLHeader");
$xmlFooter = &fDefault("xmlFooter", "$xmlFooter", "$cgXMLFooter");

# ----------------------------------------
# Generate the files

# Check to see which files need to be updated
foreach $i (@gpExt) {
	$tFile = $tVar{"$i" . "File"};

	# Check for dir and that the file can be written to
	$tDir = $tFile;
	$tDir =~ s|(/.*){1}$||;
	if ("$tDir" eq "$tFile") {
		$tDir = ".";
	}
	if (! -d $tDir) {
		&fMsg($cMsgDie, "Could not find or create: $tDir", __FILE__, __LINE__);
	}
	open(hF, ">$tFile") or &fMsg($cMsgDie, "Could not open file", __FILE__, __LINE__);
	close(hF);
}

# --------------
if ($gpExt =~ / epm /) {
	# Create the ver.epm include file
	$tFile = $tVar{"epmFile"};
	open(hF, ">$tFile");
	print hF "
$epmHeader
%product $ProdSummary
%version $ProdVer
%release $ProdBuild
%packager $ProdPackager
%vendor $ProdVendor
%copyright $ProdCopyright
%description $ProdDesc
";
	if ("$ProdLicense" ne "") {
		print hF "%license $ProdLicense\n";
	}
	if ("$ProdReadMe" ne "") {
		print hF "%readme $ProdReadMe\n";
	}
	print hF "$epmFooter\n";
}
close(hF);

# --------------
foreach $i ("h", "pl", "mak", "env", "java", "cs", "xml") {
	if ($gpExt =~ / h /) {
		$tF = $tVar{"hFile"};
		open(hF, ">$tF");
	} else {
		open(hF, ">/dev/null");
	}

	if ($gpExt =~ / pl /) {
		$tF = $tVar{"plFile"};
		open(plF, ">$tF");
	} else {
		open(plF, ">/dev/null");
	}

	if ($gpExt =~ / xml /) {
		$tF = $tVar{"xmlFile"};
		open(xmlF, ">$tF");
	} else {
		open(xmlF, ">/dev/null");
	}

	if ($gpExt =~ / mak /) {
		$tF = $tVar{"makFile"};
		open(makF, ">$tF");
	} else {
		open(makF, ">/dev/null");
	}

	if ($gpExt =~ / env /) {
		$tF = $tVar{"envFile"};
		open(envF, ">$tF");
	} else {
		open(envF, ">/dev/null");
	}

	if ($gpExt =~ / java /) {
		$tF = $tVar{"javaFile"};
		open(javaF, ">$tF");
	} else {
		open(javaF, ">/dev/null");
	}

	if ($gpExt =~ / cs /) {
		$tF = $tVar{"csFile"};
		open(csF, ">$tF");
	} else {
		open(csF, ">/dev/null");
	}
}

# Create the ver.h, ver.java include files.
# Also start the ver.mak and ver.env files.
print envF "$envHeader\n";
print hF "$hHeader\n";
print javaF "$javaHeader\n";
print csF "$csHeader\n";
print makF "$makHeader\n";
print plF "$plHeader\n";
print xmlF "$xmlHeader\n";
foreach $i (
	"ProdName",
	"ProdAlias",
	"ProdVer",
	"ProdBuild",
	"ProdSvnVer",
	"ProdWinVer",
	"ProdDate",
	"ProdSummary",
	"ProdDesc",
	"ProdSupport",
	"ProdVendor",
	"ProdPackager",
	"ProdCopyright",
	"ProdLicense",
	"ProdReadMe",
	"ProdTPVendor",
	"ProdTPVer",
	"ProdTPCopyright"
) {
	$tVal=$$i;
	print envF "$i=\"$tVal\"; export $i\n";
	print hF "#define $i \"$tVal\"\n";
	print javaF "public static final String $i = \"$tVal\";\n";
	print csF "\"$i\", \"$tVal\",\n";
	print makF "$i = $tVal\n";
	print plF "\$$i = \"$tVal\";\n";

	$tValXML = $tVal;
	$tValXML =~ s/\&/\&amp;/;
	$tValXML =~ s/</\&lt;/;
	$tValXML =~ s/>/\&gt;/;
	$tValXML =~ s/\"/\&quot;/;
	$tValXML =~ s/\'/\&apos;/;
	print xmlF "<$i>$tValXML</$i>\n";
}
print hF "$hFooter\n";
print javaF "$javaFooter\n";
print csF "$csFooter\n";
print plF "$plFooter\n";

# --------------
# Add additional var to ver.env, ver.mak, and ver.xml
foreach $i (
	"ProdDesc",
	"ProdRelServer",
	"ProdRelRoot",
	"ProdRelCategory",
	"ProdRelDir",
	"ProdDevDir",
	"ProdTag",
	"ProdOS",
	"ProdArch",
	"MkVer"
) {
	$tVal=$$i;
	print envF "$i=\"$tVal\"; export $i\n";
	print makF "$i = $tVal\n";

	$tValXML = $tVal;
	$tValXML =~ s/\&/\&amp;/;
	$tValXML =~ s/</\&lt;/;
	$tValXML =~ s/>/\&gt;/;
	print xmlF "<$i>$tValXML</$i>\n";
}

# Create a variable with the value of ProdOS
print envF "ProdOS" . $ProdOS . "=1; export ProdOS" . $ProdOS . "\n";

print makF "$makFooter\n";
print envF "$envFooter\n";
print xmlF "$xmlFooter\n";
