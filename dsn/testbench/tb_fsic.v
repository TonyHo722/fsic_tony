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
		// parameter DLYCLK_Period	= 1,
		parameter SHIFT_DEPTH = 5,
		parameter pRxFIFO_DEPTH = 5,
		parameter pCLK_RATIO = 4
	)
(
);
		localparam TEST002_CNT	= 4;

    real ioclk_pd = IOCLK_Period;

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
	
	wire soc_coreclk;
	wire fpga_coreclk;
	
	assign wb_clk = soc_coreclk;
	assign wb_rst = soc_resetb;
	assign ioclk = user_clock2;
	
//-------------------------------------------------------------------------------------

	//reg soc_rst;
	reg fpga_rst;
	reg soc_resetb;		//POR reset
	reg fpga_resetb;	//POR reset	
	
	//reg ioclk;
	//reg dlyclk;
/*
	reg [7:0] soc_compare_data;
	
	//write addr channel
	reg soc_axi_awvalid;
	reg [pADDR_WIDTH+1:2] soc_axi_awaddr;
	wire soc_axi_awready;
	
	//write data channel
	reg 	soc_axi_wvalid;
	reg 	[pDATA_WIDTH-1:0] soc_axi_wdata;
	reg 	[3:0] soc_axi_wstrb;
	wire	soc_axi_wready;
	
	//read addr channel
	reg 	soc_axi_arvalid;
	reg 	[pADDR_WIDTH+1:2] soc_axi_araddr;
	wire 	soc_axi_arready;
	
	//read data channel
	wire 	soc_axi_rvalid;
	wire 	[pDATA_WIDTH-1:0] soc_axi_rdata;
	reg 	soc_axi_rready;
	
	reg 	soc_cc_is_enable;		//axi_lite enable
*/


	//write addr channel
	reg fpga_axi_awvalid;
	reg [pADDR_WIDTH+1:2] fpga_axi_awaddr;
	wire fpga_axi_awready;
	
	//write data channel
	reg 	fpga_axi_wvalid;
	reg 	[pDATA_WIDTH-1:0] fpga_axi_wdata;
	reg 	[3:0] fpga_axi_wstrb;
	wire	fpga_axi_wready;
	
	//read addr channel
	reg 	fpga_axi_arvalid;
	reg 	[pADDR_WIDTH+1:2] fpga_axi_araddr;
	wire 	fpga_axi_arready;
	
	//read data channel
	wire 	fpga_axi_rvalid;
	wire 	[pDATA_WIDTH-1:0] fpga_axi_rdata;
	reg 	fpga_axi_rready;
	
	reg 	fpga_cc_is_enable;		//axi_lite enable

/*
	reg [pDATA_WIDTH-1:0] soc_as_is_tdata;
	reg [3:0] soc_as_is_tstrb;
	reg [3:0] soc_as_is_tkeep;
	reg soc_as_is_tlast;
	reg [1:0] soc_as_is_tid;
	reg soc_as_is_tvalid;
	reg [1:0] soc_as_is_tuser;
	reg soc_as_is_tready;		//when local side axis switch Rxfifo size <= threshold then as_is_tready=0; this flow control mechanism is for notify remote side do not provide data with is_as_tvalid=1

//	wire [7:0] soc_Serial_Data_Out_tdata;
//	wire soc_Serial_Data_Out_tstrb;
//	wire soc_Serial_Data_Out_tkeep;
//	wire soc_Serial_Data_Out_tid_tuser;	// tid and tuser	
//	wire soc_Serial_Data_Out_tlast_tvalid_tready;		//flowcontrol

	wire [pDATA_WIDTH-1:0] soc_is_as_tdata;
	wire [3:0] soc_is_as_tstrb;
	wire [3:0] soc_is_as_tkeep;
	wire soc_is_as_tlast;
	wire [1:0] soc_is_as_tid;
	wire soc_is_as_tvalid;
	wire [1:0] soc_is_as_tuser;
	wire soc_is_as_tready;		//when remote side axis switch Rxfifo size <= threshold then is_as_tready=0; this flow control mechanism is for notify local side do not provide data with as_is_tvalid=1
*/
	wire [pSERIALIO_WIDTH-1:0] soc_serial_txd;
	wire soc_txclk;
	wire fpga_txclk;
	
	reg [pDATA_WIDTH-1:0] fpga_as_is_tdata;
	reg [3:0] fpga_as_is_tstrb;
	reg [3:0] fpga_as_is_tkeep;
	reg fpga_as_is_tlast;
	reg [1:0] fpga_as_is_tid;
	reg fpga_as_is_tvalid;
	reg [1:0] fpga_as_is_tuser;
	reg fpga_as_is_tready;		//when local side axis switch Rxfifo size <= threshold then as_is_tready=0; this flow control mechanism is for notify remote side do not provide data with is_as_tvalid=1

	wire [pSERIALIO_WIDTH-1:0] fpga_serial_txd;
