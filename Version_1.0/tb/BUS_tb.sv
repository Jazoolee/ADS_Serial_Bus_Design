`timescale 1ns/1ns
module BUS_tb();
	logic clk, rstn, m1_ready, m2_ready;
	logic m1_rw, m2_rw, s1_busy;
	logic [7:0] s1_wdata, s2_wdata, s3_wdata;
    logic [7:0] m1_rdata, m2_rdata;
	logic [3:0] arbiter_state;
    logic [3:0] decoder_state;
    logic [3:0] slave1_state;

	 
	ADS_BUS bus(.*);
	
	initial begin
        clk = '0;
        rstn = '1;
        m1_ready = '0;
        m2_ready = '0;
        s1_busy = '1;
        m1_rw = '1;
        m2_rw = '0;
    end

    initial forever #10 clk <= ~clk;

    initial begin
        #20 rstn = '0;
        #1 rstn = '1;
    end

    initial begin
        #50 m1_ready = '1;
        #20 m1_ready = '0;
    end

    initial begin
        #800 s1_busy = '0; // slave1_split scenario
    end

    initial begin
        #280 m2_ready = '1;
        #20 m2_ready = '0;
    end
	 
	 initial begin
		$monitor(s1_wdata, $time);
	 end
endmodule