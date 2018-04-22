if {$argc != 5} {
  puts "Expected: <rosetta root> <accel verilog> <proj name> <proj dir> <freq>"
  exit
}

# pull cmdline variables to use during setup
set config_rosetta_root  [lindex $argv 0]
set config_rosetta_verilog "$config_rosetta_root/src/main/verilog"
set config_accel_verilog [lindex $argv 1]
set config_proj_name [lindex $argv 2]
set config_proj_dir [lindex $argv 3]
set config_freq [lindex $argv 4]
puts $config_rosetta_verilog
# fixed for platform
set config_proj_part "xczu3eg-sbva484-1-i"
set xdc_dir "$config_rosetta_root/src/main/script/host"

# set up project
create_project $config_proj_name $config_proj_dir -part $config_proj_part
update_ip_catalog

# add the Verilog implementation for the accelerator
add_files -norecurse $config_accel_verilog
# add misc verilog files used by fpga-rosetta
add_files -norecurse $config_rosetta_verilog/Q_srl.v $config_rosetta_verilog/DualPortBRAM.v

# create block design
create_bd_design "procsys"
create_bd_cell -type ip -vlnv xilinx.com:ip:zynq_ultra_ps_e:3.1 zynq_ultra_ps_e_0
set zups [get_bd_cells zynq_ultra_ps_e_0]
#apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {make_external "FIXED_IO, DDR" Master "Disable" Slave "Disable" } $ps7
#source "${xdc_dir}/pynq_revC.tcl" # Doesn't seem to require anything from here.
set_property -dict [ list \
    CONFIG.PSU_BANK_0_IO_STANDARD {LVCMOS18} \
    CONFIG.PSU_BANK_1_IO_STANDARD {LVCMOS18} \
    CONFIG.PSU_BANK_2_IO_STANDARD {LVCMOS18} \
    CONFIG.PSU_BANK_3_IO_STANDARD {LVCMOS18} \
    CONFIG.PSU_MIO_13_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_14_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_15_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_16_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_21_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_22_DRIVE_STRENGTH {4} \
    CONFIG.PSU__CRF_APB__ACPU_CTRL__DIVISOR0 {1} \
    CONFIG.PSU__CRF_APB__ACPU_CTRL__SRCSEL {APLL} \
    CONFIG.PSU__CRF_APB__APLL_CTRL__DIV2 {1} \
    CONFIG.PSU__CRF_APB__APLL_CTRL__FBDIV {72} \
    CONFIG.PSU__CRF_APB__APLL_CTRL__SRCSEL {PSS_REF_CLK} \
    CONFIG.PSU__CRF_APB__APLL_TO_LPD_CTRL__DIVISOR0 {3} \
    CONFIG.PSU__CRF_APB__DBG_FPD_CTRL__DIVISOR0 {2} \
    CONFIG.PSU__CRF_APB__DBG_FPD_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRF_APB__DBG_TRACE_CTRL__DIVISOR0 {2} \
    CONFIG.PSU__CRF_APB__DBG_TRACE_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRF_APB__DBG_TSTMP_CTRL__DIVISOR0 {2} \
    CONFIG.PSU__CRF_APB__DBG_TSTMP_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRF_APB__DDR_CTRL__DIVISOR0 {4} \
    CONFIG.PSU__CRF_APB__DDR_CTRL__FREQMHZ {533} \
    CONFIG.PSU__CRF_APB__DDR_CTRL__SRCSEL {DPLL} \
    CONFIG.PSU__CRF_APB__DPDMA_REF_CTRL__DIVISOR0 {2} \
    CONFIG.PSU__CRF_APB__DPDMA_REF_CTRL__SRCSEL {APLL} \
    CONFIG.PSU__CRF_APB__DPLL_CTRL__DIV2 {1} \
    CONFIG.PSU__CRF_APB__DPLL_CTRL__FBDIV {64} \
    CONFIG.PSU__CRF_APB__DPLL_CTRL__SRCSEL {PSS_REF_CLK} \
    CONFIG.PSU__CRF_APB__DPLL_TO_LPD_CTRL__DIVISOR0 {3} \
    CONFIG.PSU__CRF_APB__DP_AUDIO_REF_CTRL__DIVISOR0 {16} \
    CONFIG.PSU__CRF_APB__DP_AUDIO_REF_CTRL__DIVISOR1 {1} \
    CONFIG.PSU__CRF_APB__DP_AUDIO_REF_CTRL__SRCSEL {RPLL} \
    CONFIG.PSU__CRF_APB__DP_STC_REF_CTRL__DIVISOR0 {15} \
    CONFIG.PSU__CRF_APB__DP_STC_REF_CTRL__DIVISOR1 {1} \
    CONFIG.PSU__CRF_APB__DP_STC_REF_CTRL__SRCSEL {RPLL} \
    CONFIG.PSU__CRF_APB__DP_VIDEO_REF_CTRL__DIVISOR0 {4} \
    CONFIG.PSU__CRF_APB__DP_VIDEO_REF_CTRL__DIVISOR1 {1} \
    CONFIG.PSU__CRF_APB__DP_VIDEO_REF_CTRL__SRCSEL {VPLL} \
    CONFIG.PSU__CRF_APB__GDMA_REF_CTRL__DIVISOR0 {2} \
    CONFIG.PSU__CRF_APB__GDMA_REF_CTRL__SRCSEL {APLL} \
    CONFIG.PSU__CRF_APB__GPU_REF_CTRL__DIVISOR0 {1} \
    CONFIG.PSU__CRF_APB__GPU_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRF_APB__PCIE_REF_CTRL__DIVISOR0 {2} \
    CONFIG.PSU__CRF_APB__PCIE_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRF_APB__SATA_REF_CTRL__DIVISOR0 {2} \
    CONFIG.PSU__CRF_APB__SATA_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRF_APB__TOPSW_LSBUS_CTRL__DIVISOR0 {5} \
    CONFIG.PSU__CRF_APB__TOPSW_LSBUS_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRF_APB__TOPSW_MAIN_CTRL__DIVISOR0 {2} \
    CONFIG.PSU__CRF_APB__TOPSW_MAIN_CTRL__SRCSEL {DPLL} \
    CONFIG.PSU__CRF_APB__VPLL_CTRL__DIV2 {1} \
    CONFIG.PSU__CRF_APB__VPLL_CTRL__FBDIV {71} \
    CONFIG.PSU__CRF_APB__VPLL_CTRL__FRACDATA {0.2871} \
    CONFIG.PSU__CRF_APB__VPLL_CTRL__SRCSEL {PSS_REF_CLK} \
    CONFIG.PSU__CRF_APB__VPLL_FRAC_CFG__ENABLED {1} \
    CONFIG.PSU__CRF_APB__VPLL_TO_LPD_CTRL__DIVISOR0 {3} \
    CONFIG.PSU__CRL_APB__ADMA_REF_CTRL__DIVISOR0 {3} \
    CONFIG.PSU__CRL_APB__ADMA_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__AMS_REF_CTRL__DIVISOR0 {29} \
    CONFIG.PSU__CRL_APB__AMS_REF_CTRL__DIVISOR1 {1} \
    CONFIG.PSU__CRL_APB__AMS_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__CAN0_REF_CTRL__DIVISOR0 {15} \
    CONFIG.PSU__CRL_APB__CAN0_REF_CTRL__DIVISOR1 {1} \
    CONFIG.PSU__CRL_APB__CAN0_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__CAN1_REF_CTRL__DIVISOR0 {15} \
    CONFIG.PSU__CRL_APB__CAN1_REF_CTRL__DIVISOR1 {1} \
    CONFIG.PSU__CRL_APB__CAN1_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__CPU_R5_CTRL__DIVISOR0 {3} \
    CONFIG.PSU__CRL_APB__CPU_R5_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__CSU_PLL_CTRL__DIVISOR0 {4} \
    CONFIG.PSU__CRL_APB__CSU_PLL_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__DBG_LPD_CTRL__DIVISOR0 {6} \
    CONFIG.PSU__CRL_APB__DBG_LPD_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__GEM0_REF_CTRL__DIVISOR0 {12} \
    CONFIG.PSU__CRL_APB__GEM0_REF_CTRL__DIVISOR1 {1} \
    CONFIG.PSU__CRL_APB__GEM0_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__GEM1_REF_CTRL__DIVISOR0 {12} \
    CONFIG.PSU__CRL_APB__GEM1_REF_CTRL__DIVISOR1 {1} \
    CONFIG.PSU__CRL_APB__GEM1_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__GEM2_REF_CTRL__DIVISOR0 {12} \
    CONFIG.PSU__CRL_APB__GEM2_REF_CTRL__DIVISOR1 {1} \
    CONFIG.PSU__CRL_APB__GEM2_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__GEM3_REF_CTRL__DIVISOR0 {12} \
    CONFIG.PSU__CRL_APB__GEM3_REF_CTRL__DIVISOR1 {1} \
    CONFIG.PSU__CRL_APB__GEM3_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__GEM_TSU_REF_CTRL__DIVISOR0 {6} \
    CONFIG.PSU__CRL_APB__GEM_TSU_REF_CTRL__DIVISOR1 {1} \
    CONFIG.PSU__CRL_APB__GEM_TSU_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__I2C0_REF_CTRL__DIVISOR0 {15} \
    CONFIG.PSU__CRL_APB__I2C0_REF_CTRL__DIVISOR1 {1} \
    CONFIG.PSU__CRL_APB__I2C0_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__I2C1_REF_CTRL__DIVISOR0 {15} \
    CONFIG.PSU__CRL_APB__I2C1_REF_CTRL__DIVISOR1 {1} \
    CONFIG.PSU__CRL_APB__I2C1_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__IOPLL_CTRL__DIV2 {0} \
    CONFIG.PSU__CRL_APB__IOPLL_CTRL__FBDIV {45} \
    CONFIG.PSU__CRL_APB__IOPLL_CTRL__SRCSEL {PSS_REF_CLK} \
    CONFIG.PSU__CRL_APB__IOPLL_TO_FPD_CTRL__DIVISOR0 {3} \
    CONFIG.PSU__CRL_APB__IOU_SWITCH_CTRL__DIVISOR0 {6} \
    CONFIG.PSU__CRL_APB__IOU_SWITCH_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__LPD_LSBUS_CTRL__DIVISOR0 {15} \
    CONFIG.PSU__CRL_APB__LPD_LSBUS_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__LPD_SWITCH_CTRL__DIVISOR0 {3} \
    CONFIG.PSU__CRL_APB__LPD_SWITCH_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__NAND_REF_CTRL__DIVISOR0 {15} \
    CONFIG.PSU__CRL_APB__NAND_REF_CTRL__DIVISOR1 {1} \
    CONFIG.PSU__CRL_APB__NAND_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__PCAP_CTRL__DIVISOR0 {8} \
    CONFIG.PSU__CRL_APB__PCAP_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__PL0_REF_CTRL__DIVISOR0 {15} \
    CONFIG.PSU__CRL_APB__PL0_REF_CTRL__DIVISOR1 {1} \
    CONFIG.PSU__CRL_APB__PL0_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__PL1_REF_CTRL__DIVISOR0 {15} \
    CONFIG.PSU__CRL_APB__PL1_REF_CTRL__DIVISOR1 {4} \
    CONFIG.PSU__CRL_APB__PL1_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__PL2_REF_CTRL__DIVISOR0 {5} \
    CONFIG.PSU__CRL_APB__PL2_REF_CTRL__DIVISOR1 {1} \
    CONFIG.PSU__CRL_APB__PL2_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__PL3_REF_CTRL__DIVISOR0 {4} \
    CONFIG.PSU__CRL_APB__PL3_REF_CTRL__DIVISOR1 {1} \
    CONFIG.PSU__CRL_APB__PL3_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__QSPI_REF_CTRL__DIVISOR0 {12} \
    CONFIG.PSU__CRL_APB__QSPI_REF_CTRL__DIVISOR1 {1} \
    CONFIG.PSU__CRL_APB__QSPI_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__RPLL_CTRL__DIV2 {1} \
    CONFIG.PSU__CRL_APB__RPLL_CTRL__FBDIV {70} \
    CONFIG.PSU__CRL_APB__RPLL_CTRL__FRACDATA {0.779} \
    CONFIG.PSU__CRL_APB__RPLL_CTRL__SRCSEL {PSS_REF_CLK} \
    CONFIG.PSU__CRL_APB__RPLL_FRAC_CFG__ENABLED {1} \
    CONFIG.PSU__CRL_APB__RPLL_TO_FPD_CTRL__DIVISOR0 {3} \
    CONFIG.PSU__CRL_APB__SDIO0_REF_CTRL__DIVISOR0 {8} \
    CONFIG.PSU__CRL_APB__SDIO0_REF_CTRL__DIVISOR1 {1} \
    CONFIG.PSU__CRL_APB__SDIO0_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__SDIO1_REF_CTRL__DIVISOR0 {8} \
    CONFIG.PSU__CRL_APB__SDIO1_REF_CTRL__DIVISOR1 {1} \
    CONFIG.PSU__CRL_APB__SDIO1_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__SPI0_REF_CTRL__DIVISOR0 {8} \
    CONFIG.PSU__CRL_APB__SPI0_REF_CTRL__DIVISOR1 {1} \
    CONFIG.PSU__CRL_APB__SPI0_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__SPI1_REF_CTRL__DIVISOR0 {8} \
    CONFIG.PSU__CRL_APB__SPI1_REF_CTRL__DIVISOR1 {1} \
    CONFIG.PSU__CRL_APB__SPI1_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__TIMESTAMP_REF_CTRL__DIVISOR0 {15} \
    CONFIG.PSU__CRL_APB__TIMESTAMP_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__UART0_REF_CTRL__DIVISOR0 {15} \
    CONFIG.PSU__CRL_APB__UART0_REF_CTRL__DIVISOR1 {1} \
    CONFIG.PSU__CRL_APB__UART0_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__UART1_REF_CTRL__DIVISOR0 {15} \
    CONFIG.PSU__CRL_APB__UART1_REF_CTRL__DIVISOR1 {1} \
    CONFIG.PSU__CRL_APB__UART1_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__USB0_BUS_REF_CTRL__DIVISOR0 {6} \
    CONFIG.PSU__CRL_APB__USB0_BUS_REF_CTRL__DIVISOR1 {1} \
    CONFIG.PSU__CRL_APB__USB0_BUS_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__USB1_BUS_REF_CTRL__DIVISOR0 {6} \
    CONFIG.PSU__CRL_APB__USB1_BUS_REF_CTRL__DIVISOR1 {1} \
    CONFIG.PSU__CRL_APB__USB1_BUS_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__USB3_DUAL_REF_CTRL__DIVISOR0 {5} \
    CONFIG.PSU__CRL_APB__USB3_DUAL_REF_CTRL__DIVISOR1 {15} \
    CONFIG.PSU__CRL_APB__USB3_DUAL_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__USB3__ENABLE {1} \
    CONFIG.PSU__DDRC__ADDR_MIRROR {1} \
    CONFIG.PSU__DDRC__BANK_ADDR_COUNT {3} \
    CONFIG.PSU__DDRC__BG_ADDR_COUNT {NA} \
    CONFIG.PSU__DDRC__CL {NA} \
    CONFIG.PSU__DDRC__CWL {NA} \
    CONFIG.PSU__DDRC__DDR4_ADDR_MAPPING {NA} \
    CONFIG.PSU__DDRC__DDR4_CAL_MODE_ENABLE {NA} \
    CONFIG.PSU__DDRC__DDR4_CRC_CONTROL {NA} \
    CONFIG.PSU__DDRC__DDR4_MAXPWR_SAVING_EN {NA} \
    CONFIG.PSU__DDRC__DDR4_T_REF_MODE {NA} \
    CONFIG.PSU__DDRC__DDR4_T_REF_RANGE {NA} \
    CONFIG.PSU__DDRC__DEVICE_CAPACITY {8192 MBits} \
    CONFIG.PSU__DDRC__DIMM_ADDR_MIRROR {ERR: NA  | 0} \
    CONFIG.PSU__DDRC__DRAM_WIDTH {32 Bits} \
    CONFIG.PSU__DDRC__ENABLE {1} \
    CONFIG.PSU__DDRC__ENABLE_DP_SWITCH {1} \
    CONFIG.PSU__DDRC__FGRM {NA} \
    CONFIG.PSU__DDRC__LP_ASR {NA} \
    CONFIG.PSU__DDRC__MEMORY_TYPE {LPDDR 4} \
    CONFIG.PSU__DDRC__PARITY_ENABLE {NA} \
    CONFIG.PSU__DDRC__RANK_ADDR_COUNT {1} \
    CONFIG.PSU__DDRC__SB_TARGET {NA} \
    CONFIG.PSU__DDRC__SELF_REF_ABORT {NA} \
    CONFIG.PSU__DDRC__SPEED_BIN {LPDDR4_1066} \
    CONFIG.PSU__DDRC__TRAIN_WRITE_LEVEL {1} \
    CONFIG.PSU__DDRC__T_FAW {40} \
    CONFIG.PSU__DDRC__T_RAS_MIN {42} \
    CONFIG.PSU__DDRC__T_RC {64} \
    CONFIG.PSU__DDRC__T_RP {12} \
    CONFIG.PSU__DDRC__VREF {0} \
    CONFIG.PSU__DDR__INTERFACE__FREQMHZ {266.500} \
    CONFIG.PSU__DISPLAYPORT__LANE0__ENABLE {1} \
    CONFIG.PSU__DISPLAYPORT__LANE0__IO {GT Lane1} \
    CONFIG.PSU__DISPLAYPORT__LANE1__ENABLE {1} \
    CONFIG.PSU__DISPLAYPORT__LANE1__IO {GT Lane0} \
    CONFIG.PSU__DISPLAYPORT__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__DPAUX__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__DPAUX__PERIPHERAL__IO {MIO 27 .. 30} \
    CONFIG.PSU__DP__LANE_SEL {Dual Lower} \
    CONFIG.PSU__DP__REF_CLK_FREQ {27} \
    CONFIG.PSU__DP__REF_CLK_SEL {Ref Clk1} \
    CONFIG.PSU__FPGA_PL0_ENABLE {1} \
    CONFIG.PSU__FPGA_PL1_ENABLE {1} \
    CONFIG.PSU__FPGA_PL2_ENABLE {1} \
    CONFIG.PSU__FPGA_PL3_ENABLE {1} \
    CONFIG.PSU__GEN_IPI__TRUSTZONE {<Select>} \
    CONFIG.PSU__GPIO0_MIO__IO {MIO 0 .. 25} \
    CONFIG.PSU__GPIO0_MIO__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__GPIO1_MIO__IO {MIO 26 .. 51} \
    CONFIG.PSU__GPIO1_MIO__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__GPIO2_MIO__IO {MIO 52 .. 77} \
    CONFIG.PSU__GPIO2_MIO__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__GPIO_EMIO__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__GPIO_EMIO__PERIPHERAL__IO {6} \
    CONFIG.PSU__GT__LINK_SPEED {HBR} \
    CONFIG.PSU__GT__PRE_EMPH_LVL_4 {0} \
    CONFIG.PSU__GT__VLT_SWNG_LVL_4 {0} \
    CONFIG.PSU__I2C0__PERIPHERAL__ENABLE {0} \
    CONFIG.PSU__I2C1__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__I2C1__PERIPHERAL__IO {MIO 4 .. 5} \
    CONFIG.PSU__OVERRIDE__BASIC_CLOCK {1} \
    CONFIG.PSU__PCIE__ACS_VIOLAION {0} \
    CONFIG.PSU__PJTAG__PERIPHERAL__ENABLE {0} \
    CONFIG.PSU__PMU__GPI0__ENABLE {0} \
    CONFIG.PSU__PMU__GPI1__ENABLE {0} \
    CONFIG.PSU__PMU__GPI2__ENABLE {0} \
    CONFIG.PSU__PMU__GPI3__ENABLE {0} \
    CONFIG.PSU__PMU__GPI4__ENABLE {0} \
    CONFIG.PSU__PMU__GPI5__ENABLE {0} \
    CONFIG.PSU__PMU__GPO0__ENABLE {1} \
    CONFIG.PSU__PMU__GPO0__IO {MIO 32} \
    CONFIG.PSU__PMU__GPO1__ENABLE {1} \
    CONFIG.PSU__PMU__GPO1__IO {MIO 33} \
    CONFIG.PSU__PMU__GPO2__ENABLE {0} \
    CONFIG.PSU__PMU__GPO3__ENABLE {0} \
    CONFIG.PSU__PMU__GPO4__ENABLE {0} \
    CONFIG.PSU__PMU__GPO5__ENABLE {0} \
    CONFIG.PSU__PMU__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__PSS_ALT_REF_CLK__ENABLE {0} \
    CONFIG.PSU__PSS_REF_CLK__FREQMHZ {33.333} \
    CONFIG.PSU__QSPI__PERIPHERAL__ENABLE {0} \
    CONFIG.PSU__SD0__DATA_TRANSFER_MODE {4Bit} \
    CONFIG.PSU__SD0__GRP_CD__ENABLE {1} \
    CONFIG.PSU__SD0__GRP_CD__IO {MIO 24} \
    CONFIG.PSU__SD0__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__SD0__PERIPHERAL__IO {MIO 13 .. 16 21 22} \
    CONFIG.PSU__SD0__SLOT_TYPE {SD 2.0} \
    CONFIG.PSU__SD1__DATA_TRANSFER_MODE {4Bit} \
    CONFIG.PSU__SD1__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__SD1__PERIPHERAL__IO {MIO 46 .. 51} \
    CONFIG.PSU__SD1__SLOT_TYPE {SD 2.0} \
    CONFIG.PSU__SPI0__GRP_SS0__ENABLE {1} \
    CONFIG.PSU__SPI0__GRP_SS0__IO {MIO 41} \
    CONFIG.PSU__SPI0__GRP_SS1__ENABLE {0} \
    CONFIG.PSU__SPI0__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__SPI0__PERIPHERAL__IO {MIO 38 .. 43} \
    CONFIG.PSU__SPI1__GRP_SS0__ENABLE {1} \
    CONFIG.PSU__SPI1__GRP_SS0__IO {MIO 9} \
    CONFIG.PSU__SPI1__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__SPI1__PERIPHERAL__IO {MIO 6 .. 11} \
    CONFIG.PSU__TTC0__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__UART0__BAUD_RATE {115200} \
    CONFIG.PSU__UART0__MODEM__ENABLE {1} \
    CONFIG.PSU__UART0__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__UART0__PERIPHERAL__IO {MIO 2 .. 3} \
    CONFIG.PSU__UART1__BAUD_RATE {115200} \
    CONFIG.PSU__UART1__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__UART1__PERIPHERAL__IO {EMIO} \
    CONFIG.PSU__USB0__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__USB0__PERIPHERAL__IO {MIO 52 .. 63} \
    CONFIG.PSU__USB0__REF_CLK_FREQ {26} \
    CONFIG.PSU__USB0__REF_CLK_SEL {Ref Clk0} \
    CONFIG.PSU__USB1__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__USB1__PERIPHERAL__IO {MIO 64 .. 75} \
    CONFIG.PSU__USB1__REF_CLK_FREQ {26} \
    CONFIG.PSU__USB1__REF_CLK_SEL {Ref Clk0} \
    CONFIG.PSU__USB3_0__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__USB3_0__PERIPHERAL__IO {GT Lane2} \
    CONFIG.PSU__USB3_1__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__USB3_1__PERIPHERAL__IO {GT Lane3} \
    CONFIG.PSU__USE__IRQ0 {1} \
    CONFIG.PSU__USE__M_AXI_GP2 {1} \
] $zups