//	wire [7:0] fpga_Serial_Data_Out_tdata;
//	wire fpga_Serial_Data_Out_tstrb;
//	wire fpga_Serial_Data_Out_tkeep;
//	wire fpga_Serial_Data_Out_tid_tuser;	// tid and tuser	
//	wire fpga_Serial_Data_Out_tlast_tvalid_tready;		//flowcontrol

	wire [pDATA_WIDTH-1:0] fpga_is_as_tdata;
	wire [3:0] fpga_is_as_tstrb;
	wire [3:0] fpga_is_as_tkeep;
	wire fpga_is_as_tlast;
	wire [1:0] fpga_is_as_tid;
	wire fpga_is_as_tvalid;
	wire [1:0] fpga_is_as_tuser;
	wire fpga_is_as_tready;		//when remote side axis switch Rxfifo size <= threshold then is_as_tready=0, this flow control mechanism is for notify local side do not provide data with as_is_tvalid=1


	//wire [7:0] Serial_Data_Out_ad_delay1;
	//wire txclk_delay1;

	//wire [7:0] Serial_Data_Out_ad_delay;
	//wire txclk_delay;

	//assign #4 Serial_Data_Out_ad_delay1 = Serial_Data_Out_ad;
	//assign #4 txclk_delay1 = txclk;
	//assign #4 Serial_Data_Out_ad_delay = Serial_Data_Out_ad_delay1;
	//assign #4 txclk_delay = txclk_delay1;

//-------------------------------------------------------------------------------------	
	fsic_clock_div soc_clock_div (
	.resetb(soc_resetb),
	.in(ioclk),
	.out(soc_coreclk)
	);

	fsic_clock_div fpga_clock_div (
	.resetb(fpga_resetb),
	.in(ioclk),
	.out(fpga_coreclk)
	);

