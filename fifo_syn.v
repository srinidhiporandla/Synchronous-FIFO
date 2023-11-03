module fifo(clk_i,rst_i,wdata_i,rdata_o,full_o,empty_o,wr_en_i,rd_en_i,underflow_o,overflow_o);
parameter DEPTH=16;
parameter WIDTH=8;
parameter PTR_WIDTH=$clog2(DEPTH);
input clk_i,rst_i,wr_en_i,rd_en_i;
input [WIDTH-1:0]wdata_i;
output reg full_o,empty_o,underflow_o,overflow_o;
output reg [WIDTH-1:0]rdata_o;
reg wr_toggle_f,rd_toggle_f;
reg [PTR_WIDTH-1:0]wr_ptr,rd_ptr;
reg [WIDTH-1:0]mem[DEPTH-1:0];
integer i;

always@(posedge clk_i)begin
	if(rst_i)begin
		full_o=0;
		empty_o=0;
		rdata_o=0;
		overflow_o=0;
		underflow_o=0;
		wr_toggle_f=0;
		rd_toggle_f=0;
		wr_ptr=0;
		rd_ptr=0;
		for(i=0;i<DEPTH;i=i+1) 
			mem[i]=0;
	end
	else begin
		overflow_o=0;
		underflow_o=0;

		if(wr_en_i)begin
			if(full_o) overflow_o=1;
			else begin
				mem[wr_ptr] = wdata_i;
				if(wr_ptr == DEPTH-1)
					wr_toggle_f = ~wr_toggle_f;
				wr_ptr = wr_ptr + 1;
			end
		end
		if(rd_en_i)begin
			if(empty_o) underflow_o=1;
			else begin
					rdata_o = mem[rd_ptr];
					if(rd_ptr == DEPTH-1) rd_toggle_f=~rd_toggle_f;
					rd_ptr = rd_ptr+1;
			end
		end
	end
end
always@(*)begin
	empty_o=0;
	full_o=0;
	if((wr_ptr==rd_ptr)&&(wr_toggle_f!=rd_toggle_f)) 
		full_o=1;
	if((wr_ptr==rd_ptr)&&(wr_toggle_f==rd_toggle_f)) 
		empty_o=1;
end
endmodule
