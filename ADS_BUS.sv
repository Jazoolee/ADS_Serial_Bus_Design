module ADS_BUS(
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
   // output [3:0] arbiter_state,
    // output [3:0] decoder_state,
    // output [3:0] slave1_state
    );

    logic m1_tx, m2_tx;
    logic m1_rx, m2_rx;
    logic s1_tx, s2_tx, s3_tx;
    logic s1_rx, s2_rx, s3_rx;
    logic [1:0] addr;
    logic addr_rdy;
    logic slv_ready, slv_responded;
    logic m1, m2;
    logic m1_mux_sel, m2_mux_sel;
    logic m1_arbiter_data, m2_arbiter_data;
    logic m1_decoder_data, m2_decoder_data;
    
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
      // .state_o(arbiter_state)
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
        .s3_rx(s3_rx),
        .addr(addr),
        .addr_rdy(addr_rdy),
        .m1(m1),
        .m2(m2),        
        .slv_ready(slv_ready),
        .slv_responded(slv_responded),
        .m1_mux_sel(m1_mux_sel),
        .m2_mux_sel(m2_mux_sel)
        // .state_o(decoder_state)
    );

    slave1 slave1(
        .clk(clk),
        .rstn(rstn),
        .rx(s1_rx),
        .tx(s1_tx),
        .busy(s1_busy),
      .wdata(s1_wdata)
        // .state_o(slave1_state)
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