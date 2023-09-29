// This code snippet was auto generated by xls2vlog.py from source file: ./user_project_wrapper.xlsx
// User: josh
// Date: Sep-22-23



module USER_PRJ0 #( parameter pUSER_PROJECT_SIDEBAND_WIDTH   = 5,
					parameter pADDR_WIDTH   = 12,
                   parameter pDATA_WIDTH   = 32
                 )
(
  output wire                        awready,
  output wire                        arready,
  output wire                        wready,
  output wire                        rvalid,
  output wire  [(pDATA_WIDTH-1) : 0] rdata,
  input  wire                        awvalid,
  input  wire                [11: 0] awaddr,
  input  wire                        arvalid,
  input  wire                [11: 0] araddr,
  input  wire                        wvalid,
  input  wire                 [3: 0] wstrb,
  input  wire  [(pDATA_WIDTH-1) : 0] wdata,
  input  wire                        rready,
  input  wire                        ss_tvalid,
  input  wire  [(pDATA_WIDTH-1) : 0] ss_tdata,
  input  wire                 [1: 0] ss_tuser,
  `if USER_PROJECT_SIDEBAND_SUPPORT != 0
	input  wire                 [pUSER_PROJECT_SIDEBAND_WIDTH-1: 0] ss_tupsb,
  `endif
  input  wire                 [3: 0] ss_tstrb,
  input  wire                 [3: 0] ss_tkeep,
  input  wire                        ss_tlast,
  input  wire                        sm_tready,
  output wire                        ss_tready,
  output wire                        sm_tvalid,
  output wire  [(pDATA_WIDTH-1) : 0] sm_tdata,
  output wire                 [2: 0] sm_tid,
  `if USER_PROJECT_SIDEBAND_SUPPORT != 0
	output  wire                 [pUSER_PROJECT_SIDEBAND_WIDTH-1: 0] sm_tupsb,
  `endif
  output wire                 [3: 0] sm_tstrb,
  output wire                        sm_tkeep,
  output wire                        sm_tlast,
  output wire                        low__pri_irq,
  output wire                        High_pri_req,
  output wire                [23: 0] la_data_o,
  input  wire                        axi_clk,
  input  wire                        axis_clk,
  input  wire                        axi_reset_n,
  input  wire                        axis_rst_n,
  input  wire                        user_clock2,
  input  wire                        uck2_rst_n
);

`if USER_PROJECT_SIDEBAND_SUPPORT != 0
	localparam	FIFO_WIDTH = pUSER_PROJECT_SIDEBAND_WIDTH + 4 + 1 + 1 + pDATA_WIDTH;		//upsb, tid, tstrb, tkeep, tlast, tdata
`else
	localparam	FIFO_WIDTH = 4 + 1 + 1 + pDATA_WIDTH;		//tid, tstrb, tkeep, tlast, tdata
`endif


wire awvalid_in;
wire wvalid_in;

reg [31:0] RegisterData;

//write addr channel
assign 	awvalid_in	= awvalid; 
wire awready_out;
assign awready = awready_out;

//write data channel
assign 	wvalid_in	= wvalid;
wire wready_out;
assign wready = wready_out;

// if both awvalid_in=1 and wvalid_in=1 then output awready_out = 1 and wready_out = 1
assign awready_out = (awvalid_in && wvalid_in) ? 1 : 0;
assign wready_out = (awvalid_in && wvalid_in) ? 1 : 0;

assign arready = 1;

assign rvalid = 1;
assign rdata =  RegisterData;

//write register
always @(posedge axi_clk or negedge axi_reset_n)  begin
  if ( !axi_reset_n ) begin
    RegisterData <= 32'haa55aa55;
  end
  else begin
    if ( awvalid_in && wvalid_in ) begin		//when awvalid_in=1 and wvalid_in=1 means awready_out=1 and wready_out=1
      if (awaddr[11:2] == 10'h000 ) begin //offset 0
        if ( wstrb[0] == 1) RegisterData[7:0] <= wdata[7:0];
        if ( wstrb[1] == 1) RegisterData[15:8] <= wdata[15:8];
        if ( wstrb[2] == 1) RegisterData[23:16] <= wdata[23:16];
        if ( wstrb[3] == 1) RegisterData[31:24] <= wdata[31:24];  
      end
      else begin
        RegisterData <= RegisterData;
      end
    end
  end
end

reg [2:0] r_ptr;
reg [2:0] w_ptr;
reg [(FIFO_WIDTH-1) : 0] fifo[7:0];

wire full;
wire empty;

assign empty = (r_ptr == w_ptr);
assign full = (r_ptr == (w_ptr+1) );

assign ss_tready = !full;

//for push to fifo
always @(posedge axis_clk or negedge axis_rst_n)  begin
  if ( !axis_rst_n ) begin
    w_ptr <= 0;
  end
  else begin
	if ( ss_tready && ss_tvalid) begin
		fifo[w_ptr] <= {ss_tstrb, ss_tkeep, ss_tlast, ss_tdata}; 
		`if USER_PROJECT_SIDEBAND_SUPPORT != 0
			fifo[w_ptr] <= {ss_tupsb, ss_tstrb, ss_tkeep, ss_tlast, ss_tdata}; 
		`else
			fifo[w_ptr] <= {ss_tstrb, ss_tkeep, ss_tlast, ss_tdata}; 
		`endif
		w_ptr <= w_ptr + 1;
	end
  end
end  

//for pop from fifo

`if USER_PROJECT_SIDEBAND_SUPPORT != 0
	assign {sm_tupsb, sm_tstrb, sm_tkeep, sm_tlast, sm_tdata} = fifo[r_ptr];
`else
	assign {sm_tstrb, sm_tkeep, sm_tlast, sm_tdata} = fifo[r_ptr];
`endif

assign sm_tvalid = !empty;
always @(posedge axis_clk or negedge axis_rst_n)  begin
  if ( !axis_rst_n ) begin
    r_ptr <= 0;
  end
  else begin
	if ( sm_tready && sm_tvalid) begin
		r_ptr <= r_ptr + 1;
	end
  end
end  

assign sm_tid = 3'b000;		//[TODO] remove tid in user project.
assign low__pri_irq  = 1'b0;
assign High_pri_req  = 1'b0;
assign la_data_o     = 24'b0;


endmodule // USER_PRJ0


