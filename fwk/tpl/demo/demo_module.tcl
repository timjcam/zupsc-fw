################################################################################
# Main tcl for the Demo module
################################################################################

proc init {} {
  variable Config

  # Declaring to FWK that Config variables should be rendered 
  # as VHDL package and added to the project
  variable addConfigAsHdl 1
  
  # Setting default value for Reset Type
  set Config(C_RESET_TYPE) "SYNC"
}

proc setSources {} {
  variable Sources
  lappend Sources {"../hdl/app_demo_top.vhd" "VHDL 2008"}
}

proc setAddressSpace {} {
}

proc doOnCreate {} {
  addSources "Sources"
}

proc doOnBuild {} {
}

proc setSim {} {
}
