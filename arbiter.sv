module arbiter(
    input logic clk,
    input logic rstn,

    input logic m1_tx,
    output logic m1_rx,

    input logic m2_tx,
    output logic m2_rx,

    output logic [13:0] addr,
    output logic addr_rdy,
    output logic m1,
    output logic m2,
    input logic slv_ready
	 );

    logic m1_queued;
    logic m2_queued;
    logic m1_splitted;
    logic m2_splitted;
    logic [13:0] counter; 
    logic m_rx;
    
    logic [2:0] state;
    localparam IDLE = 3'b000;
    localparam BUS_REQUESTED = 3'b001;
    localparam SPLIT = 3'b010;
    localparam ADDR_TX = 3'b011;
    localparam SLV_WAIT = 3'b100;
    localparam DATA_TX = 3'b101;

    assign m1 = (m1_queued && !m1_splitted);
    assign m2 = (m2_queued && !m2_splitted);

    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            state <= IDLE;
            m1_rx <= '1;
            m2_rx <= '1;
            counter <= '0;
            m1_queued <= '0;
            m2_queued <= '0;
            m1_splitted <= '0;
            m2_splitted <= '0;
        end else begin
            case (state)
                IDLE: begin
                    m1_rx <= '1;
                    m2_rx <= '1;
                    counter <= '0;
                    m1_queued <= '0;
                    m2_queued <= '0;
                    m1_splitted <= '0;
                    m2_splitted <= '0;
                    if (!m1_tx || !m2_tx) state <= BUS_REQUESTED;
                end
                BUS_REQUESTED: begin
                    if ((!m1_tx && !m1_splitted) && (!m2_tx && !m2_splitted)) begin
                        m1_queued <= '1;
                        m2_queued <= '0;
                    end else if ((!m1_tx && m1_splitted) && (!m2_tx && !m2_splitted)) begin
                        m1_queued <= '0;
                        m2_queued <= '1;
                    end else if ((!m1_tx && !m1_splitted) && (!m2_tx && m2_splitted)) begin
                        m1_queued <= '1;
                        m2_queued <= '0;
                    end else if (!m1_tx) begin
                        m1_queued <= '1;
                        m2_queued <= '0;
                    end else if (!m2_tx) begin
                        m1_queued <= '0;
                        m2_queued <= '1;
                    end

                    if (m1_queued && !m1_splitted) m1_rx <= '0;
                    if (m2_queued && !m2_splitted) m2_rx <= '0;
                    state <= ADDR_TX;
                end
                ADDR_TX: begin
                    if (counter <= 13) begin
                        if (m1_queued && !m1_splitted) begin
                            addr[counter] <= m1_tx;
                            m1_rx <= '1;
                        end
                        if (m2_queued && !m2_splitted) begin
                            addr[counter] <= m2_tx;
                            m2_rx <= '1;
                        end
                        counter <= counter + 1;
                    end else begin
                        addr_rdy <= '1;
                        state <= SLV_WAIT;
                        counter <= 0;
                    end
                end
                SLV_WAIT: begin
                    if (slv_ready) begin
                        if (m1_queued && !m1_splitted) m1_rx <= '0;
                        if (m2_queued && !m2_splitted) m2_rx <= '0;
                        state <= DATA_TX; 
                    end else begin
                        if ((m1_queued && !m2_tx) || (m2_queued && !m1_tx)) state <= SPLIT;
                    end
                end
                DATA_TX: begin
                    if (counter <= 7) begin
                        counter <= counter + 1;
                    end else begin
                        counter <= 0;
                        if (m1_splitted) begin
                            m1_queued <= '1;
                            m1_splitted <= '0;
                            m2_queued <= '0;
                            state <= SLV_WAIT;
                        end else if (m2_splitted) begin
                            m1_queued <= '0;
                            m2_queued <= '1;
                            m2_splitted <= '0;
                            state <= SLV_WAIT;
                        end else state <= IDLE;
                    end
                end
                SPLIT: begin
                    if (m1_queued && !m2_tx) m1_splitted <= '1; 
                    if (m2_queued && !m1_tx) m2_splitted <= '1;
                    state <= BUS_REQUESTED; 
                end
            endcase
        end
    end
endmodule