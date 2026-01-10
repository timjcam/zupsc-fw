## -------------------------------------------------------------------------- #
#           ____  _____________  __                                           #
#          / __ \/ ____/ ___/\ \/ /                 _   _   _                 #
#         / / / / __/  \__ \  \  /                 / \ / \ / \                #
#        / /_/ / /___ ___/ /  / /               = ( M | S | K )=              #
#       /_____/_____//____/  /_/                   \_/ \_/ \_/                #
#                                                                             #
# --------------------------------------------------------------------------- #
# @copyright Copyright 2021 DESY
# SPDX-License-Identifier: Apache-2.0
# --------------------------------------------------------------------------- #
# @date 2021-03-17
# @author Lukasz Butkowski  <lukasz.butkowski@desy.de>
# --------------------------------------------------------------------------- #
# @brief
# Part of DESY FPGA Firmware Framework (fwk)
# Contains procedures for rust_hdl tool
# --------------------------------------------------------------------------- #


# do not execute tool dependent stages (setPrjProperties setProperties)
variable SetPrjProperties 0

namespace eval ::fwfwk::tool {
  # default library name - if not specified
  variable defLibrary "defaultlib"
  # default tool flags
  variable Flags {-fsynopsys -fexplicit}
}

# ==============================================================================
proc cleanProject {PrjBuildName} {
  # if { [file exists ${::fwfwk::ProjectPath}/vhdl_ls.toml] } {
  #   file delete -force ${::fwfwk::ProjectPath}/vhdl_ls.toml
  # }
}

# ==============================================================================
proc createProject {PrjBuildName} {
  variable SourcesArray
  array set SourcesArray {}
  set SourcesArray(0,LibIdx) 0

  addToolLibraries

}

# ==============================================================================
proc closeProject {} {}

