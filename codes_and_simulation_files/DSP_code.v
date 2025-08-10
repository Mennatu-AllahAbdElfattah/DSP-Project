module dsp48a1_unit #(
    // A and B pipeline registers
    parameter A0REG = 0,
    parameter A1REG = 1,
    parameter B0REG = 0,
    parameter B1REG = 1,

    // Other pipeline registers
    parameter CREG        = 1,
    parameter DREG        = 1,
    parameter MREG        = 1,
    parameter PREG        = 1,
    parameter CARRYINREG  = 1,
    parameter CARRYOUTREG = 1,
    parameter OPMODEREG   = 1,

    // Functional attributes
    parameter CARRYINSEL = "OPMODE5", // Options: "OPMODE5" or "CARRYIN"
    parameter B_INPUT     = "DIRECT",  // Options: "DIRECT" or "CASCADE"
    parameter RSTTYPE     = "SYNC"     // Options: "SYNC" or "ASYNC"
)(
    //  Data Ports
    input  wire [17:0] A, B, D,
    input  wire [47:0] C,
    input  wire        CARRYIN,
    output reg [35:0] M,
    output reg [47:0] P,
    output reg        CARRYOUT, CARRYOUTF,

    //  Clock Enable Ports
    input  wire CEA, CEB, CEC, CED, CEM, CEP, CECARRYIN, CEOPMODE,

    //  Reset Ports
    input  wire RSTA, RSTB, RSTC, RSTD, RSTM, RSTP, RSTCARRYIN, RSTOPMODE,

    //  Control Inputs
    input  wire        CLK,
    input  wire [7:0]  OPMODE,

    //  Cascade Ports
    input  wire [47:0] PCIN,
    input  wire [17:0] BCIN,
    output reg [47:0] PCOUT,
    output reg [17:0] BCOUT
);

// Internal signals..
reg [17:0] A0_reg, A1_reg, A0_to_use, A1_to_use,
           B0, B1, B0_reg, B1_reg, B0_to_use, B1_to_use,
           D_reg, D_to_use,
           pre_adder_out;
reg [47:0] C_reg, C_to_use,
           P_reg, X, Z, post_adder_out;
reg [6:0] OPMODE_reg, OPMODE_to_use;
reg [35:0] M_reg, M_to_use, M_mul;
reg CYI, Carry_Cascade, CIN,
    CYO, Carry_Out_Cascade, post_adder_carry_out;

//registers for the DSP48A1 unit
generate

    if (RSTTYPE == "SYNC") begin           // Synchronous reset and clock enable
        always @(posedge CLK) begin              
            if (A0REG) begin                   // A0 register
                if (RSTA) begin
                    A0_reg <= 0;
                end else if (CEA) begin
                    A0_reg <= A;
                end
            end if (A1REG) begin               // A1 register
                if (RSTA) begin
                    A1_reg <= 0;
                end else if (CEA) begin
                    A1_reg <= A0_to_use;
                end
            end if (B0REG) begin               // B0 register
                if (RSTB) begin
                    B0_reg <= 0;
                end else if (CEB) begin
                    B0_reg <= B0;
                end
            end if (B1REG) begin               // B1 register
                if (RSTB) begin
                    B1_reg <= 0;
                end else if (CEB) begin
                   B1_reg <= B1;
                end
            end if (CREG) begin                // C register
                if (RSTC) begin
                    C_reg <= 0;
                end else if (CEC) begin
                    C_reg <= C;
                end
            end if (DREG) begin                // D register
                if (RSTD) begin
                    D_reg <= 0;
                end else if (CED) begin
                    D_reg <= D;
                end
            end if (MREG) begin                // M register
                if (RSTM) begin
                    M_reg <= 0;
                end else if (CEM) begin
                    M_reg <= M_mul;
                end
            end if (PREG) begin                // P register
                if (RSTP) begin
                    P_reg <= 0;
                end else if (CEP) begin
                    P_reg <= post_adder_out;
                end
            end if (CARRYINREG) begin          // CARRYIN register
                if (RSTCARRYIN) begin
                    CYI <= 0;
                end else if (CECARRYIN) begin
                    CYI <= Carry_Cascade;
                end
            end if (CARRYOUTREG) begin         // CARRYOUT register
                if (RSTCARRYIN) begin
                    CYO <= 0;
                end else if (CECARRYIN) begin
                    CYO <= post_adder_carry_out;
                end
            end if (OPMODEREG) begin           // OPMODE register
                if (RSTOPMODE) begin
                    OPMODE_reg <= 8'b0;
                end else if (CEOPMODE) begin
                    OPMODE_reg <= OPMODE;
                end
            end
        end
    end else begin                         // Asynchronous reset and clock enable
        always @(posedge CLK or posedge RSTA or posedge RSTB or posedge RSTC or posedge RSTD or posedge RSTM or posedge RSTP or posedge RSTCARRYIN or posedge RSTOPMODE) begin
            if (RSTA) begin
                A0_reg <= 0;
                A1_reg <= 0;
            end else if (CEA) begin
                A0_reg <= A;
                A1_reg <= A0_to_use;
            end
            if (RSTB) begin
                B0_reg <= 0;
                B1_reg <= 0;
            end else if (CEB) begin
                B0_reg <= B0;
                B1_reg <= B1;
            end
            if (RSTC) begin
                C_reg <= 0;
            end else if (CEC) begin
                C_reg <= C;
            end
            if (RSTD) begin
                D_reg <= 0;
            end else if (CED) begin
                D_reg <= D;
            end
            if (RSTM) begin
                M_reg <= 0;
            end else if (CEM) begin
                M_reg <= M_mul;
            end
            if (RSTP) begin
                P_reg <= 0;
            end else if (CEP) begin
                P_reg <= post_adder_out;
            end
            if (RSTCARRYIN) begin
                CYI <= 0;
            end else if (CECARRYIN) begin
                CYI <= Carry_Cascade;
            end
            if (RSTCARRYIN) begin
                CYO <= 0;
            end else if (CECARRYIN) begin
                CYO <= post_adder_carry_out;
            end
            if (RSTOPMODE) begin
                OPMODE_reg <= 8'b0;
            end else if (CEOPMODE) begin
                OPMODE_reg <= OPMODE; 
            end
        end
    end

