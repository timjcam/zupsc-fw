## -------------------------------------------------------------------------- #
#           ____  _____________  __                                           #
#          / __ \/ ____/ ___/\ \/ /                 _   _   _                 #
#         / / / / __/  \__ \  \  /                 / \ / \ / \                #
#        / /_/ / /___ ___/ /  / /               = ( M | S | K )=              #
#       /_____/_____//____/  /_/                   \_/ \_/ \_/                #
#                                                                             #
# --------------------------------------------------------------------------- #
# @copyright Copyright 2022 DESY
# SPDX-License-Identifier: Apache-2.0
# --------------------------------------------------------------------------- #
# @date 2022-04-27
# @author Seyed Nima Omidsajedi <nima.sajedi@desy.de>
# @author Lukasz Butkowski <lukasz.butkowski@desy.de>
# --------------------------------------------------------------------------- #
# @brief#
# Part of DESY FPGA Firmware Framework (fwk)
# contains procedures for Xilinx Vitis creation and build
# --------------------------------------------------------------------------- #

# ==============================================================================
proc testProject {} {
}

# ==============================================================================
proc cleanProject {PrjBuildName} {
  # delete existing project files if existing
  set curFile "${::fwfwk::PrjBuildPath}"
  if { [ file exists $curFile ] } {
    file delete -force $curFile
  }
}

# ==============================================================================
proc createProject {PrjBuildName} {
  variable ::fwfwk::HwFile
  #variable AppName
  ::fwfwk::printInfo "Create Project from fwfwk_vitis.tcl, createProject proc"
  ::fwfwk::printInfo "Create Vitis Platform"

  # check variables HW file
  if { ![info exists ::fwfwk::HwFile] } {
    ::fwfwk::printError "No ::fwfwk::HwFile defined. Please set env variable FWK_HW_FILE. e.g. export FWK_HW_FILE=top.xsa"; ::fwfwk::exit -2;}
  if { ![info exists ::fwfwk::CpuType] } {
    ::fwfwk::printError "No ::fwfwk::CpuType defined. Please set CpuType in cfg/config.cfg e.g. CpuType=psu_cortexa53_0";  ::fwfwk::exit -2; }
  if { ![info exists ::fwfwk::Arch] } {
    ::fwfwk::printError "No ::fwfwk::Arch defined. Please set Arch in cfg/config.cfg e.g. Arch=64-bit";  ::fwfwk::exit -2; }
  if { ![info exists ::fwfwk::OsType] } {
    ::fwfwk::printError "No ::fwfwk::OsType defined. Please set OsType in cfg/config.cfg e.g. OsType=standalone";  ::fwfwk::exit -2; }

  if { ![info exists ::fwfwk::AppName] } {
    ::fwfwk::printWarning "No ::fwfwk::AppName defined. An empty template will be created. It can later be copied to another location. Set AppName in cfg/name_of_sw_project.cfg to the folder name within ::fwfwk::SrcPath, e.g. AppName=hello_world"
  } elseif { ![info exists ::fwfwk::AppLang] } {
    ::fwfwk::printWarning "An application was specified but no ::fwfwk::AppLang defined. Using C by default. Set AppLang in cfg/name_of_sw_project.cfg to either \"c\" or \"c++\", e.g. AppName=c++"
  }

  set appLang "c"
  if { [info exists ::fwfwk::AppLang] } {
    if { [llength $::fwfwk::AppLang] > 0} {
      set appLang $::fwfwk::AppLang
    }
  }

  setws -switch ${::fwfwk::WorkspacePath}
  ::fwfwk::printDivider
  ::fwfwk::printInfo "Workspace path : ${::fwfwk::WorkspacePath}"
  ::fwfwk::printInfo "Platform name  : ${::fwfwk::PlatformName}"
  ::fwfwk::printInfo "HW file: ${::fwfwk::HwFile}"
  ::fwfwk::printDivider

  # get Vitis version
  set xsctVersion [lindex [version] 1]

  ::fwfwk::printInfo "Xilinx Vitis Version $xsctVersion is used"
  # --------------------------------------------------------
  # create platform
  ::fwfwk::printInfo "Creating Plarform..."
  if {[set result [catch {eval \
                            platform create \
                            -name ${::fwfwk::PlatformName} \
                            -hw   ${::fwfwk::HwFile} \
                            -arch ${::fwfwk::Arch} \
                            -fsbl-target ${::fwfwk::CpuType}
  } resulttext]]} {
    puts ""
    ::fwfwk::printError "$resulttext"
    ::fwfwk::exit -2
  }

  platform write

  ::fwfwk::printInfo "Creating Domain..."
  domain create -name {app_domain} -os ${::fwfwk::OsType} -proc ${::fwfwk::CpuType} -runtime {cpp} -support-app {empty_application}

  platform write
  platform active ${::fwfwk::PlatformName}

  if { [ info exists ::fwfwk::Stdin ] } {
    bsp config stdin ${::fwfwk::Stdin}
  }
  if { [ info exists ::fwfwk::Stdout ] } {
    bsp config stdout ${::fwfwk::Stdout}
  }
  bsp write
  bsp reload
  bsp regenerate

  platform generate -quick

  if { [info exists ::fwfwk::AppName] } {
    # --------------------------------------------------------
    # creating application on a platform domain
    ::fwfwk::printCBM "\nCreating Vitis Application"

    set targetDir "${::fwfwk::WorkspacePath}/${::fwfwk::AppName}/src"
    file mkdir ${::fwfwk::WorkspacePath}/${::fwfwk::AppName}

    if { [ file exists $targetDir ] } {
      file delete -force $targetDir
      ::fwfwk::printWarning "Vitis application: Overwrite to existing target directory"
    }

    if { $appLang == "c" } {
      if { $xsctVersion < 2021.1 } {
        app create -name ${::fwfwk::AppName} -domain "app_domain" -template "Empty Application" -proc ${::fwfwk::CpuType} -lang $appLang
      } else {
        app create -name ${::fwfwk::AppName} -domain "app_domain" -template "Empty Application(C)" -proc ${::fwfwk::CpuType} -lang $appLang
      }
    } elseif { $appLang == "c++" } {
      app create -name ${::fwfwk::AppName} -domain "app_domain" -template "Empty Application (C++)" -proc ${::fwfwk::CpuType} -lang $appLang
    }

    # DesyRDL-generated headers are being placed here, so add it to the include path
    app config -name ${::fwfwk::AppName} include-path ${::fwfwk::WorkspacePath}/include

    # Remove the linker script that Vitis auto-generates; we have our own.
    file delete -force $targetDir
  }
}


