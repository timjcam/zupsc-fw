## -------------------------------------------------------------------------- #
#           ____  _____________  __                                           #
#          / __ \/ ____/ ___/\ \/ /                 _   _   _                 #
#         / / / / __/  \__ \  \  /                 / \ / \ / \                #
#        / /_/ / /___ ___/ /  / /               = ( M | S | K )=              #
#       /_____/_____//____/  /_/                   \_/ \_/ \_/                #
#                                                                             #
# --------------------------------------------------------------------------- #
# @copyright Copyright 2019-2021 DESY
# SPDX-License-Identifier: Apache-2.0
# --------------------------------------------------------------------------- #
# @date 2019-12-22
# @author Lukasz Butkowski  <lukasz.butkowski@desy.de>
# --------------------------------------------------------------------------- #
# @brief#
# Part of DESY FPGA Firmware Framework (fwk)
# contains procedures for Xilinx Vivado creation and buidl
# --------------------------------------------------------------------------- #

# ==============================================================================
proc testProject {} {
}

# ==============================================================================
proc cleanProject {PrjBuildName} {
  # delete existing project files if existing
  set ProjExt [ list xpr data gen]
  foreach ext $ProjExt {
    set curFile "${PrjBuildName}.$ext"
    if { [ file exists $curFile ] } {
      file delete -force $curFile
    }
  }

}

# ==============================================================================
proc createProject {PrjBuildName} {
  create_project -force $PrjBuildName
  # Enable -assert flag for the default synth run. Can be disabled in
  # project.tcl in case of issues.
  set_property steps.synth_design.args.assert true [get_runs synth_1]

  ::fwfwk::catchHdl setIpRepos

  set_property -name {STEPS.WRITE_BITSTREAM.ARGS.BIN_FILE} -value {true} -objects [get_runs impl_1]

}

proc setIpRepos {} {

  foreach ipRepo $::fwfwk::IpRepoPath {
    if {[file exists $ipRepo]} {
      ::fwfwk::printInfo "Adding IpRepoPath: $::fwfwk::IpRepoPath to repo."
      set_property ip_repo_paths "[get_property IP_REPO_PATHS [current_project]] $ipRepo" [current_project]
    }
  }
  foreach ipRepo $::fwfwk::HlsIpRepoPath {
    if {[file exists $ipRepo]} {
      ::fwfwk::printInfo "Adding HlsIpRepoPath: $::fwfwk::HlsIpRepoPath to repo."
      set_property ip_repo_paths "[get_property IP_REPO_PATHS [current_project]] $ipRepo" [current_project]
    }
  }
  update_ip_catalog -rebuild
}

proc openProject {PrjBuildName} {

  set Prj ${PrjBuildName}.xpr
  if { ! [ file exists $Prj ] } {
    ## project file isn't there, rebuild it.
    ::fwfwk::printDivider
    ::fwfwk::printError "Project ${::fwfwk::PrjBuildName} not found. Use create command to recreate it."
    ::fwfwk::exit -1
  }
  if {[set result [catch {open_project $PrjBuildName} resulttext]]} {
    ::fwfwk::printWarning "Project already opened."
  }
  if {! $::fwfwk::GuiMode} {    # update compile order only in non GUI mode
    update_compile_order -fileset [current_fileset]
  }

}

proc startProjectGui {PrjBuildName} {
  start_gui
  # open project
  openProject $PrjBuildName
}

# ==============================================================================
proc closeProject {} {
  close_project
}

# ==============================================================================
proc saveProject {} {}