endgenerate

// Input MUXes for the DSP48A1 unit

    always @(*) begin

    // D input
    D_to_use = (DREG) ? D_reg : D;

    // A pipeline
    A0_to_use = (A0REG) ? A0_reg : A;
    A1_to_use = (A1REG) ? A1_reg : A0_to_use;

    // B input 
    B0 = (B_INPUT == "CASCADE") ? BCIN :
         (B_INPUT == "DIRECT")  ? B : 18'd0;

    // B pipeline
    B0_to_use = (B0REG) ? B0_reg : B0;
    B1_to_use = (B1REG) ? B1_reg : B1;

    // C input
    C_to_use = (CREG) ? C_reg : C;

    // CARRYIN selection
    Carry_Cascade = (CARRYINSEL == "CARRYIN") ? CARRYIN :
                    (CARRYINSEL == "OPMODE5") ? OPMODE[5] : 1'b0;

    // Final carry input to use
    CIN = (CARRYINREG) ? CYI : Carry_Cascade;

    // M output
    M_to_use = (MREG) ? M_reg : M_mul;

    // P output
    P = (PREG) ? P_reg : post_adder_out;

    // Carry out selection
    Carry_Out_Cascade = (CARRYOUTREG) ? CYO : post_adder_carry_out;

    // OPMODE register selection
    OPMODE_to_use = (OPMODEREG) ? OPMODE_reg : OPMODE;
end


// operations
always @(*) begin
    
    // pre_adder/subtractor 
        if (OPMODE_to_use[6] == 0) begin
            pre_adder_out = B0_to_use + D_to_use;
        end else begin
            pre_adder_out = D_to_use - B0_to_use;
        end
        if (OPMODE_to_use[4] == 1) begin
            B1 = pre_adder_out;
        end else begin
            B1 = B0_to_use;
        end
        BCOUT = B1_to_use;                  // Bcout assignment
    // multiplier
        M_mul = B1_to_use * A1_to_use;
        M = M_to_use;
    //  x mux 
        case (OPMODE_to_use[1:0])
            2'b00: begin
                X = 0;
            end
            2'b01: begin
                X = M_to_use;
            end
            2'b10: begin
                X = P;
            end
            2'b11: begin
                X = {D_to_use, A1_to_use, B1_to_use};
            end
            default: begin
                X = 0; // Default case
            end
        endcase
        // z mux
        case (OPMODE_to_use[3:2])
            2'b00: begin
                Z = 0;
            end
            2'b01: begin
                Z = PCIN;
            end
            2'b10: begin
                Z = P;
            end
            2'b11: begin
                Z = C_to_use;
            end
            default: begin
                Z = 0; // Default case
            end
        endcase
        // post adder
            if (OPMODE_to_use[7] == 0) begin
                {post_adder_carry_out, post_adder_out} = Z + X + CIN;
            end else begin
                {post_adder_carry_out, post_adder_out} = Z - X - CIN;
            end
            CARRYOUT = Carry_Out_Cascade;
            CARRYOUTF = Carry_Out_Cascade;
            PCOUT = P;
end
endmodule