# ==============================================================================
proc openProject {PrjBuildName} {
  setws -switch $::fwfwk::WorkspacePath

  if { ! [ file exists $::fwfwk::WorkspacePath ] } {
    ## project file isn't there, rebuild it.
    ::fwfwk::printError "Project ${::fwfwk::PrjBuildName} not found. Use create command to recreate it."
    ::fwfwk::exit -1
  }

  if { ![info exists ::fwfwk::AppName] } {
    ::fwfwk::printWarning "No ::fwfwk::AppName defined. Please set AppName in cfg/config.cfg e.g. AppName=AppName. Using project name"
    set ::fwfwk::AppName $::fwfwk::ProjectName
  }

}

# ==============================================================================
proc closeProject {} {
}

# ==============================================================================
proc saveProject {} {}

# ==============================================================================
proc addSources {args srcList} {

  foreach src $srcList {
    set path [lindex $src 0]
    set type [lindex $src 1]

    set appDir ${::fwfwk::WorkspacePath}/${::fwfwk::AppName}
    set absPath [file normalize $path]

    if { $type == "includes"} {
      if { ![file isdirectory $path] } {
        ::fwfwk::printError "fwk can only add directories of include files to a Vitis project, not single files. Cannot add $path."
        ::fwfwk::exit -1
      }
      app config -name ${::fwfwk::AppName} include-path $absPath

    } elseif { $type == "sources"} {
      if { ![file isdirectory $path] } {
        ::fwfwk::printError "fwk can only add directories of source files to a Vitis project, not single files. Cannot add $path."
        ::fwfwk::exit -1
      }

      # we want a symlink that replicates the source path relative to ::fwfwk::SrcPath
      set len1 [string length $::fwfwk::SrcPath]
      set len2 [string length $absPath]
      set srcSubdirPath [string range $absPath $len1 $len2]

      set targetDir $appDir/src/$srcSubdirPath

      # make sure parent folder exists before creating the symlink
      file mkdir [file dirname $targetDir]
      file link -symbolic $targetDir $absPath

    } elseif { $type == "linker-script"} {
      # The application project is created with the "Empty Application" template.
      # This template includes a generated linker script.
      # Replace it with a symlink at the same location.
      file link -symbolic $appDir/src/[file tail $path] $absPath
    }

  }
}

# ==============================================================================
proc buildProject {args} {

  setws -switch ${::fwfwk::WorkspacePath}

  platform active ${::fwfwk::PlatformName}
  domain active {app_domain}

  if {[set result [catch {eval \
                            app build -name ${::fwfwk::AppName}
  } resulttext]]} {
    puts ""
    ::fwfwk::printError "$resulttext"
    ::fwfwk::exit -2
  }
  puts ""
  ::fwfwk::printCBM "== Report Application and its Domain =="

  set app_report [app report -name ${::fwfwk::AppName}]
  set domain_report [domain report -name app_domain]
  puts $app_report
  puts $domain_report
}

# ==============================================================================
proc exportOut {} {
  ::fwfwk::printInfo "Copy elf file of the project to artifacts out"
  puts "from:  ${::fwfwk::WorkspacePath}/${::fwfwk::AppName}/Debug/${::fwfwk::AppName}.elf"
  puts "to  :  $::fwfwk::ProjectPath/out/${::fwfwk::PrjBuildName}/${::fwfwk::AppName}.elf"

  if { [catch {file copy -force \
                 ${::fwfwk::WorkspacePath}/${::fwfwk::AppName}/Debug/${::fwfwk::AppName}.elf \
                 $::fwfwk::ProjectPath/out/${::fwfwk::PrjBuildName}/${::fwfwk::AppName}.elf} resulttext ] } {
    puts ""
    ::fwfwk::printError "$resulttext"
    ::fwfwk::printInfo "For more information check the project build log !"

    ::fwfwk::exit -2
  }
}
