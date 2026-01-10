## -------------------------------------------------------------------------- #
#           ____  _____________  __                                           #
#          / __ \/ ____/ ___/\ \/ /                 _   _   _                 #
#         / / / / __/  \__ \  \  /                 / \ / \ / \                #
#        / /_/ / /___ ___/ /  / /               = ( M | S | K )=              #
#       /_____/_____//____/  /_/                   \_/ \_/ \_/                #
#                                                                             #
# --------------------------------------------------------------------------- #
# @copyright Copyright 2023 DESY
# SPDX-License-Identifier: Apache-2.0
# --------------------------------------------------------------------------- #
# @date 2023-11-07
# @author Seyed Nima Omidsajedi <nima.sajedi@desy.de>
# --------------------------------------------------------------------------- #
# @brief#
# Part of DESY FPGA Firmware Framework (fwk)
# contains procedures for Xilinx Vitis HLS creation and build
# --------------------------------------------------------------------------- #

variable SourcesList
# no address to be generated, disable globally
set ::fwfwk::addr::TypesToGen {}

proc cleanProject {PrjBuildName} {

  ::fwfwk::printCBM "Clean project"
  # delete existing project files if existing
  set curFile "${::fwfwk::PrjBuildPath}/$PrjBuildName"
  if { [ file exists $curFile ] } {
    file delete -force $curFile
  }

}

# ==============================================================================
proc createProject {PrjBuildName} {
  variable SourcesList
  ::fwfwk::printInfo "Create Project from fwfwk_vitis_hls.tcl, createProject proc"
  foreach nsTop [namespace children ::fwfwk::src ] {
    open_project [subst $${nsTop}::Name]
    set top [subst $${nsTop}::Top]
    set solution [subst $${nsTop}::Name]
    set part [subst $${nsTop}::Part]
    ::fwfwk::printInfo "Create Solution"
    open_solution $solution

    # open_solution $::fwfwk::ProjectConf
    ::fwfwk::printInfo "Set FPGA Part: $::fwfwk::Part"
    set_part $part

    ::fwfwk::printInfo "Set Top: $::fwfwk::Top"
    set_top $top

    ::fwfwk::printInfo "Set Clock period (ns)"
    create_clock -period $::fwfwk::ClockPeriod -name default

    ::fwfwk::printInfo "Set Clock uncertainty"
    set_clock_uncertainty $::fwfwk::ClockUncertainty
  }
}


# ==============================================================================
proc openProject {PrjBuildName} {

  # Disabled due to multiple HLS IPs

  #::fwfwk::printInfo "Openning HLS Project $::fwfwk::PrjBuildName ..."
  # open_project $PrjBuildName

  #::fwfwk::printInfo "Openning HLS Solution $::fwfwk::PrjBuildName ..."
  # open_solution $::fwfwk::ProjectConf

}

# ==============================================================================
proc closeProject {} {
  close_solution
  close_project
}

# ==============================================================================
proc saveProject {} {
  variable SourcesList
  # crate makefiles for csimulation
  set CMakeListFile [open ${::fwfwk::PrjBuildPath}/CMakeLists.txt w]

  puts $CMakeListFile "cmake_minimum_required(VERSION 3.3)"
  puts $CMakeListFile "project (${::fwfwk::PrjBuildName})"
  puts $CMakeListFile "set(CMAKE_CXX_STANDARD 14)"
  puts $CMakeListFile "include_directories($::env(XILINX_HLS)/include)"
  puts $CMakeListFile "enable_testing()"
  puts $CMakeListFile "add_compile_options(-fPIC -O3  -lm  -Wno-unused-result \
    -D__SIM_FPO__ -D__SIM_OPENCV__ -D__SIM_FFT__ -D__SIM_FIR__ -D__SIM_DDS__ -D__DSP48E1__ -g)"

  foreach src $SourcesList {
    set path [lindex $src 0]
    set type [lindex $src 1]
    set cFlags    [lindex $src 2]
    set cSimFlags [lindex $src 3]
    if { $type == "source"} {
      puts $CMakeListFile "list (APPEND SRC_LIST \"$path\")"
      puts $CMakeListFile "message(\"-- Adding Source $path\")"
      if { $cFlags != "" || $cSimFlags != "" } {
        puts $CMakeListFile "set_source_files_properties(\"$path\" PROPERTIES COMPILE_FLAGS \"$cFlags $cSimFlags\")"
      }
    }
  }
  puts $CMakeListFile "add_library(hlsip STATIC \$\{SRC_LIST\})"
  puts $CMakeListFile ""

  foreach src $SourcesList {
    set path [lindex $src 0]
    set type [lindex $src 1]
    set cFlags    [lindex $src 2]
    set cSimFlags [lindex $src 3]
    set name  [file rootname [file tail $path]]
    if { $type == "testbench"} {
      puts $CMakeListFile "add_executable(${name} ${path})"
      puts $CMakeListFile "target_link_libraries(${name} PRIVATE hlsip)"
      puts $CMakeListFile "add_test(NAME ${name} COMMAND \$<TARGET_FILE:${name}>)"
      if { $cFlags != "" || $cSimFlags != "" } {
        puts $CMakeListFile "set_source_files_properties(\"$path\" PROPERTIES COMPILE_FLAGS \"$cFlags $cSimFlags\")"
      }
    }
  }

  close $CMakeListFile
  ::fwfwk::printInfo "-- created CMakeList.txt file in project build $::fwfwk::PrjBuildPath"

}

