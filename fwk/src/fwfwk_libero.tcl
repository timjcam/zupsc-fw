#proc addGenIPs { args sources} {}

proc addSources {args srcList} {
  # default library work
  set library ""
  set file_type ""

  # parse the library argument
  set args [::fwfwk::utils::parseArgValue $args "-lib" library]
  set args [::fwfwk::utils::parseArgValue $args "-type" file_type]

  if { $library != "" } {
    add_library -library $library
  }
  if { $file_type == "" } {
    set file_type hdl_source
  }
  foreach tmp $srcList {
    set file_name [lindex $tmp 0]
    if { $library == "" } {
      if {[set result [catch [create_links -$file_type $file_name] resulttext]]} {
        ::fwfwk::printDivider
        ::fwfwk::utils::cprint $resulttext {"ERROR" -fg red -style bright}
        ::fwfwk::printError "create_links failed"
        ::fwfwk::exit -2
      }
    } else {
      if {[set result [catch [create_links -$file_type $file_name -library $library] resulttext]]} {
        ::fwfwk::printDivider
        ::fwfwk::utils::cprint $resulttext {"ERROR" -fg red -style bright}
        ::fwfwk::printError "create_links failed"
        ::fwfwk::exit -2
      }
    }
  }
}

#proc addToolLibraries {} {}

proc buildProject {args} {
  clean_tool -name {SYNTHESIZE}
  run_tool -name {SYNTHESIZE}

  clean_tool -name {COMPILE}
  clean_tool -name {PLACEROUTE}
  clean_tool -name {VERIFYTIMING}
  clean_tool -name {VERIFYPOWER}
  clean_tool -name {EXPORTSDF}
  clean_tool -name {GENERATEPROGRAMMINGDATA}
  clean_tool -name {GENERATEPROGRAMMINGFILE}

  run_tool -name {COMPILE}
  run_tool -name {PLACEROUTE}

  project_settings -hdl {VHDL}
  run_tool -name {EXPORTSDF}
  project_settings -hdl {VERILOG}
  run_tool -name {EXPORTSDF}

  run_tool -name {VERIFYTIMING}
  run_tool -name {VERIFYPOWER}

  run_tool -name {GENERATEPROGRAMMINGDATA}
  run_tool -name {GENERATEPROGRAMMINGFILE}
}


proc cleanProject {} {
}

proc createProject {} {
  file delete -force $::fwfwk::PrjBuildName

  new_project \
    -name "$::fwfwk::PrjBuildName" \
    -location "$::fwfwk::PrjBuildName" \
    -family $::fwfwk::FamilyType \
    -die $::fwfwk::Die \
    -package $::fwfwk::Package \
    -hdl "VHDL"

  select_profile -name {Synplify Pro ME}
  select_profile -name {ModelSim ME Pro}
}

proc exportOut {} {
  export_bitstream_file \
    -file_name ${::fwfwk::src::Top} \
    -export_dir "$::fwfwk::ProjectPath/out/" \
    ${::fwfwk::ExportBitstreamFileOptions}

  export_prog_job \
    -job_file_name ${::fwfwk::src::Top} \
    -export_dir "$::fwfwk::ProjectPath/out/" \
    ${::fwfwk::ExportProgJobOptions}

  export_pin_reports \
    -export_dir "$::fwfwk::ProjectPath/out/" \
    ${::fwfwk::ExportPinReportsOptions}
}

#proc genAddIP { IpPath } {}

proc openProject {} {
  open_project -file ./$::fwfwk::PrjBuildName.prjx
}

proc closeProject {} {
  close_project -save 1
}

proc saveProject {} {
  save_project
}

#proc simProject {} {}

#proc startProjectGui {} {}

#proc testProject {} {}
