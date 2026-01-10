## -------------------------------------------------------------------------- #
#           ____  _____________  __                                           #
#          / __ \/ ____/ ___/\ \/ /                 _   _   _                 #
#         / / / / __/  \__ \  \  /                 / \ / \ / \                #
#        / /_/ / /___ ___/ /  / /               = ( M | S | K )=              #
#       /_____/_____//____/  /_/                   \_/ \_/ \_/                #
#                                                                             #
# --------------------------------------------------------------------------- #
# @copyright Copyright 2019-2023 DESY
# SPDX-License-Identifier: Apache-2.0
# --------------------------------------------------------------------------- #
# @date 2023-01-26
# @author Lukasz Butkowski  <lukasz.butkowski@desy.de>
# @author Michael Buechler <michael.buechler@desy.de>
# @author Seyed Nima Omidsajedi <nima.sajedi@desy.de>
# --------------------------------------------------------------------------- #
# @brief
# Part of DESY FPGA Firmware Framework (fwk)
# Main FPGA firmware framework with namespaces definitions
# --------------------------------------------------------------------------- #

# ==============================================================================
## main framework namespace
# consist of namespace variables and procedures
namespace eval ::fwfwk {

  # main framework variables
  variable ProjectPath

  variable ProjectName
  variable ProjectConf
  variable ToolType
  variable CoSimTool ""

  variable PrjPath
  variable PrjBuildName
  variable PrjBuildPath
  variable PrjCmpPath
  variable ReleasePath
  variable ReleaseName

  variable WorkspacePath
  variable PlatformName
  variable AppName
  variable HwFile
  variable IntHwFile
  variable OsType
  variable CpuType
  variable Arch

  variable Top
  variable Clock 10ns
  variable ClockPeriod 10ns
  variable ClockUncertainty 0

  variable HlsSrcList
  variable sw_src_dir {}
  variable sw_src_name {}

  variable SrcPath
  #variable LibPath

  variable NamespacesList {}
  variable SrcNamespacesList {}

  variable VerMajor 0
  variable VerMinor 0
  variable VerPatch 0
  variable VerCommits 0
  variable VerShasum 0
  variable VerString ""

  variable IpFlow 0

  array set AddressSpace {}
  set AddressSpaceDict   {}
  set AddressSpaceChDict {}
  set RdlFiles {}

  # ==============================================================================
  ## @brief
  # addFwModule {ns ModuleName TclFile}
  #   adds firmware module to the fwfwk namespace
  #   creates a new namespace under ::fwfwk::src::{ModuleName} with dedicated procedures
  #   as well sources provided module TclFile
  # @param  ns            name of the namespace where module should be included
  # @param  ModuleName    name of the module, this wil give name to new namespace
  # @param  TclFile       module Tcl file to be sourced under module namespace
  #
  proc addSrcModule {ns ModuleName TclFile} {}

  # ==============================================================================
  ## @brief
  # addSrcModuleAsIp {ns ModuleName TclFile}
  #   Creates packaged IP from a firmware module and adds it to the tool's IP repo
  #   creates a new namespace under ::fwfwk::src::{ModuleName} with dedicated procedures
  # @param  ns            name of the namespace where module should be included
  # @param  ModuleName    name of the module, this wil give name to new namespace
  # @param  TclFile       module Tcl file to be sourced under module namespace
  #
  proc addSrcModuleAsIp {ns ModuleName TclFile} {}

  # ==============================================================================
  ##   create a list of available namespaces under ::fwfwk::NamespacesList
  #   default namespace ::fwfwk
  #
  proc createNamespacesList {{ns ::fwfwk}} {}

  # ==============================================================================
  ## loadProjectInfo::
  #   loads project information and configuration form the provided config file cfgFile
  #
  proc loadProjectInfo {cfgFile} {}

  # ==============================================================================
  ## printProjectInfo:: prints to output main project settings
  #
  proc printProjectInfo {} {}


  # ==============================================================================
  ## setSources::
  #   executes addSources procedure from all namespacess
  #   recursively from last children to parent
  #
  proc setSources {{ns ::}} {}

  # ==============================================================================
  ## setProperties::
  #   executes addSources procedure from all namespacess
  #   recursively from last children to parent
  #
  proc setProperties {{ns ::}} {}

  # ==============================================================================
  ## addSourcess:: add sources to project in selected namespaces
  #   it uses ToolType variable to run tool depended procedure
  # Argument:
  #   namespaces - namespace where the list of sources is located
  #   args - variable name with sources list and additional arguments
  #          to pass to the tool procedure like "-fileset test"
  #
  proc addSources {{ns ::} args} {}

  # ==============================================================================
  ## @brief
  # getVersions::
  # based on git tag sets VerMajor VerMinor VerPatch VerCsh VerCommits
  proc getVersion {{ns ::}} {}

  proc genPrjVerFile {{ns} fileType fileName} {}
  proc genModVerFile {{ns} fileType fileName} {}
  proc addAddressSpace {{ns} {_AddressSpace} Name Type BaseAddress Args {Config {}}} {}

  # ==============================================================================
  ## setSwSources::
  #   executes swAddSources procedure from all namespacess
  #   recursively from last children to parent
  #
  proc setSwSources {name ipDir} {
    variable sw_src_name
    sourceFwkFile $ipDir
    lappend sw_src_name $name
  }

  # ==============================================================================
  ## @brief
  # genHdlFromConfig {}
  #  Exports the contents of Config variable as VHDL package using Jinja tool
  # and adds it to the Module's sources variable
  proc genHdlFromConfig {} {}

}

# ==============================================================================
# ==============================================================================
# Make procedures visible
namespace eval ::fwfwk {
  namespace export doOnCreate \
  setSources \
  addSrcModule \
  addSrcModuleAsIp \
  printProjectInfo \
  parseVhdlConfigFile \
  setProperties \
  addSources \
  getVersion \
  genPrjVerFile \
  genModVerFile \
  setSwSources \
  sw_src_dir \
  sw_src_name \
  listSubmodules \
  getSubmoduleVersion \
  genHdlFromConfig

}
# globally visible procedures which are under each namespace
proc addSrcModule {ModuleName TclFile} {}
proc addSrcModuleAsIp {ModuleName TclFile} {}
proc addSources {args} {}
proc parseVhdlConfigFile {varName vhdlFile} {}
proc getVersion {} {}
proc genModVerFile {fileType fileName} {}
proc genPrjVerFile {fileType fileName} {}
proc addAddressSpace {{_AddressSpace} Name Type BaseAddress Args {Config {}}} {}

# ==============================================================================
# ==============================================================================
proc ::fwfwk::addSrcModule {ns ModuleName TclFile {ConfigVars {}} } {

  ::fwfwk::printInfo "Creating namespace ${ns}::${ModuleName}"

  if { [namespace exists ${ns}::${ModuleName}] } {
    ::fwfwk::printError "namespace ${ns}::${ModuleName} already exists, please add Module: ${ModuleName} only one time "
    ::fwfwk::exit -2
  }

  lappend ::fwfwk::SrcNamespacesList ${ns}::${ModuleName}

  # check if Tcl file exist before creating new namespace
  # set tclfile to temp to be accessible for created namespace
  if { [ file isfile $TclFile ] }  {
    # full path
    set ::fwfwk::tmpTclPath [file normalize $TclFile ]
  } elseif { [ file isfile $::fwfwk::ProjectPath/$TclFile ] } {
    # relative to project path
    set ::fwfwk::tmpTclPath [file normalize $::fwfwk::ProjectPath/$TclFile ]
  } else {
    # relative to tcl file
    set curDir [pwd]
    if {[info exists ${ns}::TclPath] } {
      cd [subst $${ns}::TclPath]
    }
    if { [ file isfile $TclFile ] } {
      set ::fwfwk::tmpTclPath [file normalize $TclFile ]
    } else {
      ::fwfwk::printError "${ns}::${ModuleName} cannot open Tcl file, namespace not created\n"
      ::fwfwk::exit -2
    }
    cd $curDir
  }

  # Save the Configuration parameters inside fwfwk namespace 
  # such that we can influence the ${ns}::${ModuleName} namespace
  set ::fwfwk::tmpModConfVars $ConfigVars

  # create namespace for the module
  namespace eval ${ns}::${ModuleName} {
    variable IsSrcModule 1

    variable Name ""
    variable Vendor ""

    variable Path

    variable Config

    variable Vhdl {}
    variable Vhdl08 {}
    variable Verilog {}
    variable Sv {}
    variable Ucf {}
    variable Ngc {}
    variable Xdc {}
    variable C {}

    #variable TclFile {}

    variable CurrentNamespace {}

    variable VerMajor 0
    variable VerMinor 0
    variable VerPatch 0
    variable VerCommits 0
    variable VerShasum 0
    variable VerString ""
    variable VerHex 00000000
    variable Ver
    variable Timestamp

    array set AddressSpace {}

    set CurrentNamespace [namespace current]
    set ModuleName [namespace tail $CurrentNamespace]
    set NsLevel [expr {[llength [split $CurrentNamespace "::"]]/2 - 1}]

    # aliases to ::fwfwk function to be available in new namespace
    interp alias {}  ${CurrentNamespace}::addSrcModule {} ::fwfwk::addSrcModule ${CurrentNamespace}
    interp alias {}  ${CurrentNamespace}::addSrcModuleAsIp {} ::fwfwk::addSrcModuleAsIp ${CurrentNamespace}
    interp alias {}  ${CurrentNamespace}::addSources {} ::fwfwk::addSources ${CurrentNamespace}
    interp alias {}  ${CurrentNamespace}::addFwkIp {} ::fwfwk::addFwkIp
    interp alias {}  ${CurrentNamespace}::addGenIPSources {} ::fwfwk::addGenIPSources ${CurrentNamespace}
    interp alias {}  ${CurrentNamespace}::parseVhdlConfigFile {} ::fwfwk::parseVhdlConfigFile ${CurrentNamespace}
    interp alias {}  ${CurrentNamespace}::getVersion {} ::fwfwk::getVersion ${CurrentNamespace}
    interp alias {}  ${CurrentNamespace}::genModVerFile {} ::fwfwk::genModVerFile ${CurrentNamespace}
    interp alias {}  ${CurrentNamespace}::genPrjVerFile {} ::fwfwk::genPrjVerFile ${CurrentNamespace}
    interp alias {}  ${CurrentNamespace}::addAddressSpace {} ::fwfwk::addAddressSpace ${CurrentNamespace}
    interp alias {}  ${CurrentNamespace}::genHdlFromConfig {} ::fwfwk::genHdlFromConfig ${CurrentNamespace}

    # framework sourceFwkFile module procedure handles stubs
    # commented - we check if exists before calling, no more stubs execution
    # proc setSources {} {}
    # proc setAddressSpace {} {}
    # proc setProperties {} {}
    # proc setPrjProperties {} {}
    # proc doOnCreate {} {}
    # proc doOnBuild {} {}
    # proc doPostBuild {} {}

    # sourceFwkFile module tcl file, check absolute and relative path
    set TclFile $::fwfwk::tmpTclPath
    set TclPath [file dirname [file normalize $TclFile]]
    set Path [file normalize $TclPath/.. ]

    sourceFwkFile $TclFile

    # run init procedure in namespace if exists
    set curDir [pwd]
    cd [subst $${CurrentNamespace}::TclPath]

    set Ver 0
    set Timestamp 0
    # get module version
    ::fwfwk::getVersion $CurrentNamespace

    # inject versions to configuration variable
    set Config(C_VERSION)       [format 0x%08x $Ver]
    set Config(C_TIMESTAMP)     $Timestamp
    set Config(C_PRJ_VERSION)   [format 0x%08x $::fwfwk::Ver]
    set Config(C_PRJ_SHASUM)    $::fwfwk::VerShasum
    set Config(C_PRJ_TIMESTAMP) $::fwfwk::Timestamp

    # Inject the Config parameters inside the namespace BEFORE 
    # running the init proc of a module in order to make sure
    # higher level namespace can influence the init Config parameters.
    if { [llength [namespace which ${CurrentNamespace}::init]] } {
      dict for {key value} $::fwfwk::tmpModConfVars {
        set Config($key) $value
      }
      ::fwfwk::catchHdl ${CurrentNamespace}::init "in $TclFile"
    }
    cd $curDir
  }

  unset -nocomplain ::fwfwk::tmpModConfVars
  unset -nocomplain ::fwfwk::tmpTclPath

}

