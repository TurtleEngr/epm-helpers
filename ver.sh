# Input DEF file for: mkver.pl.  All variables must have "export "
# at the beginning.  No spaces around the "=".  And all values
# enclosed with double quotes.  Variables may include other variables
# in their values.

# Set this to latest version of mkver.pl (earlier DEF files should
# still work with newer versions of mkver.pl)
export MkVer="2.2"

export ProdName="epm-helpers"
# One word [-_.a-zA-Z0-9]

export ProdAlias=""
# One word [-_.a-zA-Z0-9]

export ProdVer="1.4"
# [0-9]*.[0-9]*{.[0-9]*}{.[0-9]*}
# 3 levels only

export ProdRC=""
# Release Candidate ver, to put after ProdVer
# "-rc.ProdRC"

export ProdBuild="1"
# [0-9.]*
# Inc. this between each production build
# Put at end of ProdSemVer: "+ProdBuild"

# Generated ProdBuildTime=YYYY.MM.DD.hh.mm
# Generated ProdSemVer=ProdVer[-rc.ProdRC][+ProdBuildTime]
# Generated ProdPkgName=ProdName-ProdVer[-rc.ProdRC]

export ProdSummary="epm-helpers are programs that help with package building with the EPM tool"
# All on one line (< 80 char)

export ProdDesc="EPM will build packages across many non-windows platforms. There is a lot of meta-data about products that needs to be kept consistent in all the files in the product. The a ver.sh file will define a single place for all meta-data components. mkver.sh will generate the different types of include files that may be used across different languges in your product."
# All on one line

export ProdVendor="TurtleEngr"

export ProdPackager="RE"
export ProdSupport="turtle.engr@gmail.com"
export ProdCopyright="2021"

export ProdDate=""
# Curent date, if empty
# 20[0-9][0-9]-[01][0-9]-[0123][0-9]

export ProdLicense="dist/usr/local/share/doc/epm-helpers/LICENSE"
# Required, usually a path

export ProdReadMe="dist/usr/local/share/doc/epm-helpers/README.md"
# Required, usually a path

# Third Party (if any) If repackaging a product, put in its version.
export ProdTPVendor=""
export ProdTPVer=""
export ProdTPCopyright=""

export ProdRelServer="rel.DOMAIN.com"
export ProdRelRoot="/release/package"
export ProdRelCategory="software/ThirdParty/$ProdName"
# Generated: ProdRelDir=/var/www/rel/package/released/software/tid/jboss
# Generated: ProdDevDir=/var/www/rel/package/development/software/tid/jboss

# Generated: ProdTag=tag-ProdVer
# (All "." in ProdVer converted to "-")

# Generated: ProdOSDist
# Generated: ProdOSVer
# Generated: ProdOS=mx19.4
#	OSDist	OSVer
# linux
# 	deb
#	ubuntu	16,18
#	mx	19,20
# 	rhes
# 	cent
# 	fc
# cygwin
#	cygwin
# mswin32
#	win	xp
# solaris
#	sun
# darwin
#	mac

# Generated: ProdArch
# i386
# x86_64

# Output file control variables. (Unused types can be removed.)
# The *File vars can include dir. names
# The *Header and *Footer defaults are more complete than what is
# shown here.

export envFile="ver.env"
export envHeader=""
export envFooter=""

export epmFile="ver.epm"
export epmHeader="%include epm.require"
export epmFooter="%include epm.list"

export makFile="ver.mak"
export makHeader=""
export makFooter=""
