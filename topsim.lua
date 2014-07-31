--------------------------------------------------------------------------------
-- TOPINKA SIMULATOR CUSTOM LUA SCRIPTS FOR IFLY 737 ---------------------------
-- 
-- By Chuck Topinka (chuck@chucktopinka.com)
--
-- GFConfig and FSUIPC button assignments are used for most input purposes. Lua
-- script is pretty much just for controlling indicators that were assigned away
-- from GFConfig (which is most of them).
--
-- File history
-- 2014-07-01: Added flight attendant and ground crew simulation
-- 2014-06-30: Initial creation completed
-- 2014-06-24: Initial creation
--------------------------------------------------------------------------------
-- User settings
bright_bright = 15	-- GoFlight brightness for alerts
bright_norm   = 8	-- GoFlight brightness for normal ops
bright_low	  = 4	-- GoFlight brightness for certain conditions

preflight_time	= 20	-- Number of minutes prior to pushback

-- Panel definitions
acp_model		= GFP8
acp_unit		= 0
efis_model		= GFRP48
efis_unit		= 0
electric_model		= GFP8
electric_unit		= 3
fuel_system_model	= GFT8
fuel_system_unit	= 1
inst_model		= GFRP48
inst_unit		= 2
light_model		= GFT8
light_unit		= 0
mcp_model		= GFMCP
mcp_unit		= 0
misc_model		= GFP8
misc_unit		= 1
xpdr_model		= GF46
xpdr_unit		= 0
--------------------------------------------------------------------------------

-- Know we got in here.
gfd.SetDisplay(GF46,0,0,"IFLY")
gfd.SetDisplay(GF46,0,1,140701)

--------------------------------------------------------------------------------
-- Initialize aircraft (sets aircraft to match T8 switch settings)
--------------------------------------------------------------------------------
ipc.sleep(5000) -- Sleep for 5 seconds to let the aircraft load

gfd.GetValues(light_model,light_unit)
if gfd.TestButton(0) then -- Runway Turnoff Lights
	ipc.writeUW("9400",5)
else
	ipc.writeUW("9400",4)
end
if gfd.TestButton(1) then -- Taxi Lights
	ipc.writeUW("9400",8)
else
	ipc.writeUW("9400",7)
end
if gfd.TestButton(2) then -- APU is a spring loaded starter so N/A
end
if gfd.TestButton(3) then -- Logo Lights
	ipc.writeUW("9400",11)
else
	ipc.writeUW("9400",10)
end
if gfd.TestButton(4) then -- Position Lights
	ipc.writeUW("9400",15)
else
	if gfd.TestButton(5) then -- Strobe Lights
		ipc.writeUW("9400",14)
	else
		ipc.writeUW("9400",16)
	end
end
if gfd.TestButton(6) then -- Anti Collision Lights
	ipc.writeUW("9400",25)
else
	ipc.writeUW("9400",24)
end
if gfd.TestButton(7) then -- Wing Lights
	ipc.writeUW("9400",22)
else
	ipc.writeUW("9400",21)
end

gfd.GetValues(fuel_system_model,fuel_system_unit)
if gfd.TestButton(0) then -- Fuel Crossfeed Valve
	ipc.writeUW("9400",1118)
else
	ipc.writeUW("9400",1119)
end
if gfd.TestButton(1) then -- Fuel Aft 1 Pump
	ipc.writeUW("9400",1127)
else
	ipc.writeUW("9400",1128)
end
if gfd.TestButton(2) then -- Fuel Fwd 1 Pump
	ipc.writeUW("9400",1130)
else
	ipc.writeUW("9400",1131)
end
if gfd.TestButton(3) then -- Center Left Pump
	ipc.writeUW("9400",1121)
else
	ipc.writeUW("9400",1122)
end
if gfd.TestButton(4) then -- Center Right Pump
	ipc.writeUW("9400",1124)
else
	ipc.writeUW("9400",1125)
end
if gfd.TestButton(5) then -- Fuel Fwd 2 Pump
	ipc.writeUW("9400",1136)
else
	ipc.writeUW("9400",1137)