# ==============================================================================
proc ::fwfwk::addSrcModuleAsIp {ns ModuleName TclFile {ConfigVars {}}} {
  # the namespace is created as for a normal module
  ::fwfwk::addSrcModule ::fwfwk::ip $ModuleName $TclFile $ConfigVars

  # check variables
  # set modNs ::fwfwk::ip::${ModuleName}
  # set Name  [subst $${modNs}::Name]
  # if { $Name == ""} { ::fwfwk::printError "No `Name` variable defined in module $ModuleName init."; ::fwfwk::exit -1 }
  # set Vendor  [subst $${modNs}::Vendor]
  # if { $Vendor == ""} { ::fwfwk::printError "No `Vendor` variable defined in module $ModuleName init."; ::fwfwk::exit -1 }

}

# ==============================================================================
# generate module in namespace as an IP using tool dependent functions
proc ::fwfwk::packageIp {ns} {
  set ModuleName [subst $${ns}::ModuleName]

  set ::fwfwk::IpFlow 1

  ::fwfwk::printCBM "\n== CREATE/PACKAGE IP  $ModuleName =="

  set curDir [pwd]
  file mkdir ${::fwfwk::PrjPath}/ip_${ModuleName}
  cd $::fwfwk::PrjPath/ip_${ModuleName}

  ::fwfwk::tool::createProject ip_$ModuleName

  #
  # follow a similar flow to ::fwfwk::createProject
  #
  if { $::fwfwk::addr::TypesToGen != {} } {
    ::fwfwk::addr::main $::fwfwk::addr::TypesToGen ::fwfwk::ip::${ModuleName}::AddressSpace ip_${ModuleName}
    ::fwfwk::addr::addAddrSrc
  } else { ::fwfwk::printInfo "No address space outputs to generate set in ::fwfwk::addr::TypesToGen" }

  ::fwfwk::setSources ::fwfwk::ip::$ModuleName
  # extra steps, e.g. generate address space sources and mapfile

  ::fwfwk::doOnCreate ::fwfwk::ip::$ModuleName

  # call tool-specific IP packaging procedure
  ::fwfwk::tool::packageIp $::fwfwk::IpRepoPath ::fwfwk::ip::$ModuleName

  ::fwfwk::tool::closeProject

  # # don't repeat these as part of the main project flow
  # rename ${ns}::${ModuleName}::setSources ""
  # proc ${ns}::${ModuleName}::setSources {} {puts "empty setSources"}
  # rename ${ns}::${ModuleName}::doOnCreate ""
  # proc ${ns}::${ModuleName}::doOnCreate {} {puts "empty doOnCreate"}
  ::fwfwk::printSuccess "IP $ModuleName Sucessfully created\n"

  set ::fwfwk::IpFlow 0

  cd $curDir

}

