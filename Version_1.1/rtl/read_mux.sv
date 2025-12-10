module read_mux(
    // input logic clk,
    // input logic rstn,
    input logic mux_sel,
    input logic decoder_data,
    input logic arbiter_data,
    output logic master_rx
    );

    // always @(posedge clk or negedge rstn) begin
    //     if (!rstn) begin
    //         master_rx <= arbiter_data;
    //     end else begin
    //         if (mux_sel) master_rx <= decoder_data;
    //         else master_rx <= arbiter_data;
    //     end
    // end
    assign master_rx = mux_sel ? decoder_data : arbiter_data;
endmodule