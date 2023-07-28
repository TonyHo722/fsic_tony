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
		parameter pADDR_WIDTH   = 15,
		parameter pDATA_WIDTH   = 32,
		parameter IOCLK_Period	= 10,
		// parameter DLYCLK_Period	= 1,
		parameter SHIFT_DEPTH = 5,
		parameter pRxFIFO_DEPTH = 5,
		parameter pCLK_RATIO = 4
	)
(
);
		localparam CoreClkPhaseLoop	= 4;
		localparam UP_BASE=32'h3000_0000;
		localparam AA_BASE=32'h3000_2000;
		localparam IS_BASE=32'h3000_3000;
		
		
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

	
//-------------------------------------------------------------------------------------

	reg[31:0] i;
	
	reg[31:0] cfg_read_expect_data;
	reg[31:0] cfg_read_result;

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

	wire	wbs_ack;
	wire	[pDATA_WIDTH-1: 0] wbs_rdata;

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
		.wbs_rdata(wbs_rdata),		
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

	assign wb_clk = soc_coreclk;
	assign wb_rst = ~soc_resetb;		//wb_rst is high active
	assign ioclk = user_clock2;
	

	
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
        
		test001();	//soc cfg write test
		test002();	//test002_fpga_axis_req
		test003();	//test003_fpga_cfg_read
		test004();	//test004_fpga_mail_box_write
		
		#400;
		$finish;
        
    end
    
	//WB Master wb_ack_o handling
	always @( posedge wb_clk or posedge wb_rst) begin
		if ( wb_rst ) begin
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
			$display("test001: soc cfg write test", i);

			#100;
			soc_apply_reset(40,40);
			fpga_apply_reset(40,40);

		
			#200;

			soc_is_cfg_write(0, 4'b0001, 1);				//ioserdes rxen

			soc_is_cfg_read(0, 4'b0001);				//ioserdes cfg read

			soc_is_cfg_write(0, 4'b0001, 3);				//ioserdes txen

			soc_is_cfg_read(0, 4'b0001);				//ioserdes cfg read

			soc_aa_cfg_write(0, 4'b1111, 32'ha5a5_a5a5);				//offset 0x00~0xff for mail box write to AA

			soc_aa_cfg_read(0, 4'b1111);				//offset 0x00~0xff for mail box read from AA

			//soc_up_cfg_read(0, 4'b1111);				
			#100;
			test001_is_soc_cfg();

			test001_aa_soc_cfg();
			#100;
		end
	endtask

	task test001_is_soc_cfg;
		begin
			//Test offset 0x00 only for io serdes
			$display("test001_is_soc_cfg: soc cfg read/write test");

			cfg_read_expect_data = 32'h01;	
			soc_is_cfg_write(0, 4'b0001, cfg_read_expect_data);				//ioserdes rxen
			soc_is_cfg_read(0, 4'b1111);
			if (cfg_read_result !== cfg_read_expect_data) 
				$display($time, "=> test001_is_soc_cfg [ERROR] cfg_read_expect_data=%x, cfg_read_result=%x", cfg_read_expect_data, cfg_read_result);
			else
				$display($time, "=> test001_is_soc_cfg [PASS] cfg_read_expect_data=%x, cfg_read_result=%x", cfg_read_expect_data, cfg_read_result);
			$display("-----------------");

			cfg_read_expect_data = 32'h03;	
			soc_is_cfg_write(0, 4'b0001, cfg_read_expect_data);				//ioserdes rxen
			soc_is_cfg_read(0, 4'b1111);
			if (cfg_read_result !== cfg_read_expect_data) 
				$display($time, "=> test001_is_soc_cfg [ERROR] cfg_read_expect_data=%x, cfg_read_result=%x", cfg_read_expect_data, cfg_read_result);
			else
				$display($time, "=> test001_is_soc_cfg [PASS] cfg_read_expect_data=%x, cfg_read_result=%x", cfg_read_expect_data, cfg_read_result);
			$display("-----------------");
			$display("test001_is_soc_cfg: soc cfg read/write test - end");
			$display("--------------------------------------------------------------------");

			#100;
		end
	endtask


	task test001_aa_soc_cfg;
		begin
			//Test offset 0x00~0xff for mail box write to AA
			$display("test001_aa_soc_cfg: soc cfg read/write test");

			$display("test001_aa_soc_cfg: AA Mail Box read/write test - start");
			for (i=0;i<32'h100;i=i+4) begin

				cfg_read_expect_data = 	32'ha5a5_a5a5;	
				soc_aa_cfg_write(i, 4'b1111, cfg_read_expect_data);				
				soc_aa_cfg_read(i, 4'b1111);
				if (cfg_read_result !== cfg_read_expect_data) 
					$display($time, "=> test001_aa_soc_cfg [ERROR] cfg_read_expect_data=%x, cfg_read_result=%x", cfg_read_expect_data, cfg_read_result);
				else
					$display($time, "=> test001_aa_soc_cfg [PASS] cfg_read_expect_data=%x, cfg_read_result=%x", cfg_read_expect_data, cfg_read_result);
				$display("-----------------");
			end
			$display("test001_aa_soc_cfg: AA Mail Box read/write test - end");
			$display("--------------------------------------------------------------------");

			//Test offset 0x100~0xfff for AA internal register 
			$display("test001_aa_soc_cfg: AA internal register read/write test - start");
			for (i=0;i<32'h100;i=i+4) begin

				cfg_read_expect_data = 	32'ha5a5_a5a5;	
				soc_aa_cfg_write(i+32'h100, 4'b1111, cfg_read_expect_data);				
				soc_aa_cfg_read(i+32'h100, 4'b1111);
				if (cfg_read_result !== cfg_read_expect_data) 
					$display($time, "=> test001_aa_soc_cfg [ERROR] cfg_read_expect_data=%x, cfg_read_result=%x", cfg_read_expect_data, cfg_read_result);
				else
					$display($time, "=> test001_aa_soc_cfg [PASS] cfg_read_expect_data=%x, cfg_read_result=%x", cfg_read_expect_data, cfg_read_result);
				$display("-----------------");
			end
			$display("test001_aa_soc_cfg: AA Mail Box read/write test - end");
			$display("--------------------------------------------------------------------");

			#100;
		end
	endtask


	initial begin		//get wishbone read data result.
		while (1) begin
			@(posedge soc_coreclk);
			if (wbs_ack==1 && wbs_we == 0) begin
				$display($time, "=> get wishbone read data result be : cfg_read_result =%x, wbs_rdata=%x", cfg_read_result, wbs_rdata);
				cfg_read_result = wbs_rdata ;		//use non block assignment
				$display($time, "=> get wishbone read data result af : cfg_read_result =%x, wbs_rdata=%x", cfg_read_result, wbs_rdata);
			end	
		end
	end

	task test004;
		//input [7:0] compare_data;

		begin
			for (i=0;i<CoreClkPhaseLoop;i=i+1) begin
				$display("test004: TX/RX test - loop %02d", i);
				fork 
					soc_apply_reset(40+i*10, 40);			//change coreclk phase in soc
					fpga_apply_reset(40,40);		//fix coreclk phase in fpga
				join
				#40;
				//soc_cc_is_enable=1;
				fpga_cc_is_enable=1;
				fork 
					soc_is_cfg_write(0, 4'b0001, 1);				//ioserdes rxen
					fpga_cfg_write(0,1,1,0);
				join
				$display($time, "=> soc rxen_ctl=1");
				$display($time, "=> fpga rxen_ctl=1");

				#400;
				fork 
					soc_is_cfg_write(0, 4'b0001, 3);				//ioserdes txen
					fpga_cfg_write(0,3,1,0);
				join
				$display($time, "=> soc txen_ctl=1");
				$display($time, "=> fpga txen_ctl=1");

				#200;
				fpga_as_is_tdata = 32'h5a5a5a5a;
				#40;
				#200;

				test004_fpga_mail_box_write();		//target to AA
				#200;
			end
		end
	endtask

	reg[31:0]idx1;

	task test004_fpga_mail_box_write;
		//input [7:0] compare_data;

		//FPGA to SOC Axilite test
		begin
			@ (posedge soc_coreclk);
			fpga_as_is_tready <= 1;
			
			for(idx1=0; idx1<32/4; idx1=idx1+1)begin		//
				fpga_axilite_write(28'h0000_2000 + idx1*4, 4'b1111, 32'h11111111 * idx1);
					//mailbox supported range address = 0x0000_2000 ~ 0000_201F
					//BE = 4'b1111
					//data = 32'h11111111 * idx1
			end

			$display($time, "=> test004_fpga_mail_box_write done");
		end
	endtask

	task fpga_axilite_write;
		input [27:0] address;
		input [3:0] BE;
		input [31:0] data;
		begin
			fpga_as_is_tdata <= (BE<<28) + address;	//for axilite write address phase
			//$strobe($time, "=> fpga_as_is_tdata in address phase = %x", fpga_as_is_tdata);
			fpga_as_is_tstrb <=  4'b0000;
			fpga_as_is_tkeep <=  4'b0000;
			fpga_as_is_tid <=  2'b01;		//target to Axis-Axilite
			fpga_as_is_tuser <=  2'b01;		//for axilite write
			fpga_as_is_tlast <=  1'b0;
			fpga_as_is_tvalid <= 1;

			@ (posedge fpga_coreclk);
			while (fpga_is_as_tready == 0) begin		// wait util fpga_is_as_tready == 1 then change data
					@ (posedge fpga_coreclk);
			end

			fpga_as_is_tdata <=  data;	//for axilite write data phase
			fpga_as_is_tstrb <=  4'b0000;
			fpga_as_is_tkeep <=  4'b0000;
			fpga_as_is_tid <=  2'b01;		//target to Axis-Axilite
			fpga_as_is_tuser <=  2'b01;		//for axilite write
			fpga_as_is_tlast <=  1'b0;
			fpga_as_is_tvalid <= 1;

			@ (posedge fpga_coreclk);
			while (fpga_is_as_tready == 0) begin		// wait util fpga_is_as_tready == 1 then change data
					@ (posedge fpga_coreclk);
			end
			fpga_as_is_tvalid <= 0;
		
		end
	endtask


	task test003;
		//input [7:0] compare_data;

		begin
			for (i=0;i<CoreClkPhaseLoop;i=i+1) begin
				$display("test003: fpga_cfg_read test - loop %02d", i);
				fork 
					soc_apply_reset(40+i*10, 40);			//change coreclk phase in soc
					fpga_apply_reset(40,40);		//fix coreclk phase in fpga
				join
				#40;
				//soc_cc_is_enable=1;
				fpga_cc_is_enable=1;
				fork 
					soc_is_cfg_write(0, 4'b0001, 1);				//ioserdes rxen
					fpga_cfg_write(0,1,1,0);
				join
				$display($time, "=> soc rxen_ctl=1");
				$display($time, "=> fpga rxen_ctl=1");

				#400;
				fork 
					soc_is_cfg_write(0, 4'b0001, 3);				//ioserdes txen
					fpga_cfg_write(0,3,1,0);
				join
				$display($time, "=> soc txen_ctl=1");
				$display($time, "=> fpga txen_ctl=1");

				#200;
				fpga_as_is_tdata = 32'h5a5a5a5a;
				#40;
				#200;

				test003_fpga_cfg_read();

				#200;
			end
		end
	endtask

	reg[31:0]idx2;

	task test003_fpga_cfg_read;		//target to io serdes
		//input [7:0] compare_data;

		//FPGA to SOC Axilite test
		begin

			@ (posedge soc_coreclk);
			fpga_as_is_tready <= 1;
			
			for(idx2=0; idx2<32/4; idx2=idx2+1)begin		//
				fpga_axilite_read_req(32'h0000_3000 + idx2*4);
					//read address = h0000_3000 ~ h0000_301F for io serdes
				repeat(100) @ (posedge soc_coreclk);    //TODO wait for read competion to replace the delay	
				//fpga_is_as_data_valid();
			end
			$display($time, "=> test003_fpga_cfg_read done");
		end
	endtask


	task fpga_axilite_read_req;
		input [31:0] address;
		begin
			fpga_as_is_tdata <= address;	//for axilite read address req phase
			$strobe($time, "=> fpga_axilite_read_req in address req phase = %x - tvalid", fpga_as_is_tdata);
			fpga_as_is_tstrb <=  4'b0000;
			fpga_as_is_tkeep <=  4'b0000;
			fpga_as_is_tid <=  2'b01;		//target to Axis-Axilite
			fpga_as_is_tuser <=  2'b10;		//for axilite read req
			fpga_as_is_tlast <=  1'b0;
			fpga_as_is_tvalid <= 1;

			@ (posedge fpga_coreclk);
			while (fpga_is_as_tready == 0) begin		// wait util fpga_is_as_tready == 1 then change data
					@ (posedge fpga_coreclk);
			end
			$strobe($time, "=> fpga_axilite_read_req in address req phase = %x - transfer", fpga_as_is_tdata);
			fpga_as_is_tvalid <= 0;
		
		end
	endtask

	task fpga_is_as_data_valid;
		// input [31:0] address;
		begin
			fpga_as_is_tready <= 1;		//TODO change to other location for set fpga_as_is_tready
			//force fpga_is_as_tvalid=1;
			
			$strobe($time, "=> fpga_is_as_data_valid wait fpga_is_as_tvalid");
			@ (posedge fpga_coreclk);
			while (fpga_is_as_tvalid == 0) begin		// wait util fpga_is_as_tvalid == 1 
					@ (posedge fpga_coreclk);
			end
			$strobe($time, "=> fpga_is_as_data_valid wait fpga_is_as_tvalid done, fpga_is_as_tvalid = %b", fpga_is_as_tvalid);
		
		end
	endtask

	task test002;		//test002_fpga_axis_req
		//input [7:0] compare_data;

		begin
			for (i=0;i<CoreClkPhaseLoop;i=i+1) begin
				$display("test002: fpga_axis_req - loop %02d", i);
				fork 
					soc_apply_reset(40+i*10, 40);			//change coreclk phase in soc
					fpga_apply_reset(40,40);		//fix coreclk phase in fpga
				join
				#40;
				//soc_cc_is_enable=1;
				fpga_cc_is_enable=1;
				fork 
					soc_is_cfg_write(0, 4'b0001, 1);				//ioserdes rxen
					fpga_cfg_write(0,1,1,0);
				join
				$display($time, "=> soc rxen_ctl=1");
				$display($time, "=> fpga rxen_ctl=1");

				#400;
				fork 
					soc_is_cfg_write(0, 4'b0001, 3);				//ioserdes txen
					fpga_cfg_write(0,3,1,0);
				join
				$display($time, "=> soc txen_ctl=1");
				$display($time, "=> fpga txen_ctl=1");

				#200;
				fpga_as_is_tdata = 32'h5a5a5a5a;
				#40;
				#200;

				test002_fpga_axis_req();		//target to Axis Switch

				#200;
			end
		end
	endtask

	reg[31:0]idx3;

	task test002_fpga_axis_req;
		//input [7:0] compare_data;

		//FPGA to SOC Axilite test
		begin
			//force User project up_as_tready = 1;
			force dut.AXIS_SW0.up_as_tready = 1;

			@ (posedge soc_coreclk);
			fpga_as_is_tready <= 1;
			
			for(idx3=0; idx3<32; idx3=idx3+1)begin		//
				fpga_axis_req(32'h11111111 * idx3, 2'b00);		//target to User Project
				//if (idx3 > 12 ) 			force dut.AXIS_SW0.up_as_tready = 1;
			end
			release dut.AXIS_SW0.up_as_tready;
			
			$display($time, "=> test002_fpga_axis_req done");
		end
	endtask

	task fpga_axis_req;
		input [31:0] data;
		input [1:0] tid;
		begin
			fpga_as_is_tdata <= data;	//for axis write data
			$strobe($time, "=> fpga_axis_req fpga_as_is_tdata = %x", fpga_as_is_tdata);
			fpga_as_is_tstrb <=  4'b0000;
			fpga_as_is_tkeep <=  4'b0000;
			fpga_as_is_tid <=  tid;		//set target
			fpga_as_is_tuser <=  2'b00;		//for axis req
			fpga_as_is_tlast <=  1'b0;
			fpga_as_is_tvalid <= 1;

			@ (posedge fpga_coreclk);
			while (fpga_is_as_tready == 0) begin		// wait util fpga_is_as_tready == 1 then change data
					@ (posedge fpga_coreclk);
			end
			fpga_as_is_tvalid <= 0;
		
		end
	endtask

// soc_axis_loopback
initial begin
	soc_axis_loopback();
end

	task soc_axis_loopback;
		//input [31:0] data;
		//input [1:0] tid;
		begin
			$display($time, "=> soc_axis_loopback force dut.AXIS_SW0.up_as_tvalid = 1");
			force dut.AXIS_SW0.up_as_tvalid = dut.AXIS_SW0.as_up_tvalid;
			force dut.AXIS_SW0.up_as_tdata = dut.AXIS_SW0.as_up_tdata;
			force dut.AXIS_SW0.up_as_tstrb =  dut.AXIS_SW0.as_up_tstrb;
			force dut.AXIS_SW0.up_as_tkeep =  dut.AXIS_SW0.as_up_tkeep;
			//force dut.AXIS_SW0.up_as_tid =    dut.AXIS_SW0.as_up_tid;
			force dut.AXIS_SW0.up_as_tuser =  dut.AXIS_SW0.as_up_tuser;
			force dut.AXIS_SW0.up_as_tlast =  dut.AXIS_SW0.as_up_tlast;

		
		end
	endtask




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
		input [11:0] offset;		//4K range
		input [3:0] sel;
		input [31:0] data;
		
		begin
			@ (posedge soc_coreclk);		
			wbs_adr <= IS_BASE;			
			wbs_adr[11:2] <= offset[11:2];	//only provide DW address 
			
			wbs_wdata <= data;
			wbs_sel <= sel;
			wbs_cyc <= 1'b1;
			wbs_stb <= 1'b1;
			wbs_we <= 1'b1;	

			@(posedge soc_coreclk);
			while(wbs_ack==0) begin
				@(posedge soc_coreclk);
			end

			$display($time, "=> soc_is_cfg_write : wbs_adr=%x, wbs_sel=%b, wbs_wdata=%x", wbs_adr, wbs_sel, wbs_wdata); 
		end
	endtask

	task soc_is_cfg_read;
		input [11:0] offset;		//4K range
		input [3:0] sel;
		
		begin
			@ (posedge soc_coreclk);		
			wbs_adr <= IS_BASE;			
			wbs_adr[11:2] <= offset[11:2];	//only provide DW address 
			
			wbs_sel <= sel;
			wbs_cyc <= 1'b1;
			wbs_stb <= 1'b1;
			wbs_we <= 1'b0;	

			@(posedge soc_coreclk);
			while(wbs_ack==0) begin
				@(posedge soc_coreclk);
			end

			$display($time, "=> soc_is_cfg_read : wbs_adr=%x, wbs_sel=%b", wbs_adr, wbs_sel); 
			#1;		//add delay to make sure cfg_read_result get the correct data 
		end
	endtask

	task soc_aa_cfg_write;
		input [11:0] offset;		//4K range
		input [3:0] sel;
		input [31:0] data;
		
		begin
			@ (posedge soc_coreclk);		
			wbs_adr <= AA_BASE;
			wbs_adr[11:2] <= offset[11:2];	//only provide DW address 
			
			wbs_wdata <= data;
			wbs_sel <= sel;
			wbs_cyc <= 1'b1;
			wbs_stb <= 1'b1;
			wbs_we <= 1'b1;	
			
			@(posedge soc_coreclk);
			while(wbs_ack==0) begin
				@(posedge soc_coreclk);
			end

			$display($time, "=> soc_aa_cfg_write : wbs_adr=%x, wbs_sel=%b, wbs_wdata=%x", wbs_adr, wbs_sel, wbs_wdata); 
		end
	endtask

	task soc_aa_cfg_read;
		input [11:0] offset;		//4K range
		input [3:0] sel;
		
		begin
			@ (posedge soc_coreclk);		
			wbs_adr <= AA_BASE;
			wbs_adr[11:2] <= offset[11:2];	//only provide DW address 
			
			wbs_sel <= sel;
			wbs_cyc <= 1'b1;
			wbs_stb <= 1'b1;
			wbs_we <= 1'b0;		
			
			@(posedge soc_coreclk);
			while(wbs_ack==0) begin
				@(posedge soc_coreclk);
			end
			$display($time, "=> soc_aa_cfg_read : wbs_adr=%x, wbs_sel=%b", wbs_adr, wbs_sel); 
			#1;		//add delay to make sure cfg_read_result get the correct data 
		end
	endtask

	task soc_up_cfg_read;
		input [11:0] offset;		//4K range
		input [3:0] sel;
		
		begin
			@ (posedge soc_coreclk);		
			wbs_adr <= UP_BASE;
			wbs_adr[11:2] <= offset[11:2];	//only provide DW address 
			
			wbs_sel <= sel;
			wbs_cyc <= 1'b1;
			wbs_stb <= 1'b1;
			wbs_we <= 1'b0;		
			
			@(posedge soc_coreclk);
			while(wbs_ack==0) begin
				@(posedge soc_coreclk);
			end
			
			$display($time, "=> soc_up_cfg_read : wbs_adr=%x, wbs_sel=%b", wbs_adr, wbs_sel); 
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