# ==============================================================================
proc addSources {args srcList} {

  # default library work
  set library ""

  # parse the library argument
  set args [::fwfwk::utils::parseArgValue $args "-lib" library]

  # get file list
  set srcFiles {}
  foreach srcFile $srcList  {
    lappend srcFiles [lindex $srcFile 0]
  }

  # Suppress the [filemgmt 56-12] Warning which clutters the output for not much benefit:
  # [filemgmt 56-12] xxx cannot be added to the project because it already exists in the project, skipping this file
  set_msg_config -id {[filemgmt 56-12]} -limit 0

  # add files
  if { $args == "" } {
    if {[set result [catch {eval add_files $srcFiles} resulttext]]} {
      ::fwfwk::printDivider
      ::fwfwk::utils::cprint $resulttext {"ERROR" -fg red -style bright}
      ::fwfwk::printError "add_files failed"
      ::fwfwk::exit -2
    }
  } else {
    if {[set result [catch {eval add_files $args $srcFiles} resulttext]]} {
      ::fwfwk::printDivider
      ::fwfwk::utils::cprint $resulttext {"ERROR" -fg red -style bright}
      ::fwfwk::printError "add_files failed"
      ::fwfwk::exit -2
    }
  }

  # set files properties
  foreach srcItem $srcList  {
    set srcFile   [lindex $srcItem 0]
    set srcType   [lindex $srcItem 1]
    set srcLib    [lindex $srcItem 2]
    set usedIn    [lindex $srcItem 3]
    set procOrder [lindex $srcItem 4]
    # support upper and lower case in the list or different format
    switch -regexp [string tolower $srcType] {
      "^vhdl?$" {
        set_property FILE_TYPE "VHDL" [get_files $srcFile]
        if { $srcLib != "" } { set_property LIBRARY $srcLib [get_files $srcFile]
        } elseif { $library != "" } { set_property LIBRARY $library [get_files $srcFile] }
        if { $usedIn != "" } {
          if {[string compare -nocase $usedIn "simulation"] == 0} {
            # remove the sim file from 'sources_1' to place it in proper simulation fileset
            remove_files $srcFile
            # add file to sim fileset (if $srcLib is set, create corresponding fileset; otherwise use the default sim_1)
            if { $srcLib != "" }    {
              create_fileset -simset -quiet $srcLib
              add_files -fileset $srcLib -norecurse $srcFile
            } elseif { $library != "" } {
              create_fileset -simset -quiet $library
              add_files -fileset $library -norecurse $srcFile
            } else {
              add_files -fileset sim_1 -norecurse $srcFile
            }
          }
          set_property FILE_TYPE "VHDL" [get_files $srcFile]
          set_property USED_IN $usedIn [get_files $srcFile]
        }
      }
      "^vhdl? ?(20)?08$" {
        set_property FILE_TYPE "VHDL 2008" [get_files $srcFile]
        if { $srcLib != "" } { set_property LIBRARY $srcLib [get_files $srcFile]
        } elseif { $library != "" } { set_property LIBRARY $library [get_files $srcFile] }
        if { $usedIn != "" } {
          if {[string compare -nocase $usedIn "simulation"] == 0} {
            # remove the sim file from 'sources_1' to place it in proper simulation fileset
            remove_files $srcFile
            # add file to sim fileset (if $srcLib is set, create corresponding fileset; otherwise use the default sim_1)
            if { $srcLib != "" }    {
              create_fileset -simset -quiet $srcLib
              add_files -fileset $srcLib -norecurse $srcFile
            } elseif { $library != "" } {
              create_fileset -simset -quiet $library
              add_files -fileset $library -norecurse $srcFile
            } else {
              add_files -fileset sim_1 -norecurse $srcFile
            }
          }
          set_property FILE_TYPE "VHDL 2008" [get_files $srcFile]
          set_property USED_IN $usedIn [get_files $srcFile]
        }
      }
      "^v(erilog)?$" {
        set_property FILE_TYPE "Verilog" [get_files $srcFile]
        if { $srcLib != "" } { set_property LIBRARY $srcLib [get_files $srcFile]
        } elseif { $library != "" } { set_property LIBRARY $library [get_files $srcFile] }
        if { $usedIn != "" } {
          if {[string compare -nocase $usedIn "simulation"] == 0} {
            # remove the sim file from 'sources_1' to place it in proper simulation fileset
            remove_files $srcFile
            # add file to sim fileset (if $srcLib is set, create corresponding fileset; otherwise use the default sim_1)
            if { $srcLib != "" }    {
              create_fileset -simset -quiet $srcLib
              add_files -fileset $srcLib -norecurse $srcFile
            } elseif { $library != "" } {
              create_fileset -simset -quiet $library
              add_files -fileset $library -norecurse $srcFile
            } else {
              add_files -fileset sim_1 -norecurse $srcFile
            }
          }
          set_property FILE_TYPE "Verilog" [get_files $srcFile]
          set_property USED_IN $usedIn [get_files $srcFile]
        }
      }
      "^systemverilog|^sv$" {
        set_property FILE_TYPE "SystemVerilog" [get_files $srcFile]
        if { $srcLib != "" } { set_property LIBRARY $srcLib [get_files $srcFile]
        } elseif { $library != "" } { set_property LIBRARY $library [get_files $srcFile] }
        if { $usedIn != "" } {
          if {[string compare -nocase $usedIn "simulation"] == 0} {
            # remove the sim file from 'sources_1' to place it in proper simulation fileset
            remove_files $srcFile
            # add file to sim fileset (if $srcLib is set, create corresponding fileset; otherwise use the default sim_1)
            if { $srcLib != "" }    {
              create_fileset -simset -quiet $srcLib
              add_files -fileset $srcLib -norecurse $srcFile
            } elseif { $library != "" } {
              create_fileset -simset -quiet $library
              add_files -fileset $library -norecurse $srcFile
            } else {
              add_files -fileset sim_1 -norecurse $srcFile
            }
          }
          set_property FILE_TYPE "SystemVerilog" [get_files $srcFile]
          set_property USED_IN $usedIn [get_files $srcFile]
        }
      }
      "^xdc$" {
        remove_files $srcFile;
        # add file to constraints fileset (if $srcLib is set, create corresponding fileset; otherwise use the default constrs_1)
        if { $srcLib != "" }    {
          create_fileset -constrset -quiet $srcLib
          add_files -fileset $srcLib -norecurse $srcFile
        } else {
          add_files -fileset constrs_1 -norecurse $srcFile
        }
        set_property FILE_TYPE "XDC" [get_files $srcFile]
        if { $usedIn    != "" } { set_property USED_IN          $usedIn    [get_files $srcFile] }
        if { $procOrder != "" } { set_property PROCESSING_ORDER $procOrder [get_files $srcFile] }
      }
      "^tcl_cstr$" {
        remove_files $srcFile;
        # add file to constraints fileset (if $srcLib is set, create corresponding fileset; otherwise use the default constrs_1)
        if { $srcLib != "" }    {
          create_fileset -constrset -quiet $srcLib
          add_files -fileset $srcLib -norecurse $srcFile
        } else {
          add_files -fileset constrs_1 -norecurse $srcFile
        }
        set_property FILE_TYPE "TCL" [get_files $srcFile]
        if { $usedIn    != "" } { set_property USED_IN          $usedIn    [get_files $srcFile] }
        if { $procOrder != "" } { set_property PROCESSING_ORDER $procOrder [get_files $srcFile] }
      }
      "^tcl$" {
        # first remove the Tcl script from 'sources_1' to place it in proper utils fileset
        remove_files $srcFile
        # add script to utils_1 fileset and set file properties
        add_files -fileset utils_1 -norecurse $srcFile
        set_property FILE_TYPE "TCL" [get_files $srcFile]
        if { $srcLib != "" } { set_property LIBRARY $srcLib [get_files $srcFile]
        } elseif { $library != "" } { set_property LIBRARY $library [get_files $srcFile] }
        # if it's a 'pre/post step' hook script, then set the corresponding run property
        switch [string tolower $usedIn] {
          "synth.pre"                 { set_property STEPS.SYNTH_DESIGN.TCL.PRE                 [get_files $srcFile -of [get_fileset utils_1]] [get_runs [current_run -synthesis]];      set_property USED_IN "synthesis"      [get_files $srcFile]  }
          "synth.post"                { set_property STEPS.SYNTH_DESIGN.TCL.POST                [get_files $srcFile -of [get_fileset utils_1]] [get_runs [current_run -synthesis]];      set_property USED_IN "synthesis"      [get_files $srcFile]  }
          "opt.pre"                   { set_property STEPS.OPT_DESIGN.TCL.PRE                   [get_files $srcFile -of [get_fileset utils_1]] [get_runs [current_run -implementation]]; set_property USED_IN "implementation" [get_files $srcFile]  }
          "opt.post"                  { set_property STEPS.OPT_DESIGN.TCL.POST                  [get_files $srcFile -of [get_fileset utils_1]] [get_runs [current_run -implementation]]; set_property USED_IN "implementation" [get_files $srcFile]  }
          "power_opt.pre"             { set_property STEPS.POWER_OPT_DESIGN.TCL.PRE             [get_files $srcFile -of [get_fileset utils_1]] [get_runs [current_run -implementation]]; set_property USED_IN "implementation" [get_files $srcFile]  }
          "power_opt.post"            { set_property STEPS.POWER_OPT_DESIGN.TCL.POST            [get_files $srcFile -of [get_fileset utils_1]] [get_runs [current_run -implementation]]; set_property USED_IN "implementation" [get_files $srcFile]  }
          "place.pre"                 { set_property STEPS.PLACE_DESIGN.TCL.PRE                 [get_files $srcFile -of [get_fileset utils_1]] [get_runs [current_run -implementation]]; set_property USED_IN "implementation" [get_files $srcFile]  }
          "place.post"                { set_property STEPS.PLACE_DESIGN.TCL.POST                [get_files $srcFile -of [get_fileset utils_1]] [get_runs [current_run -implementation]]; set_property USED_IN "implementation" [get_files $srcFile]  }
          "post_place_power_opt.pre"  { set_property STEPS.POST_PLACE_POWER_OPT_DESIGN.TCL.PRE  [get_files $srcFile -of [get_fileset utils_1]] [get_runs [current_run -implementation]]; set_property USED_IN "implementation" [get_files $srcFile]  }
          "post_place_power_opt.post" { set_property STEPS.POST_PLACE_POWER_OPT_DESIGN.TCL.POST [get_files $srcFile -of [get_fileset utils_1]] [get_runs [current_run -implementation]]; set_property USED_IN "implementation" [get_files $srcFile]  }
          "phys_opt.pre"              { set_property STEPS.PHYS_OPT_DESIGN.TCL.PRE              [get_files $srcFile -of [get_fileset utils_1]] [get_runs [current_run -implementation]]; set_property USED_IN "implementation" [get_files $srcFile]  }
          "phys_opt.post"             { set_property STEPS.PHYS_OPT_DESIGN.TCL.POST             [get_files $srcFile -of [get_fileset utils_1]] [get_runs [current_run -implementation]]; set_property USED_IN "implementation" [get_files $srcFile]  }
          "route.pre"                 { set_property STEPS.ROUTE_DESIGN.TCL.PRE                 [get_files $srcFile -of [get_fileset utils_1]] [get_runs [current_run -implementation]]; set_property USED_IN "implementation" [get_files $srcFile]  }
          "route.post"                { set_property STEPS.ROUTE_DESIGN.TCL.POST                [get_files $srcFile -of [get_fileset utils_1]] [get_runs [current_run -implementation]]; set_property USED_IN "implementation" [get_files $srcFile]  }
          "write_bitstream.pre"       { set_property STEPS.WRITE_BITSTREAM.TCL.PRE              [get_files $srcFile -of [get_fileset utils_1]] [get_runs [current_run -implementation]]; set_property USED_IN "write_bitstream" [get_files $srcFile] }
          "write_bitstream.post"      { set_property STEPS.WRITE_BITSTREAM.TCL.POST             [get_files $srcFile -of [get_fileset utils_1]] [get_runs [current_run -implementation]]; set_property USED_IN "write_bitstream" [get_files $srcFile] }
          default                     { ::fwfwk::printWarning "Found unknown 'Tcl hook' type '$usedIn' for script $srcFile. Will keep the file in utils_1 fileset, but will not set any 'pre/post step' property." }
        }
      }
      default {
        #do nothing
      }
    }
  }

}

