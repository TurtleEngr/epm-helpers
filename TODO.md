= TODO

* Implement better tests

* Imp release targets

* Use different vars for %release
  Selection var?
  Select with if's in ver.epm file.
  %if epm_test
      %release $ProdBuildTime
  %elseif epm_rc
      %release rc.$ProdRC
  %else epm-prod - use ProdBuild
      %release $ProdBuild
  $elseif !RELEASE
      %release $ProdBuildTime
  $elseif RELEASE - use ProdBuild
      %release $ProdBuild
  %endif
