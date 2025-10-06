`timescale 1ps/1ps
module arbiter_tb1();
    logic clk, rstn;
    logic m1_tx, m2_tx;
    logic m1_rx, m2_rx;
    logic s1_tx, s2_tx, s3_tx;
    logic s1_rx, s2_rx;
    logic m1_data_ready, m2_data_ready;
    logic [13:0] addr;
    logic addr_rdy;
    logic m1, m2;
    logic busy;
    
    master1 master1(
        .clk(clk),
        .rstn(rstn),
        .tx(m1_tx),
        .rx(m1_rx),
        .data_ready(m1_data_ready)
    );

    master2 master2(
        .clk(clk),
        .rstn(rstn),
        .tx(m2_tx),
        .rx(m2_rx),
        .data_ready(m2_data_ready)
    );
    
    arbiter arbiter(
        .clk(clk),
        .rstn(rstn),
        .m1_tx(m1_tx),
        .m1_rx(m1_rx),
        .m2_tx(m2_tx),
        .m2_rx(m2_rx),
        .slv_ready(slv_ready),
        .m1(m1),
        .m2(m2),
        .addr(addr),
        .addr_rdy(addr_rdy)
    );

    address_decoder address_decoder(
        .clk(clk),
        .rstn(rstn),
        .m1_tx(m1_tx),
        .m2_tx(m2_tx),
        .s1_tx(s1_tx),
        .s1_rx(s1_rx),
        .s2_tx(s2_tx),
        .s2_rx(s2_rx),
        .s3_tx(s3_tx),
        .m1(m1),
        .m2(m2),
        .addr(addr),
        .addr_rdy(addr_rdy),
        .slv_ready(slv_ready)
    );

    slave1 slave1(
        .clk(clk),
        .rstn(rstn),
        .rx(s1_rx),
        .tx(s1_tx),
        .busy(busy)
    );

    slave2 slave2(
        .clk(clk),
        .rstn(rstn),
        .rx(s2_rx),
        .tx(s2_tx)
    );

    initial begin
        clk = '0;
        rstn = '1;
        s3_tx = '1;
        m1_data_ready = '0;
        m2_data_ready = '0;
        busy = '1;
    end

    initial forever #10 clk <= ~clk;

    initial begin
        #20 rstn = '0;
        #1 rstn = '1;
    end

    initial begin
        #50 m1_data_ready = '1;
        #20 m1_data_ready = '0;
    end

    initial begin
        #590 busy = '0;
    end

    initial begin
        #800 m2_data_ready = '1;
        #20 m2_data_ready = '0;
    end
endmodule