#THIS set_property -dict [apply_preset $ps7] $ps7
# enable AXI HP ports, set target frequency
set_property -dict [list CONFIG.PSU__USE__S_AXI_GP2 {1} CONFIG.PSU__USE__S_AXI_GP3 {1} CONFIG.PSU__USE__S_AXI_GP4 {1} CONFIG.PSU__USE__S_AXI_GP5 {1}] $zups
# Set the bitwidth of the AXI ports.
set_property -dict [list CONFIG.PSU__SAXIGP2__DATA_WIDTH {128} CONFIG.PSU__SAXIGP3__DATA_WIDTH {128} CONFIG.PSU__SAXIGP4__DATA_WIDTH {128} CONFIG.PSU__SAXIGP5__DATA_WIDTH {128}] $zups
#THIS set_property -dict [list CONFIG.PCW_USE_S_AXI_HP0 {1} CONFIG.PCW_USE_S_AXI_HP1 {1} CONFIG.PCW_USE_S_AXI_HP2 {1} CONFIG.PCW_USE_S_AXI_HP3 {1}] $ps7
# TODO expose top-level ports?
#THIS #set_property -dict [list CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ $config_freq CONFIG.PCW_USE_S_AXI_HP0 {1} CONFIG.PCW_USE_S_AXI_HP1 {1} CONFIG.PCW_USE_S_AXI_HP2 {1} CONFIG.PCW_USE_S_AXI_HP3 {1}] [get_bd_cells processing_system7_0]
#THIS set_property -dict [list CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ $config_freq CONFIG.PCW_FPGA1_PERIPHERAL_FREQMHZ {142.86} CONFIG.PCW_FPGA2_PERIPHERAL_FREQMHZ {200} CONFIG.PCW_FPGA3_PERIPHERAL_FREQMHZ {166.67} CONFIG.PCW_EN_CLK1_PORT {1} CONFIG.PCW_EN_CLK2_PORT {1} CONFIG.PCW_EN_CLK3_PORT {1} CONFIG.PCW_USE_M_AXI_GP0 {1}] $ps7
set_property -dict [list CONFIG.PSU__FPGA_PL0_ENABLE {1} CONFIG.PSU__FPGA_PL1_ENABLE {1} CONFIG.PSU__FPGA_PL2_ENABLE {1} CONFIG.PSU__FPGA_PL3_ENABLE {1}] $zups
set_property -dict [list CONFIG.PSU__CRL_APB__PL0_REF_CTRL__FREQMHZ $config_freq CONFIG.PSU__CRL_APB__PL1_REF_CTRL__FREQMHZ {142.86} CONFIG.PSU__CRL_APB__PL2_REF_CTRL__FREQMHZ {200} CONFIG.PSU__CRL_APB__PL3_REF_CTRL__FREQMHZ {166.67}] $zups