end
if gfd.TestButton(6) then -- Fuel Aft 2 Pump
	ipc.writeUW("9400",1133)
else
	ipc.writeUW("9400",1134)
end
if gfd.TestButton(7) then -- Landing Lights
	ipc.writeUW("9400",2)
else
	ipc.writeUW("9400",1)
end



-- END Initialize aircraft (sets aircraft to match T8 switch settings)
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- AUDIO CONTROL PANEL (ACP) ---------------------------------------------------
--
-- Offset list
-- No offsets listed
--
-- END AUDIO CONTROL PANEL (ACP) -----------------------------------------------
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- ELECTRICAL PANEL ------------------------------------------------------------
--
-- Offset list
-- 940E 6 GRD_POWER_AVAILABLE_Light_Status
-- 940F 3 ENG_1_GEN_OFF_BUS_Light_Status
-- 940F 4 ENG_2_GEN_OFF_BUS_Light_Status
-- 940F 5 APU_GEN_OFF_BUS_Light_Status
--
--------------------------------------------------------------------------------

-- Ground Power Available Light
function updateGpuAvailLight(offset, value)
	-- Turn light off
	gfd.ClearLight(electric_model,electric_unit,0)
	if logic.And(value,0x0040) ~=0 then
		-- Turn light on
		gfd.SetLight(electric_model,electric_unit,0)
	end
end
event.offset("940E", "UB", "updateGpuAvailLight")

-- Generator Off Bus Lights
function updateGenOffBusLights(offset, value)
	-- Turn lights off
	gfd.ClearLight(electric_model,electric_unit,1)
	gfd.ClearLight(electric_model,electric_unit,2)
	gfd.ClearLight(electric_model,electric_unit,3)
	gfd.ClearLight(electric_model,electric_unit,4)
	
	-- Turn lights on
	if logic.And(value,0x0008) ~=0 then
		-- ENG_1_GEN_OFF_BUS_Light_Status
		gfd.SetLight(electric_model,electric_unit,1)
	end
	if logic.And(value,0x0010) ~=0 then
		-- ENG_2_GEN_OFF_BUS_Light_Status
		gfd.SetLight(electric_model,electric_unit,4)
	end
	if logic.And(value,0x0020) ~=0 then
		-- APU_GEN_OFF_BUS_Light_Status
		gfd.SetLight(electric_model,electric_unit,2)
		gfd.SetLight(electric_model,electric_unit,3)
	end
end
event.offset("940F", "UB", "updateGenOffBusLights")

-- END ELECTRICAL PANEL --------------------------------------------------------
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- FUEL SYSTEM -----------------------------------------------------------------
-- 
-- Offset list
-- 941B 1/2 VALVE_OPEN_Light_Status (1 dim 2 bright)
-- 941C 0 LOW_PRESSURE_Light_CENTER_L_Status
-- 941C 1 LOW_PRESSURE_Light_CENTER_R_Status
-- 941C 2 LOW_PRESSURE_Light_L_AFT_Status
-- 941C 3 LOW_PRESSURE_Light_L_FWD_Status
-- 941C 4 LOW_PRESSURE_Light_R_FWD_Status
-- 941C 5 LOW_PRESSURE_Light_R_AFT_Status
--
--------------------------------------------------------------------------------

-- Crossfeed Valve Light
function updateXfeedValveLight(offset, value)
	if logic.And(value,0x0004) ~=0 then
		-- valve in transit
		-- Bright display. XXX Can we set brightness of just one LED?
		gfd.SetBright(fuel_system_model, fuel_system_unit, bright_bright)		
		gfd.SetLight(fuel_system_model, fuel_system_unit, 0)
	elseif logic.And(value,0x0002) ~=0 then
		-- valve open
		-- regular display. XXX Can we set brightness of just one LED?
		gfd.SetBright(fuel_system_model, fuel_system_unit, bright_low)
		gfd.SetLight(fuel_system_model, fuel_system_unit, 0)
	else
		-- light off
		gfd.ClearLight(fuel_system_model, fuel_system_unit, 0)
	end
end
event.offset("941B", "UB", "updateXfeedValveLight")