FSIC #(
		.pSERIALIO_WIDTH(pSERIALIO_WIDTH),
		.pADDR_WIDTH(pADDR_WIDTH),
		.pDATA_WIDTH(pDATA_WIDTH),
		.pRxFIFO_DEPTH(pRxFIFO_DEPTH),
		.pCLK_RATIO(pCLK_RATIO)
	)
	dut (
		.serial_tclk(soc_txclk),
		.serial_rclk(fpga_txclk),
		.serial_txd(soc_serial_txd),
		.serial_rxd(fpga_serial_txd),
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

	fpga  #(
		.pSERIALIO_WIDTH(pSERIALIO_WIDTH),
		.pADDR_WIDTH(pADDR_WIDTH),
		.pDATA_WIDTH(pDATA_WIDTH),
		.pRxFIFO_DEPTH(pRxFIFO_DEPTH),
		.pCLK_RATIO(pCLK_RATIO)
	)
	fpga_fsic(
		.axis_rst_n(~fpga_rst),
		.axi_reset_n(~fpga_rst),
		.serial_tclk(fpga_txclk),
		.serial_rclk(soc_txclk),
		.ioclk(ioclk),
		.axis_clk(fpga_coreclk),
		.axi_clk(fpga_coreclk),
		
		//write addr channel
		.axi_awvalid_s_awvalid(fpga_axi_awvalid),
		.axi_awaddr_s_awaddr(fpga_axi_awaddr),
		.axi_awready_axi_awready3(fpga_axi_awready),

		//write data channel
		.axi_wvalid_s_wvalid(fpga_axi_wvalid),
		.axi_wdata_s_wdata(fpga_axi_wdata),
		.axi_wstrb_s_wstrb(fpga_axi_wstrb),
		.axi_wready_axi_wready3(fpga_axi_wready),

		//read addr channel
		.axi_arvalid_s_arvalid(fpga_axi_arvalid),
		.axi_araddr_s_araddr(fpga_axi_araddr),
		.axi_arready_axi_arready3(fpga_axi_arready),
		
		//read data channel
		.axi_rvalid_axi_rvalid3(fpga_axi_rvalid),
		.axi_rdata_axi_rdata3(fpga_axi_rdata),
		.axi_rready_s_rready(fpga_axi_rready),
		
		.cc_is_enable(fpga_cc_is_enable),


		.as_is_tdata(fpga_as_is_tdata),
		.as_is_tstrb(fpga_as_is_tstrb),
		.as_is_tkeep(fpga_as_is_tkeep),
		.as_is_tlast(fpga_as_is_tlast),
		.as_is_tid(fpga_as_is_tid),
		.as_is_tvalid(fpga_as_is_tvalid),
		.as_is_tuser(fpga_as_is_tuser),
		.as_is_tready(fpga_as_is_tready),
		.serial_txd(fpga_serial_txd),
		.serial_rxd(soc_serial_txd),
		.is_as_tdata(fpga_is_as_tdata),
		.is_as_tstrb(fpga_is_as_tstrb),
		.is_as_tkeep(fpga_is_as_tkeep),
		.is_as_tlast(fpga_is_as_tlast),
		.is_as_tid(fpga_is_as_tid),
		.is_as_tvalid(fpga_is_as_tvalid),
		.is_as_tuser(fpga_is_as_tuser),
		.is_as_tready(fpga_is_as_tready)
	);


	
    initial begin
        soc_resetb = 0;
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
        
		test001();
		test002();
		
		#400;
		$finish;
        
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

	task test001;
		begin
			#100;
			soc_apply_reset(40,40);
			fpga_apply_reset(40,40);


		
			#200;

			soc_is_cfg_write(0, 1);				//ioserdes rxen

			soc_is_cfg_write(0, 3);				//ioserdes txen

			repeat (6) @ (posedge soc_coreclk);
			wbs_adr <= 32'h3000_2000;			//aa mailbox write
			wbs_wdata <= 32'ha5a5_a5a5;
			wbs_sel <= 4'b1111;
			wbs_cyc <= 1'b1;
			wbs_stb <= 1'b1;
			wbs_we <= 1'b1;		

			repeat (10) @ (posedge soc_coreclk);
			wbs_adr <= 32'h3000_0000;			//aa read
			wbs_wdata <= 32'ha5a5_a5a5;
			wbs_sel <= 4'b1111;
			wbs_cyc <= 1'b1;
			wbs_stb <= 1'b1;
			wbs_we <= 1'b0;		
		end
	endtask

	reg[31:0] i;

	task test002;
		//input [7:0] compare_data;

		begin
			for (i=0;i<TEST002_CNT;i=i+1) begin
				$display("test002: TX/RX test - loop %02d", i);
				fork 
					soc_apply_reset(40+i*10, 40);			//change coreclk phase in soc
					fpga_apply_reset(40,40);		//fix coreclk phase in fpga
				join
				#40;
				//soc_cc_is_enable=1;
				fpga_cc_is_enable=1;
				fork 
					soc_is_cfg_write(0, 1);				//ioserdes rxen
					fpga_cfg_write(0,1,1,0);
				join
				$display($time, "=> soc rxen_ctl=1");
				$display($time, "=> fpga rxen_ctl=1");

				#400;
				fork 
					soc_is_cfg_write(0, 3);				//ioserdes txen
					fpga_cfg_write(0,3,1,0);
				join
				$display($time, "=> soc txen_ctl=1");
				$display($time, "=> fpga txen_ctl=1");

				#200;
				fpga_as_is_tdata = 32'h5a5a5a5a;
				#40;

				fork
					test002_fpga();					//fpga issue data to soc
				join	
				#200;
			end
		end
	endtask

	reg[31:0]idx1;

	task test002_fpga;
		//input [7:0] compare_data;

		begin
			@ (posedge soc_coreclk);
			fpga_as_is_tready = 1;
			
			for(idx1=0; idx1<16; idx1=idx1+1)begin
				fpga_as_is_tdata <=  idx1 * 32'h11111111;
				fpga_as_is_tstrb <=  idx1 * 4'h1;
				fpga_as_is_tkeep <=  idx1 * 4'h1;
				fpga_as_is_tid <=  idx1 * 2'h1;
				fpga_as_is_tuser <=  idx1 * 2'h1;
				fpga_as_is_tlast <=  idx1 * 1'h1;
				fpga_as_is_tvalid <= 1;

				@ (posedge fpga_coreclk);
				while (fpga_is_as_tready == 0) begin		// wait util fpga_is_as_tready == 1 then change data
						@ (posedge fpga_coreclk);
				end
			end
			fpga_as_is_tvalid <= 0;

			$display($time, "=> test002_fpga done");
		end
	endtask