# ==============================================================================
proc buildProject {args} {
  # ------------------------------------------------------------------
  # compilation
  reset_run "impl_1"
  reset_run "synth_1"

  set VivadoJobs 1
  set VivadoHost ""

  if { [info exists ::env(FWK_VIVADO_JOBS)] } {
    set VivadoJobs $::env(FWK_VIVADO_JOBS)
    ::fwfwk::printInfo "Running Vivado with $VivadoJobs jobs. (env FWK_VIVADO_JOBS=$VivadoJobs)\n"
  } else {
    ::fwfwk::printWarning "No FWK_VIVADO_JOBS env variable set. Running Vivado with 1 job.\n"
  }
  if { [info exists ::env(FWK_VIVADO_HOST)] } {
    set VivadoHost "-host \{$::env(FWK_VIVADO_HOST) $VivadoJobs\}"
    ::fwfwk::printInfo "Running Vivado on host: $VivadoHost\n"
  } else {
    set VivadoHost "-jobs $VivadoJobs"
  }

  if {[catch { eval launch_runs synth_1 $VivadoHost } resulttext ]} { puts $resulttext; printRunResults ; ::fwfwk::exit -1 }
  if {[catch { wait_on_run synth_1 } resulttext ]} { ::fwfwk::exit -1 }

  if {[catch { eval launch_runs impl_1 $VivadoHost } resulttext ]} { puts $resulttext; printRunResults ;  ::fwfwk::exit -1 }
  if {[catch { wait_on_run impl_1 } resulttext ]} { ::fwfwk::exit -1 }

  if {[catch { eval launch_runs impl_1 -to_step write_bitstream $VivadoHost } resulttext ]} { puts $resulttext; printRunResults ;  ::fwfwk::exit -1 }
  wait_on_run [current_run]

  printRunResults
}