-- Fuel Pressure Lights
function updateFuelPressureLights(offset, value)
	-- Turn off all fuel system lights
	gfd.ClearLight(fuel_system_model, fuel_system_unit, 1)
	gfd.ClearLight(fuel_system_model, fuel_system_unit, 2)
	gfd.ClearLight(fuel_system_model, fuel_system_unit, 3)
	gfd.ClearLight(fuel_system_model, fuel_system_unit, 4)
	gfd.ClearLight(fuel_system_model, fuel_system_unit, 5)
	gfd.ClearLight(fuel_system_model, fuel_system_unit, 6)
	
	if logic.And(value,0x0001) ~=0 then
		-- LOW_PRESSURE_Light_CENTER_L_Status On
		gfd.SetLight(fuel_system_model, fuel_system_unit, 3)
	end
	if logic.And(value,0x0002) ~=0 then
		-- LOW_PRESSURE_Light_CENTER_R_Status On
		gfd.SetLight(fuel_system_model, fuel_system_unit, 4)
	end
	if logic.And(value,0x0004) ~=0 then
		-- LOW_PRESSURE_Light_L_AFT_Status On
		gfd.SetLight(fuel_system_model, fuel_system_unit, 1)
	end
	if logic.And(value,0x0008) ~=0 then
		-- LOW_PRESSURE_Light_L_FWD_Status On
		gfd.SetLight(fuel_system_model, fuel_system_unit, 2)
	end
	if logic.And(value,0x0010) ~=0 then
		-- LOW_PRESSURE_Light_R_FWD_Status On
		gfd.SetLight(fuel_system_model, fuel_system_unit, 5)
	end
	if logic.And(value,0x0020) ~=0 then
		-- LOW_PRESSURE_Light_R_AFT_Status On
		gfd.SetLight(fuel_system_model, fuel_system_unit, 6)
	end
end
event.offset("941C", "UB", "updateFuelPressureLights")

-- END FUEL SYSTEM -------------------------------------------------------------
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- INSTRUMENT PANEL ------------------------------------------------------------
--
-- Offset list
-- 940B 2 AP_Indicators_Light_Status amber
-- 940B 3 AP_Indicators_Light_Status red
-- 940B 4 AT_Indicators_Light_Status amber
-- 940B 5 AT_Indicators_Light_Status red
-- 940B 6 FMC1_Indicators_Light_Status
-- 9420 0 Fire_Warning_Light_Status
-- 9420 1 Master_Caution_Light_Status
-- 941E 6 AUTO_BRAKE_DISARM_Light_Status
--
--------------------------------------------------------------------------------

-- Disengage Lights
function setDisengageLights(offset, value)
	-- Clear lights
	gfd.ClearLight(inst_model, inst_unit, 2)
	gfd.ClearLight(inst_model, inst_unit, 3)
	gfd.ClearLight(inst_model, inst_unit, 4)
	
	-- Set lights
	if logic.And(value,0x0004) ~=0 then
		-- AP_Indicators_Light_Status amber
		gfd.SetLight(inst_model, inst_unit, 2)
	end
	if logic.And(value,0x0008) ~=0 then
		-- AP_Indicators_Light_Status red
		gfd.SetLight(inst_model, inst_unit, 2)
	end
	if logic.And(value,0x0010) ~=0 then
		-- AT_Indicators_Light_Status amber
		gfd.SetLight(inst_model, inst_unit, 3)
	end
	if logic.And(value,0x0020) ~=0 then
		-- AT_Indicators_Light_Status red
		gfd.SetLight(inst_model, inst_unit, 3)
	end
	if logic.And(value,0x0040) ~=0 then
		-- FMC1_Indicators_Light_Status
		gfd.SetLight(inst_model, inst_unit, 4)
	end
end
event.offset("940B", "UB", "setDisengageLights")

