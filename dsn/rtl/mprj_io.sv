// This code snippet was auto generated by xls2vlog.py from source file: /home/patrick/Downloads/Interface-Definition.xlsx
// User: patrick
// Date: Jul-19-23



module MPRJ_IO #( 	parameter pUSER_PROJECT_SIDEBAND_WIDTH   = 5,
					parameter pSERIALIO_WIDTH   = 13,
					parameter pADDR_WIDTH   = 12,
					parameter pDATA_WIDTH   = 32
                )
(
  output wire  [pSERIALIO_WIDTH-1: 0] serial_rxd,
  output wire          serial_rclk,
  input  wire   [4: 0] user_prj_sel,
  input  wire  [pSERIALIO_WIDTH-1: 0] serial_txd,
  input  wire          serial_tclk,
  input  wire  [37: 0] io_in,
  input  wire          vccd1,
  input  wire          vccd2,
  input  wire          vssd1,
  input  wire          vssd2,
  output wire  [37: 0] io_out,
  output wire  [37: 0] io_oeb,
  output wire          io_clk,
  input  wire          user_clock2,
  input  wire          axi_clk,
  input  wire          axi_reset_n,
  input  wire          axis_clk,
  input  wire          uck2_rst_n,
  input  wire          axis_rst_n
);

	localparam BASE_OFFSET = 8;
	localparam RXD_OFFSET = BASE_OFFSET;
	localparam RXCLK_OFFSET = RXD_OFFSET + pSERIALIO_WIDTH;
	localparam TXD_OFFSET = RXCLK_OFFSET + 1;
	localparam TXCLK_OFFSET = TXD_OFFSET + pSERIALIO_WIDTH;
	localparam IOCLK_OFFSET = TXCLK_OFFSET + 1;
	localparam TXRX_WIDTH = IOCLK_OFFSET - BASE_OFFSET;

// MPRJ_IO PIN PLANNING
// --------------------------------
// [19: 8]  I   RXD
// [   20]  I   RXCLK

// --------------------------------
// [32:21]  O   TXD
// [   33]  O   TXCLK

// --------------------------------
// [   37]  I   IO_CLK

/*
assign serial_rxd    = 12'b0;
assign serial_rclk   = 1'b0;
assign io_out        = 38'b0;
assign io_oeb        = 38'b0;
*/

assign io_clk = io_in[IOCLK_OFFSET];

assign io_oeb[ 7: 0]   =  8'h00;

assign io_oeb[RXD_OFFSET +: pSERIALIO_WIDTH]   = 0;  // RXD
assign io_oeb[RXCLK_OFFSET]   =  0;    // RX_CLK

assign io_oeb[TXD_OFFSET +: pSERIALIO_WIDTH]   = 13'h1FFF;  // TXD		//[TODO]
//assign io_oeb[TXD_OFFSET +: pSERIALIO_WIDTH]   = ~0;  // TXD		//[TODO]
assign io_oeb[TXCLK_OFFSET]   =  1'b1;    // TX_CLK

assign io_oeb[IOCLK_OFFSET]   =  1'b0;    // IO_CLK (from FPGA)


assign serial_rxd  = io_in[RXD_OFFSET +: pSERIALIO_WIDTH];
assign serial_rclk = io_in[RXCLK_OFFSET];

assign io_out[TXD_OFFSET +: pSERIALIO_WIDTH] = serial_txd;
assign io_out[TXCLK_OFFSET] = serial_tclk;


endmodule // MPRJ_IO