# add the accelerator RTL module into the block design
create_bd_cell -type module -reference PYNQWrapper PYNQWrapper_0

# connect control-status registers
#THIS apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/ps7/M_AXI_GP0" Clk "Auto" }  [get_bd_intf_pins PYNQWrapper_0/csr]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/zynq_ultra_ps_e_0/M_AXI_HPM0_LPD" Clk "Auto" }  [get_bd_intf_pins PYNQWrapper_0/csr]
#apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/zynq_ultra_ps_e_0/M_AXI_HPM0_LPD" intc_ip "New AXI Interconnect" Clk_xbar "Auto" Clk_master "Auto" Clk_slave "Auto" }  [get_bd_intf_pins PYNQWrapper_0/csr]

# connect AXI master ports, connect mem1 to HP2 to try to improve DRAM bandwidth.
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/PYNQWrapper_0/mem0" Clk "Auto" }  [get_bd_intf_pins zynq_ultra_ps_e_0/S_AXI_HP0_FPD]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/PYNQWrapper_0/mem2" Clk "Auto" }  [get_bd_intf_pins zynq_ultra_ps_e_0/S_AXI_HP1_FPD]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/PYNQWrapper_0/mem1" Clk "Auto" }  [get_bd_intf_pins zynq_ultra_ps_e_0/S_AXI_HP2_FPD]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/PYNQWrapper_0/mem3" Clk "Auto" }  [get_bd_intf_pins zynq_ultra_ps_e_0/S_AXI_HP3_FPD]
#apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/PYNQWrapper_0/mem0" intc_ip "Auto" Clk_xbar "Auto" Clk_master "Auto" Clk_slave "Auto" }  [get_bd_intf_pins zynq_ultra_ps_e_0/S_AXI_HP0_FPD]
#apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/PYNQWrapper_0/mem1" intc_ip "Auto" Clk_xbar "Auto" Clk_master "Auto" Clk_slave "Auto" }  [get_bd_intf_pins zynq_ultra_ps_e_0/S_AXI_HP1_FPD]
#apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/PYNQWrapper_0/mem2" intc_ip "Auto" Clk_xbar "Auto" Clk_master "Auto" Clk_slave "Auto" }  [get_bd_intf_pins zynq_ultra_ps_e_0/S_AXI_HP2_FPD]
#apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/PYNQWrapper_0/mem3" intc_ip "Auto" Clk_xbar "Auto" Clk_master "Auto" Clk_slave "Auto" }  [get_bd_intf_pins zynq_ultra_ps_e_0/S_AXI_HP3_FPD]

