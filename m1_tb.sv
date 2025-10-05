`timescale 1ps/1ps
module m1_tb();
    logic clk, rstn;
    logic tx, rx;
    logic data_ready;

    master1 master1(
        .clk(clk),
        .rstn(rstn),
        .tx(tx),
        .rx(rx),
        .data_ready(data_ready)
    );

    initial begin
        clk = '0;
        rstn = '1;
        data_ready = '0;
        rx = '1;
    end

    initial forever #10 clk <= ~clk;

    initial begin
        #20 rstn = '0;
        #1 rstn = '1;
    end

    initial begin
        #40 data_ready = '1;
        #20 data_ready = '0;
    end

    initial begin
        #90 rx = '0;
        #20 rx = '1;
    end

    initial begin
        #410 rx = '0;
        #20 rx = '1;
    end

    initial #100 rx = '0;
endmodule