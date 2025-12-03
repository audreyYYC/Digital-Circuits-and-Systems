module INF(
	// input signal
	clk,
	rst_n,
	in_valid,
	in_mode,
	in_addr,
	in_data,
	// input axi 
	ar_ready,
	r_data,
	r_valid,
	aw_ready,
	w_ready,
	// output signals
	out_valid,
	out_data,
	// output axi
	ar_addr,
	ar_valid,
	r_ready,
	aw_addr,
	aw_valid,
	w_data,
	w_valid
);
//---------------------------------------------------------------------
//   PORT DECLARATION
//---------------------------------------------------------------------
input clk, rst_n, in_valid, in_mode;
input [3:0] in_addr;
input [7:0] in_data, r_data; 
input ar_ready, r_valid, aw_ready, w_ready;
output logic out_valid;
output logic [7:0] out_data, w_data;
output logic [3:0] ar_addr, aw_addr;
output logic ar_valid, r_ready, aw_valid, w_valid;

//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------
typedef enum logic [2:0] { 
    S_IDLE, S_AR, S_R, S_AW, S_W, S_OUTPUT
} state_t;
state_t state;
logic [1:0] counter;
logic [3:0] addr;
logic [0:3][7:0] data;

//---------------------------------------------------------------------
//   YOUR DESIGN
//---------------------------------------------------------------------
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
		out_valid <= 0;
		out_data <= 0;
		ar_addr <= 0;
        ar_valid <= 0;
        r_ready <= 0;
        aw_addr <= 0;
        aw_valid <= 0;
        w_data <= 0;
        w_valid <= 0;

        state <= S_IDLE;
		counter <= 0;
        data <= 0;
        addr <= 0;
	end
    else begin
        case (state)
        S_IDLE: begin
            if (in_valid) begin
                case (counter)
                0: begin
                    addr <= in_addr;
                    counter <= 1;
                    if(in_mode)
                        data[0] <= in_data;
                end
                1: begin
                    counter <= 2;
                    if(in_mode)
                        data[1] <= in_data;
                end
                2: begin
                    counter <= 3;
                    if(in_mode)
                        data[2] <= in_data;
                end
                3: begin
                    counter <= 0;
                    if(in_mode) begin
                        data[3] <= in_data;
                        state <= S_AW;
                        aw_addr <= addr;
                        aw_valid <= 1;
                    end
                    else begin
                        state <= S_AR;
                        ar_addr <= addr;
                        ar_valid <= 1;
                    end
                end
                endcase
            end
        end

        S_AR: begin
            if (ar_ready) begin
                state <= S_R;
                ar_valid <= 0;
                ar_addr <= 0;
                r_ready <= 1;
            end
        end

        S_R: begin
            if(r_valid) begin
                counter <= counter + 1;
                case (counter)
                0: data[0] <= r_data;
                1: data[1] <= r_data;
                2: data[2] <= r_data;
                3: begin
                    data[3] <= r_data;
                    r_ready <= 0;
                    out_valid <= 1;
                    out_data <= data[0];
                    data[0] <= 0;
                    state <= S_OUTPUT;
                end
                endcase
            end
        end

        S_AW: begin
            if (aw_ready) begin
                state <= S_W;
                aw_valid <= 0;
                aw_addr <= 0;
                w_valid <= 1;
                w_data <= data[0];
            end
        end

        S_W: begin
            if (w_ready) begin
                counter <= counter + 1;
                case (counter)
                0: begin
                    w_data <= data[1];
                    data[0] <= 0;
                    data[1] <= 0;
                end
                1: begin
                    w_data <= data[2];
                    data[2] <= 0;
                end
                2: begin
                    w_data <= data[3];
                    data[3] <= 0;
                end
                3: begin
                    w_data <= 0;
                    w_valid <= 0;
                    state <= S_OUTPUT;
                    out_valid <= 1;
                end
                endcase
            end
        end

        S_OUTPUT: begin
            counter <= counter + 1;
            case (counter)
            0: begin
                out_valid <= 1;
                out_data <= data[1];
                data[1] <= 0;
            end
            1: begin
                out_valid <= 1;
                out_data <= data[2];
                data[2] <= 0;
            end
            2: begin
                out_valid <= 1;
                out_data <= data[3];
                data[3] <= 0;
            end
            3: begin
                out_valid <= 0;
                out_data <= 0;
                state <= S_IDLE;
            end
            endcase
        end

        endcase
    end
end

endmodule