# rewire reset port to use active-high
disconnect_bd_net [get_bd_nets rst_ps8*peripheral_aresetn] [get_bd_pins PYNQWrapper_0/reset]
connect_bd_net [get_bd_pins [get_bd_cells *rst_ps8*]/peripheral_reset] [get_bd_pins PYNQWrapper_0/reset]

# Setting the clock doesn't work, using the clock wizard in the meantime.
create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:5.4 clk_wiz_0
#set_property -dict [list CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {150.000} CONFIG.USE_LOCKED {false} CONFIG.RESET_TYPE {ACTIVE_LOW} CONFIG.MMCM_DIVCLK_DIVIDE {1} CONFIG.MMCM_CLKOUT0_DIVIDE_F {8.000} CONFIG.RESET_PORT {resetn} CONFIG.CLKOUT1_JITTER {107.567}] [get_bd_cells clk_wiz_0]
set_property -dict [list CONFIG.CLKOUT1_REQUESTED_OUT_FREQ $config_freq CONFIG.USE_LOCKED {false} CONFIG.RESET_TYPE {ACTIVE_LOW} CONFIG.RESET_PORT {resetn}] [get_bd_cells clk_wiz_0]
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_resetn0] [get_bd_pins clk_wiz_0/resetn]
delete_bd_objs [get_bd_nets zynq_ultra_ps_e_0_pl_clk0]
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_clk0] [get_bd_pins clk_wiz_0/clk_in1]
connect_bd_net [get_bd_pins clk_wiz_0/clk_out1] [get_bd_pins ps8_0_axi_periph/ACLK]
connect_bd_net [get_bd_pins clk_wiz_0/clk_out1] [get_bd_pins ps8_0_axi_periph/S00_ACLK]
connect_bd_net [get_bd_pins clk_wiz_0/clk_out1] [get_bd_pins ps8_0_axi_periph/M00_ACLK]
connect_bd_net [get_bd_pins clk_wiz_0/clk_out1] [get_bd_pins PYNQWrapper_0/clk]
connect_bd_net [get_bd_pins clk_wiz_0/clk_out1] [get_bd_pins axi_mem_intercon/ACLK]
connect_bd_net [get_bd_pins clk_wiz_0/clk_out1] [get_bd_pins axi_mem_intercon/S00_ACLK]
connect_bd_net [get_bd_pins clk_wiz_0/clk_out1] [get_bd_pins axi_mem_intercon/M00_ACLK]
connect_bd_net [get_bd_pins clk_wiz_0/clk_out1] [get_bd_pins axi_mem_intercon_1/ACLK]
connect_bd_net [get_bd_pins clk_wiz_0/clk_out1] [get_bd_pins axi_mem_intercon_1/S00_ACLK]
connect_bd_net [get_bd_pins clk_wiz_0/clk_out1] [get_bd_pins axi_mem_intercon_1/M00_ACLK]
connect_bd_net [get_bd_pins clk_wiz_0/clk_out1] [get_bd_pins axi_mem_intercon_2/ACLK]
connect_bd_net [get_bd_pins clk_wiz_0/clk_out1] [get_bd_pins axi_mem_intercon_2/S00_ACLK]
connect_bd_net [get_bd_pins clk_wiz_0/clk_out1] [get_bd_pins axi_mem_intercon_2/M00_ACLK]
connect_bd_net [get_bd_pins clk_wiz_0/clk_out1] [get_bd_pins axi_mem_intercon_3/ACLK]
connect_bd_net [get_bd_pins clk_wiz_0/clk_out1] [get_bd_pins axi_mem_intercon_3/S00_ACLK]
connect_bd_net [get_bd_pins clk_wiz_0/clk_out1] [get_bd_pins axi_mem_intercon_3/M00_ACLK]
connect_bd_net [get_bd_pins clk_wiz_0/clk_out1] [get_bd_pins rst_ps8_0_99M/slowest_sync_clk]
connect_bd_net [get_bd_pins clk_wiz_0/clk_out1] [get_bd_pins zynq_ultra_ps_e_0/maxihpm0_lpd_aclk]
connect_bd_net [get_bd_pins clk_wiz_0/clk_out1] [get_bd_pins zynq_ultra_ps_e_0/saxihp0_fpd_aclk]
connect_bd_net [get_bd_pins clk_wiz_0/clk_out1] [get_bd_pins zynq_ultra_ps_e_0/saxihp1_fpd_aclk]
connect_bd_net [get_bd_pins clk_wiz_0/clk_out1] [get_bd_pins zynq_ultra_ps_e_0/saxihp2_fpd_aclk]
connect_bd_net [get_bd_pins clk_wiz_0/clk_out1] [get_bd_pins zynq_ultra_ps_e_0/saxihp3_fpd_aclk]