# ==============================================================================
proc saveProject {} {
  variable defLibrary

  # ghdl uses Tcl just to crate cmake file sim is run using make
  # no tcl in sum process, all set sim commands should be here
  ::fwfwk::setSim

  variable SourcesArray
  variable Flags

  if {[info exists ::fwfwk::TopLanguage] == 0} {
    set ::fwfwk::TopLanguage vhdl
  }

  # select ghdl if variable set
  if { [info exists ::env(GHDL)] } {
    set GHDL $::env(GHDL)
  } else {
    set GHDL "ghdl"
  }

  # sort array and create sorted list
  foreach {key value} [array get SourcesArray] {
    set curId  [lindex [split $key ,] 0]
    set curKey [lindex [split $key ,] 1]
    lappend libList [list $curId $curKey $value]
  }
  set libListSorted [lsort -integer -index 0 $libList]
  set depLibs {}

  set CMakeListFile [open ${::fwfwk::PrjBuildPath}/CMakeLists.txt w]

  puts $CMakeListFile "cmake_minimum_required(VERSION 3.3)"
  # puts $CMakeListFile "cmake_minimum_required(VERSION 3.21)"
  # Set the project name
  puts $CMakeListFile "project (${::fwfwk::PrjBuildName} NONE)"
  puts $CMakeListFile "enable_testing()"
  puts $CMakeListFile "string(ASCII 27 Esc)"; # set to get colors

  # get flags and tool options
  # set ghdlFlags ""
  if { [info exists ::env(FWK_GHDL_FLAGS)] } {
    lappend Flags [split $::env(FWK_GHDL_FLAGS) " "]
  }
  # set ghdlLibDirOpt ""
  if { [info exists ::env(FWK_GHDL_LIBS)] } {
    set ghdlLibs [split $::env(FWK_GHDL_LIBS) ":"]
    foreach lib $ghdlLibs {
      lappend Flags "-P$lib"
    }
  }

  switch [string tolower $::fwfwk::TopLanguage] {
    "vhdl" {
      set Flags [linsert $Flags 0 "--std=93c"]
    }
    "vhdl 2008" {
      set Flags [linsert $Flags 0 "--std=08"]
    }
    default {
      set Flags [linsert $Flags 0 "--std=93c"]
    }
  }
  #-- generate deps tree
  foreach element $libListSorted {
    set curId    [lindex $element 0]
    set lib      [lindex $element 1]
    set sourcess [lindex $element 2]
    if {$curId == 0} { continue }
    set workDir ${::fwfwk::PrjBuildPath}/${lib}
    file mkdir $workDir
    foreach src $sourcess {
      set srcPath  [lindex $src 0]
      set srcStd   [lindex $src 1]
      set fileName [file rootname [file tail $srcPath]]
      set ghdlFlags [join $Flags " "]
      set cmdToRun "${GHDL} -i $ghdlFlags --work=${lib} --workdir=${workDir} ${srcPath}"
      if { [catch { eval exec >&@stdout "$cmdToRun" } resulttext] } {
        ::fwfwk::printError "ghdl failed."
        ::fwfwk::exit -2
      }
    }
    lappend Flags "-P${workDir}"
  }

  set dependences {}
  foreach test $::fwfwk::src::SimTop {
    if { [catch { eval exec "${GHDL} --version" } resulttext] } {
      ::fwfwk::printError "ghdl failed. $resulttext"
      ::fwfwk::exit -2
    }
    if {![regexp {.*llvm.*} $resulttext totalmatch]} {
      ::fwfwk::printWarning "Using GHDL non LLVM version. Use LLVM version for depedency feature."
      break
    }
    set match [regexp {^([a-zA-Z0-9_]+)\.([a-zA-Z0-9_]+)$} $test totalmatch testLib top]
    if { $match == 0 } {
      set testLib $defLibrary
    }
    ::fwfwk::printDivider
    ::fwfwk::printInfo "ghdl generate depedencies file"
    set ghdlFlags [join $Flags " "]
    set cmdToRun "${GHDL} --gen-depends $ghdlFlags --work=${testLib} --workdir=${::fwfwk::PrjBuildPath}/${testLib} $test > gen_deps.mk"
    puts $cmdToRun
    ::fwfwk::printDivider
    if { [catch { eval exec >&@stderr "$cmdToRun" } resulttext] } {
      ::fwfwk::printError "ghdl failed. $resulttext"
      ::fwfwk::exit -2
    }

    set depsFile [open gen_deps.mk]
    set depsContent [read $depsFile]
    close $depsFile

    set depsList ""
    set match [regexp  {Files dependences(.*)} $depsContent totalmatch depsList]
    set depsList [split $depsList "\n"]
    set target ""
    set tdep ""
    
    foreach dep $depsList {
      regexp  {(.*): (.*)} $dep totalmatch target tdep
      if { $target != ""} {
        lappend dependences [list $target $tdep]
      }
    }
  }

  set outFiles {}
  foreach element $libListSorted {
    set curId    [lindex $element 0]
    set lib      [lindex $element 1]
    set sourcess [lindex $element 2]
    if {$curId == 0} { continue }
    set varName "VHDL_SRC_[string toupper $lib]"
    set outVarName "VHDL_[string toupper $lib]_OUT"
    set workDir ${::fwfwk::PrjBuildPath}/${lib}
    file delete -force $workDir
    file mkdir $workDir
    # puts $CMakeListFile "add_subdirectory(${lib} ${workDir})"
    # if { [llength $depLibs] > 0 } {
    #   puts "$depLibs : [llength $depLibs]"
    #   puts $CMakeListFile "add_dependencies(library_${lib} ${depLibs})"
    # }
    # set CMakeLibListFile [open ${workDir}/CMakeLists.txt w]
    # puts $CMakeLibListFile "cmake_minimum_required(VERSION 3.3)"
    # Set the project name

    foreach src $sourcess {
      set srcPath  [lindex $src 0]
      set fileName [file rootname [file tail $srcPath]]
      set outFile "${workDir}/$fileName.o"
      if {[lsearch -index 0 $dependences $outFile] >= 0} {
        lappend outFiles $outFile
        set deps [lindex [lsearch -index 0 -inline $dependences $outFile] 1]
        lappend outFileList $outFile
        puts $CMakeListFile "list (APPEND \"$outVarName\" \"$outFile\" )"
        puts $CMakeListFile "list (APPEND \"OUT_FILES\" \"$outFile\" )"
        puts $CMakeListFile "add_custom_command("
        puts $CMakeListFile "    OUTPUT  $outFile"
        puts $CMakeListFile "    COMMAND ${GHDL} -a $ghdlFlags --work=${lib} --workdir=${workDir} ${srcPath}"
        puts $CMakeListFile "    DEPENDS $deps"
        puts $CMakeListFile "    DEPENDS $srcPath"
        puts $CMakeListFile "    COMMENT \"Analyze\$\{Esc\}\[33m ${lib} \$\{Esc\}\[m$srcPath\""
        puts $CMakeListFile "    VERBATIM"
        puts $CMakeListFile ")"
      }
    }
    puts $CMakeListFile "add_custom_target(library_$lib DEPENDS \$\{$outVarName\} )"
    # close $CMakeLibListFile
    # puts "-- created CMakeList.txt file in project build $workDir"
    lappend depLibs "library_$lib"
  }

  set idx 0
  foreach test $::fwfwk::src::SimTop {
    if { [llength $::fwfwk::src::SimTime] == 1} {
      set simStopTime "--stop-time=$::fwfwk::src::SimTime"
    } elseif { [llength $::fwfwk::src::SimTime] >= 1} {
      set simStopTime "--stop-time=[lindex $::fwfwk::src::SimTime $idx]"; incr idx
    } else {
      set simStopTime ""
    }
    set match [regexp {^([a-zA-Z0-9_]+)\.([a-zA-Z0-9_]+)$} $test totalmatch testLib top]
    if { $match == 0 } {
      set testLib $defLibrary
    }
    puts $CMakeListFile "message(STATUS \"Elaborate: $test in ${testLib}\")"
    puts $CMakeListFile "list (APPEND TEST_EX \"$test\" )"
    puts $CMakeListFile "add_custom_command("
    puts $CMakeListFile "    OUTPUT  $test"
    puts $CMakeListFile "    COMMAND ${GHDL} -e $ghdlFlags --work=${testLib} --workdir=${::fwfwk::PrjBuildPath}/${testLib} $test"
    puts $CMakeListFile "    DEPENDS \$\{OUT_FILES\}"
    puts $CMakeListFile "    VERBATIM"
    puts $CMakeListFile "    COMMENT \"\${Esc}\[32mElaboarate $test\""
    puts $CMakeListFile ")"

    if { $::fwfwk::CoSimTool == "cocotb" } {

      foreach cotest $::fwfwk::src::CoSimTop {
        set module [lindex $cotest 0]
        set generics [lrange $cotest 1 end]
        set test_name "${module}__${test}"
        set ghdlGenerics ""
        foreach {generic value} $generics {
          set test_name "${test_name}__${generic}_${value}"
          set ghdlGenerics "${ghdlGenerics} -g${generic}=${value}"
        }
        set cmdToRun "cocotb-config --lib-name-path vpi ghdl"
        if { [catch { eval exec "$cmdToRun" } cocotblibPath] } {::fwfwk::printError "cocotb failed: ${cocotblibPath}."; ::fwfwk::exit -2}
        set cmdToRun "cocotb-config --libpython"
        if { [catch { eval exec "$cmdToRun" } cocotblibPy] } {::fwfwk::printError "cocotb failed: ${cocotblibPy}."; ::fwfwk::exit -2}
        puts $CMakeListFile "message(STATUS \"Test case: ${module} ${generics}\")"
        puts $CMakeListFile "add_test(NAME $test_name"
        puts $CMakeListFile "  COMMAND ${GHDL} -r --workdir=${::fwfwk::PrjBuildPath} ${test} ${ghdlGenerics} --assert-level=error --wave=${test}.ghw --vcd=${test}.vcd --vpi=$cocotblibPath"
        puts $CMakeListFile ")"
        puts $CMakeListFile "set_tests_properties($test_name PROPERTIES ENVIRONMENT \"MODULE=$module;TOPLEVEL=$test;TOPLEVEL_LANG=vhdl;LIBPYTHON_LOC=$cocotblibPy;PYTHONPATH=$::env(PYTHONPATH);COCOTB_ANSI_OUTPUT=1\")"
        # Using PASS_REGULAR_EXPRESSION ensures that we detect early failures that prevents cocotb
        # from printing the usual status information
        puts $CMakeListFile "set_tests_properties($test_name PROPERTIES PASS_REGULAR_EXPRESSION \"TESTS=\[0-9\]+ PASS=\[0-9\]+ FAIL=0 SKIP=\[0-9\]+;No tests were discovered\")"

        puts $CMakeListFile "set_tests_properties($test_name PROPERTIES ATTACHED_FILES result.xml)"
      }
    } else {
      puts $CMakeListFile "add_test(NAME $test"
      puts $CMakeListFile "  COMMAND ${GHDL} -r --workdir=${::fwfwk::PrjBuildPath} $test $simStopTime --assert-level=error --wave=${test}.ghw --vcd=${test}.vcd"
      puts $CMakeListFile ")"
    }
  }

  puts $CMakeListFile "add_custom_target(${::fwfwk::ProjectName}_${::fwfwk::ProjectConf}_elab DEPENDS \$\{TEST_EX\})"

  set match [regexp {^([a-zA-Z0-9_]+)\.([a-zA-Z0-9_]+)$} $test totalmatch synthLib top]
  if { $match == 0 } {
    set synthLib $defLibrary
  }
  # puts $CMakeListFile "add_custom_target(${::fwfwk::src::Top}_synth COMMAND ghdl -e -fsynopsys $ghdlFlags $ghdlLibDirOpt --work=${synthLib} --workdir=${::fwfwk::PrjBuildPath}/${synthLib} $::fwfwk::src::Top DEPENDS $depLibs)"
  puts $CMakeListFile "add_custom_target(${::fwfwk::ProjectName}_${::fwfwk::ProjectConf}_synth"
  puts $CMakeListFile "  COMMAND ${GHDL} --synth $ghdlFlags --work=${synthLib} --workdir=${::fwfwk::PrjBuildPath}/${synthLib} $::fwfwk::src::Top > ${::fwfwk::src::Top}_synth.vhd"
  puts $CMakeListFile "  DEPENDS \$\{OUT_FILES\}"
  puts $CMakeListFile ")"

  close $CMakeListFile
  ::fwfwk::printInfo "-- created CMakeList.txt file in project build $::fwfwk::PrjBuildPath"
}

