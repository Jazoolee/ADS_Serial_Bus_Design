module address_decoder(
    input logic clk,
    input logic rstn,

    input logic m1_tx,
    input logic m2_tx,

    output logic m1_rx,
    output logic m2_rx,

    input logic s1_tx,
    input logic s2_tx,
    input logic s3_tx,

    output logic s1_rx,
    output logic s2_rx,
    output logic s3_rx,

    input logic [1:0] addr,
    input logic addr_rdy,
    input logic m1,
    input logic m2,
    output logic slv_ready,
    output logic slv_responded,

    output logic m1_mux_sel,
    output logic m2_mux_sel
    );

    logic [13:0] counter;
    logic [1:0] s1_splits; 

    logic s1_queued;
    logic s2_queued;
    logic s3_queued;

    logic [3:0] state;
    localparam IDLE = 4'b0000;
    localparam SLV_REQUESTED = 4'b0001;
    localparam SLV_WAIT = 4'b0010;
    localparam SLV_RESPONDED = 4'b1010;
    localparam SLV_GRANTED = 4'b0011;
    localparam ADDR_TX = 4'b0100;
    localparam ADDR_RX = 4'b0101;
    localparam DATA_TX = 4'b0110;
    localparam WAIT_DATA_RX = 4'b0111;
    localparam DATA_RX = 4'b1000;
    localparam SPLIT = 4'b1001;

    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            state <= IDLE;
            s1_rx <= '1;
            s2_rx <= '1;
            s3_rx <= '1;
            slv_ready <= '0;
            s1_splits <= 2'b00;
            counter <= 0;
            slv_responded <= '0;
            m1_mux_sel <= '0;
            m2_mux_sel <= '0;
            s1_queued <= '0;
            s2_queued <= '0;
            s3_queued <= '0;
        end else begin
            case (state)
                IDLE: begin
                    slv_ready <= '0;
                    slv_responded <= '0;                    
                    if (s1_splits == 2'b11 || s1_splits == 2'b01) s1_rx <= '0;
                    else if (s1_splits == 2'b10) begin
                        if (counter < 1) counter <= counter + 1;
                        else s1_rx <= '0;
                    end
                    if (addr_rdy) begin
                        s1_rx <= '1;
                        state <= SLV_REQUESTED;
                    end
                    else if ((s1_splits == 2'b11 || s1_splits == 2'b01) && !s1_tx) begin
                        slv_ready <= '1;
                        slv_responded <= '1;
                        state <= SLV_GRANTED;
                    end 
                    else if ((s1_splits == 2'b10) && !s1_tx) begin
                        if (counter == 1) begin
                            slv_ready <= '1;
                            slv_responded <= '1;
                            state <= SLV_GRANTED;
                        end
                    end
                end
                SLV_REQUESTED: begin
                    counter <= 0;
                    case (addr)
                        2'b00: s1_rx <= '0;
                        2'b01: s2_rx <= '0;
                        2'b10: s3_rx <= '0;
                    endcase
                    state <= SLV_WAIT;
                end
                SLV_WAIT: begin
                    if (counter < 1) counter <= counter + 1;
                    else begin
                        counter <= '0;
                        state <= SLV_RESPONDED;
                    end
                end
                SLV_RESPONDED: begin
                    if (!s1_tx || !s2_tx || !s3_tx) begin
                        slv_ready <= '1;
                        slv_responded <= '1;
                        s1_rx <= '1;
                        s2_rx <= '1;
                        s3_rx <= '1;
                        state <= SLV_GRANTED;
                    end else if ((!s1_rx && s2_rx && s3_rx) && s1_tx) begin
                        slv_ready <= '0;
                        slv_responded <= '1;
                        state <= SPLIT;
                    end
                end
                SLV_GRANTED: begin
                    counter <= 0;
                    slv_ready <= '0;
                    slv_responded <= '0;
                    state <= ADDR_TX;
                end
                ADDR_TX: state <= ADDR_RX;
                ADDR_RX: begin
                    if (!s1_tx) s1_rx <= m1? m1_tx : m2_tx;
                    if (!s2_tx) s2_rx <= m1? m1_tx : m2_tx;     
                    if (!s3_tx) s3_rx <= m1? m1_tx : m2_tx;                

                    if (counter == 12) begin
                        counter <= 0;
                        if ((m1 && m1_tx) || (m2 && m2_tx)) state <= DATA_TX;
                        else if ((m1 && !m1_tx) || (m2 && !m2_tx)) begin
                            if (!s1_tx) s1_queued <= '1;
                            if (!s2_tx) s2_queued <= '1;
                            if (!s3_tx) s3_queued <= '1;
                            state <= WAIT_DATA_RX;   
                        end                      
                    end else counter <= counter + 1;                 
                end
                DATA_TX: begin
                    if (counter <= 7) begin
                        if (!s1_tx) begin
                            s1_rx <= m1? m1_tx : m2_tx;
                            if (counter == 7) begin
                                if (s1_splits == 2'b01 || s1_splits == 2'b10) s1_splits <= 2'b00;
                                else if (s1_splits == 2'b11) s1_splits[0] <= '0;
                            end
                        end
                        if (!s2_tx) s2_rx <= m1? m1_tx : m2_tx;
                        if (!s3_tx) s3_rx <= m1? m1_tx : m2_tx;
                        counter <= counter + 1;
                    end else begin
                        counter <= 0;
                        state <= IDLE;
                    end
                end
                WAIT_DATA_RX: begin
                    s1_rx <= '1;
                    s2_rx <= '1;
                    s3_rx <= '1;
                    if (counter < 1) counter <= counter + 1;
                    else begin
                        counter <= '0;
                        state <= DATA_RX;
                    end
                end
                DATA_RX: begin
                    if (counter <= 7)begin                        
                        if (m1) begin 
                            m1_rx <= s1_queued ? s1_tx : (s2_queued ? s2_tx : s3_tx);
                            m1_mux_sel <= '1;
                        end
                        if (m2) begin
                            m2_rx <= s1_queued ? s1_tx : (s2_queued ? s2_tx : s3_tx);
                            m2_mux_sel <= '1;
                        end
                        counter <= counter + 1;
                    end else begin
                        m1_mux_sel <= '0;
                        m2_mux_sel <= '0;
                        counter <= 0;
                        if (s1_queued) begin
                            s1_queued <= '0;
                            if (s1_splits == 2'b01 || s1_splits == 2'b10) s1_splits <= 2'b00;
                            else if (s1_splits == 2'b11) s1_splits[0] <= '0;
                        end
                        if (s2_queued) s2_queued <= '0;
                        if (s3_queued) s3_queued <= '0;
                        state <= IDLE;
                    end
                end
                SPLIT: begin
                    counter <= 0;
                    if (s1_splits == 2'b00) s1_splits[0] <= '1;
                    else if (s1_splits == 2'b01) s1_splits[1] <= '1;
                    slv_ready <= '0;
                    slv_responded <= '0;
                    state <= IDLE;
                end
                default: state <= IDLE;
            endcase
        end
    end

endmodule