-- Set Fire Warn and Caution Lights
function setWarnLights(offset, value)
	-- Clear lights
	gfd.ClearLight(inst_model, inst_unit, 0)
	gfd.ClearLight(inst_model, inst_unit, 1)
	
	-- Set lights
	if logic.And(value,0x0001) ~=0 then
		-- Fire_Warning_Light_Status
		gfd.SetLight(inst_model, inst_unit, 0)
	end
	if logic.And(value,0x0002) ~=0 then
		-- Master_Caution_Light_Status
		gfd.SetLight(inst_model, inst_unit, 1)
	end
end
event.offset("9420", "UB", "setWarnLights")

-- Set Autobrake Disarm Light
function setAutobrakeDisarmLight(offset, value)
	-- Clear light
	gfd.ClearLight(inst_model, inst_unit, 7)
	
	-- Set light
	if logic.And(value,0x0040) ~=0 then
		-- ENGINE_CONTROL_1_Light_Status
		gfd.SetLight(inst_model, inst_unit, 7)
	end
end
event.offset("941E", "UB", "setAutobrakeDisarmLight")

-- END INSTRUMENT PANEL --------------------------------------------------------
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- MODE CONTROL PANEL (MCP) ----------------------------------------------------
-- 
-- Offset list
-- 9409 0 AT_Light_Status
-- 9409 1 VNAV_Status
-- 9409 2 LNAV_Status
-- 9409 3 CMD_A_Status
-- 9409 4 CMD_B_Status
-- 9409 5 MA_1_Light_Status
-- 9409 6 VOR_LOC_Status
-- 940A 0 CWS_A_Status
-- 940A 1 CWS_B_Status
-- 940A 2 MA_2_Light_Status
-- 940A 3 N1_Status
-- 940A 4 SPEED_Status
-- 940A 5 LVL_CHG_Status
-- 940A 6 HDG_SEL_Status
-- 940A 7 APP_Status
-- 940B 0 ALT_HLD_Status
-- 940B 1 VS_Status
-- 9434 2 Course_1
-- 9436 2 SPD
-- 9438 2 HDG
-- 943A 2 ALT
-- 943C 2 VS
-- 943E 2 Course_2
--
-- GFMCP Light Numbering
-- 0 = NAV
-- 1 = Hdg HOLD
-- 2 = IAS/Mach HOLD
-- 4 = Alt HOLD
-- 5 = APPR
-- 6 = B/C
-- 7 = A/P CMD
--
--
--------------------------------------------------------------------------------

-- Altitude
function updateAltitude(offset, value)
	gfd.SetDisplay(mcp_model,mcp_unit,4,value)
end
event.offset("943A","UW","updateAltitude")

-- Captain Course
function updateCaptCourse(offset, value)
	if value < 10 then
		display = "00"..value
	elseif value < 100 then
		display = "0"..value
	else
		display = value
	end
	gfd.SetDisplay(mcp_model,mcp_unit,0,display)
end
event.offset("9434","UW","updateCaptCourse")

-- Heading
function updateHeading(offset, value)
	if value < 10 then
		display = "00"..value
	elseif value < 100 then
		display = "0"..value
	else
		display = value
	end
	gfd.SetDisplay(mcp_model,mcp_unit,1,display)
end
event.offset("9438","UW","updateHeading")

-- MCP IAS MACH
function updateSpeed(offset, value)
	if value == 65535 then
		-- blank display
		gfd.SetDisplay(mcp_model,mcp_unit,2,"")
	else
		-- display speed
		gfd.SetDisplay(mcp_model,mcp_unit,2,value)
	end
end
event.offset("9436", "UW", "updateSpeed")

-- MCP Vertical Speed
function updateVS(offset, value)
	if value == -1 then
		-- blank display
		gfd.SetDisplay(mcp_model,mcp_unit,3,"")
	else
		-- display vertical speed
		gfd.SetDisplay(mcp_model,mcp_unit,3,value)
	end
end
event.offset("943C", "SW", "updateVS")

