module Bus_m2_s3_fpga_tb(
    input logic clk, rstn,
    input logic [1:0] trigger,
    output wire [7:0] led
);
    // logic clk,rstn,trigger;
	logic m1_ready, m2_ready;
	logic m1_rw, m2_rw, s1_busy;
	logic [7:0] s1_wdata, s2_wdata, s3_wdata;
    logic [7:0] m1_rdata, m2_rdata;
    logic [3:0] slave1_state;
    logic [1:0]state;
	 
	Bus_m2_s3 Bus_m2_s3(.*);
	
	assign led = s1_wdata;
    // assign led = slave1_state;
	
	initial begin
        m1_ready = '0;
        m2_ready = '0;
        s1_busy = '1;
        m1_rw = '1;
        m2_rw = '0;
        state = 2'b00;
        // trigger = '1;
        // clk = '0;
    end

    // initial forever #10 clk <= ~clk;

    // initial begin
    //     #20 rstn = '0;
    //     #1 rstn = '1;
    // end

    // initial begin
    //     #100 trigger = '0;
    //     #20 trigger = '1;
    // end

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            state <= 2'b00;
            s1_busy = '1;
            m2_ready <= '0;
        end else begin
            case (state)
            2'b00: begin
                if (trigger[0]) begin
                    m1_ready <= '1;
                    state <= 2'b01;
                end
            end
            2'b01: begin
                m1_ready <= '0;
                state <= 2'b10;
            end
            2'b10: begin
                m2_ready <= '1;
                state <= 2'b11;
            end
            2'b11: begin
                m2_ready <= '0;
                if (trigger[1]) s1_busy = '0;
            end
            endcase
        end
    end

endmodule