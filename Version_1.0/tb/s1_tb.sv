`timescale 1ps/1ps
module s1_tb();
    logic clk, rstn;
    logic tx, rx;
    logic busy;

    slave1 slave1(
        .clk(clk),
        .rstn(rstn),
        .tx(tx),
        .rx(rx),
        .busy(busy)
    );

    initial begin
        clk = '0;
        rstn = '1;
        busy = '0;
        rx = '1;
    end

    initial forever #10 clk <= ~clk;

    initial begin
        #20 rstn = '0;
        #1 rstn = '1;
    end

    initial begin
        #30 rx = '0;
        #20 rx = '1;
        repeat (8) #20 rx = ~rx;
    end

    initial begin
        #20 busy = '1;
        #50 busy = '0;
    end
endmodule