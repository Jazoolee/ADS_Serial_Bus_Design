`timescale 1ps/1ps
module arbiter_tb1();
    logic clk, rstn;
    logic m1_tx, m2_tx;
    logic m1_rx, m2_rx;
    logic s1_tx, s2_tx, s3_tx;
    logic s1_rx, s2_rx;
    logic m1_data_ready, m2_data_ready;
    logic [1:0] addr;
    logic addr_rdy;
    logic slv_ready, slv_responded;
    logic m1, m2;
    logic busy;
    logic m1_rw, m2_rw;
    logic m1_mux_sel, m2_mux_sel;
    logic m1_arbiter_data, m2_arbiter_data;
    logic m1_decoder_data, m2_decoder_data;
    
    master1 master1(
        .clk(clk),
        .rstn(rstn),
        .tx(m1_tx),
        .rx(m1_rx),
        .data_ready(m1_data_ready),
        .rw(m1_rw)
    );

    master2 master2(
        .clk(clk),
        .rstn(rstn),
        .tx(m2_tx),
        .rx(m2_rx),
        .data_ready(m2_data_ready),
        .rw(m2_rw)
    );
    
    arbiter arbiter(
        .clk(clk),
        .rstn(rstn),
        .m1_tx(m1_tx),
        .m1_rx(m1_arbiter_data),
        .m2_tx(m2_tx),
        .m2_rx(m2_arbiter_data),
        .slv_ready(slv_ready),
        .slv_responded(slv_responded),
        .m1(m1),
        .m2(m2),
        .addr(addr),
        .addr_rdy(addr_rdy)
    );

    read_mux m1_read_mux (
        .mux_sel(m1_mux_sel),
        .decoder_data(m1_decoder_data),
        .arbiter_data(m1_arbiter_data),
        .master_rx(m1_rx)
    );

    read_mux m2_read_mux (
        .mux_sel(m2_mux_sel),
        .decoder_data(m2_decoder_data),
        .arbiter_data(m2_arbiter_data),
        .master_rx(m2_rx)
    );

    address_decoder address_decoder(
        .clk(clk),
        .rstn(rstn),
        .m1_tx(m1_tx),
        .m2_tx(m2_tx),
        .m1_rx(m1_decoder_data),
        .m2_rx(m2_decoder_data),
        .s1_tx(s1_tx),
        .s2_tx(s2_tx),
        .s3_tx(s3_tx),
        .s1_rx(s1_rx),        
        .s2_rx(s2_rx),
        .addr(addr),
        .addr_rdy(addr_rdy),
        .m1(m1),
        .m2(m2),        
        .slv_ready(slv_ready),
        .slv_responded(slv_responded),
        .m1_mux_sel(m1_mux_sel),
        .m2_mux_sel(m2_mux_sel)
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
        m1_rw = '1;
        m2_rw = '0;
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
        #3000 busy = '0; // slave1_split scenario
    end

    initial begin
        #90 m2_data_ready = '1; // slave1_split scenario
        #20 m2_data_ready = '0;

        // #590 m2_data_ready = '1;
        // #20 m2_data_ready = '0;
    end
endmodule