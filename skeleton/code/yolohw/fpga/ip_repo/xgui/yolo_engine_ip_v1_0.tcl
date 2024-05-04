# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "A" -parent ${Page_0}
  ipgui::add_param $IPINST -name "AXI_WIDTH_AD" -parent ${Page_0}
  ipgui::add_param $IPINST -name "AXI_WIDTH_DA" -parent ${Page_0}
  ipgui::add_param $IPINST -name "AXI_WIDTH_DS" -parent ${Page_0}
  ipgui::add_param $IPINST -name "AXI_WIDTH_ID" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_S00_AXI_ADDR_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_S00_AXI_DATA_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "D" -parent ${Page_0}
  ipgui::add_param $IPINST -name "I" -parent ${Page_0}
  ipgui::add_param $IPINST -name "L" -parent ${Page_0}
  ipgui::add_param $IPINST -name "M" -parent ${Page_0}
  ipgui::add_param $IPINST -name "MEM_ADDRW" -parent ${Page_0}
  ipgui::add_param $IPINST -name "MEM_DW" -parent ${Page_0}


}

proc update_PARAM_VALUE.A { PARAM_VALUE.A } {
	# Procedure called to update A when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.A { PARAM_VALUE.A } {
	# Procedure called to validate A
	return true
}

proc update_PARAM_VALUE.AXI_WIDTH_AD { PARAM_VALUE.AXI_WIDTH_AD } {
	# Procedure called to update AXI_WIDTH_AD when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AXI_WIDTH_AD { PARAM_VALUE.AXI_WIDTH_AD } {
	# Procedure called to validate AXI_WIDTH_AD
	return true
}

proc update_PARAM_VALUE.AXI_WIDTH_DA { PARAM_VALUE.AXI_WIDTH_DA } {
	# Procedure called to update AXI_WIDTH_DA when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AXI_WIDTH_DA { PARAM_VALUE.AXI_WIDTH_DA } {
	# Procedure called to validate AXI_WIDTH_DA
	return true
}

proc update_PARAM_VALUE.AXI_WIDTH_DS { PARAM_VALUE.AXI_WIDTH_DS } {
	# Procedure called to update AXI_WIDTH_DS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AXI_WIDTH_DS { PARAM_VALUE.AXI_WIDTH_DS } {
	# Procedure called to validate AXI_WIDTH_DS
	return true
}

proc update_PARAM_VALUE.AXI_WIDTH_ID { PARAM_VALUE.AXI_WIDTH_ID } {
	# Procedure called to update AXI_WIDTH_ID when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AXI_WIDTH_ID { PARAM_VALUE.AXI_WIDTH_ID } {
	# Procedure called to validate AXI_WIDTH_ID
	return true
}

proc update_PARAM_VALUE.C_S00_AXI_ADDR_WIDTH { PARAM_VALUE.C_S00_AXI_ADDR_WIDTH } {
	# Procedure called to update C_S00_AXI_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S00_AXI_ADDR_WIDTH { PARAM_VALUE.C_S00_AXI_ADDR_WIDTH } {
	# Procedure called to validate C_S00_AXI_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S00_AXI_DATA_WIDTH { PARAM_VALUE.C_S00_AXI_DATA_WIDTH } {
	# Procedure called to update C_S00_AXI_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S00_AXI_DATA_WIDTH { PARAM_VALUE.C_S00_AXI_DATA_WIDTH } {
	# Procedure called to validate C_S00_AXI_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.D { PARAM_VALUE.D } {
	# Procedure called to update D when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.D { PARAM_VALUE.D } {
	# Procedure called to validate D
	return true
}

proc update_PARAM_VALUE.I { PARAM_VALUE.I } {
	# Procedure called to update I when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.I { PARAM_VALUE.I } {
	# Procedure called to validate I
	return true
}

proc update_PARAM_VALUE.L { PARAM_VALUE.L } {
	# Procedure called to update L when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.L { PARAM_VALUE.L } {
	# Procedure called to validate L
	return true
}