# ==============================================================================
proc addSources {args srcList} {
  variable SourcesList
  # parse the library argument
  set cGlobalFlags ""
  set args [::fwfwk::utils::parseArgValue $args "-cflags" cGlobalFlags]

  foreach src $srcList {
    set path      [lindex $src 0]
    set type      [lindex $src 1]
    set cFlags    [lindex $src 2]
    set cSimFlags [lindex $src 3]
    set tbArg ""
    set cFlagsArg ""
    set cSimFlagsArg ""

    if { $cGlobalFlags != "" } {
      lappend cFlags $cGlobalFlags
      lappend cSimFlags $cGlobalFlags
    }

    if { $type == "testbench"} {
      ::fwfwk::printInfo "Add related Testbench"
      set tbArg "-tb"
    } else {
      ::fwfwk::printInfo "Add Top Module (HLS code for IP)"
    }
    if { $cFlags != "" } {
      set cFlagsArg [concat "-cflags \"$cFlags\""]
    }
    if { $cSimFlags != "" } {
      set cSimFlagsArg [concat "-csimflags \"$cSimFlags\""]
    }
    if { [catch { eval add_files $tbArg $cFlagsArg $cSimFlagsArg $path } resulttext ] } {
      ::fwfwk::printError $resulttext; ::fwfwk::exit -1
    }

    # append to general sources list to be used later e.g. in csim
    lappend SourcesList $src
    lappend ::fwfwk::HlsSrcList "$tbArg $cFlagsArg $cSimFlagsArg $path"
  }

}

# ==============================================================================
proc simProject {} {

  # simulation with gcc over makefile

  # here place sim using vitis_hls
}

# ==============================================================================
proc synthProject {} {
  variable SourcesList
  ::fwfwk::printInfo "Synthesizes Vitis HLS project for the active solution"
  foreach nsTop [namespace children ::fwfwk::src ] {

    ###
    #open_project [subst $${nsTop}::Name]
    puts "#############################"
    puts [subst $${nsTop}::Name]
    puts [subst $${nsTop}::Top]
    puts [subst $${nsTop}::Part]
    puts "#############################"
    ##
    set top      [subst $${nsTop}::Top]
    set solution [subst $${nsTop}::Name]
    set part     [subst $${nsTop}::Part]

    set VerMajor [subst $${nsTop}::VerMajor]
    set VerMinor [subst $${nsTop}::VerMinor]
    set VerPatch [subst $${nsTop}::VerPatch]

    set Vendor   [subst $${nsTop}::Vendor]
    set Name     [subst $${nsTop}::Name]

    ::fwfwk::printInfo "Create Solution"
    
    open_project [subst $${nsTop}::Name]

    foreach src $::fwfwk::HlsSrcList {
      # puts  "add_files $tbArg $cFlagsArg $cSimFlagsArg $path"
      if { [catch { eval add_files $src } resulttext ] } {
        ::fwfwk::printError $resulttext; ::fwfwk::exit -1
      }
    }
    open_solution $solution
    set_top $top
    set_part $part
    create_clock -period $::fwfwk::ClockPeriod -name default
    set_clock_uncertainty $::fwfwk::ClockUncertainty

    if { [catch { csynth_design } resulttext ] } { ::fwfwk::printError $resulttext; ::fwfwk::exit -1 }

    ####### Export RTL as IP
    ::fwfwk::printInfo "Export and package the generated RTL code as a Xilinx IP"
    set command "export_design -format ip_catalog \
            -ipname ${Name} \
            -version \"${VerMajor}.${VerMinor}.${VerPatch}\" \
            -vendor ${Vendor} \
            -taxonomy /fwkHls \
            -rtl VHDL \
            -output $::fwfwk::ProjectPath/out/$::fwfwk::PrjBuildName/$Name"

    ::fwfwk::catchHdl $command
  }
}

# ==============================================================================
proc startProjectGui {} {
}
# ==============================================================================
proc buildProject {args} {
  synthProject
}

# ==============================================================================
proc exportOut {} {

  foreach nsTop [namespace children ::fwfwk::src ] {
    set VerMajor [subst $${nsTop}::VerMajor]
    set VerMinor [subst $${nsTop}::VerMinor]
    set VerPatch [subst $${nsTop}::VerPatch]

    set Vendor   [subst $${nsTop}::Vendor]
    set Name     [subst $${nsTop}::Name]

    file mkdir $::fwfwk::HlsIpRepoPath

    if { [file exists $::fwfwk::HlsIpRepoPath/${Name}_v${VerMajor}.${VerMinor}] } {
      file delete -force -- $::fwfwk::HlsIpRepoPath/${Name}_v${VerMajor}.${VerMinor}
    }
    file copy -force $::fwfwk::PrjBuildPath/$Name/$Name/impl/ip/ \
      $::fwfwk::HlsIpRepoPath/${Name}_v${VerMajor}.${VerMinor}

    file rename -force $::fwfwk::ProjectPath/out/$::fwfwk::PrjBuildName/${Name}.zip \
      $::fwfwk::ProjectPath/out/$::fwfwk::PrjBuildName/${Name}_v${VerMajor}.${VerMinor}.zip

    ::fwfwk::printCBM "Exported HLS IP at: $::fwfwk::ProjectPath/out/hls_ips/${Name}_v${VerMajor}.${VerMinor}.zip"
    ::fwfwk::printCBM "Placed HLS IP at: $::fwfwk::HlsIpRepoPath/${Name}_v${VerMajor}.${VerMinor}"
  }
}