-- MCP Indicator Lights
function setModeLights9409(offset,value)
	-- Clear all relevant lights
	gfd.ClearLight(mcp_model,mcp_unit,0)
	gfd.ClearLight(mcp_model,mcp_unit,2)
	gfd.ClearLight(mcp_model,mcp_unit,7)
	gfd.ClearLight(efis_model,efis_unit,6)
	gfd.ClearLight(efis_model,efis_unit,7)

	-- Turn on correct lights
	if logic.And(value,0x0001) ~=0 then
		-- AT_Light_Status
		gfd.SetLight(efis_model,efis_unit,7)
	end
	if logic.And(value,0x0002) ~=0 then
		-- VNAV_Status
		gfd.SetLight(mcp_model,mcp_unit,2)
	end
	if logic.And(value,0x0004) ~=0 then
		-- LNAV_Status
		gfd.SetLight(mcp_model,mcp_unit,0)
	end
	if logic.And(value,0x0008) ~=0 then
		-- CMD_A_Status
		gfd.SetLight(mcp_model,mcp_unit,7)
	end
	if logic.And(value,0x0020) ~=0 then
		-- MA_1_Light_Status
		gfd.SetLight(efis_model,efis_unit,6)
	end
end
event.offset("9409", "UB", "setModeLights9409")

function setModeLights940A(offset,value)
	-- Clear all relevant lights
	gfd.ClearLight(mcp_model,mcp_unit,1)
	gfd.ClearLight(mcp_model,mcp_unit,4)
	gfd.ClearLight(mcp_model,mcp_unit,5)

	-- Turn on correct lights
	if logic.And(value,0x0020) ~=0 then
		-- LVL_CHG_Status
		gfd.SetLight(mcp_model,mcp_unit,4)
	end
	if logic.And(value,0x0040) ~=0 then
		-- HDG_SEL_Status
		gfd.SetLight(mcp_model,mcp_unit,1)
	end
	if logic.And(value,0x0080) ~=0 then
		-- APP_Status
		gfd.SetLight(mcp_model,mcp_unit,5)
	end		
end
event.offset("940A", "UB", "setModeLights940A")

-- END MODE CONTROL PANEL (MCP) ------------------------------------------------
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- MISCELLANEOUS PANEL ---------------------------------------------------------
--
-- Offset List
-- 9424 4 FWD_ENTRY_Light_Status
-- 9426 2 AIRSTAIR_Light_Status
--
--------------------------------------------------------------------------------
-- Forward entry door (substitute for all door lights)
function updateFwdEntryDoorLight(offset,value)
	-- Clear light
	gfd.ClearLight(misc_model, misc_unit, 7)
	
	-- Set light
	if logic.And(value,0x0010) ~=0 then
		-- FWD_ENTRY_Light_Status
		gfd.SetLight(misc_model, misc_unit, 7)
	end
end
event.offset("9424", "UB", "updateFwdEntryDoorLight")

-- Airstair Light
function updateAirstairLight(offset,value)
	-- Clear light
	gfd.ClearLight(misc_model, misc_unit, 6)
	
	-- Set light
	if logic.And(value,0x0004) ~=0 then
		-- AIRSTAIR_Light_Status
		gfd.SetLight(misc_model, misc_unit, 6)
	end
end
event.offset("9426", "UB", "updateAirstairLight")

-- END MISCELLANEOUS PANEL ---------------------------------------------------------
--------------------------------------------------------------------------------
	

--------------------------------------------------------------------------------
-- TRANSPONDER -----------------------------------------------------------------
--
-- Offset List
-- 946A 2 Transponder (UW)
-- 94CE 1 Transponder_Mode_Switches_Status
-- 94CF 1 Transponder_ATC_Switches_Status
-- 94D0 1 Transponder_IDENT_Switches_Status
-- 94D1 1 Transponder_ALT_Switches_Status
--
--------------------------------------------------------------------------------
-- Transponder setting
function updateXpdrSetting(offset, value)
	if value == 65535 then
		gfd.SetDisplay(xpdr_model,xpdr_unit,1, "")
	else
		gfd.SetDisplay(xpdr_model,xpdr_unit,1, value)
	end
end
event.offset("946A", "UW", "updateXpdrSetting")

