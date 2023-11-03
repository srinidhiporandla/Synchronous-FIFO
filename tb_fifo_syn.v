`include "fifo_syn.v"
module tb;
parameter DEPTH=16;
parameter WIDTH=8;
parameter PTR_WIDTH=$clog2(DEPTH);
reg clk_i,rst_i,wr_en_i,rd_en_i;
reg [WIDTH-1:0]wdata_i;
wire full_o,empty_o,underflow_o,overflow_o;
wire [WIDTH-1:0]rdata_o;
reg [26*8-1:0]testcase;
integer i,j,k,wr_dly,rd_dly;
fifo #(.DEPTH(DEPTH),.WIDTH(WIDTH),.PTR_WIDTH(PTR_WIDTH)) dut(clk_i,rst_i,wdata_i,rdata_o,full_o,empty_o,wr_en_i,rd_en_i,underflow_o,overflow_o);
initial begin
	clk_i=0;
	forever #5 clk_i=~clk_i;
end
initial begin
	$value$plusargs("testcase=%s",testcase);
	reset_fifo();
	case(testcase)
		"test_full": begin
			write_fifo(DEPTH);
		end
		"test_empty":begin
			write_fifo(DEPTH);
			read_fifo(DEPTH);
		end
		"test_full_error":begin
			write_fifo(DEPTH+5);
		end
		"test_empty_error":begin
			write_fifo(DEPTH);
			read_fifo(DEPTH+4);
		end
		"test_concurrent_write_read":begin
			fork
				for(j=0;j<DEPTH;j=j+1)begin
					write_fifo(1);
					wr_dly=($urandom_range(1,10));
					repeat(wr_dly)@(posedge clk_i);
				end
				for(k=0;k<DEPTH;k=k+1)begin
					read_fifo(1);
					rd_dly=($urandom_range(1,10));
					repeat(rd_dly)@(posedge clk_i);
				end	
			join
		end
	endcase
	#100;
	$finish;
end
task reset_fifo();
begin
	rst_i=1;
	wr_en_i=0;
	rd_en_i=0;
	@(posedge clk_i);
	rst_i=0;	
end
endtask
task write_fifo(input integer num_writes);
integer i;
begin
	for(i=0;i<num_writes;i=i+1)begin
		@(posedge clk_i);
		wr_en_i=1;
		wdata_i=$random;
	end
	@(posedge clk_i);
	wr_en_i=0;
end
endtask
task read_fifo(input integer num_reads);
integer i;
begin
	for(i=0;i< num_reads;i=i+1)begin
	 	@(posedge clk_i);
		rd_en_i=1;
	end
	@(posedge clk_i);
	rd_en_i=0;
end
endtask

endmodule