# connect accelerator AXI masters to Zynq PS
#apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/PYNQWrapper_0/mem0" Clk "Auto" }  [get_bd_intf_pins processing_system7_0/S_AXI_HP0]
#apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/PYNQWrapper_0/mem1" Clk "Auto" }  [get_bd_intf_pins processing_system7_0/S_AXI_HP1]
#apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/PYNQWrapper_0/mem2" Clk "Auto" }  [get_bd_intf_pins processing_system7_0/S_AXI_HP2]
#apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/PYNQWrapper_0/mem3" Clk "Auto" }  [get_bd_intf_pins processing_system7_0/S_AXI_HP3]
# make the block design look prettier
regenerate_bd_layout
validate_bd_design
save_bd_design
# write block design tcl
write_bd_tcl $config_proj_dir/rosetta.tcl

# use global mode (no out-of-context) for bd synthesis
#set_property synth_checkpoint_mode None [get_files $config_proj_dir/$config_proj_name.srcs/sources_1/bd/procsys/procsys.bd]

# create HDL wrapper
make_wrapper -files [get_files $config_proj_dir/$config_proj_name.srcs/sources_1/bd/procsys/procsys.bd] -top
add_files -norecurse $config_proj_dir/$config_proj_name.srcs/sources_1/bd/procsys/hdl/procsys_wrapper.v
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
set_property top procsys_wrapper [current_fileset]

# use manual compile order to ensure accel verilog is processed prior to block design
#update_compile_order -fileset sources_1
#set_property source_mgmt_mode DisplayOnly [current_project]


# set synthesis strategy
set_property strategy Flow_PerfOptimized_high [get_runs synth_1]

set_property STEPS.SYNTH_DESIGN.ARGS.DIRECTIVE AlternateRoutability [get_runs synth_1]
set_property STEPS.SYNTH_DESIGN.ARGS.RETIMING true [get_runs synth_1]

set_property strategy Performance_ExtraTimingOpt [get_runs impl_1]
set_property STEPS.OPT_DESIGN.ARGS.DIRECTIVE Explore [get_runs impl_1]
set_property STEPS.POST_ROUTE_PHYS_OPT_DESIGN.ARGS.DIRECTIVE AggressiveExplore [get_runs impl_1]
set_property STEPS.PHYS_OPT_DESIGN.ARGS.DIRECTIVE AggressiveExplore [get_runs impl_1]
set_property STEPS.POST_ROUTE_PHYS_OPT_DESIGN.IS_ENABLED true [get_runs impl_1]