-- Transponder mode
function updateXpdrMode(offset, value)
	if value ==0 then
		gfd.SetDisplay(xpdr_model, xpdr_unit, 0, "TEST")	
	elseif value == 1 then
		gfd.SetDisplay(xpdr_model, xpdr_unit, 0, "STBY")	
	elseif value == 2 then
		gfd.SetDisplay(xpdr_model, xpdr_unit, 0, "OFF")		
	elseif value == 3 then
		gfd.SetDisplay(xpdr_model, xpdr_unit, 0, "ON")		
	elseif value == 4 then
		gfd.SetDisplay(xpdr_model, xpdr_unit, 0, "TA")		
	elseif value == 5 then
		gfd.SetDisplay(xpdr_model, xpdr_unit, 0, "TARA")	
	else
		gfd.SetDisplay(xpdr_model, xpdr_unit, 0, value)
	end
end
event.offset("94CE", "UB", "updateXpdrMode")

-- Transponder ident
function updateXpdrIdent(offset, value)
	if logic.And(value,0x0001) ~=0 then
		gfd.SetDisplay(xpdr_model, xpdr_unit, 0, "IDENT")
	else
		gfd.SetDisplay(xpdr_model, xpdr_unit, 0, "STBY")
	end
end
event.offset("94D0", "UB", "updateXpdrIdent")

-- END TRANSPONDER -------------------------------------------------------------
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- GROUND CREW -----------------------------------------------------------------
--
-- When ground crew called using the Ground Call button, this will either
-- connect or disconnect ground services (Power and Air)
--
-- Offset List
-- 940E 6 GRD_POWER_AVAILABLE_Light_Status
-- 941F 0 Parking_Brake_Light_Status
-- 94E9 1 Ground_Call_Clicked
-- 9400 1213 KEY_COMMAND_AIRSYSTEM_GROUND_SUPPLY_ON
-- 9400 1214 KEY_COMMAND_AIRSYSTEM_GROUND_SUPPLY_OFF
-- 9400 1215 KEY_COMMAND_ELECTRICAL_GROUND_SUPPLY_ON
-- 9400 1216 KEY_COMMAND_ELECTRICAL_GROUND_SUPPLY_OFF
--
--------------------------------------------------------------------------------
function doGroundCrew(offset,value)
	if logic.And(value,0x0002) ~=0 then -- Ground call clicked
		gpu = ipc.readUB("940E")
		if logic.And(gpu,0x0040) ~=0 then -- Disconnect services
			-- Make sure parking brake set
			pbrake = ipc.readUB("941F")
			if logic.And(pbrake,0x0001) ~=0 then
				ipc.writeUW("9400",1214)
				ipc.writeUW("9400",1216)
			else -- Parking brake must be set
				ipc.setowndisplay("Ground Crew",10,10,25,25)
				ipc.display("Please set your parking brake, captain.",5)
			end
		else	-- Connect services
			ipc.writeUW("9400",1215)
			ipc.writeUW("9400",1213)
		end
	end	
end
event.offset("94E9", "UB", "doGroundCrew")

-- END GROUND CREW -------------------------------------------------------------
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- PREFLIGHT -------------------------------------------------------------------
--
-- Opens the doors and attaches ground services prior to flight.
-- 941F 0 Parking_Brake_Light_Status
-- 9400 1213 KEY_COMMAND_AIRSYSTEM_GROUND_SUPPLY_ON
-- 9400 1215 KEY_COMMAND_ELECTRICAL_GROUND_SUPPLY_ON
-- 9400 1220 KEY_COMMAND_MISC_EXIT_1_OPEN
-- 9400 1223 KEY_COMMAND_MISC_EXIT_2_OPEN
-- 9400 1226 KEY_COMMAND_MISC_EXIT_3_OPEN
--
--------------------------------------------------------------------------------
-- Make sure parking brake is set
pbrake = ipc.readUB("941F")
if logic.And(pbrake,0x0001) ~=0 then
	ipc.writeUW("9400",1213) -- Ground Air
	ipc.writeUW("9400",1215) -- Ground Power
	--ipc.writeUW("9400",1220) -- Exit 1 (?)
	--ipc.writeUW("9400",1223) -- Exit 2 (?)
	--ipc.writeUW("9400",1226) -- Exit 3 (?)
end
