`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/16/2023 11:55:15 AM
// Design Name: 
// Module Name: tb_fsic
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_fsic #( parameter BITS=32,
		parameter pSERIALIO_WIDTH   = 12,
		parameter pADDR_WIDTH   = 10,
		parameter pDATA_WIDTH   = 32,
		parameter IOCLK_Period	= 10,
		parameter DLYCLK_Period	= 1,
		parameter SHIFT_DEPTH = 5,
		parameter pRxFIFO_DEPTH = 5,
		parameter pCLK_RATIO = 4
	)
(
);

    real ioclk_pd = IOCLK_Period;

  reg 			resetb;	
  wire 			ioclk;	
  wire           wb_rst;
  wire           wb_clk;
  reg   [31: 0] wbs_adr;
  reg   [31: 0] wbs_wdata;
  reg    [3: 0] wbs_sel;
  reg           wbs_cyc;
  reg           wbs_stb;
  reg           wbs_we;
  reg  [127: 0] la_data_in;
  reg  [127: 0] la_oenb;
  reg   [37: 0] io_in;
  reg           vccd1;
  reg           vccd2;
  reg           vssd1;
  reg           vssd2;
  reg           user_clock2;
	reg [31:0] mem1 [0:255];
	reg [31:0] mem2 [0:255];
	reg [31:0] mem3 [0:255];
	
	wire coreclk;
	assign wb_clk = coreclk;
	assign wb_rst = resetb;
	assign ioclk = user_clock2;
	
	fsic_clock_div soc_clock_div (
	.resetb(resetb),
	.in(ioclk),
	.out(coreclk)
	);

FSIC #(
		.pSERIALIO_WIDTH(pSERIALIO_WIDTH),
		.pADDR_WIDTH(pADDR_WIDTH),
		.pDATA_WIDTH(pDATA_WIDTH),
		.pRxFIFO_DEPTH(pRxFIFO_DEPTH),
		.pCLK_RATIO(pCLK_RATIO)
	)
	dut (
		.wb_rst(wb_rst),
		.wb_clk(wb_clk),
		.wbs_adr(wbs_adr),
		.wbs_wdata(wbs_wdata),
		.wbs_sel(wbs_sel),
		.wbs_cyc(wbs_cyc),
		.wbs_stb(wbs_stb),
		.wbs_we(wbs_we),
		.la_data_in(la_data_in),
		.la_oenb(la_oenb),
		.io_in(io_in),
		.vccd1(vccd1),
		.vccd2(vccd2),
		.vssd1(vssd1),
		.vssd2(vssd2),
		.wbs_ack(wbs_ack),
		.la_data_out(la_data_out),
		.user_irq(user_irq),
		.io_out(io_out),
		.io_oeb(io_oeb),
		.user_clock2(user_clock2)
	);

	integer index;
	
    initial begin
        resetb = 0;
		wbs_adr = 0;
		wbs_wdata = 0;
		wbs_sel = 0;
		wbs_cyc = 0;
		wbs_stb = 0;
		wbs_we = 0;
		la_data_in = 0;
		la_oenb = 0;
		io_in = 0;
		vccd1 = 1;
		vccd2 = 1;
		vssd1 = 1;
		vssd2 = 1;
		user_clock2 = 0;
        

		wbs_adr = 32'b0;
		wbs_wdata = 32'b0;
		wbs_sel = 4'b0;
		wbs_cyc = 1'b0;
		wbs_stb = 1'b0;
		wbs_we = 1'b0;		
		
		for ( index = 0; index < 256; index = index + 1)
		begin
			mem1[index] = index;
			mem2[index] = index;
			mem3[index] = index;
		end
		
		#100;
		resetb = 1;

	
		#200;

		repeat (6) @ (posedge coreclk);		
		wbs_adr <= 32'h3000_3000;			//ioserdes rxen
		wbs_wdata <= 32'h0000_0001;
		wbs_sel <= 4'b0001;
		wbs_cyc <= 1'b1;
		wbs_stb <= 1'b1;
		wbs_we <= 1'b1;		

		repeat (6) @ (posedge coreclk);
		wbs_adr <= 32'h3000_3000;			//ioserdes txen
		wbs_wdata <= 32'h0000_0003;
		wbs_sel <= 4'b0001;
		wbs_cyc <= 1'b1;
		wbs_stb <= 1'b1;
		wbs_we <= 1'b1;		

		repeat (6) @ (posedge coreclk);
		wbs_adr <= 32'h3000_2000;			//aa mailbox write
		wbs_wdata <= 32'ha5a5_a5a5;
		wbs_sel <= 4'b1111;
		wbs_cyc <= 1'b1;
		wbs_stb <= 1'b1;
		wbs_we <= 1'b1;		

		repeat (10) @ (posedge coreclk);
		wbs_adr <= 32'h3000_0000;			//aa read
		wbs_wdata <= 32'ha5a5_a5a5;
		wbs_sel <= 4'b1111;
		wbs_cyc <= 1'b1;
		wbs_stb <= 1'b1;
		wbs_we <= 1'b0;		
        
    end
    
	//WB Master wb_ack_o handling
	always @( posedge wb_clk or negedge wb_rst) begin
		if ( !wb_rst ) begin
			wbs_adr <= 32'h0;
			wbs_wdata <= 32'h0;
			wbs_sel <= 4'b0;
			wbs_cyc <= 1'b0;
			wbs_stb <= 1'b0;
			wbs_we <= 1'b0;			
		end else begin 
			if ( wbs_ack ) begin
				wbs_adr <= 32'h0;
				wbs_wdata <= 32'h0;
				wbs_sel <= 4'b0;
				wbs_cyc <= 1'b0;
				wbs_stb <= 1'b0;
				wbs_we <= 1'b0;
			end
		end
	end    
	always #(ioclk_pd/2) user_clock2 = ~user_clock2;


endmodule