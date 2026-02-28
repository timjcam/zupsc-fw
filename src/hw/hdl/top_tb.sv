`timescale 1us/1ps
`define ZYNQ_VIP top_tb.dut.sys.zynq_ultra_ps_e_0.inst


 
module top_tb;

  // Parameters
  parameter FPGA_VERSION = 1;
  parameter SIM_MODE     = 0;



  // Signals
  reg clk;
  reg reset_n;
  reg resp;
   
  wire [3:0]  dcct_adc_cnv;
  wire [3:0]  dcct_adc_sck;
  reg  [3:0]  dcct_adc_busy;
  reg  [3:0]  dcct_adc_sdo;
  
  wire [3:0]  stpt_dac_sck;
  wire [3:0]  stpt_dac_sync;
  wire [3:0]  stpt_dac_sdo;
  
  wire [3:0]  mon_adc_rst;
  wire [3:0]  mon_adc_cnv;
  wire [3:0]  mon_adc_sck;
  wire [3:0]  mon_adc_fs;
  reg  [3:0]  mon_adc_busy;
  reg  [3:0]  mon_adc_sdo;
  
  reg  [15:0] dig_in;
  wire [15:0] dig_out;
  
  reg [3:0]   dcct_flt;

  wire [7:0]  sfp_led;
  reg  [5:0]  sfp_rxlos;
  wire [7:0]  fp_led;
  wire [3:0]  fp_out;
  wire [19:0] dbg;
  wire        afe_enb;
  

  // Instantiate DUT
  top #(
    .FPGA_VERSION(FPGA_VERSION),
    .SIM_MODE(SIM_MODE)
  ) dut (
    .dcct_adc_cnv(dcct_adc_cnv),
    .dcct_adc_sck(dcct_adc_sck),
    .dcct_adc_busy(dcct_adc_busy),
    .dcct_adc_sdo(dcct_adc_sdo),

    .stpt_dac_sck(stpt_dac_sck),
    .stpt_dac_sync(stpt_dac_sync),
    .stpt_dac_sdo(stpt_dac_sdo),
        
    .mon_adc_rst(mon_adc_rst),
    .mon_adc_cnv(mon_adc_cnv),
    .mon_adc_sck(mon_adc_sck),
    .mon_adc_fs(mon_adc_fs),
    .mon_adc_busy(mon_adc_busy),
    .mon_adc_sdo(mon_adc_sdo),
    
    .dig_in(dig_in),
    .dig_out(dig_out),
    
    .dcct_flt(dcct_flt),
    
    .sfp_led(sfp_led),
    .sfp_rxlos(sfp_rxlos),
    .fp_led(fp_led),
    .fp_out(fp_out),
    .dbg(dbg),
    .afe_enb(afe_enb)
  );

  // Clock generation
  initial begin
    $display ("Running the Test Bench"); 
    clk = 0;
    forever #5 clk = ~clk; // 100MHz clock
  end

  // Reset generation
  initial begin
    reset_n = 0;
    #20;
    reset_n = 1;
    #100;
      // Add test stimulus here.
      dig_in = 16'h0;
      mon_adc_busy = 4'b0;
      mon_adc_sdo = 4'b0;
      dcct_adc_busy = 4'b0;
      dcct_adc_sdo = 4'b0;

    #10000000; // Run simulation for 10ms
    $finish;
  end


  // Example stimulus (replace with your actual test cases)
  initial begin

  	`ZYNQ_VIP.por_srstb_reset(1'b1); 
    #50; 
    `ZYNQ_VIP.por_srstb_reset(1'b0); 
    `ZYNQ_VIP.fpga_soft_reset(32'h1); 
    #50 ;  // This delay depends on your clock frequency. It should be at least 16 clock cycles.  
    `ZYNQ_VIP.por_srstb_reset(1'b1); 
    `ZYNQ_VIP.fpga_soft_reset(32'h0); 
    #50 ; 


    //Write the NCO to set the 10KHz
    //`ZYNQ_VIP.write_data(32'hA0000018,4, 32'd427853, resp);  // 10KHz 
    `ZYNQ_VIP.write_data(32'hA0000018,4, 32'd4294967, resp);   // 100KHz
    #2000
    //`ZYNQ_VIP.write_data(32'hA0000020,4, 32'h2, resp);    
    //#2000
    //`ZYNQ_VIP.write_data(32'hA0000020,4, 32'h3, resp);             
    //#2000
 

 
    #100000000;
    
    
    
  end
  
  
endmodule
  