/*
	reg[31:0]idx2;

	task test002_fpga;
		//input [7:0] compare_data;

		begin
			fpga_as_is_tready = 1;
			@ (posedge fpga_coreclk);
			//for Axis Switch Rx
			for(idx2=0; idx2<16; idx2=idx2+1)begin
				@ (posedge fpga_coreclk);
				while ( fpga_is_as_tvalid == 0) begin
					@ (posedge fpga_coreclk);
				end
				$display($time, "=> fpga idx2=%x", idx2);
			end
		$display($time, "=> test002_fpga done");
		end
	endtask
*/

/*	
	task test00n;
		begin
		end
	endtask
*/

	//apply reset
	task soc_apply_reset;
		input real delta1;		// for POR De-Assert
		input real delta2;		// for reset De-Assert
		begin
			#(40);
			$display($time, "=> soc POR Assert"); 
			soc_resetb = 0;
			//$display($time, "=> soc reset Assert"); 
			//soc_rst = 1;
			#(delta1);

			$display($time, "=> soc POR De-Assert"); 
			soc_resetb = 1;

			#(delta2);
			//$display($time, "=> soc reset De-Assert"); 
			//soc_rst = 0;
		end	
	endtask
	
	task fpga_apply_reset;
		input real delta1;		// for POR De-Assert
		input real delta2;		// for reset De-Assert
		begin
			#(40);
			$display($time, "=> fpga POR Assert"); 
			fpga_resetb = 0;
			$display($time, "=> fpga reset Assert"); 
			fpga_rst = 1;
			#(delta1);

			$display($time, "=> fpga POR De-Assert"); 
			fpga_resetb = 1;

			#(delta2);
			$display($time, "=> fpga reset De-Assert"); 
			fpga_rst = 0;
		end
	endtask

	task soc_is_cfg_write;
		input [11:2] offset;
		input [31:0] data;
		
		begin
			repeat (6) @ (posedge soc_coreclk);		
			wbs_adr <= 32'h3000_3000;			//is base
			wbs_adr[11:2] <= offset;			//offset
			
			wbs_wdata <= data;
			wbs_sel <= 4'b0001;
			wbs_cyc <= 1'b1;
			wbs_stb <= 1'b1;
			wbs_we <= 1'b1;	
			
			$strobe($time, "=> soc_is_cfg_write : wbs_adr=%x, wbs_wdata=%b", wbs_adr, wbs_wdata); 
		end
	endtask

	task fpga_cfg_write;		//input addr, data, strb and valid_delay 
		input [pADDR_WIDTH+1:2] axi_awaddr;
		input [pDATA_WIDTH-1:0] axi_wdata;
		input [3:0] axi_wstrb;
		input [7:0] valid_delay;
		
		begin
			fpga_axi_awaddr <= axi_awaddr;
			fpga_axi_awvalid <= 0;
			fpga_axi_wdata <= axi_wdata;
			fpga_axi_wstrb <= axi_wstrb;
			fpga_axi_wvalid <= 0;
			//$display($time, "=> fpga_delay_valid before : valid_delay=%x", valid_delay); 
			repeat (valid_delay) @ (posedge fpga_coreclk);
			//$display($time, "=> fpga_delay_valid after  : valid_delay=%x", valid_delay); 
			fpga_axi_awvalid <= 1;
			fpga_axi_wvalid <= 1;
			@ (posedge fpga_coreclk);
			while (fpga_axi_awready == 0) begin		//assume both fpga_axi_awready and fpga_axi_wready assert as the same time.
					@ (posedge fpga_coreclk);
			end
			$display($time, "=> fpga_cfg_write : fpga_axi_awaddr=%x, fpga_axi_awvalid=%b, fpga_axi_awready=%b, fpga_axi_wdata=%x, axi_wstrb=%x, fpga_axi_wvalid=%b, fpga_axi_wready=%b", fpga_axi_awaddr, fpga_axi_awvalid, fpga_axi_awready, fpga_axi_wdata, axi_wstrb, fpga_axi_wvalid, fpga_axi_wready); 
			fpga_axi_awvalid <= 0;
			fpga_axi_wvalid <= 0;
		end
		
	endtask

endmodule