module read_mux(
    input logic mux_sel,
    input logic decoder_data,
    input logic arbiter_data,
    output logic master_rx
    );

    assign master_rx = mux_sel ? decoder_data : arbiter_data;
endmodule