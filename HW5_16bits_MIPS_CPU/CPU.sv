module CPU(
    //INPUT
    clk,
    rst_n,
    in_valid,
    instruction,

    //OUTPUT
    out_valid,
    instruction_fail,
    out_0,
    out_1,
    out_2,
    out_3,
    out_4,
    out_5
);
// INPUT
input clk;
input rst_n;
input in_valid;
input [31:0] instruction;

// OUTPUT
output logic out_valid, instruction_fail;
output logic [15:0] out_0, out_1, out_2, out_3, out_4, out_5;

//================================================================
// DESIGN
//================================================================
typedef enum logic [2:0] { 
    ADD, MULT, LS, RS, RELU, LRELU, ADDI, IDLE
} op_t;
op_t op;
logic [2:0] des_1, des_2, des_3;
logic [5:0] shamt;
logic signed [15:0] rs, rt;
logic [15:0] imm, ans, out;
logic signed [15:0][10:0] out_m;
logic  flag, shift, shift_2;


//IF & DECODE
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        op <= IDLE;
        imm <= 0;
        des_1 <= 6;
        shamt <= 0;
    end
    else if(in_valid) begin
        if(instruction[31:26] == 6'b001000) begin
            op <= ADDI;
            imm <= instruction[15:0];
            case (instruction[25:21]) //rs
                5'b10001: rs <= out_0;
                5'b10010: rs <= out_1;
                5'b01000: rs <= out_2;
                5'b10111: rs <= out_3;
                5'b11111: rs <= out_4;
                5'b10000: rs <= out_5;
            endcase
            case (instruction[20:16]) //rt
                5'b10001: des_1 <= 0;
                5'b10010: des_1 <= 1;
                5'b01000: des_1 <= 2;
                5'b10111: des_1 <= 3;
                5'b11111: des_1 <= 4;
                5'b10000: des_1 <= 5;
            endcase
        end
        else if(instruction[31:26] == 6'b0) begin
            case (instruction[5:0]) //funct
                6'b100000: begin
                    op <= ADD;
                    flag <= 0;
                end
                6'b011000: begin
                    op <= MULT;
                    flag <= 0;
                end
                6'b000000: begin
                    op <= LS;
                    flag <= 0;
                end
                6'b000010: begin
                    op <= RS;
                    flag <= 0;
                end
                6'b110001: begin
                    op <= RELU;
                    flag <= 0;
                end
                6'b110010: begin
                    op <= LRELU;
                    flag <= 0;
                end
                default: begin
                    op <= IDLE;
                    des_1 <= 7;
                    flag <= 1;
                end
            endcase
            case (instruction[25:21]) //rs
                5'b10001: rs <= out_0;
                5'b10010: rs <= out_1;
                5'b01000: rs <= out_2;
                5'b10111: rs <= out_3;
                5'b11111: rs <= out_4;
                5'b10000: rs <= out_5;
            endcase
            case (instruction[20:16]) //rt
                5'b10001: rt <= out_0;
                5'b10010: rt <= out_1;
                5'b01000: rt <= out_2;
                5'b10111: rt <= out_3;
                5'b11111: rt <= out_4;
                5'b10000: rt <= out_5;
            endcase
            case (instruction[15:11]) //rd
                5'b10001: des_1 <= 0;
                5'b10010: des_1 <= 1;
                5'b01000: des_1 <= 2;
                5'b10111: des_1 <= 3;
                5'b11111: des_1 <= 4;
                5'b10000: des_1 <= 5;
            endcase
            shamt <= instruction[10:6];
        end
        else begin
            op <= IDLE;
            flag <= 1;
        end
    end
    else begin
        op <= IDLE;
        flag <= 0;
    end
end


//EXE
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        des_2 <= 6;
    end
    else begin
        case (op)
            IDLE: begin
                shift <= 0;
                if (flag)
                    des_2 <= 7;
                else
                    des_2 <= 6;
            end
            ADD: begin
                shift <= 0;
                out <= rs + rt;
                des_2 <= des_1;
            end
            MULT: begin
                shift <= 1;
                des_2 <= des_1;
                out_m[0] <= $signed({1'b0, rs[3:0]}) * $signed({1'b0, rt[3:0]});
                out_m[1] <= $signed({1'b0, rs[7:4]}) * $signed({1'b0, rt[3:0]});
                out_m[2] <= $signed({1'b0, rs[11:8]}) * $signed({1'b0, rt[3:0]});
                out_m[3] <= $signed(rs[15:12]) * $signed({1'b0, rt[3:0]});
                out_m[4] <= $signed({1'b0, rs[3:0]}) * $signed({1'b0, rt[7:4]});
                out_m[5] <= $signed({1'b0, rs[7:4]}) * $signed({1'b0, rt[7:4]});
                out_m[6] <= $signed({1'b0, rs[11:8]}) * $signed({1'b0, rt[7:4]});
                out_m[7] <= $signed(rs[15:12]) * $signed({1'b0, rt[7:4]});
                out_m[8] <= $signed({1'b0, rs[3:0]}) * $signed({1'b0, rt[11:8]});
                out_m[9] <= $signed({1'b0, rs[7:4]}) * $signed({1'b0, rt[11:8]});
                out_m[10] <= $signed({1'b0, rs[11:8]}) * $signed({1'b0, rt[11:8]});
                out_m[11] <= $signed(rs[15:12]) * $signed({1'b0, rt[11:8]});
                out_m[12] <= $signed({1'b0, rs[3:0]}) * $signed(rt[15:12]);
                out_m[13] <= $signed({1'b0, rs[7:4]}) * $signed(rt[15:12]);
                out_m[14] <= $signed({1'b0, rs[11:8]}) * $signed(rt[15:12]);
                out_m[15] <= $signed(rs[15:12]) * $signed(rt[15:12]);
            end
            LS: begin
                shift <= 0;
                out <= rt << shamt;
                des_2 <= des_1;
            end
            RS: begin
                shift <= 0;
                out <= rt >>> shamt;
                des_2 <= des_1;
            end
            RELU: begin
                shift <= 0;
                des_2 <= des_1;
                if (!rt[15]) 
                    out <= rt;
                else
                    out <= 0;
            end
            LRELU: begin
                if (rt[15]) begin
                    shift <= 1;
                    des_2 <= des_1;
                    out_m[0] <= $signed({1'b0, rs[3:0]}) * $signed({1'b0, rt[3:0]});
                    out_m[1] <= $signed({1'b0, rs[7:4]}) * $signed({1'b0, rt[3:0]});
                    out_m[2] <= $signed({1'b0, rs[11:8]}) * $signed({1'b0, rt[3:0]});
                    out_m[3] <= $signed(rs[15:12]) * $signed({1'b0, rt[3:0]});
                    out_m[4] <= $signed({1'b0, rs[3:0]}) * $signed({1'b0, rt[7:4]});
                    out_m[5] <= $signed({1'b0, rs[7:4]}) * $signed({1'b0, rt[7:4]});
                    out_m[6] <= $signed({1'b0, rs[11:8]}) * $signed({1'b0, rt[7:4]});
                    out_m[7] <= $signed(rs[15:12]) * $signed({1'b0, rt[7:4]});
                    out_m[8] <= $signed({1'b0, rs[3:0]}) * $signed({1'b0, rt[11:8]});
                    out_m[9] <= $signed({1'b0, rs[7:4]}) * $signed({1'b0, rt[11:8]});
                    out_m[10] <= $signed({1'b0, rs[11:8]}) * $signed({1'b0, rt[11:8]});
                    out_m[11] <= $signed(rs[15:12]) * $signed({1'b0, rt[11:8]});
                    out_m[12] <= $signed({1'b0, rs[3:0]}) * $signed(rt[15:12]);
                    out_m[13] <= $signed({1'b0, rs[7:4]}) * $signed(rt[15:12]);
                    out_m[14] <= $signed({1'b0, rs[11:8]}) * $signed(rt[15:12]);
                    out_m[15] <= $signed(rs[15:12]) * $signed(rt[15:12]);
                end
                else begin
                    shift <= 0;
                    out <= rt;
                    des_2 <= des_1;
                end
            end
            ADDI: begin
                shift <= 0;
                out <= rs + imm;
                des_2 <= des_1;
            end
        endcase
    end
end


//EXE 2
logic signed [30:0] wb_0, wb_1, wb_2, wb_3, wb_4, wb_5, wb_6;

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        des_3 <= 6;
    end
    else begin
        if (shift) begin
            wb_0 <= out_m[0];
            wb_1 <= (out_m[1] + out_m[4]) << 4;
            wb_2 <= (out_m[2] + out_m[5] + out_m[8]) << 8;
            wb_3 <= $signed(out_m[3] + out_m[6] + out_m[9] + out_m[12]) << 12;
            wb_4 <= $signed(out_m[7] + out_m[10] + out_m[13]) << 16;
            wb_5 <= $signed(out_m[11] + out_m[14]) << 20;
            wb_6 <= $signed(out_m[15]) << 24;
        end
        else begin
            wb_0 <= out;
        end
        des_3 <= des_2;
        shift_2 <= shift;
    end
end


//Write Back
logic signed [30:0] sum1, sum2, sum3;
logic signed [15:0] wb;

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_0 <= 0;
        out_1 <= 0;
        out_2 <= 0;
        out_3 <= 0;
        out_4 <= 0;
        out_5 <= 0;
        out_valid <= 0;
        instruction_fail <= 0;
    end
    else begin
        if (des_3 == 6) begin
            out_valid <= 0;
            instruction_fail <= 0;
            out_0 <= 0;
            out_1 <= 0;
            out_2 <= 0;
            out_3 <= 0;
            out_4 <= 0;
            out_5 <= 0;
        end
        else if (des_3 == 7) begin
            out_valid <= 1;
            instruction_fail <= 1;
        end
        else begin
            out_valid <= 1;
            instruction_fail <= 0;
            case (des_3)
                0: out_0 <= wb;
                1: out_1 <= wb;
                2: out_2 <= wb;
                3: out_3 <= wb;
                4: out_4 <= wb;
                5: out_5 <= wb;
            endcase
        end
    end
end
always_comb begin
    if (shift_2) begin
        sum1 = wb_0 + wb_1 + wb_2;
        sum2 = wb_3 + wb_4;
        sum3 = wb_5 + wb_6;
        wb = (sum1 + sum2 + sum3) >>> 15;
    end
    else 
        wb = wb_0;
end


endmodule
/*
          3  2  1  0
       7  6  5  4
   11 10  9  8
15 14 13 12
*/