# ==============================================================================
# add tool libraries based on availability in the environment paths
proc addToolLibraries {} {
  variable SourcesArray
  set path ''

  # Xilinx ISE
  # if { [info exists ::env(XILINX)] } {
  #   set path "$::env(XILINX)/vhdl/src"
  #   if { [file exists $path]} {
  #     set idx [findLibIndex unisim]
  #     lappend SourcesArray($idx,unisim) $path/unisims/unisim_VCOMP.vhd
  #     lappend SourcesArray($idx,unisim) $path/unisims/unisim_VPKG.vhd
  #     set idx [findLibIndex unimacro]
  #     lappend SourcesArray($idx,unimacro) $path/unimacro/unimacro_VCOMP.vhd
  #   }
  # }

  # # Xilinx Vivado
  # if { [info exists ::env(XILINX_VIVADO)] } {
  #   set path "$::env(XILINX_VIVADO)/data/vhdl/src"
  #   if { [file exists $path]} {
  #     set idx [findLibIndex unisim]
  #     lappend SourcesArray($idx,unisim) $path/unisims/unisim_VCOMP.vhd
  #     lappend SourcesArray($idx,unisim) $path/unisims/unisim_VPKG.vhd
  #     set idx [findLibIndex unimacro]
  #     lappend SourcesArray($idx,unimacro) $path/unimacro/unimacro_VCOMP.vhd
  #   }
  # }

  # if { [file exists $path]} {
  #   puts "Found $path"
  #   foreach library [glob -directory $path -tails -types d *] {
  #     #puts $library
  #     set files [concat [glob -directory ${path}/${library} -nocomplain -types f *.vhd]]
  #     foreach libFile $files { 
  #       lappend SourcesArray($library) $libFile
  #     }
  #   }
  # }
}

