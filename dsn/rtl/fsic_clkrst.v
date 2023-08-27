// This code snippet was auto generated by xls2vlog.py from source file: /home/patrick/Downloads/Interface-Definition.xlsx
// User: patrick
// Date: Jun-06-23


module FSIC_CLKRST (
  input  wire  [4: 0] user_prj_sel,
  input  wire         mb_irq,
  input  wire         wb_rst,
  input  wire         wb_clk,
  output wire  [2: 0] user_irq,

  input  wire         low__pri_irq,
  input  wire         high_pri_irq,

  input  wire         user_clock2,
  output wire         uck2_rst_n,

  output  wire         axi_clk,
  output wire         axi_reset_n,

  output  wire         axis_clk,
  output wire         axis_rst_n,

  input  wire         io_clk,
  output wire         ioclk
);


  assign axi_clk = wb_clk;
  assign axis_clk = wb_clk;  

// ----------------------------------------------------------
// AXI-Lite
reg [2:0] axi_reset_nr; 
always @(posedge axi_clk or posedge wb_rst)
  if( wb_rst )
    axi_reset_nr <= 3'b000;
  else
    axi_reset_nr <= {axi_reset_nr[1:0], 1'b1};

assign axi_reset_n = axi_reset_nr[2];


// ----------------------------------------------------------
// AXIS
reg [2:0] axis_rst_nr; 
always @(posedge axis_clk or posedge wb_rst)
  if( wb_rst )
    axis_rst_nr <= 3'b000;
  else
    axis_rst_nr <= {axis_rst_nr[1:0], 1'b1};

assign axis_rst_n = axis_rst_nr[2];


// ----------------------------------------------------------
// user_clock2
reg [2:0] uck2_rst_nr; 
always @(posedge user_clock2 or posedge wb_rst)
  if( wb_rst )
    uck2_rst_nr <= 3'b000;
  else
    uck2_rst_nr <= {uck2_rst_nr[1:0], 1'b1};

assign uck2_rst_n = uck2_rst_nr[2];


// ----------------------------------------------------------
// IRQ
assign user_irq[2] = high_pri_irq;
assign user_irq[1] = low__pri_irq;
assign user_irq[0] = mb_irq;


// ----------------------------------------------------------
// IOCLK for IO_SERDES

/*
// TBD
reg div2_clk;
always @(posedge user_clock2 or negedge uck2_rst_n)
  if( ~uck2_rst_n )
    div2_clk <= 1'b0;
  else
    div2_clk <= ~div2_clk; 
*/

// TBD
assign ioclk = io_clk;

endmodule // FSIC_CLKRST


