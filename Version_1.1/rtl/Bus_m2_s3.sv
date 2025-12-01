module Bus_m2_s3(
    input clk,
    input rstn,

    input m1_ready,
    input m2_ready,
    input m1_rw,
    input m2_rw,
    input s1_busy,
    output [7:0] s1_wdata,
    output [7:0] s2_wdata,
    output [7:0] s3_wdata,
    output [7:0] m1_rdata,
    output [7:0] m2_rdata
    );

    logic m1_tx, m2_tx;
    logic m1_rx, m2_rx;
    logic s1_tx, s2_tx, s3_tx;
    logic s1_rx, s2_rx, s3_rx;
    
    master1 master1(
        .clk(clk),
        .rstn(rstn),
        .tx(m1_tx),
        .rx(m1_rx),
        .data_ready(m1_ready),
        .rw(m1_rw),
        .rdata(m1_rdata)
    );

    master2 master2(
        .clk(clk),
        .rstn(rstn),
        .tx(m2_tx),
        .rx(m2_rx),
        .data_ready(m2_ready),
        .rw(m2_rw),
        .rdata(m2_rdata)
    );

    Bus Bus(
        .clk(clk),
        .rstn(rstn),
        .m1_tx(m1_tx),
        .m2_tx(m2_tx),
        .m1_rx(m1_rx),
        .m2_rx(m2_rx),
        .s1_tx(s1_tx),
        .s2_tx(s2_tx),
        .s3_tx(s3_tx),
        .s1_rx(s1_rx),
        .s2_rx(s2_rx),
        .s3_rx(s3_rx)
    );

    slave1 slave1(
        .clk(clk),
        .rstn(rstn),
        .rx(s1_rx),
        .tx(s1_tx),
        .busy(s1_busy),
      .wdata(s1_wdata)
    );

    slave2 slave2(
        .clk(clk),
        .rstn(rstn),
        .rx(s2_rx),
        .tx(s2_tx),
        .wdata(s2_wdata)
    );

    slave2 slave3(
        .clk(clk),
        .rstn(rstn),
        .rx(s3_rx),
        .tx(s3_tx),
        .wdata(s3_wdata)
    );
endmodule