# ==============================================================================
proc addSources {args srcList} {
  variable SourcesArray
  variable defLibrary

  # parse the library argument
  set library ""
  set args [::fwfwk::utils::parseArgValue $args "-lib" library]

  foreach src $srcList {
    # Currently GHDL HDL supports VHDL only
    set srcFile [lindex $src 0]
    set srcType [lindex $src 1]
    set srcLib  [lindex $src 2]
    if {$srcType == "PYTHONPATH" && $::fwfwk::CoSimTool == "cocotb" } {
      if { [info exists ::env(PYTHONPATH)] } {
        set ::env(PYTHONPATH) "${srcFile}:$::env(PYTHONPATH)"
      } else {
        set ::env(PYTHONPATH) ${srcFile}
      }
    }
    set ext [file extension $srcFile]
    if { $ext == ".vhd" } {
      if { $srcLib != ""} { # use file library
        set idx [findLibIndex $srcLib]
        lappend SourcesArray($idx,$srcLib) $srcFile
      } elseif { $library != ""} { # -lib arg default library
        set idx [findLibIndex $library]
        lappend SourcesArray($idx,$library) $srcFile
      } else { # use default tool library
        set idx [findLibIndex $defLibrary]
        lappend SourcesArray($idx,$defLibrary) $srcFile
      }
    }
  }
}

# ==============================================================================
proc findLibIndex {library} {
  variable SourcesArray
  foreach {key value} [array get SourcesArray] {
    set curId  [lindex [split $key ,] 0]
    set curKey [lindex [split $key ,] 1]
    if {$curKey == $library} {
      return $curId
    }
  }
  # if not found, add index based on current lib cnt
  incr SourcesArray(0,LibIdx)
  return $SourcesArray(0,LibIdx)
}
# ==============================================================================
proc simProject {} {

}


# ==============================================================================
# dummy
proc addGenIPs { args sources} {}
proc wrapIP {args} {}
