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
# @date 2023-09-12
# @author Lukasz Butkowski  <lukasz.butkowski@desy.de>
# @author Imre Pechan       <Imre.Pechan@extern.sckcen.be>
# --------------------------------------------------------------------------- #
# @brief
# Part of DESY FPGA Firmware Framework (fwk)
# Contains procedures for teros_hdl tool
# --------------------------------------------------------------------------- #


# do not execute tool dependent stages (setPrjProperties setProperties)
variable SetPrjProperties 0

array set SourcesArray {}
variable SourcesArray
variable LibList {}

# ==============================================================================
proc cleanProject {PrjBuildName} {
  if { [file exists ${::fwfwk::ProjectPath}/teros_proj.yml] } {
    file delete -force ${::fwfwk::ProjectPath}/teros_proj.yml
  }
}

# ==============================================================================
proc createProject {PrjBuildName} {

  # set to include all OSVVM libs
  if {[info exists ::fwfwk::OsvvmPath] } {
    set ::fwfwk::lib::osvvm::IncludeModule {osvvm Common DpRam UART Axi4 Axi4Lite Axi4Stream}
  }

}


# ==============================================================================
proc saveProject {} {
  variable SourcesArray
  set terosYmlFile [open ${::fwfwk::ProjectPath}/teros_proj.yml w]

  addToolLibraries

  puts $terosYmlFile "name: ${::fwfwk::ProjectName}"
  puts $terosYmlFile "files:"

  foreach { lib sourcess } [ array get SourcesArray ] {

    foreach src $sourcess {
      puts $terosYmlFile "  - name: \"$src\""
      # file type is resolved automatically by Teros HDL
      # puts $terosYmlFile "    file_type: \"vhdlSource-2008\""
      puts $terosYmlFile "    is_include_file: false"
      puts $terosYmlFile "    include_path: \"\""
      puts $terosYmlFile "    logical_name: ${lib}"

      # look for topmodule if it was specified
      if {[info exists ::fwfwk::src::Top]} {
        if {[string first ${::fwfwk::src::Top} $src] != -1} {
          set toplevel $src
        }
      }
    }
  }

  # add toplevel if it was found
  if {[info exists toplevel]} {
    puts $terosYmlFile "toplevel: \"$toplevel\""
  } else {
    puts "-- Warning: Top module not found for Teros HDL"
  }

  close $terosYmlFile
  puts "-- Created teros_proj.yml file in project root"
}

# ==============================================================================
# add tool libraries based on availability in the environment paths
proc addToolLibraries {} {
  variable SourcesArray
  set path ''

  # Xilinx ISE
  if { [info exists ::env(XILINX)] } {
    set path "$::env(XILINX)/vhdl/src"
    if { [file exists $path]} {
      lappend SourcesArray(unisim) $path/unisims/unisim_VCOMP.vhd
      lappend SourcesArray(unisim) $path/unisims/unisim_VPKG.vhd
      lappend SourcesArray(unimacro) $path/unimacro/unimacro_VCOMP.vhd
    }
  }

  # Xilinx Vivado
  if { [info exists ::env(XILINX_VIVADO)] } {
    set path "$::env(XILINX_VIVADO)/data/vhdl/src"
    if { [file exists $path]} {
      lappend SourcesArray(unisim) $path/unisims/unisim_VCOMP.vhd
      lappend SourcesArray(unisim) $path/unisims/unisim_VPKG.vhd
      lappend SourcesArray(unimacro) $path/unimacro/unimacro_VCOMP.vhd
    }
  }
}

# ==============================================================================
proc addSources {args srcList} {
  variable SourcesArray

  # default library work
  set defLibrary defaultlib

  # parse the library argument
  set library ""
  set args [::fwfwk::utils::parseArgValue $args "-lib" library]

  foreach src $srcList {
    set srcFile [lindex $src 0]
    set srcLib  [lindex $src 2]

    if { $srcLib != ""} {   # use file library
      lappend SourcesArray($srcLib) $srcFile
    } elseif { $library != ""} { # -lib if no file provided
      lappend SourcesArray($library) $srcFile
    } else { # use default tool library
      lappend SourcesArray($defLibrary) $srcFile
    }
  }

}

# ==============================================================================
# dummy
# ==============================================================================
proc addGenIPs {args sources} {}

# ==============================================================================
proc closeProject {} {}

# ==============================================================================
proc packageIp {args} {}
proc addIp {args} {}
proc wrapIP {args} {}