proc update_PARAM_VALUE.M { PARAM_VALUE.M } {
	# Procedure called to update M when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.M { PARAM_VALUE.M } {
	# Procedure called to validate M
	return true
}

proc update_PARAM_VALUE.MEM_ADDRW { PARAM_VALUE.MEM_ADDRW } {
	# Procedure called to update MEM_ADDRW when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.MEM_ADDRW { PARAM_VALUE.MEM_ADDRW } {
	# Procedure called to validate MEM_ADDRW
	return true
}

proc update_PARAM_VALUE.MEM_DW { PARAM_VALUE.MEM_DW } {
	# Procedure called to update MEM_DW when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.MEM_DW { PARAM_VALUE.MEM_DW } {
	# Procedure called to validate MEM_DW
	return true
}


proc update_MODELPARAM_VALUE.MEM_ADDRW { MODELPARAM_VALUE.MEM_ADDRW PARAM_VALUE.MEM_ADDRW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.MEM_ADDRW}] ${MODELPARAM_VALUE.MEM_ADDRW}
}

proc update_MODELPARAM_VALUE.MEM_DW { MODELPARAM_VALUE.MEM_DW PARAM_VALUE.MEM_DW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.MEM_DW}] ${MODELPARAM_VALUE.MEM_DW}
}

proc update_MODELPARAM_VALUE.A { MODELPARAM_VALUE.A PARAM_VALUE.A } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.A}] ${MODELPARAM_VALUE.A}
}

proc update_MODELPARAM_VALUE.D { MODELPARAM_VALUE.D PARAM_VALUE.D } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.D}] ${MODELPARAM_VALUE.D}
}

proc update_MODELPARAM_VALUE.I { MODELPARAM_VALUE.I PARAM_VALUE.I } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.I}] ${MODELPARAM_VALUE.I}
}

proc update_MODELPARAM_VALUE.L { MODELPARAM_VALUE.L PARAM_VALUE.L } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.L}] ${MODELPARAM_VALUE.L}
}

proc update_MODELPARAM_VALUE.M { MODELPARAM_VALUE.M PARAM_VALUE.M } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.M}] ${MODELPARAM_VALUE.M}
}

proc update_MODELPARAM_VALUE.AXI_WIDTH_AD { MODELPARAM_VALUE.AXI_WIDTH_AD PARAM_VALUE.AXI_WIDTH_AD } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AXI_WIDTH_AD}] ${MODELPARAM_VALUE.AXI_WIDTH_AD}
}

proc update_MODELPARAM_VALUE.AXI_WIDTH_ID { MODELPARAM_VALUE.AXI_WIDTH_ID PARAM_VALUE.AXI_WIDTH_ID } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AXI_WIDTH_ID}] ${MODELPARAM_VALUE.AXI_WIDTH_ID}
}

proc update_MODELPARAM_VALUE.AXI_WIDTH_DA { MODELPARAM_VALUE.AXI_WIDTH_DA PARAM_VALUE.AXI_WIDTH_DA } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AXI_WIDTH_DA}] ${MODELPARAM_VALUE.AXI_WIDTH_DA}
}

proc update_MODELPARAM_VALUE.AXI_WIDTH_DS { MODELPARAM_VALUE.AXI_WIDTH_DS PARAM_VALUE.AXI_WIDTH_DS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AXI_WIDTH_DS}] ${MODELPARAM_VALUE.AXI_WIDTH_DS}
}

proc update_MODELPARAM_VALUE.C_S00_AXI_DATA_WIDTH { MODELPARAM_VALUE.C_S00_AXI_DATA_WIDTH PARAM_VALUE.C_S00_AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S00_AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.C_S00_AXI_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_S00_AXI_ADDR_WIDTH { MODELPARAM_VALUE.C_S00_AXI_ADDR_WIDTH PARAM_VALUE.C_S00_AXI_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S00_AXI_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_S00_AXI_ADDR_WIDTH}
}

