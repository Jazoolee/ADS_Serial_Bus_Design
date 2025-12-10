module Bus(
    input logic clk,
    input logic rstn,

    input logic m1_tx, m2_tx,
    output logic m1_rx, m2_rx,

    input logic s1_tx, s2_tx, s3_tx,
    output logic s1_rx, s2_rx, s3_rx,
    output logic [3:0] state
    );

    logic [1:0] addr;
    logic addr_rdy;
    logic slv_ready, slv_responded;
    logic m1, m2;
    logic m1_mux_sel, m2_mux_sel;
    logic m1_arbiter_data, m2_arbiter_data;
    logic m1_decoder_data, m2_decoder_data;
    
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
        .addr_rdy(addr_rdy),
        .state_o(state)
    );

    read_mux m1_read_mux (
        // .clk(clk),
        // .rstn(rstn),
        .mux_sel(m1_mux_sel),
        .decoder_data(m1_decoder_data),
        .arbiter_data(m1_arbiter_data),
        .master_rx(m1_rx)
    );

    read_mux m2_read_mux (
        // .clk(clk),
        // .rstn(rstn),
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
        // .state_o(state)
    );
endmodule