# ==============================================================================
proc ::fwfwk::loadProjectInfo {cfgFile} {

  global executionFolder

  set configFile [file join $::fwfwk::ProjectPath cfg default.cfg]
  ::fwfwk::printInfo "Getting default project configuration from: default.cfg"

  if {[file exists $configFile]} {
    set Cfg [open $configFile r]
    while { [gets $Cfg line] >= 0 } {
      set match [regexp {^(?!#\n)(\w+)\s*=\s*(.*)$} $line totalmatch name value]
      if {1 == $match} {
        set $name  $value
        set ::fwfwk::$name $value
      }
    }

  } else  {
    ::fwfwk::printError "Cannot open default.cfg"
    ::fwfwk::exit -7
  }

  # check provided cfgFile
  if {[file exists $executionFolder/$cfgFile]} {
    # if provided in relation to execution folders
    set cfgFile $executionFolder/$cfgFile
  } elseif {[file exists $cfgFile]} {
    # if provided in absolute path
  } else {
    # file do not exist
      ::fwfwk::printError "$cfgFile does not exist"
      ::fwfwk::exit -7
  }

  # updating default configuration with changed config
  if { [file normalize $configFile] != [file normalize $cfgFile]  } {
      ::fwfwk::printInfo "Getting project configuration from: $cfgFile"

    set Cfg [open $cfgFile r]
    while { [gets $Cfg line] >= 0 } {
      set match [regexp {^(?!#\n)(\w+)\s*=\s*(.*)$} $line totalmatch name value]
      if {1 == $match} {
        set $name  $value
        set ::fwfwk::$name $value
      }
    }

  }

  set ::fwfwk::PrjBuildName ${::fwfwk::ProjectName}_${::fwfwk::ProjectConf}
  set ::fwfwk::PrjPath      [file join $::fwfwk::ProjectPath prj]
  set ::fwfwk::PrjBuildPath [file join $::fwfwk::PrjPath $::fwfwk::PrjBuildName]
  set ::fwfwk::PrjCmpPath   [file join $::fwfwk::PrjBuildPath compiled_res]
  set ::fwfwk::WorkspacePath $::fwfwk::PrjBuildPath
  set ::fwfwk::PlatformName  ${::fwfwk::ProjectName}_platform
  set ::fwfwk::IpRepoPath    ${::fwfwk::PrjBuildPath}/ip_repo
  set ::fwfwk::HlsIpRepoPath ${::fwfwk::PrjPath}/hls_ip_repo

  if { [info exists ::env(FWK_HW_FILE)] } {

    set hwFilePath [lindex [lsort -dictionary [glob -nocomplain $::env(FWK_HW_FILE)]] end]
    if { [file exists $hwFilePath] } {  # absolute path
      set ::fwfwk::HwFile $hwFilePath
    }

    set hwFilePath [lindex [lsort -dictionary [glob -nocomplain $executionFolder/$::env(FWK_HW_FILE)]] end]
    if { [file exists $hwFilePath] } {  # relative path
      set ::fwfwk::HwFile $hwFilePath
    }
    if { ![info exists ::fwfwk::HwFile] } {
      set ::fwfwk::HwFile ""; #$::env(FWK_HW_FILE)
      ::fwfwk::printWarning "Cannot find HW File: $::env(FWK_HW_FILE)"
    }
  }

  set ::fwfwk::SrcPath ${::fwfwk::ProjectPath}/src

  # set library path
  if {![llength [namespace which -variable ::fwfwk::LibPath]]} {
    # if variable does not exists
    # set default lib path
    set ::fwfwk::LibPath ${::fwfwk::ProjectPath}/src/lib
    # if path does not exist
  } elseif {![file exists ${::fwfwk::ProjectPath}/${::fwfwk::LibPath} ]} {
    # set default lib path
    set ::fwfwk::LibPath ${::fwfwk::ProjectPath}/src/lib
  } else {
    set ::fwfwk::LibPath  ${::fwfwk::ProjectPath}/${::fwfwk::LibPath}
  }

}


# ==============================================================================
# init
# -----------------------------------------------------------------------------
proc ::fwfwk::init {} {
  # initialize top to bottom by including project tcl to sources modules
  ::fwfwk::addSrcModule ::fwfwk src $::fwfwk::ProjectTcl
}

# ==============================================================================
proc ::fwfwk::createNamespacesList {{ns ::}} {

  foreach ins [namespace children $ns] {
    ::fwfwk::createNamespacesList ${ins}
  }
  lappend ::fwfwk::NamespacesList $ns
}
# ==============================================================================
proc ::fwfwk::genSrcTree {} {
  ::fwfwk::printDivider
  set tree [list]
  lappend tree "Tree View of the Sources:"
  set nl [::fwfwk::createNamespacesList ::fwfwk::src]
  set snl [lsort $nl]
  foreach ele $snl {
    set depth [subst $${ele}::NsLevel]
    set curDepth [expr {$depth *2}]
    set curName [lindex [split ${ele} ::] end]
    # ::fwfwk::printInfo [format "%*s- %-*s" ${curDepth} "+"  24 ${curName}]
    lappend tree [format "%*s- %-*s" ${curDepth} "+"  24 ${curName}]
  }
  ::fwfwk::printInfoMLine $tree
}
# ==============================================================================
# #n
# proc ::fwfwk::genSwSrcTree  {} {
#   puts "----------------------------------------------------"
#   puts "List of SW IPs:"
#   foreach item $::fwfwk::sw_src_name {
#     puts "  + $item"
#   }
#   puts " --------------------"
#   puts $::fwfwk::sw_src_dir
#   puts "----------------------------------------------------"
# }
# #n

# ==============================================================================
# open project
proc ::fwfwk::openProject {} {
  ::fwfwk::printInfo "Openning $::fwfwk::PrjBuildName project ...\n"

  # change directory to the current project build
  cd $::fwfwk::PrjBuildPath

  ::fwfwk::tool::openProject $::fwfwk::PrjBuildName
}

# ==============================================================================
proc ::fwfwk::createProject {} {

  #check if project build folder exists, create prj and project build folder
  ::fwfwk::createPrjDir

  # change directory to the current project build
  cd $::fwfwk::PrjBuildPath

  # deletes existing project files if existing and recreates it
  ::fwfwk::tool::cleanProject $::fwfwk::PrjBuildName

  # package IPS
  ::fwfwk::iterateSrcModules ::fwfwk::ip {::fwfwk::packageIp [namespace current]}

  ::fwfwk::printDivider
  ::fwfwk::printCBM "== CREATE =="
  ::fwfwk::printInfo "Creating ( $::fwfwk::PrjBuildName ) $::fwfwk::ToolType project ..."
  ::fwfwk::printInfo "in $::fwfwk::PrjBuildPath"

  ::fwfwk::tool::createProject $::fwfwk::PrjBuildName

  # set project properties, FPGA type, etc..
  if { $::fwfwk::tool::SetPrjProperties } { ::fwfwk::setPrjProperties }

  #set sources
  ::fwfwk::printDivider
  ::fwfwk::printCBM "== GEN/ADD ADDRESS SPACE =="
  # if { $::fwfwk::addr::TypesToGen != {} } {
    ::fwfwk::addr::main $::fwfwk::addr::TypesToGen
    ::fwfwk::addr::addAddrSrc
  # } else { puts "Noting to generate set in ::fwfwk::addr::TypesToGen" }

  # Convert Config variables to HDL Package using Jinja2 templating engine
  ::fwfwk::genHdlFromConfig

  #set sources
  ::fwfwk::printDivider
  ::fwfwk::printCBM "== SET SOURCES =="
  ::fwfwk::setSources ::fwfwk::src
  ::fwfwk::setSources ::fwfwk::lib

  # set properties
  # if { $::fwfwk::tool::SetPrjProperties } { ::fwfwk::setProperties }

  # execute doOnCreate
  ::fwfwk::printDivider
  ::fwfwk::printCBM "== DO ON CREATE =="
  ::fwfwk::doOnCreate ::fwfwk::src
  ::fwfwk::doOnCreate ::fwfwk::lib

  # save project and close
  ::fwfwk::tool::saveProject
  if {! $::fwfwk::GuiMode} {    # close project only in non GUI mode
    ::fwfwk::tool::closeProject
  }

  ::fwfwk::printDivider
  ::fwfwk::printSuccess "Project creation completed successfully\n"
}

# ==============================================================================
proc ::fwfwk::buildProject {} {

  puts ""
  ::fwfwk::printInfo "Running build of ( $::fwfwk::PrjBuildName ) project ...\n"

  # change directory to the current project build
  cd $::fwfwk::PrjBuildPath

  # open project
  ::fwfwk::tool::openProject $::fwfwk::PrjBuildName

  # create output folder
  ::fwfwk::createOutDir

  ::fwfwk::printCBM "== RE-GEN ADDRESS SPACE =="
  if { $::fwfwk::addr::TypesToGen != {} } {
    ::fwfwk::addr::main $::fwfwk::addr::TypesToGen
  } else {
    ::fwfwk::printInfo "Nothing to generate set in ::fwfwk::addr::TypesToGen"
    }

  puts ""
  ::fwfwk::printCBM "== DO ON BUILD =="
  # execute doOnBuild
  ::fwfwk::doOnBuild ::fwfwk::src

  puts ""
  ::fwfwk::printCBM "== BUILD =="
  # build project and close it afterwards
  ::fwfwk::tool::buildProject

  puts ""
  ::fwfwk::printCBM "== EXPORT ARTIFACTS =="
  # copy artifacts in the out directory
  ::fwfwk::tool::exportOut

  if {! $::fwfwk::GuiMode || ! $::fwfwk::ShellMode } {    # close project only in non GUI mode
    ::fwfwk::tool::closeProject
  }

  puts ""
  ::fwfwk::printCBM "== DO POST BUILD =="
  # execute doPostBuild
  ::fwfwk::doPostBuild

  ::fwfwk::printDivider
  ::fwfwk::printSuccess "Build completed successfully.\n"

}

proc ::fwfwk::postBuildProject {} {

  puts ""
  ::fwfwk::printInfo "Running postbuild of ( $::fwfwk::PrjBuildName ) project ...\n"

  # change directory to the current project build
  cd $::fwfwk::PrjBuildPath

  puts ""
  ::fwfwk::printCBM "== DO POST BUILD =="
  # execute doPostBuild
  ::fwfwk::doPostBuild

  puts "-------------------------------------------------\n"
  ::fwfwk::printSuccess "Postbuild completed (successfully).\n"

}

# ==============================================================================
proc ::fwfwk::simulateProject {} {

  puts ""
  ::fwfwk::printInfo "Running Simulation of ( $::fwfwk::PrjBuildName ) project ...\n"

  # change directory to the current project build
  cd $::fwfwk::PrjBuildPath

  # open project
  ::fwfwk::tool::openProject $::fwfwk::PrjBuildName

  ::fwfwk::printCBM "== SET SIM =="
  ::fwfwk::setSim

  ::fwfwk::printCBM "== SIMULATE =="
  ::fwfwk::tool::simProject

  # # execute doOnBuild
  # ::fwfwk::doOnSim
  # puts "-------------------------------------------------"

  ::fwfwk::tool::closeProject

  ::fwfwk::printDivider
  ::fwfwk::printSuccess "Simulation Run completed successfully.\n"
}

proc ::fwfwk::synthProject {} {

  puts ""
  ::fwfwk::printInfo "Running Synthesis of ( $::fwfwk::PrjBuildName ) project ...\n"

  ::fwfwk::printCBM "== SYNTHESIS =="
  ::fwfwk::tool::synthProject

  ::fwfwk::printDivider
  ::fwfwk::printSuccess "Synthesis completed successfully.\n"
}

# Clean project directory
# ------------------------------------------------------------------------------
proc ::fwfwk::cleanProject {PrjBuildName} {
  ::fwfwk::cleanPrj
  ::fwfwk::cleanOut
}

# ==============================================================================
# Removes $::fwfwk::PrjBuildPath files
# ------------------------------------------------------------------------------
proc ::fwfwk::cleanPrj {} {
  ::fwfwk::utils::cleanDir $::fwfwk::PrjBuildPath
}

# ==============================================================================
# Removes $::fwfwk::$::fwfwk::ProjectPath/out/${::fwfwk::PrjBuildName} files
# ------------------------------------------------------------------------------
proc ::fwfwk::cleanOut {} {
  ::fwfwk::utils::cleanDir $::fwfwk::ProjectPath/out/${::fwfwk::PrjBuildName}
}

# ==============================================================================
# Creates $::fwfwk::PrjBuildPath
# ------------------------------------------------------------------------------
proc ::fwfwk::createPrjDir {} {
  file mkdir $::fwfwk::PrjBuildPath
}

# ==============================================================================
# Creates $::fwfwk::$::fwfwk::ProjectPath/out/${::fwfwk::PrjBuildName}
# ------------------------------------------------------------------------------
proc ::fwfwk::createOutDir {} {
  file mkdir $::fwfwk::ProjectPath/out/${::fwfwk::PrjBuildName}
}

# ==============================================================================
# TODO: implement test
proc ::fwfwk::testProject {} {}

# ==============================================================================
# TODO: implement gui
proc ::fwfwk::guiProject {} {
  puts ""
  ::fwfwk::printInfo "Running GUI ( $::fwfwk::PrjBuildName ) project ...\n"
  set ::fwfwk::GuiMode 1

  # change directory to the current project build
  cd $::fwfwk::PrjBuildPath

  if { [info procs ::fwfwk::tool::startProjectGui] > 0 } {
    ::fwfwk::tool::startProjectGui $::fwfwk::PrjBuildName
  }

}

proc ::fwfwk::openSdk {} {
  puts ""
  ::fwfwk::printInfo "Opening SDK ( $::fwfwk::PrjBuildName ) ...\n"

  # change directory to the current project build
  cd $::fwfwk::PrjBuildPath

  if { [info procs ::fwfwk::tool::openSdk] > 0 } {
    ::fwfwk::tool::openSdk
  }

}

# ==============================================================================
# executes the code block $script in all defined module namespaces.
# recursively from last children to parent. The root namespace is $namespace.
# ------------------------------------------------------------------------------
proc ::fwfwk::iterateSrcModules {ins script} {

  # foreach ins [namespace children $ns] {
  #   ::fwfwk::iterateSrcModules $ins $script
  # }
  for {set i [expr {[llength $::fwfwk::SrcNamespacesList]-1}]} {$i>=0} {incr i -1} {
    set ns [lindex $::fwfwk::SrcNamespacesList $i]
    if { [string match ${ins}* $ns] } {

      if { [info exists ${ns}::IsSrcModule] } {
        set curDir [pwd]
        if { [info exists ${ns}::TclPath] } {
          cd [subst $${ns}::TclPath]
        }

        namespace eval $ns $script

        cd $curDir
      }
    }; # filter namespace list with input namespace
  }
}

proc ::fwfwk::iterateSrcModulesProc { ins procedureName } {

  for {set i [expr {[llength $::fwfwk::SrcNamespacesList]-1}]} {$i>=0} {incr i -1} {
    set ns [lindex $::fwfwk::SrcNamespacesList $i]
    if { [string match ${ins}* $ns] } {

      if { [info exists ${ns}::IsSrcModule] } {
        set curDir [pwd]
        if { [info exists ${ns}::TclPath] } {
          cd [subst $${ns}::TclPath]
        }

        if { [info procs ${ns}::setSources] > 0 } {
          ::fwfwk::printInfo "executing ${ns}::${procedureName}"
          set addmsg "{in [subst $${ns}::TclFile]}"
          set script "::fwfwk::catchHdl ${ns}::${procedureName} ${addmsg}"
          namespace eval $ns $script
        }
        cd $curDir
      }; # filter namespace list with input namespace
    }
  }
}

proc ::fwfwk::iterateSrcModulesProc { ins procedureName } {

  for {set i [expr {[llength $::fwfwk::SrcNamespacesList]-1}]} {$i>=0} {incr i -1} {
    set ns [lindex $::fwfwk::SrcNamespacesList $i]
    if { [string match ${ins}* $ns] } {

      if { [info exists ${ns}::IsSrcModule] } {
        set curDir [pwd]
        if { [info exists ${ns}::TclPath] } {
          cd [subst $${ns}::TclPath]
        }
        if { [info procs ${ns}::${procedureName}] > 0 } {
          ::fwfwk::printInfo "executing ${ns}::${procedureName}"
          set addmsg "{in [subst $${ns}::TclFile]}"
          set script "::fwfwk::catchHdl ${ns}::${procedureName} ${addmsg}"
          namespace eval $ns $script
        }
        cd $curDir
      }; # filter namespace list with input namespace
    }
  }
}


# ==============================================================================
# executes setSources procedure from all namespacess
# recursively from last children to parent
# ------------------------------------------------------------------------------
proc ::fwfwk::setSources {{ns ::fwfwk::src}} {
  ::fwfwk::iterateSrcModulesProc $ns "setSources"
}

# ==============================================================================
# executes setAddressSpace procedure from all namespacess
# recursively from last children to parent
# ------------------------------------------------------------------------------
proc ::fwfwk::setAddressSpace {{ns ::fwfwk::src}} {
  ::fwfwk::iterateSrcModulesProc $ns "setAddressSpace"
}

# ==============================================================================
## @brief executes setProperties procedure from all namespacess
# recursively from last children to parent
# ------------------------------------------------------------------------------
proc ::fwfwk::setProperties {{ns ::fwfwk::src}} {
  ::fwfwk::iterateSrcModulesProc $ns "setProperties"
}

# ==============================================================================
## @brief executes setProperties procedure from all namespacess
# recursively from last children to parent
# ------------------------------------------------------------------------------
proc ::fwfwk::setPrjProperties {{ns ::fwfwk::src}} {
  ::fwfwk::iterateSrcModulesProc $ns "setPrjProperties"
}

# ==============================================================================
## @brief executes doCreate procedure from all namespacess
# recursively from last children to parent, run on project create
# ------------------------------------------------------------------------------
proc ::fwfwk::doOnCreate {{ns ::fwfwk::src}} {
  ::fwfwk::iterateSrcModulesProc $ns "doOnCreate"
}

# ==============================================================================
## @brief executes doOnBuild procedure from all namespacess
# recursively from last children to parent before tool build starts
# ------------------------------------------------------------------------------
proc ::fwfwk::doOnBuild {{ns ::fwfwk::src}} {
  ::fwfwk::iterateSrcModulesProc $ns "doOnBuild"
}
# ==============================================================================
## @brief executes doPostBuild procedure from all namespacess
# recursively from last children to parent after build
# ------------------------------------------------------------------------------
proc ::fwfwk::doPostBuild {{ns ::fwfwk::src}} {
  ::fwfwk::iterateSrcModulesProc $ns "doPostBuild"
}

# ==============================================================================
## @brief executes doOnSim procedure from all namespacess
# recursively from last children to parent before tool build starts
# ------------------------------------------------------------------------------
proc ::fwfwk::doOnSim {{ns ::fwfwk::src}} {
  ::fwfwk::iterateSrcModulesProc $ns "doOnSim"
}
# ==============================================================================
## @brief executes setSim procedure from all namespacess
# recursively from last children to parent before tool build starts
# ------------------------------------------------------------------------------
proc ::fwfwk::setSim {{ns ::fwfwk::src}} {
  ::fwfwk::iterateSrcModulesProc $ns "setSim"
}

# ==============================================================================
# ------------------------------------------------------------------------------
proc ::fwfwk::checkSources {{ns ::} pargs psources} {

  set argsIndex 0
  #set sources {};
  upvar $pargs args
  upvar $psources sources

  # check if first argument is relative namespacess
  if {[namespace exists  ${ns}::[lindex $args 0]] } {
    set ns ${ns}::[lindex $args 0]
    set argsIndex 1
  }
  # check if first argument is absolute namespacess
  if {[namespace exists  [lindex $args 0]] } {
    set ns [lindex $args 0]
    set argsIndex 1
  }

  set srcVarName ""
  foreach arg $args {
    if {[llength [namespace which -variable ${ns}::${arg}]]} {
      set srcVarName $arg
    }
  }

  # ::fwfwk::exit if variable does not exist
  if {![llength [namespace which -variable ${ns}::${srcVarName}]]} {
    return -code error "# ERROR: ::fwfwk::addSources $args variable does not exist in $ns"
  }

  # remove variable name and ns from additional args
  set varIndex [lsearch $args $srcVarName]
  if {$varIndex > -1} {
    set args [lreplace $args $varIndex $varIndex]
    set args [lrange $args $argsIndex end]
  }

  # get namespace and variable name in case srcVarName has relative namespace
  set nsq [namespace qualifiers ${ns}::${srcVarName}]
  set nst [namespace tail ${ns}::${srcVarName}]

  cd [subst $${nsq}::TclPath]

  array set orig_env [array get ::env "PYTHON*"]
  array unset ::env "PYTHON*"
  # normalize sources path
  foreach srcList [subst $${ns}::${srcVarName}] {
    # set src [lindex $srcList 0];    # first item on list is the sourceFwkFile file
    # lappend sources [file normalize "$src"]; # [lrange $srcList 1 end]
    set src {}
    set srcPath [file normalize [lindex $srcList 0]];    # first item on the list is the sourceFwkFile file
    set srcType [lindex $srcList 1];    # second item on the list is the sourceFwkFile Type
    if { $srcType == "" } { set srcType [::fwfwk::utils::getSrcType $srcPath]}
    # check if template type
    set match [regexp {(?i)(.*)_TPL} $srcType totalmatch type]
    # Template processing
    if {1 == $match} {
      set tplOutFile "[string range [file normalize $srcPath] [string length $::fwfwk::ProjectPath] end]"
      set tplOutFilePath "${::fwfwk::PrjBuildPath}${tplOutFile}"
      file mkdir [file dirname $tplOutFilePath]
      set context {}
      foreach {key value} [array get ${ns}::Config] {
        if {[llength $value] == 1} {
          lappend context "\"$key\": \"$value\""
        } else {
          set tmpList [list "\"$key\": " "\[\"" [join $value "\", \""] "\"\]" ]
          lappend context [join $tmpList ""]
        }
      }
      set jinjaArgs [list [join $context ", "]]
      # unset python environment var temporary to be able to run in Vivado
      # Vivado has bundled python which might be in different version then venv
      # pick shell python to run python scripts
      set PYTHON [exec bash -c "which python"]
      if { [catch {eval exec >&@stdout [list $PYTHON $::fwfwk::Path/fwfwk_jinja2.py $jinjaArgs $srcPath $tplOutFilePath] } resulttext] } {
        ::fwfwk::printError "Jinja2 template engine failed:"
        puts "jinja2 $jinjaArgs $srcPath\n"
        set einfo $::errorInfo
        set ecode $::errorCode
        ::fwfwk::printError "\n $einfo"
        ::fwfwk::exit -2
      } else {
        ::fwfwk::printInfo "Rendered template to $tplOutFilePath"
      }
      lappend src $tplOutFilePath
      lappend src $type
      foreach prop [lrange $srcList 2 end] { lappend src $prop}

    # no template processing
    } else {
      lappend src $srcPath
      lappend src $srcType
      foreach prop [lrange $srcList 2 end] { lappend src $prop}
    }
    lappend sources $src
  }
  if { $::fwfwk::ModuleOwnLib } {
    set args "$args -lib [subst $${ns}::ModuleName]"
  }

  array set ::env [array get orig_env]

  if { ![llength $sources] } {
    ::fwfwk::printInfo "::fwfwk::addSources ${ns}::${srcVarName} variable empty\n"
    return 1
  }

  ::fwfwk::printInfo "executing ::fwfwk::addSources in $::fwfwk::ToolType with ${ns}::${srcVarName}"
  return 0
}

# ==============================================================================
# ------------------------------------------------------------------------------
proc ::fwfwk::addSources {{ns ::} args} {

  set sources {}

  # go to namespace tcl file location (sources have relative path to tcl)
  set curDir [pwd]

  if { [::fwfwk::checkSources $ns args sources] } {cd $curDir; return }

  ::fwfwk::tool::addSources $args $sources

  cd $curDir

}

# ==============================================================================
# ------------------------------------------------------------------------------
proc ::fwfwk::addFwkIp {ModuleName} {

  ::fwfwk::printInfo "executing ::fwfwk::addFwkIp in $::fwfwk::ToolType with ::fwfwk::ip::$ModuleName"

  set ipNs ::fwfwk::ip::$ModuleName
  set IpName  [subst $${ipNs}::ModuleName]
  set IpVendor  [subst $${ipNs}::Vendor]
  set IpLibrary "fwk"
  set InsName $IpName
  set IpConfig {}

  ::fwfwk::tool::addIp $IpVendor $IpLibrary $IpName $InsName $IpConfig

}

# ==============================================================================
# ------------------------------------------------------------------------------
proc ::fwfwk::addGenIPSources {{ns ::} args} {

  set sources {}

  # go to namespace tcl file location (sources have relative path to tcl)
  set curDir [pwd]

  if { [::fwfwk::checkSources $ns args sources] } { return }

  ::fwfwk::tool::addGenIPs $args $sources

  cd $curDir

}

# ==============================================================================
## print project info
# ------------------------------------------------------------------------------
proc ::fwfwk::printProjectInfo {} {

  ::fwfwk::utils::cprint "-------------------------------------" {".*" -fg cyan -style bright}
  ::fwfwk::utils::cprint "Loaded Configuration:"                 {".*" -fg cyan -style none}
  ::fwfwk::utils::cprint "-------------------------------------" {".*" -fg cyan -style bright}
  ::fwfwk::utils::cprint "ProjectName : $::fwfwk::ProjectName "  {"ProjectName" -fg white -style none}
  ::fwfwk::utils::cprint "ProjectConf : $::fwfwk::ProjectConf "  {"ProjectConf" -fg white -style none}
  ::fwfwk::utils::cprint "ProjectTcl  : $::fwfwk::ProjectTcl "   {"ProjectTcl"  -fg white -style none}
  ::fwfwk::utils::cprint "ToolType    : $::fwfwk::ToolType"      {"ToolType"    -fg white -style none}

  if { [info exists ::env(FWK_HW_FILE)] } {
    ::fwfwk::utils::cprint "HwFile      : $::fwfwk::HwFile"        {"HwFile" -fg white -style none}
  }

  ::fwfwk::utils::cprint "....................................." {".*" -fg white -style none}
  ::fwfwk::utils::cprint "Project Version : $::fwfwk::VerString" {".*" -fg white -style bright }
  ::fwfwk::utils::cprint "-------------------------------------" {".*" -fg cyan -style bright}

}

# ==============================================================================
## returns constant variables in indexed array
# ------------------------------------------------------------------------------
proc ::fwfwk::parseVhdlConfigFile {ns varName vhdlFile} {

  set name {}
  set type {}
  set value {}

  ::fwfwk::printInfo "parsing vhdl configuration file $vhdlFile into ${ns}::${varName}"

  set curDir [pwd]
  cd [file dirname [file normalize [subst $${ns}::TclFile]]]
  set vhdlFile [file normalize "$vhdlFile"]
  cd $curDir

  if {[ file isfile $vhdlFile ]} {
    set Cfg [open $vhdlFile r]
    while { [gets $Cfg line] >= 0 } {
      set match [regexp -expanded {(^\s*\t*--.*)} $line]
      if {1 != $match} {
        set match [regexp {constant\s+(\w+).*:.*(std_logic_vector).*:=\s*([Xx]*)"([0-9a-fA-F]+)"\s*;(.*)} $line totalmatch name type hex value]
        if {1 == $match} {
          if { $hex == "x" || $hex == "X" } {
            #set Constants($name) [ expr "0x$value" ]
            set Constants($name) 0x$value
          } else {
            binary scan [binary format B64 [format %064s $value]] W dec
            set Constants($name) $dec
          }
        }
        set match [regexp {constant\s+(\w+).*:.*(integer|natural|real).*:=\s*([_\d\(\)\+\-\*\/\.]+)\s*;(.*)} $line totalmatch name type value]
        if {1 == $match} {
          regsub -all "_" $value "" value
          set Constants($name) [ expr $value ]
        }
        set match [regexp {constant\s+(\w+).*:.*(string).*:=.*\"(.*)\".*} $line totalmatch name type value]
        if {1 == $match} {
          set Constants($name) $value
        }
      } else {
        #puts "Line is commented: $line";
      }
    }

    array set ${ns}::${varName} [array get Constants]
    return [array get Constants]
    close $Cfg
  } else { ::fwfwk::printError "::fwfwk::parseVhdlConfigFile cannot open $vhdlFile" ; ::fwfwk::exit -7 }
  return
}


# ==============================================================================
# ------------------------------------------------------------------------------
proc ::fwfwk::listSubmodules {} {

  ::fwfwk::utils::cprint "         Git Submodules" {".*" -fg cyan -style bright}
  ::fwfwk::utils::cprint "-------------------------------------" {".*" -fg cyan -style bright}
  puts [format "%-*s %-*s %-*s" 30 "Module path" 24 "Version" 24 "on branch"]
  ::fwfwk::printDivider
  if {[catch {set gitInfo [exec git -C $::fwfwk::ProjectPath submodule status]} msg]} { return }
  foreach {sha modulePath version} $gitInfo {
    if { ![file exists "$::fwfwk::ProjectPath/$modulePath/.git"] } {
      puts [format "%-*s %-*s %-*s" 30 ${modulePath} 24 "Not Initialized submodule"  24 ""]
      puts "..................................................................."
      ::fwfwk::printError "Not intilized submodule ${modulePath} run 'git submodule update --init ${modulePath}'"
      ::fwfwk::exit -1
    }
    # puts "$module $version"
    set branch [exec git -C $::fwfwk::ProjectPath/$modulePath branch --show-current]
    # if { $branch == "" } { set branch "HEAD detached" }
    set version [::fwfwk::getSubmoduleVersion $modulePath]
    puts [format "%-*s %-*s %-*s" 30 ${modulePath} 24 ${version} 24 ($branch)]
  }
  # include external libs info
  if {[info exists ::fwfwk::OsvvmPath] } {
    if { [string first $::fwfwk::ProjectPath $::fwfwk::OsvvmPath ]} { # include only if not within the project path
      puts "Include: $::fwfwk::OsvvmPath : "
      if {[catch {set branch [exec git -C $::fwfwk::OsvvmPath branch --show-current]} msg]} { return }
      if {[catch {set gitinfo [exec git -C $::fwfwk::OsvvmPath describe --long --tags --first-parent]} msg]} { return }
      puts [format "%-*s %-*s %-*s" 30 "osvvm" 24 ${gitinfo} 24 ($branch)]
    }
  }
  ::fwfwk::printDivider
#  [format "%-*s %*s %*s %*s %*s %*s %*s %*s %*s" 60 ${putline} 10 ${size} 12 ${address} 12 ${realsize} 6 ${bar} 6 ${width} 6 ${fracbits} 4 ${signed} 4 ${rwAccess}]
}


proc ::fwfwk::getSubmoduleVersion {modulePath} {

  set rc [catch {set gitinfo [exec git -C $::fwfwk::ProjectPath/$modulePath describe --tags --first-parent --dirty]} msg]
  if { $rc != 0 } {
    # if no tags use commit count for HEAD
    set VerMajor 0
    set VerMinor 0
    set VerPatch 0
    set rc [catch {set gitinfo [exec git -C $::fwfwk::ProjectPath/$modulePath rev-list HEAD --count]} msg]
    if { $rc == 0 } {
      set VerCommits $msg
      set version "0.0.0-$msg"
    } else {
      set VerCommits 0
    }
    set rc [catch {set gitinfo [exec git -C $::fwfwk::ProjectPath/$modulePath rev-parse --short HEAD]} msg]
    if { $rc == 0 } {
      set VerShasum [format %08x 0x$msg]
    } else {
      set VerShasum [format %08x 0]
      ::fwfwk::printWarning "no Git repository nor commits available to generate version\n"
    }
    set version "$VerMajor.$VerMinor.$VerPatch-$VerCommits-g$VerShasum"
  } else {
    #regexp {.*(\d+)\.(\d+)\.(\d+)[-]*(\d*).*} $msg match VerMajor VerMinor VerPatch VerCommits
    set version $msg
  }

  return $version
}
# ==============================================================================
# ------------------------------------------------------------------------------
proc ::fwfwk::getVersion {{ns ::fwfwk}} {

  set now [clock seconds]
  set ${ns}::Timestamp $now

  # go to namespace tcl file location (sources have relative path to tcl)
  set curDir [pwd]
  if {[llength [namespace which -variable ${ns}::ProjectPath]]} {
    # fwfwk namespace is special, we want the version of the project here,
    # not the fwk version. It is also the only namespace with a ProjectPath
    # variable.
    cd [subst $${ns}::ProjectPath]
  } elseif {[llength [namespace which -variable ${ns}::Path]]} {
    # regular source modules have the Path variable
    cd [subst $${ns}::Path]
  } else {
    # if no Tcl in namespacess then main namespaces
    # give version of superproject
    cd $::fwfwk::ProjectPath
  }

  set VerMajor 0
  set VerMinor 0
  set VerPatch 0
  set VerCommits 0
  set Semantic 1
  set rc [catch {set gitinfo [exec git describe --long --tags --first-parent]} msg]
  if { $rc != 0 } {
    # if no tags use commit count for HEAD
    set rc [catch {set gitinfo [exec git rev-list HEAD --count]} msg]
    if { $rc == 0 } {
      set VerCommits $msg
    } else {set VerCommits 0}
  } else {
    set match 0
    regexp {(\d+)\.(\d*)[.]*(\d*)[a-zA-Z0-9_]*[-]+(\d*)[-]+g[0-9a-fA-F]+} $msg match VerMajor VerMinor VerPatch VerCommits
    if { $match == 0 } {
      ::fwfwk::printWarning "NO VERSION. Latest TAG has no minimal semantic versioning <Major.Minor> syntax. e.g. 1.2.0, Only version string set to: $msg";
      set NoSemVer $msg;
      set Semantic 0}
    if { $VerPatch == "" } { set VerPatch 0;  ::fwfwk::printWarning "Version Tag has no Patch Level. Setting Patch = 0"}
  }

  set rc [catch {set gitinfo [exec git rev-parse --short HEAD]} msg]
  if { $rc == 0 } {
    set VerShasum [format %08x 0x$msg]
  } else {
    set VerShasum [format %08x 0]
    ::fwfwk::printWarning "no Git repository nor commits available to generate version\n"
  }
  set ::fwfwk::Hostname [info hostname]
  set ::fwfwk::CI 0
  if { [info exists ::env(CI)]} {
    if { $::env(CI) == true } {
      set ::fwfwk::CI 1
      ::fwfwk::printInfo "Running in CI at $::fwfwk::Hostname"
    }
  }
  # change shasum to inform about CI and not main/master branch
  if { $::fwfwk::CI == 0} {
    set VerShasum [expr 0x${VerShasum} + 0x20000000]
    set VerShasum [format %08x $VerShasum]
  }
  set ::fwfwk::Branch ""
  set rc [catch {set gitinfo [exec git branch --show-current ]} msg]
  if { $rc == 0 } {
    if { $msg != "main" && $msg != "master" } {
      set VerShasum [expr 0x${VerShasum} + 0x10000000]
      set VerShasum [format %08x $VerShasum]
      set ::fwfwk::Branch $msg
    }
  }
  cd $curDir

  # We use Semantic Versioning 2.0
  set ${ns}::VerMajor    [scan $VerMajor %d]
  set ${ns}::VerMinor    [scan $VerMinor %d]
  set ${ns}::VerPatch    [scan $VerPatch %d]
  set ${ns}::VerCommits  [scan $VerCommits %d]
  set ${ns}::VerShasum   "0x${VerShasum}"
  if { 1 == $Semantic } {
    set ${ns}::VerString "$VerMajor.$VerMinor.$VerPatch-$VerCommits-g$VerShasum"
  } else { set ${ns}::VerString $NoSemVer }
  set ${ns}::VerHex "[format %02x [subst $${ns}::VerMajor]][format %02x [subst $${ns}::VerMinor]][format %02x [subst $${ns}::VerPatch]][format %02x [subst $${ns}::VerCommits]]"
  set ${ns}::Ver [expr 0x[subst $${ns}::VerHex]]
  # add additiona information to version string
  if {$::fwfwk::Branch != "" } { # include branch name if not CI
    regsub -all {/} ${::fwfwk::Branch} {-} subbed
    set ${ns}::VerString "[subst $${ns}::VerString]-$subbed"
  }
  if {$::fwfwk::CI == 0 && ${ns} == "::fwfwk" } {     # include host name if not CI
    set ${ns}::VerString "[subst $${ns}::VerString]-${::fwfwk::Hostname}"
  }
  # puts " DEBUG: [subst $${ns}::VerString] : [subst $${ns}::VerHex]"
  if { $ns == "::fwfwk" } {
    set ::env(FWK_PRJ_VERSION) [format 0x%08x $::fwfwk::Ver]
    set ::env(FWK_PRJ_SHASUM)  [format 0x%08x $::fwfwk::VerShasum]
    set ::env(FWK_PRJ_VERSION_COMMITS) "$::fwfwk::VerCommits"
    set ::env(FWK_PRJ_VERSION_STRING) "$::fwfwk::VerString"
    set year  [scan [clock format $::fwfwk::Timestamp -format "%y"] %d]
    set month [scan [clock format $::fwfwk::Timestamp -format "%m"] %d]
    set day   [scan [clock format $::fwfwk::Timestamp -format "%d"] %d]
    set hour  [scan [clock format $::fwfwk::Timestamp -format "%H"] %d]
    set min   [scan [clock format $::fwfwk::Timestamp -format "%M"] %d]
    set sec   [scan [clock format $::fwfwk::Timestamp -format "%S"] %d]
    set ::fwfwk::TimestampXilinx [expr \
                                    {$sec + $min * int(pow(2, 6)) + \
                                       $hour * int(pow(2,12)) + \
                                       $year * int(pow(2,17)) + \
                                       $month * int(pow(2,23)) + \
                                       $day * int(pow(2,27))}]

  }
}

# ==============================================================================
# ------------------------------------------------------------------------------
proc ::fwfwk::genPrjVerFile {{ns ::fwfwk} fileType fileName} {

  ::fwfwk::getVersion ::fwfwk

  switch $fileType {
    VHDL {

      set pkgName [file rootname [file tail $fileName]]

      set templateFile [open [file join $::fwfwk::ProjectPath fwk tpl tpl_pkg_prj_version.vhd] r]
      set template [read $templateFile]
      close $templateFile

      regsub -all {{PKG_NAME}} $template $pkgName subbed
      regsub -all {{PRJ_VERSION}} $subbed [format %08x $::fwfwk::Ver] subbed
      regsub -all {{PRJ_TIMESTAMP}} $subbed [format %08x $::fwfwk::Timestamp] subbed
      regsub -all {{PRJ_SHASUM}} $subbed [format %08x $::fwfwk::VerShasum] subbed

      set curDir [pwd]
      cd [subst $${ns}::TclPath]

      set verFile [open $fileName w]
      ::fwfwk::printInfo "Created version file: $fileType $fileName"
      puts $verFile $subbed
      close $verFile
      cd $curDir
    }
    default {
      ::fwfwk::printError "::fwfwk::genVerFile not supported fileType: $fileType\n"
    }
  }

}

# ==============================================================================
# ------------------------------------------------------------------------------
proc ::fwfwk::genModVerFile {{ns} fileType fileName} {

  ::fwfwk::getVersion ${ns}

  switch $fileType {
    VHDL {

      set pkgName [file rootname [file tail $fileName]]

      set templateFile [open [file join $::fwfwk::ProjectPath fwk tpl tpl_pkg_version.vhd] r]
      set template [read $templateFile]
      close $templateFile

      regsub -all {{PKG_NAME}} $template $pkgName subbed
      regsub -all {{VERSION}} $subbed [format %08x [subst $${ns}::Ver]] subbed
      regsub -all {{TIMESTAMP}} $subbed [format %08x [subst $${ns}::Timestamp]] subbed

      set curDir [pwd]
      cd [subst $${ns}::TclPath]

      set verFile [open $fileName w]
      ::fwfwk::printInfo "Created version file: $fileType $fileName"
      puts $verFile $subbed
      close $verFile
      cd $curDir
    }
    default {
      ::fwfwk::printError "::fwfwk::genVerFile not supported fileType: $fileType\n"
    }
  }
}

# ==============================================================================
# ------------------------------------------------------------------------------
proc ::fwfwk::addAddressSpace {{ns} {_AddressSpace} Identifier Type AddressInfo Arg {Config {}}} {

  if {[catch {upvar ${_AddressSpace} AddressSpace} msg]} {  ::fwfwk::printError $msg; ::fwfwk::exit -1 }
  if {[catch {upvar ${Config} Conf} msg]} { exit }

  set curDir [pwd]
  if {[info exists ${ns}::TclPath]} { cd [subst $${ns}::TclPath] }

  # puts "============================="
  # puts "========= addAddressSpace : $Name $Type $BaseAddress $Args"
  # foreach {key value} [array get AddressSpace ] {
  #   puts "$key, $value"
  # }

  # ----------------------------------------------------------------------------
  # address information in a few options
  # 1. AccessMode@BaseAddress&Range - AccessMode@BaseAddress&Range, AccessMode@BaseAddress
  # 2. {AccessMode BaseAddress Range}, {BaseAddress Range}, {AccessMode BaseAddress}
  set addrInfoLen [llength $AddressInfo]

  set AccessChannel {}
  set BaseAddress 0
  set Range 0xFFFFFFFFFFFFFFFF

  if { $addrInfoLen == 1 } {
    set match [regexp {([A-Z0-9]*)\@+([xXA-Fa-f0-9GMk]*)\&+([xXA-Fa-f0-9GMk]*)} $AddressInfo val AccessChannel BaseAddress Range]
    if { $match == 0 } {
      set match [regexp {([xXA-Fa-f0-9GMk]*)\&+([xXA-Fa-f0-9GMk]*)} $AddressInfo val BaseAddress Range]
      if { $match == 0 } {
        set match [regexp {([A-Z0-9]*)\@+([xXA-Fa-f0-9GMk]*)} $AddressInfo val AccessChannel BaseAddress]
        if { $match == 0 } {
          set match [regexp {([xXA-Fa-f0-9GMk]*)} $AddressInfo val BaseAddress ]
        }
        # set Range automatically based on address- binary shift operation
        set Range 0
        for {set idx 0} { $idx < 32 } { incr idx } {
          if { [expr {($BaseAddress>>$idx) & 1}] == 0 } {
            set Range [expr {$Range + int(pow(2,$idx))}]
          } else {break;}
        }
      }
    }
  } elseif { $addrInfoLen == 3 } {
    set AccessChannel [lindex $AddressInfo 0]
    set BaseAddress   [lindex $AddressInfo 1]
    set Range         [lindex $AddressInfo 2]
  } elseif { $addrInfoLen == 2 } {
    set match [regexp {^([A-D]+)([0-9]+)} [lindex $AddressInfo 0] val mode ch]
    if { $match == "1" } {
      set AccessChannel   [lindex $AddressInfo 0]
      set BaseAddress     [lindex $AddressInfo 1]
      set Range           [expr {$BaseAddress -1}]
    } else {
      set BaseAddress   [lindex $AddressInfo 0]
      set Range         [lindex $AddressInfo 1]
    }
  }

  # decode Address and Range if given with  unit prefix e.g. 2M
  set match [regexp {([0-9]+)([GMk]+)} $Range val num unit]
  if {$match == 1} {
    if { $unit == "k" } { set unitMul 1024 }
    if { $unit == "M" } { set unitMul 1048576 } ; # 1024*1024
    if { $unit == "G" } { set unitMul 1073741824 } ; # 1024*1024*1024
    set Range [format "0x%08X" [expr {$num * $unitMul - 1 }] ]
  }
  set match [regexp {([0-9]+)([GMk]+)} $BaseAddress val num unit]
  if {$match == 1} {
    if { $unit == "k" } { set unitMul 1024 }
    if { $unit == "M" } { set unitMul 1048576 } ; # 1024*1024
    if { $unit == "G" } { set unitMul 1073741824 } ; # 1024*1024*1024
    set BaseAddress [format "0x%08X" [expr {$num * $unitMul - 1 }] ]
  }
  # ----------------------------------------------------------------------------
  # number of address space items -
  # "" just this one do not count items and do not replicate
  # 1,2,... replicate address spaces
  # decoded with Identifier
  set Num        [lindex $Identifier 1]
  set Identifier [lindex $Identifier 0]

  # ----------------------------------------------------------------------------

  # puts "+ $AccessChannel $BaseAddress $Range"
  # check if address space has items
  # if not initialize parent 0 and first ID=1
  if {![info exists AddressSpace(0,ID)]} {
    set id 1
    set Parent 0
    set AddressSpace(0,ID) 1
    set ParentAddress 0
    set ParentRange 0xFFFFFFFFFFFFFFFF
    set ParentAccCH  0
    set ParentNum    0
  } else {
    set Parent 1
    # set ParentId      $AddressSpace(1,Id)
    # set ParentName    $AddressSpace(1,Name)
    set ParentAddress $AddressSpace(1,BaseAddress)
    set ParentRange   $AddressSpace(1,AddressRange)
    set ParentAccCH   $AddressSpace(1,AccessChannel)
    set ParentNum     $AddressSpace(1,Num)
    incr AddressSpace(0,ID)
    set id $AddressSpace(0,ID)
  }

  if {[expr ($ParentAddress + $BaseAddress) & $ParentRange & $Range ] > 0} {
    ::fwfwk::printError "Address to small for a Range: $Range";
    puts "= ${ns} : $AddressSpace(0,ID) : $Identifier $Type \{ $AddressInfo \} $Arg"
    ::fwfwk::exit -2;
  }

  switch -regexp $Type {
    TOP|INIT|INTERCONNECT|PROJECT {
      array unset AddressSpace
      set id 1
      set Parent 0
      set AddressSpace(0,ID) 1
      set AddressSpace($id,Parent) $Parent
      set AddressSpace($id,Id)   $Identifier
      set AddressSpace($id,Name) $Identifier
      set AddressSpace($id,Type) $Type
      set AddressSpace($id,BaseAddress)   $BaseAddress
      set AddressSpace($id,AddressRange)  $Range
      set AddressSpace($id,AccessChannel) $AccessChannel
      set AddressSpace($id,Config)        {}
      set AddressSpace($id,Num)           $Num
      # puts "^ ${ns} : $AddressSpace(0,ID) : $Identifier $Type $BaseAddress $Range $Arg $AccessChannel"
    }
    ARRAY|TREE|INST|INSTANCE { ; # array: append address space array/tree/instance to current address space
      if {[catch {upvar ${Arg} ArrayToAdd} msg]} { ::fwfwk::printError "in ::fwfwk::addAddressSpace ${ns} :\n$msg"; ::fwfwk::exit -1;}
      # decrease if empty array
      if {![info exists ArrayToAdd(1,Name)]} {
        incr AddressSpace(0,ID) -1
        set procName [info level -1]
        set body [info body $procName]
        set lineNr 0
        foreach line [split [info body $procName] "\n"] {
          incr lineNr
          if {[regexp "$Identifier.*$Type.*$Arg" $line] } {
            break
          }
        }
        puts "in [subst $${ns}::TclFile]"
        set errInfo "in procedure \"[info level -1]\" line $lineNr"
        error "Array ${Arg} empty or does not exists.\nin [subst $${ns}::TclFile]" $errInfo "FWK ADDR EMPTY"
      }
      foreach {key data} [array get ArrayToAdd] {
        set curId  [lindex [split $key ,] 0]
        set curKey [lindex [split $key ,] 1]
        set newId [expr {$curId + $id - 1}]
        if { $curKey == "Parent" } {
          if { $data == 0} { set newParent $curId
          } else {set newParent [expr {$data+$id-1}] }
          set AddressSpace($newId,$curKey) $newParent
        } elseif { $curKey == "BaseAddress" } {
          set AddressSpace($newId,$curKey) [expr {$data + $ParentAddress + $BaseAddress}]
          #set AddressSpace($newId,$curKey) [expr {$data  +$BaseAddress}]

        } elseif { $curKey == "ID" } {
          set AddressSpace(0,ID) [expr {$data+$id-1}]
          # if {$curId != 0} {
          #   unset AddressSpace($newId,ID)
          # }
        } elseif { $curKey == "Id" } { # address space Identifier
          if { $curId == 1 && $Identifier != "" } {
            set AddressSpace($newId,Id)    $Identifier
          } else {
            set AddressSpace($newId,Id) $ArrayToAdd($curId,Id)
          }

        } elseif { $curKey == "Config" } {
          if { [info exists Conf] } {
            foreach {key data} $ArrayToAdd($curId,Config) {
              set tmpvars($key) $data
            }
            foreach {key newdata} [array get Conf] { # update variables with conf provided with array (parent)
              set tmpvars($key) $newdata
            }
            set AddressSpace($newId,Config) [array get tmpvars]
          } else {
            set AddressSpace($newId,Config) $ArrayToAdd($curId,Config)
          }
        } elseif { $curKey == "AddressRange" } {
          set AddressSpace($newId,AddressRange) [expr {$Range & $data}]
        } elseif { $curKey == "AccessChannel" } {
          if {$AccessChannel == "" && $ArrayToAdd($curId,AccessChannel) == "" } { # overwrite with parent when others not provided
            set AddressSpace($newId,AccessChannel) $ParentAccCH
          } elseif { $AccessChannel == ""} { # do not overwrite access channel if not provided
            set AddressSpace($newId,AccessChannel) $ArrayToAdd($curId,AccessChannel)
          } else {
            set AddressSpace($newId,AccessChannel) $AccessChannel
          }
        } elseif { $curKey == "Num" } {
          set AddressSpace($newId,Num) $Num
        } else {
          set AddressSpace($newId,$curKey) $data
        }
        #puts "AddressSpace($newId,$curKey) $data"
      }
     # puts "- ${ns} : $AddressSpace(0,ID) : $Identifier $Type $BaseAddress $Range $Arg $AccessChannel"
    }
    default {
      #puts "= ${ns} : $AddressSpace(0,ID) : $Identifier $Type $BaseAddress $Range $Arg"
      set AddressSpace($id,Parent) $Parent
      set AddressSpace($id,Id)   $Identifier
      set AddressSpace($id,Name) $Identifier
      set AddressSpace($id,Type) $Type
      set AddressSpace($id,BaseAddress) $BaseAddress
      set AddressSpace($id,AddressRange) $Range
      set AddressSpace($id,AccessChannel) $AccessChannel
      set AddressSpace($id,Num) $Num
      if { [file exists $Arg] } { # if argument is a file normalize path
        set Arg [file normalize $Arg]
      }
      set AddressSpace($id,Arg) $Arg
      set AddressSpace($id,Config) {}

      if { [info exists ${ns}::Config] } {
        # "array get" doesn't preserve order, so apply new ordering
        set tmp [array get ${ns}::Config]
        foreach key [lsort [dict keys $tmp]] {
          dict set ConfVars $key [dict get $tmp $key]
        }
        set AddressSpace($id,Config) $ConfVars
      }

    }
  }

  # puts "!!AddAddr: ${ns} : $AddressSpace(0,ID) : $Identifier $Type $BaseAddress $Arg $AccessChannel"
  # foreach {key value} [array get AddressSpace] {
  #   lappend la "$key:$value"
  # }
  # puts [join [lsort $la] \n]

  cd $curDir
}

# ==============================================================================
# debug print function
proc ::fwfwk::printDebug { message } {
  global colorTerminal
  if {$colorTerminal == 0 } {
    set infoMessage "# DEBUG: $message"
  } else {
    # Use ANSI escape code for purple (bright magenta)
    set infoMessage "\033\[1;35m# DEBUG: \033\[0m $message"
  }
  puts $infoMessage
}
proc ::fwfwk::printInfo { message } {
  global colorTerminal
  if {$colorTerminal == 0 } {
    set infoMessage "# INFO: $message"
  } else {
    set infoMessage "\033\[1;38;5;8m# INFO: \033\[0m $message"
    #set infoMessage "\33\[1;37m# INFO: \33\[0m $message"
  }
  puts $infoMessage
  #::fwfwk::utils::cprint $infoMessage {"# INFO:"  -style bright}
}
proc ::fwfwk::printInfoMLine { message } {
  global colorTerminal
  if {$colorTerminal == 0 } {
    set infoMessage "# INFO: [lindex $message 0]"
  } else {
    set infoMessage "\033\[1;38;5;8m# INFO: \033\[0m [lindex $message 0]"
    #set infoMessage "\33\[1;37m# INFO: \33\[0m $message"
  }
  puts $infoMessage
  foreach msg [lrange $message 1 end] {
    puts $msg
  }
  #::fwfwk::utils::cprint $infoMessage {"# INFO:"  -style bright}
}

proc ::fwfwk::printSuccess { message } {
  global colorTerminal
  set infoMessage "# INFO: $message"
  if {$colorTerminal == 0 } {
    puts $infoMessage
  } else {
    # ::fwfwk::utils::cprint $infoMessage {"(?i)(# INFO:|success|successfull)" -fg green -style bright}
    puts "\033\[1;32m$infoMessage\033\[0m"
  }
}

proc ::fwfwk::printWarning { message } {
  global colorTerminal
  if {$colorTerminal == 0 } {
    set infoMessage "# WARNING: $message"
  } else {
    set infoMessage "\033\[1;38;5;11m# WARNING: \033\[0m $message"
  }
  puts $infoMessage
  # set infoMessage "# WARNING: $message"
  # ::fwfwk::utils::cprint $infoMessage {"# WARNING:" -fg yellow -style bright}
}

proc ::fwfwk::printError { message } {
  global colorTerminal
  if {$colorTerminal == 0 } {
    set infoMessage "# ERROR: $message"
  } else {
    set infoMessage "\033\[1;38;5;1m# ERROR: \033\[0m $message"
  }
  puts $infoMessage
  # set infoMessage "# ERROR: $message"
  # ::fwfwk::utils::cprint $infoMessage {"# ERROR:" -fg red -style bright}
}


proc ::fwfwk::printCBM {message} {
  global colorTerminal
  if {$colorTerminal == 0 } {
    set infoMessage $message
  } else {
    set infoMessage "\033\[1;38;5;6m${message}\033\[0m"
  }
  puts $infoMessage
  # ::fwfwk::printc {-fg cyan -style bright} $message
}

proc ::fwfwk::printc {argv message} {
  global colorTerminal
  if {$colorTerminal == 0 } {
    puts $message
  } else {
    lappend args ".*"
    foreach arg $argv {
      lappend args $arg
    }
    ::fwfwk::utils::cprint $message $args
  }
}

proc ::fwfwk::printDivider {} {
  ::fwfwk::utils::cprint -------------------------------------------------------------------------------- {".*" -fg cyan -style bright}
}

# This procedure copy a file in the release folder (out).
# It changes the name to the standard one ${::fwfwk::Appname} keeping the same extension
# An optional suffix can be given
proc ::fwfwk::releaseFile {path {suffix ""}} {

  if {$suffix != ""} {
    set suffix "_$suffix"
  }

  set ext [file extension $path]
  set releasePath [file join $::fwfwk::ReleasePath $::fwfwk::ReleaseName$suffix$ext]

  ::fwfwk::printInfo "Releasing $::fwfwk::ReleaseName$suffix$ext"
  file copy -force $path $releasePath
}

# This procedure scans all the namespace instances, fetches the 'Config' variable,
# Converts it to a JSON string,
# Runs the Jinja2 using a custom wrapper script (fwfwk_jinja2.py)
# Adds the generated file path into the namespace variable "Sources" or "Vhdl"
# This procedure runs only if namespace has a variable called "addConfigAsHdl"
# Users can visualize the JSON string as prints on CLI by adding a namespace variable
# called "printConfigJson"

# This procedure gets called by ::fwfwk namespace at the end of INIT stage and the beginning of
# createProject stage.
proc ::fwfwk::genHdlFromConfig {} {

  proc exportConfig {ns} {

    if { [info exist ${ns}::addConfigAsHdl] } { # Check if module wants to export Config as VHDL
        if { [array exists ${ns}::Config] } { # Check if Config variable exists
          set tailName [namespace tail ${ns}]
          ::fwfwk::printInfo "Found Config parameters for ${tailName} module"
          # Create hdl_config directory inside the PrjBuildPath (if it doesn't exists already)
          if {![file exists $::fwfwk::PrjBuildPath/${::fwfwk::PrjBuildName}.hdl_config]} {
            file mkdir $::fwfwk::PrjBuildPath/${::fwfwk::PrjBuildName}.hdl_config
          }

          # Choose the path of the generated code, template and the
          set hdlConfigPath $::fwfwk::PrjBuildPath/${::fwfwk::PrjBuildName}.hdl_config/pkg_${tailName}_config.vhd
          set templatePath  ${::fwfwk::ProjectPath}/fwk/tpl/tpl_pkg_module_config.vhd.j2

          # Construct a JSON data that contains Config parameters
          set jsonData "\{ \"Config\" : \{"
          foreach {key value} [array get ${ns}::Config] {
            if {[llength $value] > 1} { # List detected (assuming a list has more than one element)
                # Initialize JSON string for the list
                set listJson "\["
                foreach item $value {
                    append listJson "${item} ,"
                }
                # Remove trailing comma and close the list
                set listJson [string trimright $listJson ,]
                append listJson "\]"
                append jsonData "\"list_$key\": $listJson ,"
                # append the string "list_" in front of the Config parameter if its nested (2D)
                # Because its hard to resolve list types inside Jinja templates...
                # Template will then check if parameter has "list_" in front of the Config Parameter
                # If yes, it will create JSON structure as following:
                # list_C_2D_PARAMETER": [7 ,6 ,5 ,4 ,3 ,2 ,1 ,0 ]

              } else { # Simple key-value pair or single-element list
                  # Checking if user placed a string value inside a Config variable
                  # If yes, we attach "string_" prefix to the JSON data that feed into the Jinja engine
                  if {![string is integer -strict $value] && ![string is double -strict $value] && [string length $value] > 0} {
                    append jsonData "\"string_$key\": \"$value\" ,"
                  } else {
                    append jsonData "\"$key\": \"$value\" ,"
                  }
              }
          }
          set jsonData [string replace $jsonData end end "\}"]
          # Users can request to see the generated Config JSON to debug or inspect via printConfigJson variable
          if { [info exist ${ns}::printConfigJson] } {
            set formatted_output [::fwfwk::format_json $jsonData]
            ::fwfwk::printDebug $formatted_output
          }

          # Append timestamp information to the JSON data that is going to be consumed by jinja
          set currentTime [clock seconds]
          set currentDate [clock format $currentTime -format "%Y-%m-%d"]
          set currentTimeFormatted [clock format $currentTime -format "%H:%M:%S %Z"]
          append jsonData ", \"moduleName\" : \"${tailName}\", \"date\" : \"${currentDate}\" , \"time\" : \"${currentTimeFormatted}\" \}"

          # Unset the Python that comes together with the Tool
          array set orig_env [array get ::env "PYTHON*"]
          array unset ::env "PYTHON*"
          # Call the fwfwk_jinja2.py script to render the HDL template
          set PYTHON [exec bash -c "which python"]
          eval exec >&@stdout [list $PYTHON $::fwfwk::Path/fwfwk_jinja2.py $jsonData $templatePath $hdlConfigPath]
          # TODO: maybe catch the error and show it with ::fwfwk::printError

          # Append the generated VHDL file to the Sources variable of the particular namespace
          # Note how FWK adds the generated file to the default library of the tool by leaving the string empty
          lappend ${ns}::Vhdl [list $hdlConfigPath "VHDL" ""]
          lappend ${ns}::Sources [list $hdlConfigPath "VHDL" ""]
          ::fwfwk::printInfo "Generated a pkg_${tailName}_config.vhd file and added to the Project"
        }
    }
  }

  # Procedure to recursively discover each child node
  proc discoverChildExportConfig {ns} {
    exportConfig $ns; # Export Configs out of each child
    set children [namespace children $ns]
    foreach child $children {
        discoverChildExportConfig $child ; # Recursively list sub-namespaces
    }
  }

  # Start from the ::fwfwk::src namespace and go deeper
  discoverChildExportConfig ::fwfwk::src
}


# Takes a JSON string and formats it for better prints
# param: json_str -> JSON string that Jinja2 template engine consumes.
proc ::fwfwk::format_json {json_str} {
    set indent_level 0
    set formatted_json ""
    set in_string 0

    foreach char [split $json_str ""] {
        switch -exact -- $char {
            "{" {
                append formatted_json "\n[string repeat "\t" $indent_level]$char\n"
                incr indent_level
            }
            "}" {
                incr indent_level -1
                append formatted_json "\n[string repeat "\t" $indent_level]$char"
            }
            "[" {
                append formatted_json $char
                incr indent_level
            }
            "]" {
                incr indent_level -1
                append formatted_json "\n[string repeat "\t" $indent_level]$char"
            }
            "," {
                append formatted_json "$char\n[string repeat "\t" $indent_level]"
            }
            ":" {
                append formatted_json " $char "
            }
            "\"" {
                append formatted_json $char
                set in_string [expr {!$in_string}]
            }
            default {
                if {$in_string} {
                    append formatted_json $char
                } else {
                    append formatted_json [string trim $char]
                }
            }
        }
    }

    return $formatted_json
}