proc printRunResults {} {
  set runMessage {}
  ::fwfwk::printInfo "Results of the runs:"
  ::fwfwk::printDivider
  set runMessage {}
  # report error of run
  foreach run [get_runs] {
    set result [get_property STATUS $run]
    lappend runMessage [format "RUN: %-*s  %-*s" 27 $result 40 $run]
    set match [regexp {ERROR} $result totalmatch]
    if {1 == $match} {
      puts [::fwfwk::utils::cgrep $runMessage "ERROR" -fg red -style bright]
      set grepResult [::fwfwk::utils::grepFiles "ERROR:" [glob ${::fwfwk::PrjBuildPath}/${::fwfwk::PrjBuildName}.runs/${run}/*.log]]
      puts [::fwfwk::utils::cgrep $grepResult "ERROR" -fg red -style bright]
      ::fwfwk::exit -2
    }
  }
  foreach mes $runMessage { puts $mes }

  # check timing
  foreach run [get_runs] {
    set grepResult [::fwfwk::utils::grepFiles "Timing 38-282" [glob -nocomplain ${::fwfwk::PrjBuildPath}/${::fwfwk::PrjBuildName}.runs/${run}/*.vdi]]
    if { $grepResult != ""} {
      puts [::fwfwk::utils::cgrep $grepResult "CRITICAL WARNING" -fg yellow -style bright]
    }
  }
}

# ==============================================================================
proc packageIp { ip_folder nsTop } {
  set ipPath [file join $ip_folder [subst $${nsTop}::ModuleName]]

  ::fwfwk::printDivider
  ::fwfwk::printInfo "Creating IP in $ipPath"

  if {[catch {ipx::package_project -import_files -taxonomy /fwkModuleIP -root_dir $ipPath} msg]} {
    ::fwfwk::printError "$msg"
    ::fwfwk::exit -1
  }

  set core [ipx::current_core]

  # set nsTop ::fwfwk::src::${::fwfwk::Top}
  set VerMajor [subst $${nsTop}::VerMajor]
  set VerMinor [subst $${nsTop}::VerMinor]
  set VerPatch [subst $${nsTop}::VerPatch]

  set Vendor   [subst $${nsTop}::Vendor]
  set Name     [subst $${nsTop}::Name]
  set ModuleName  [subst $${nsTop}::ModuleName]

  set_property VERSION "${VerMajor}.${VerMinor}.${VerPatch}" $core
  set_property NAME ${ModuleName} $core
  set_property LIBRARY {fwk} $core
  set_property VENDOR $Vendor $core
  set_property SUPPORTED_FAMILIES { \
    spartan7    Production \
    artix7      Production \
    artix7l     Production \
    kintex7     Production \
    kintexuplus Production \
    virtex7     Production \
    virtexu     Production \
    virtexuplus Production \
    zynq        Production \
    zynquplus   Production \
    aspartan7   Production \
    aartix7     Production \
    azynq       Production \
    qartix7     Production \
    qkintex7    Production \
    qkintex7l   Production \
    qvirtex7    Production \
    qzynq       Production \
  } $core

  if { [info procs ${nsTop}::doOnMakeIp] > 0 } {
    ${nsTop}::doOnMakeIp
  }

  ipx::create_xgui_files $core
  ipx::update_checksums $core
  ipx::save_core $core

}

# ==============================================================================
#! add from repository
proc addIp { IpVendor IpLibrary IpName InsName IpConfig } {

  create_ip -name ${IpName} -vendor ${IpVendor} -library ${IpLibrary} -module_name ${InsName}

}

# ==============================================================================
#! add and generate tool IPs using definition list
proc addGenIPs { args ipsList } {

  foreach item $ipsList {
    set ipCoreFile  [lindex $item 0]
    set ipFileType  [lindex $item 1]
    set useIpCon    [lindex $item 2]
    ### set genSimFiles [lindex $item 3]
    set targetType  [lindex $item 3]

    if { "xci" == [string tolower $ipFileType] } {
      ::fwfwk::printInfo "Adding XCI IP core from the list: $ipCoreFile"

      set ipRepoDir   [file dirname $ipCoreFile]
      set ipRepoName  [file rootname [file tail $ipCoreFile]]

      set_property IP_REPO_PATHS $ipRepoDir [current_project]
      update_ip_catalog

      import_ip -files $ipCoreFile

      if {[string compare -nocase $useIpCon "true"] == 0} {
        ::fwfwk::printInfo "Will use the XDC(s) of the IP '$ipRepoName'"
      } else {
        set ipXdcFiles [get_files -of_objects [get_files "${ipRepoName}.xci"] -filter {FILE_TYPE == XDC}]
        set_property IS_ENABLED FALSE [get_files $ipXdcFiles]
        ::fwfwk::printInfo "Disabled the XDC(s) of the IP '$ipRepoName'"
      }

      # ### ========= PREVIOUS IMPLEMENTATION =========
      # if {[string compare -nocase $genSimFiles "true"] == 0} {
      #   ::fwfwk::printInfo "Will generate simulation files for the IP $ipRepoName."
      #   generate_target simulation [get_ips $ipRepoName]
      # } else {
      #   ::fwfwk::printInfo "No simulation file will be generated for the IP $ipRepoName."
      # }

      ### ========= NEW IMPLEMENTATION =========
      generate_target $targetType [get_ips $ipRepoName]
      export_ip_user_files -of_objects [get_ips $ipRepoName] -no_script -sync -force -quiet

      # # Enable this to print out the list of simulation files for the given IP
      # if { ( [string compare -nocase $targetType "all"]        == 0 ) ||
      #      ( [string compare -nocase $targetType "simulation"] == 0 ) } {
      #   set simFiles [get_files -compile_order sources -used_in simulation -of_objects [get_ips $ipRepoName]]
      #   foreach item $simFiles {
      #     if {[string first $ipRepoName [file tail $item]] == 0} {
      #        ::fwfwk::printInfo "IP Sim File : $item"
      #     }
      #   }
      # }

    }
  }

}


# ==============================================================================
#! create, customize, generate and add IP
proc generateIP { ipVendor ipLibrary ipName ipConfig insName } {

  create_ip -name ${ipName} -vendor ${ipVendor} -library ${ipLibrary} -module_name ${insName}
  set_property -dict $ipConfig [get_ips $insName]
  generate_target all [get_files ${::fwfwk::PrjBuildPath}/${::fwfwk::PrjBuildName}.srcs/sources_1/ip/${insName}/${insName}.xci]
  create_ip_run [get_files ${::fwfwk::PrjBuildPath}/${::fwfwk::PrjBuildName}.srcs/sources_1/ip/${insName}/${insName}.xci]

}


# ==============================================================================
#! create, customize, generate, wrap and add IP
proc wrapIP { ipVendor ipLibrary ipName ipConfig insName } {

  ::fwfwk::tool::generateIP ${ipVendor} ${ipLibrary} ${ipName} ${ipConfig} ${insName}

  set ipPath ${::fwfwk::PrjBuildPath}/${::fwfwk::PrjBuildName}.gen/sources_1/ip/${insName}

  ::fwfwk::printInfo "INFO: Generating wrapper for '${insName}' IP..."

  # capture ports and mapping from the template
  set vho [open "${ipPath}/${insName}.vho" r]
  set port {}
  set map {}
  set state 0
  while { [gets $vho line] >= 0 } {
    switch $state {
      1 {
        if {[string first "(" [string trimleft $line]] != 0 && [string first "--" [string trimleft $line]] != 0} {lappend port [string tolower $line]}
        }
      2 {
        if {[string first "(" [string trimleft $line]] != 0 && [string first "--" [string trimleft $line]] != 0} {lappend map $line}
        }
    }
    if {[string first "PORT MAP (" [string trimleft $line]] == 0 || [string first "port map (" [string trimleft $line]] == 0} {set state 2} \
    elseif {[string first "PORT (" [string trimleft $line]] == 0 || [string first "port" [string trimleft $line]] == 0} {set state 1} \
    elseif {[string first ");" [string trimleft $line]] == 0} {set state 0}
  }
  close $vho

  # generate the wrapper
  set vhd [open "${ipPath}/${insName}_wrapper.vhd" w]

  puts $vhd \
{--------------------------------------------------------------------------------
--          ____  _____________  __                                           --
--         / __ \/ ____/ ___/\ \/ /                 _   _   _                 --
--        / / / / __/  \__ \  \  /                 / \ / \ / \                --
--       / /_/ / /___ ___/ /  / /               = ( M | S | K )=              --
--      /_____/_____//____/  /_/                   \_/ \_/ \_/                --
--                                                                            --
--------------------------------------------------------------------------------
--! @copyright (c) 2023 DESY
--! SPDX-License-Identifier: Apache-2.0
--------------------------------------------------------------------------------}

  puts $vhd \
"--! @date 2023-02-22
--! @author Burak Dursun <burak.dursun@desy.de>
--------------------------------------------------------------------------------
--! @brief generated wrapper for ${insName} instance
--!
--! this file is generated using the VHDL instantiation template of generated IP
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity ${insName}_wrapper is
  port ("

  foreach line $port {puts $vhd $line}

  puts $vhd \
"end entity ${insName}_wrapper;

architecture generated of ${insName}_wrapper is

  component ${insName} is
    port ("

  foreach line $port {puts $vhd "  $line"}

  puts $vhd \
"  end component ${insName};

begin

  ins_${insName}: ${insName}
    port map ("

  foreach line $map {puts $vhd "  $line"}

  puts $vhd \
"
end architecture generated;
"

  close $vhd

  addSources "" ${::fwfwk::PrjBuildPath}/${::fwfwk::PrjBuildName}.gen/sources_1/ip/${insName}/${insName}_wrapper.vhd

}

# ==============================================================================
#! export HW and bit file to out folder
proc exportOut {} {

  set top [get_property TOP [current_fileset]]
  set dir [get_property DIRECTORY [get_runs -filter {CURRENT_STEP==write_bitstream}]]

  # we assume that bit file is always after finished build, if not somethings went wrong
  file copy -force ${dir}/${top}.bit $::fwfwk::ProjectPath/out/${::fwfwk::PrjBuildName}/${::fwfwk::PrjBuildName}_${::fwfwk::VerString}.bit
  file copy -force ${dir}/${top}.bin $::fwfwk::ProjectPath/out/${::fwfwk::PrjBuildName}/${::fwfwk::PrjBuildName}_${::fwfwk::VerString}.bin

  # Also export .ltx file (probe file) if exists
  if { [file exists ${dir}/${top}.ltx ]} {
    ::fwfwk::catchHdl "file copy -force ${dir}/${top}.ltx $::fwfwk::ProjectPath/out/${::fwfwk::PrjBuildName}/${::fwfwk::PrjBuildName}_${::fwfwk::VerString}.ltx"
  }

  # Also export .mmi file (meminfo, from write_mem_info) if exists
  if { [file exists ${dir}/${top}.mmi ]} {
    ::fwfwk::catchHdl "file copy -force ${dir}/${top}.mmi $::fwfwk::ProjectPath/out/${::fwfwk::PrjBuildName}/${::fwfwk::PrjBuildName}_${::fwfwk::VerString}.mmi"
  }

  if {[lsearch [info commands] write_hw_platform] < 0} {
    ::fwfwk::printWarning "Will not export .xsa file: Only supported by Vivado 2019.2 or later"

    ::fwfwk::printInfo "Exporting .hdf for SDK to $::fwfwk::PrjPath/${::fwfwk::PrjBuildName}/${::fwfwk::PrjBuildName}.sdk"
    file mkdir $::fwfwk::PrjPath/${::fwfwk::PrjBuildName}/${::fwfwk::PrjBuildName}.sdk
    file copy -force $::fwfwk::PrjPath/${::fwfwk::PrjBuildName}/${::fwfwk::PrjBuildName}.runs/impl_1/$top.sysdef $::fwfwk::PrjPath/${::fwfwk::PrjBuildName}/${::fwfwk::PrjBuildName}.sdk/$top.hdf
  } else {
    write_hw_platform -fixed -force -include_bit -file $::fwfwk::ProjectPath/out/${::fwfwk::PrjBuildName}/${::fwfwk::PrjBuildName}_${::fwfwk::VerString}.xsa

    ::fwfwk::printInfo "Exporting .hdf for SDK to $::fwfwk::PrjPath/${::fwfwk::PrjBuildName}/${::fwfwk::PrjBuildName}.sdk"
    file mkdir $::fwfwk::PrjPath/${::fwfwk::PrjBuildName}/${::fwfwk::PrjBuildName}.sdk
    file copy -force $::fwfwk::ProjectPath/out/${::fwfwk::PrjBuildName}/${::fwfwk::PrjBuildName}_${::fwfwk::VerString}.xsa $::fwfwk::PrjPath/${::fwfwk::PrjBuildName}/${::fwfwk::PrjBuildName}.sdk/$top.hdf
  }
}

#! open SDK
proc openSdk {} {
  update_compile_order -fileset [current_fileset]
  set top [get_property TOP [current_fileset]]
  launch_sdk -workspace $::fwfwk::PrjPath/${::fwfwk::PrjBuildName}/${::fwfwk::PrjBuildName}.sdk -hwspec $::fwfwk::PrjPath/${::fwfwk::PrjBuildName}/${::fwfwk::PrjBuildName}.sdk/$top.hdf
}

# ==============================================================================
#! export HW and bit file to out folder
proc simProject {} {

  Create Project from  "Running the simulation: $::fwfwk::src::SimTop with Simulation Time: $::fwfwk::src::SimTime"
  update_compile_order -fileset sim_1
  set_property top $::fwfwk::src::SimTop [get_filesets sim_1]
  set_property -name {xsim.simulate.runtime} -value $::fwfwk::src::SimTime -objects [get_filesets sim_1]
  launch_simulation

  create_wave_config
  save_wave_config $::fwfwk::PrjBuildPath/${::fwfwk::PrjBuildName}.wcfg
  add_files -fileset sim_1 -norecurse $::fwfwk::PrjBuildPath/${::fwfwk::PrjBuildName}.wcfg
  set_property xsim.view $::fwfwk::PrjBuildPath/${::fwfwk::PrjBuildName}.wcfg [get_filesets sim_1]

}
