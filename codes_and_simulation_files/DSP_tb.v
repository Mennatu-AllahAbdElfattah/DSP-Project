module DSP_tb();
    //  Data Ports
    reg [17:0] A, B, D;
    reg [47:0] C;
    reg        CARRYIN;
    wire [35:0] M;
    wire [47:0] P;
    wire        CARRYOUT, CARRYOUTF;

    //  Clock Enable Ports
    reg  CEA, CEB, CEC, CED, CEM, CEP, CECARRYIN, CEOPMODE;

    //  Reset Ports
    reg  RSTA, RSTB, RSTC, RSTD, RSTM, RSTP, RSTCARRYIN, RSTOPMODE;

    //  Control Inputs
    reg        CLK;
    reg [6:0]  OPMODE;

    //  Cascade Ports
    reg  [47:0] PCIN;
    reg  [17:0] BCIN;
    wire [47:0] PCOUT;
    wire [17:0] BCOUT;

    // Instantiate the DSP module
    dsp48a1_unit #(
        .A0REG(0),
        .A1REG(1),
        .B0REG(0),
        .B1REG(1),
        .CREG(1),
        .DREG(1),
        .MREG(1),
        .PREG(1),
        .CARRYINREG(1),
        .CARRYOUTREG(1),
        .OPMODEREG(1),
        .CARRYINSEL("OPMODE5"),
        .B_INPUT("DIRECT"),
        .RSTTYPE("SYNC")
    ) dsp_inst (
        .A(A), 
        .B(B), 
        .D(D), 
        .C(C), 
        .CARRYIN(CARRYIN), 
        .M(M), 
        .P(P), 
        .CARRYOUT(CARRYOUT), 
        .CARRYOUTF(CARRYOUTF),
        .CEA(CEA), 
        .CEB(CEB), 
        .CEC(CEC), 
        .CED(CED), 
        .CEM(CEM), 
        .CEP(CEP), 
        .CECARRYIN(CECARRYIN), 
        .CEOPMODE(CEOPMODE),
        .RSTA(RSTA), 
        .RSTB(RSTB), 
        .RSTC(RSTC), 
        .RSTD(RSTD), 
        .RSTM(RSTM), 
        .RSTP(RSTP), 
        .RSTCARRYIN(RSTCARRYIN), 
        .RSTOPMODE(RSTOPMODE),
        .CLK(CLK),
        .OPMODE(OPMODE),
        .PCIN(PCIN),
        .BCIN(BCIN),
        .PCOUT(PCOUT),
        .BCOUT(BCOUT)
    );

    initial begin
        CLK = 0;
        forever #1 CLK = ~CLK; // Clock generation
    end
    initial begin
    //Verify Reset Operation
        RSTA = 1;
        RSTB = 1;
        RSTC = 1;
        RSTD = 1;
        RSTM = 1;
        RSTP = 1;
        RSTCARRYIN = 1;
        RSTOPMODE = 1;
        CEA = $random % 2;
        CEB = $random % 2;
        CEC = $random % 2;
        CED = $random % 2;
        CEM = $random % 2;
        CEP = $random % 2;
        CECARRYIN = $random % 2;
        CEOPMODE = $random % 2;
        A = $random % 2;
        B = $random % 2;
        D = $random % 2;
        C = {$random, $random};
        CARRYIN = $random % 2;
        OPMODE = $random % 128;
        PCIN = {$random, $random};
        BCIN = $random ;
        @(negedge CLK);
        if (PCOUT === 0 && BCOUT === 0 && CARRYOUT === 0 && CARRYOUTF === 0 && M === 0 && P === 0) begin
            $display("Reset operation verified.");     
        end else begin
            $display("Reset operation failed.");
            $stop;
        end

    //Verify DSP Path 1
        RSTA = 0;
        RSTB = 0;
        RSTC = 0;
        RSTD = 0;
        RSTM = 0;
        RSTP = 0;
        RSTCARRYIN = 0;
        RSTOPMODE = 0;
        CEA = 1;
        CEB = 1;
        CEC = 1;
        CED = 1;
        CEM = 1;
        CEP = 1;
        CEOPMODE = 1;
        OPMODE = 8'b11011101;
        A = 20;
        B = 10;
        C = 350;
        D = 25;
        PCIN = {$random, $random};
        BCIN = $random ;
        CARRYIN = $random % 2;
        repeat (4) @(negedge CLK);
        if (BCOUT === 'hf && M === 'h12c && P === 'h32 && PCOUT === 'h32 && CARRYOUT === 0 && CARRYOUTF === 0) begin
            $display("DSP Path 1 verified.");
        end else begin
            $display("DSP Path 1 failed.");
            $stop;
        end
        
    //Verify DSP Path 2
        OPMODE = 8'b00010000;
        A = 20;
        B = 10;
        D = 25;
        C = 350;
        PCIN = {$random, $random};
        BCIN = $random ;
        CARRYIN = $random % 2;
        repeat (3) @(negedge CLK);
        if (BCOUT === 'h23 && M === 'h2bc && P === 'h0 && CARRYOUT === 0 && CARRYOUTF === 0) begin
            $display("DSP Path 2 verified.");
        end else begin
            $display("DSP Path 2 failed.");
            $stop;
        end

    //Verify DSP Path 3
    OPMODE = 8'b00001010;
    A = 20;
    B = 10;
    D = 25;
    C = 350;
    PCIN = {$random, $random};
    BCIN = $random ;
    CARRYIN = $random % 2;
    repeat (3) @(negedge CLK);
    if (BCOUT === 'ha && M === 'hc8 && P === PCOUT && CARRYOUT === CARRYOUTF) begin
        $display("DSP Path 3 verified.");
    end else begin
        $display("DSP Path 3 failed.");
        $stop;
    end

    //Verify DSP Path 4
    OPMODE = 8'b10100111;
    A = 5;
    B = 6;
    D = 25;
    C = 350;
    PCIN = 3000;
    BCIN = $random;
    CARRYIN = $random % 2;
    repeat (3) @(negedge CLK);
    if (BCOUT === 'h6 && M === 'h1e && P === 'hfe6fffec0bb1 && PCOUT === 'hfe6fffec0bb1 && CARRYOUT === 1 && CARRYOUTF === 1) begin
        $display("DSP Path 4 verified.");
    end else begin
        $display("DSP Path 4 failed.");
        $stop;
    end
    $stop;
    end
endmodule