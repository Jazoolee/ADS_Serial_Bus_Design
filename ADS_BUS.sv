module ADS_BUS(
    input clk,
    input rstn,

    input m1_ready,
    input m2_ready,
    input s1_busy
    );

    logic m1_tx, m1_rx;
    logic m2_tx, m2_rx;

    logic s1_tx, s1_rx;
    logic s2_tx, s2_rx;
    logic s3_tx, s3_rx;

    logic [13:0] addr;
    logic addr_rdy;
    logic m1;
    logic m2;
    logic slv_ready;
    logic slv_responded;

    master1 master1(
        .clk(clk),
        .rstn(rstn),
        .data_ready(m1_ready),
        .tx(m1_tx),
        .rx(m1_rx)
    );

    master2 master2(
        .clk(clk),
        .rstn(rstn),
        .data_ready(m2_ready),
        .tx(m2_tx),
        .rx(m2_rx)
    );

    arbiter arbiter(
        .clk(clk),
        .rstn(rstn),
        .m1_tx(m1_tx),
        .m1_rx(m1_rx),
        .m2_tx(m2_tx),
        .m2_rx(m2_rx),
        .addr(addr),
        .addr_rdy(addr_rdy),
        .m1(m1),
        .m2(m2),
        .slv_ready(slv_ready),
        .slv_responded(slv_responded)
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
        .s3_rx(s3_rx),
        .addr(addr),
        .addr_rdy(addr_rdy),
        .m1(m1),
        .m2(m2),
        .slv_ready(slv_ready),
        .slv_responded(slv_responded)
    );

    slave1 slave1(
        .clk(clk),
        .rstn(rstn),
        .rx(s1_rx),
        .tx(s1_tx),
        .busy(s1_busy)
    );

    slave2 slave2(
        .clk(clk),
        .rstn(rstn),
        .rx(s2_rx),
        .tx(s2_tx)
    );

    slave2 slave3(
        .clk(clk),
        .rstn(rstn),
        .rx(s3_rx),
        .tx(s3_tx)
    );
endmodule