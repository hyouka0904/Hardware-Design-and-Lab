module map3(
    input clk, 
    input rst, 
    input en, 
    input invincible,
    input wire [9:0] vga_h, 
    input wire [9:0] vga_v,  
    input [3:0] player_state, player2_state,
    input [1:0] player_jump, player2_jump,
    output wire [16:0] addr, 
    output wire clear,
    output wire fail,
    output reg [15:0] led,
    output wire p1_collision, p2_collision,
    output wire p1_land, p2_land,
    output wire should_down, should_down2,
    output wire button1_tounch
);
    parameter stactic = 4'd6, right = 4'd7, left = 4'd8, up = 4'd9;
    wire collision_with_player1, collision_with_player2;
    //wire p1_collision;
    //reg [1:0] player_jump;
    //reg [3:0] player_state;
    reg [29:0] cnt_player_jump = 0;

    wire [9:0] h, v;
    assign h = vga_h >> 1;
    assign v = vga_v >> 1;

    wire dimond1_touch, button2_tounch, dimond2_touch;
    wire p1_on_mech1;
    reg dimond1_flag = 1, botton1_flag = 1, botton2_flag = 1, dimond2_flag = 1, fail_flag = 1;
    reg [9:0] player_horizontal_displacement = 0, player_vertical_displacement = 0, player2_h_dis = 0, player2_v_dis = 0;
    reg [24:0] player_cnt_horizontal = 25'b0, player_cnt_vertical = 25'b0, player2_cnt_h = 25'b0, player2_cnt_v = 25'b0;
    reg [9:0] mech_1_v_displacement = 0, mech_2_h_displacement = 0;
    reg [24:0] mech_cnt_v = 25'b0, mech_2_cnt_h = 0;

    assign clear = (player_state == stactic && (13+player_horizontal_displacement)>=250 && (28+player_horizontal_displacement) <273 && (230-player_vertical_displacement) == 48) &&
    (player2_state == stactic && (13+player2_h_dis)>=280 && (27+player2_h_dis) <301 && (230-player2_v_dis) == 48) && dimond1_touch && dimond2_touch;

    always @(posedge clk) begin
        if(rst || !en) led <= 16'b0000_0000_0000_1111;
        else begin
            if(clear) led <= 16'b1111_1111_1111_1111;
            else if(fail) led <= 16'b1111_0000_1111_0000;
        end
    end

    assign p1_on_mech1 = ((25+player_horizontal_displacement) < 50 && (230-player_vertical_displacement)==(139+mech_1_v_displacement));

    assign dimond1_touch = (dimond1_flag) ? (
        (22+player_horizontal_displacement == 197 && player_state == right && player_vertical_displacement >= 0 && player_vertical_displacement < 3) ? 1 : 0
    ) : (
        1
    );

    assign dimond2_touch = (dimond2_flag) ? (
        (10+player2_h_dis <= 32 && player2_state == left && (230-player2_v_dis) >= 65 && (230-player2_v_dis) <= 72) ? 1 : 0
    ) : (
        1
    );

    assign fail = invincible ? 0 : (
        (fail_flag) ? (
            (player_horizontal_displacement >= 201 && player_horizontal_displacement <=208 && (230-player_vertical_displacement)==230) ||
            (player2_h_dis >= 140 && player2_h_dis <= 143 && (230-player2_v_dis) == 230) ||
            (player_horizontal_displacement >= 28 && player_horizontal_displacement <=49 && (230-player_vertical_displacement)==182) ||
            (player2_h_dis >= 28 && player2_h_dis <= 49 && (230-player2_v_dis) == 182)
        ) : (
            1
        )
    );


    assign p1_collision = (player_jump == 1 && (199 - player_vertical_displacement) == 190 && (10 + player_horizontal_displacement) < 240) ||
    (player_state == right && (28+player_horizontal_displacement) >= 275 && (230-player_vertical_displacement) >= 220) ||     // wall 7
    (player_jump == 1 && (199-player_vertical_displacement) == 147 && (10+player_horizontal_displacement) >= 90) ||   // wall 2
    (button1_tounch && player_state == left && (10+player_horizontal_displacement) <= 40 && (230-player_vertical_displacement) <= 182 && (230-player_vertical_displacement) >= 165) ||//mech 1
    (!button1_tounch && (10+player_horizontal_displacement)<40 && (199-player_vertical_displacement) <=147 && (199-player_vertical_displacement) >=139) ||
    (player_jump == 1 && (199-player_vertical_displacement) == 104 && (10+player_horizontal_displacement) >= 75 && (10+player_horizontal_displacement) < 270) || //wall 3
    (player_state == right && button2_tounch && (28+player_horizontal_displacement) >= 295 && (230-player_vertical_displacement) >= 130) ||   // mech 2
    (player_jump == 1 && (199 - player_vertical_displacement) == 56 && (10 + player_horizontal_displacement) >= 100) || // wall 6
    (player_jump == 1 && (200-player_vertical_displacement)== 10) //ceiling
    ; 

    assign p2_collision = (player2_jump == 1 && (199 - player2_v_dis) == 190 && (10 + player2_h_dis) < 240) ||
    (player2_state == right && (28+player2_h_dis) >= 275 && (230-player2_v_dis) >= 220) ||     // wall 7
    (player2_jump == 1 && (199-player2_v_dis) == 147 && (10+player2_h_dis) >= 90) ||    // wall 2
    (button1_tounch && player2_state == left && (10+player2_h_dis) <= 40 && (230-player2_v_dis) <= 182 && (230-player2_v_dis) >= 165) ||//mech 1
    (!button1_tounch && (10+player2_h_dis)<40 && (199-player2_v_dis) <=147 && (199-player2_v_dis) >= 139) ||
    (player2_jump == 1 && (199-player2_v_dis) == 104 && (10+player2_h_dis) >= 75 && (10+player2_h_dis) < 270) || //wall 3
    (player2_state == right && button2_tounch && (28+player2_h_dis)>=295 && (230-player2_v_dis) >= 130) || // mech 2
    (player2_jump == 1 && (199 - player2_v_dis) == 56 && (10 + player2_h_dis) >= 100) ||   // wall 6
    (player2_jump == 1 && (200-player2_v_dis)== 10) //ceiling
    ; 

    assign p1_land = (player_jump == 2 && (230-player_vertical_displacement) == 230 && (28+player_horizontal_displacement) < 276) ||  // floor
    (player_jump == 2 && (13 + player_horizontal_displacement) >= 274 && (28+player_horizontal_displacement) <= 320 && (230-player_vertical_displacement) == 210) ||  // wall 7
    (player_jump == 2 && (230 -player_vertical_displacement) == 182 && (8+player_horizontal_displacement) >= 8 && (25+player_horizontal_displacement) < 255) ||
    (button1_tounch && player_jump == 2 && (230-player_vertical_displacement) == 161 && (8+player_horizontal_displacement) <= 40) ||  // mech 1
    (player_jump == 2 && (13+player_horizontal_displacement)>=80 && (13+player_horizontal_displacement)<310 && (230-player_vertical_displacement)==139) || // wall 2
    (button2_tounch && player_jump == 2 && (230-player_vertical_displacement) == 124 && (28+player_horizontal_displacement) >= 295) || // mech 2
    (player_jump == 2 && (13+player_horizontal_displacement)>=85 && (13+player_horizontal_displacement)<270 && (230-player_vertical_displacement)==96) || // wall 3
    (player_jump == 2 && (13+player_horizontal_displacement)<=65 && (230-player_vertical_displacement)==71) || // wall 8
    (player_jump == 2 && (28+player_horizontal_displacement)>=110 && (230-player_vertical_displacement)==48) // wall 6
    ;

    assign p2_land = (player2_jump == 2 && (230-player2_v_dis) == 230 && (28+player2_h_dis) < 276) ||  // floor
    (player2_jump == 2 && (13 + player2_h_dis) >= 274 && (28+player2_h_dis) <= 320 && (230-player2_v_dis) == 210) ||  // wall 7
    (player2_jump == 2 && (230 -player2_v_dis) == 182 && (8+player2_h_dis) >= 8 && (25+player2_h_dis) < 255) ||
    (button1_tounch && player2_jump == 2 && (230-player2_v_dis) == 161 && (8+player2_h_dis) <= 40) ||   // mech 1
    (player2_jump == 2 && (13+player2_h_dis)>=80 && (13+player2_h_dis)<310 && (230-player2_v_dis)==139) || // wall 2
    (button2_tounch && player2_jump == 2 && (230-player2_v_dis)==124 && (28+player2_h_dis) >= 295) || // mech 2
    (player2_jump == 2  && (13+player2_h_dis)>=85 && (13+player2_h_dis)<270 && (230-player2_v_dis)==96) ||  // wall 3
    (player2_jump == 2 && (13+player2_h_dis)<=65 && (230-player2_v_dis)==71) ||  // wall 8
    (player2_jump == 2 && (28+player2_h_dis)>=110 && (230-player2_v_dis)==48)  // wall 6
    ;

    assign should_down = (player_state == left && (22+player_horizontal_displacement) <= 277 && (230-player_vertical_displacement)>= 210 && (230-player_vertical_displacement) < 212) ||
    (player_state == right && (8+player_horizontal_displacement) >= 230 && (230-player_vertical_displacement) >= 182 && (230-player_vertical_displacement) < 184) ||
    (player_state == right && (8+player_horizontal_displacement) >= 35 &&  (230-player_vertical_displacement) >= 161 && (230-player_vertical_displacement) < 163) ||
    (player_state == left && (22+player_horizontal_displacement) <= 90 && (230-player_vertical_displacement) >= 137 && (230-player_vertical_displacement) <= 139) ||
    (player_state == left && (22+player_horizontal_displacement)  <= 296 && (230-player_vertical_displacement) >= 122 && (230-player_vertical_displacement) <= 124) ||
    (player_state == right && (8+player_horizontal_displacement) >= 270 && (230-player_vertical_displacement) >= 94 && (230-player_vertical_displacement) <= 96) ||
    (player_state == left && (22+player_horizontal_displacement) <=85 && (230-player_vertical_displacement) >= 94 && (230-player_vertical_displacement) <= 96) ||
    (player_state == right && (8+player_horizontal_displacement) >= 53 && (230-player_vertical_displacement) >= 71 && (230-player_vertical_displacement) < 73) || 
    (player_state == left && (22+player_horizontal_displacement) <= 110 && (230-player_vertical_displacement) >= 46 && (230-player_vertical_displacement) <= 48)
    ;

    assign should_down2 = (player2_state == left && (22+player2_h_dis) <= 277 && (230-player2_v_dis)>= 210 && (230-player2_v_dis) < 212) ||
    (player2_state == right && (8+player2_h_dis) >= 230 && (230-player2_v_dis) >= 182 && (230-player2_v_dis) < 184) ||
    (player2_state == right && (8+player2_h_dis) >= 35 &&  (230-player2_v_dis) >= 161 && (230-player2_v_dis) < 163) ||
    (player2_state == left && (22+player2_h_dis) <= 90 && (230-player2_v_dis) >= 137 && (230-player2_v_dis) <= 139) ||
    (player2_state == left && (22+player2_h_dis) <= 296 && (230-player2_v_dis) >= 122 && (230-player2_v_dis) <= 124) ||
    (player2_state == right && (8+player2_h_dis) >=270 && (230-player2_v_dis) >= 94 && (230-player2_v_dis)<=96) ||
    (player2_state == left && (22+player2_h_dis) <=85 && (230-player2_v_dis) >= 94 && (230-player2_v_dis) <= 96) ||
    (player2_state == right && (8+player2_h_dis) >= 53 && (230-player2_v_dis) >= 71 && (230-player2_v_dis) < 73) ||
    (player2_state == left && (22+player2_h_dis) <= 110 && (230-player2_v_dis) >= 46 && (230-player2_v_dis) <= 48) 
    ;

    assign button1_tounch = (botton1_flag) ? (
        (((22+player_horizontal_displacement) >=100 && (8+player_horizontal_displacement) < 105 && (230-player_vertical_displacement) <= 182 && (230-player_vertical_displacement) >=180 ) ||
    ((30+player2_h_dis) >= 100 && (10+player2_h_dis) < 105 && (230-player2_v_dis) <= 182 && (230-player2_v_dis) >= 180)) ? 1 : 0
    ) : (
        1
    ) ;

    assign button2_tounch = (botton2_flag) ? (
        (((22+player_horizontal_displacement) >= 244 && (8+player_horizontal_displacement) <250 && (200-player_vertical_displacement) >= 104 && (200-player_vertical_displacement) <= 106) || 
        ((30+player2_h_dis) >= 244 && (10+player2_h_dis) < 250 && (200-player2_v_dis) >= 104 && (200-player2_v_dis) <= 106)) ? 1 : 0
    ) : (
        1
    );

    assign addr = (h>=0 && h <320 && v>=0 && v < 10) ? (   // ceiling
        h+(v+220)*320
    ) : (
        (h >= 164 && h < 176 && v >= 230 && v < 236) ? (   //red river
            19521
        ) : (
            (h >= 224 && h < 236 && v >= 230 && v < 236) ? (  // blue river
                22470
            ) : (
                (h >= 50 && h < 70 && v >= 182 && v < 188) ? (  // green river
                    60910
                ) : (
                    (h >=0 && h < 320 && v >= 230 && v < 240) ? (   // floor
                        h + (v-230+220)*320
                    ) : (
                        (h >=0 && h<10 && v>=10 && v<230) ? (    // left boundary
                            (h+305) + v*320
                        ) : (
                            (h>=310 && h<320 && v>=10 && v<230) ? (  // right boundary
                                (h-310+305) + v*320
                            ) : (
                                (h>=10 && h<240 && v >=182 && v<190) ? (    // wall 1
                                    (h-10+50) + (v-182+215)*320
                                ) : (
                                    (h>=90 && h<310 && v>=139 && v<147) ? (   // wall 2
                                        (h-90) + (v-139+220)*320
                                    ) : (
                                        (h>=85 && h < 270 && v >= 96 && v<104) ? (  // wall 3
                                            (h-85) + (v-96+220)*320
                                        ) : (
                                                (h>=110 && h<310 && v>=48 && v<56) ? (  // wall 6
                                                    (h-110) + (v-48+220)*320
                                                ) : (
                                                    (h>=250 && h<273 && v>=19 && v<48) ? (   // red door
                                                        (h-250) + (v-19+89)*320
                                                    ) : (
                                                        (h>=280 && h<301 && v>=19 && v<48) ? (  // blue door
                                                            (h-280+32) + (v-19+89)*320
                                                        ) : (
                                                            (h >= 275 && h < 310 && v >= 210 && v < 230) ? (  // wall 7
                                                                (h-290) + (v-215+218)*320
                                                            ) : (
                                                                (h>=0 && h<65 && v>=71 && v<81) ? (    // wall 8
                                                                    (h+160)+(v+158)*320
                                                                ) : (
                                                                    (h>=194 && h <206 && v>=203 && v<220) ? (       // red dimond 1
                                                                        dimond1_touch ? 12900 : (((h-99)+(v-66)*320))
                                                                    ) : (
                                                                        (h>=20 && h<32 && v>=44 && v<60) ? (        // blue dimond 1
                                                                            dimond2_touch ? 12900 : ((h+75)+((v+76)*320))
                                                                        ) : (
                                                                            (h>=100 && h<105 && v>=177 && v<182) ? (     //button 1
                                                                                (button1_tounch) ? (
                                                                                    60800
                                                                                ) : (
                                                                                    540
                                                                                )
                                                                            ) : (
                                                                                (h>=10 && h<40 && v>=(139+mech_1_v_displacement) && v<(147+mech_1_v_displacement)) ? (   //mech 1
                                                                                    h + (v+88-mech_1_v_displacement)*320
                                                                                ) : (
                                                                                    (h>=244 && h<250 && v>=104 && v<=110) ? (
                                                                                        (button2_tounch) ? 60800 : 540
                                                                                    ) : (
                                                                                        (h>=(310-mech_2_h_displacement) && h<(325-mech_2_h_displacement) && v>=124 && v<139) ? (
                                                                                            (button2_tounch) ? (
                                                                                                (310-mech_2_h_displacement) + (v+100)*320
                                                                                            ) : (
                                                                                                12900
                                                                                            )
                                                                                        ) : (
                                                                                            (player_state == right) ? (
                                                                                                ((h >= (8+player_horizontal_displacement)) && (h < (22+player_horizontal_displacement)) && (v >= (200-player_vertical_displacement)) && (v < (230-player_vertical_displacement))) ? (
                                                                                                    (h+63-player_horizontal_displacement) + (v+player_vertical_displacement-200) * 320
                                                                                                ) : (
                                                                                                    (player2_state == stactic) ? (
                                                                                                        (h>=(13+player2_h_dis) && h<(27+player2_h_dis) && v>=(200-player2_v_dis) && v<(230-player2_v_dis)) ? (
                                                                                                            (h+148-player2_h_dis) + (v+player2_v_dis-141) * 320
                                                                                                        ) : (
                                                                                                            12900
                                                                                                        )
                                                                                                    ) : (
                                                                                                        (player2_state == left) ? (
                                                                                                            (h>=(10+player2_h_dis) && h<(33+player2_h_dis) && v>=(200-player2_v_dis) && v<(229-player2_v_dis)) ? (
                                                                                                                (h+151-player2_h_dis) + (v+player2_v_dis-110) * 320
                                                                                                            ) : (
                                                                                                                12900
                                                                                                            )
                                                                                                        ) : (
                                                                                                            (player2_state == right) ? (
                                                                                                                (h>=(1+player2_h_dis) && h<(33+player2_h_dis) && v>=(200-player2_v_dis) && v<(230-player2_v_dis)) ? (
                                                                                                                    (h+175-player2_h_dis) + (v+player2_v_dis-142) * 320
                                                                                                                ) : (
                                                                                                                    12900
                                                                                                                )
                                                                                                            ) : (
                                                                                                                (player2_state == up) ? (
                                                                                                                    (player2_jump == 1) ? (
                                                                                                                        (h>=(9+player2_h_dis) && h<(25+player2_h_dis) && v>=(200-player2_v_dis) && v<(229-player2_v_dis)) ? (
                                                                                                                            (h+175-player2_h_dis) + (v+player2_v_dis-110) * 320
                                                                                                                        ) : (
                                                                                                                            12900
                                                                                                                        )
                                                                                                                    ) : (
                                                                                                                        (h>=(13+player2_h_dis) && h<(27+player2_h_dis) && v>=(200-player2_v_dis) && v<(230-player2_v_dis)) ? (
                                                                                                                            (h+148-player2_h_dis) + (v+player2_v_dis-141) * 320
                                                                                                                        ) : (
                                                                                                                            12900
                                                                                                                        )                                                                                                  
                                                                                                                    )
                                                                                                                ) : (
                                                                                                                    12900
                                                                                                                )
                                                                                                            )
                                                                                                        )
                                                                                                    )
                                                                                                )
                                                                                            ) : (
                                                                                                (player_state == stactic) ? (
                                                                                                    ((h >= (13+player_horizontal_displacement)) && (h < (28+player_horizontal_displacement)) && (v >= (200-player_vertical_displacement)) && (v < (230-player_vertical_displacement))) ? (
                                                                                                        (h+40-player_horizontal_displacement) + (v+player_vertical_displacement-200) * 320
                                                                                                    ) : (
                                                                                                        (player2_state == stactic) ? (
                                                                                                            (h>=(13+player2_h_dis) && h<(27+player2_h_dis) && v>=(200-player2_v_dis) && v<(230-player2_v_dis)) ? (
                                                                                                                (h+148-player2_h_dis) + (v+player2_v_dis-141) * 320
                                                                                                            ) : (
                                                                                                                12900
                                                                                                            )
                                                                                                        ) : (
                                                                                                            (player2_state == left) ? (
                                                                                                                (h>=(10+player2_h_dis) && h<(33+player2_h_dis) && v>=(200-player2_v_dis) && v<(229-player2_v_dis)) ? (
                                                                                                                    (h+151-player2_h_dis) + (v+player2_v_dis-110) * 320
                                                                                                                ) : (
                                                                                                                    12900
                                                                                                                )
                                                                                                            ) : (
                                                                                                                (player2_state == right) ? (
                                                                                                                    (h>=(1+player2_h_dis) && h<(33+player2_h_dis) && v>=(200-player2_v_dis) && v<(230-player2_v_dis)) ? (
                                                                                                                        (h+175-player2_h_dis) + (v+player2_v_dis-142) * 320
                                                                                                                    ) : (
                                                                                                                        12900
                                                                                                                    )
                                                                                                                ) : (
                                                                                                                    (player2_state == up) ? (
                                                                                                                        (player2_jump == 1) ? (
                                                                                                                            (h>=(9+player2_h_dis) && h<(25+player2_h_dis) && v>=(200-player2_v_dis) && v<(229-player2_v_dis)) ? (
                                                                                                                                (h+175-player2_h_dis) + (v+player2_v_dis-110) * 320
                                                                                                                            ) : (
                                                                                                                                12900
                                                                                                                            )
                                                                                                                        ) : (
                                                                                                                            (h>=(13+player2_h_dis) && h<(27+player2_h_dis) && v>=(200-player2_v_dis) && v<(230-player2_v_dis)) ? (
                                                                                                                                (h+148-player2_h_dis) + (v+player2_v_dis-141) * 320
                                                                                                                            ) : (
                                                                                                                                12900
                                                                                                                            )                                                                                                  
                                                                                                                        )
                                                                                                                    ) : (
                                                                                                                        12900
                                                                                                                    )
                                                                                                                )
                                                                                                            )
                                                                                                        )
                                                                                                    )
                                                                                                ) : (
                                                                                                    (player_state == left) ? (
                                                                                                        ((h >= (8+player_horizontal_displacement)) && (h < (22+player_horizontal_displacement)) && (v >= (200-player_vertical_displacement)) && (v < (230-player_vertical_displacement))) ? (
                                                                                                            (h+78-player_horizontal_displacement) + (v+player_vertical_displacement-200) * 320
                                                                                                        ) : (
                                                                                                            (player2_state == stactic) ? (
                                                                                                                (h>=(13+player2_h_dis) && h<(27+player2_h_dis) && v>=(200-player2_v_dis) && v<(230-player2_v_dis)) ? (
                                                                                                                    (h+148-player2_h_dis) + (v+player2_v_dis-141) * 320
                                                                                                                ) : (
                                                                                                                    12900
                                                                                                                )
                                                                                                            ) : (
                                                                                                                (player2_state == left) ? (
                                                                                                                    (h>=(10+player2_h_dis) && h<(33+player2_h_dis) && v>=(200-player2_v_dis) && v<(229-player2_v_dis)) ? (
                                                                                                                        (h+151-player2_h_dis) + (v+player2_v_dis-110) * 320
                                                                                                                    ) : (
                                                                                                                        12900
                                                                                                                    )
                                                                                                                ) : (
                                                                                                                    (player2_state == right) ? (
                                                                                                                        (h>=(1+player2_h_dis) && h<(33+player2_h_dis) && v>=(200-player2_v_dis) && v<(230-player2_v_dis)) ? (
                                                                                                                            (h+175-player2_h_dis) + (v+player2_v_dis-142) * 320
                                                                                                                        ) : (
                                                                                                                            12900
                                                                                                                        )
                                                                                                                    ) : (
                                                                                                                        (player2_state == up) ? (
                                                                                                                            (player2_jump == 1) ? (
                                                                                                                                (h>=(9+player2_h_dis) && h<(25+player2_h_dis) && v>=(200-player2_v_dis) && v<(229-player2_v_dis)) ? (
                                                                                                                                    (h+175-player2_h_dis) + (v+player2_v_dis-110) * 320
                                                                                                                                ) : (
                                                                                                                                    12900
                                                                                                                                )
                                                                                                                            ) : (
                                                                                                                                (h>=(13+player2_h_dis) && h<(27+player2_h_dis) && v>=(200-player2_v_dis) && v<(230-player2_v_dis)) ? (
                                                                                                                                    (h+148-player2_h_dis) + (v+player2_v_dis-141) * 320
                                                                                                                                ) : (
                                                                                                                                    12900
                                                                                                                                )                                                                                                  
                                                                                                                            )
                                                                                                                        ) : (
                                                                                                                            12900
                                                                                                                        )
                                                                                                                    )
                                                                                                                )
                                                                                                            )
                                                                                                        )
                                                                                                    ) : (
                                                                                                        (player_state == up) ? (
                                                                                                            (player_jump == 1) ? (
                                                                                                                ((h >= (10+player_horizontal_displacement)) && (h < (25+player_horizontal_displacement)) && (v >= (199-player_vertical_displacement)) && (v < (227-player_vertical_displacement))) ? (
                                                                                                                    (h+43-player_horizontal_displacement) + (v+player_vertical_displacement-169) * 320
                                                                                                                ) : (   
                                                                                                                    (player2_state == stactic) ? (
                                                                                                                        (h>=(13+player2_h_dis) && h<(27+player2_h_dis) && v>=(200-player2_v_dis) && v<(230-player2_v_dis)) ? (
                                                                                                                            (h+148-player2_h_dis) + (v+player2_v_dis-141) * 320
                                                                                                                        ) : (
                                                                                                                            12900
                                                                                                                        )
                                                                                                                    ) : (
                                                                                                                        (player2_state == left) ? (
                                                                                                                            (h>=(10+player2_h_dis) && h<(33+player2_h_dis) && v>=(200-player2_v_dis) && v<(229-player2_v_dis)) ? (
                                                                                                                                (h+151-player2_h_dis) + (v+player2_v_dis-110) * 320
                                                                                                                            ) : (
                                                                                                                                12900
                                                                                                                            )
                                                                                                                        ) : (
                                                                                                                            (player2_state == right) ? (
                                                                                                                                (h>=(1+player2_h_dis) && h<(33+player2_h_dis) && v>=(200-player2_v_dis) && v<(230-player2_v_dis)) ? (
                                                                                                                                    (h+175-player2_h_dis) + (v+player2_v_dis-142) * 320
                                                                                                                                ) : (
                                                                                                                                    12900
                                                                                                                                )
                                                                                                                            ) : (
                                                                                                                                (player2_state == up) ? (
                                                                                                                                    (player2_jump == 1) ? (
                                                                                                                                        (h>=(9+player2_h_dis) && h<(25+player2_h_dis) && v>=(200-player2_v_dis) && v<(229-player2_v_dis)) ? (
                                                                                                                                            (h+175-player2_h_dis) + (v+player2_v_dis-110) * 320
                                                                                                                                        ) : (
                                                                                                                                            12900
                                                                                                                                        )
                                                                                                                                    ) : (
                                                                                                                                        (h>=(13+player2_h_dis) && h<(27+player2_h_dis) && v>=(200-player2_v_dis) && v<(230-player2_v_dis)) ? (
                                                                                                                                            (h+148-player2_h_dis) + (v+player2_v_dis-141) * 320
                                                                                                                                        ) : (
                                                                                                                                            12900
                                                                                                                                        )                                                                                                  
                                                                                                                                    )
                                                                                                                                ) : (
                                                                                                                                    12900
                                                                                                                                )
                                                                                                                            )
                                                                                                                        )
                                                                                                                    )
                                                                                                                )
                                                                                                            ) : (
                                                                                                                ((h >= (10+player_horizontal_displacement)) && (h < (25+player_horizontal_displacement)) && (v >= (200-player_vertical_displacement)) && (v < (230-player_vertical_displacement))) ? (
                                                                                                                    (h+43-player_horizontal_displacement) + (v+player_vertical_displacement-200) * 320
                                                                                                                ) : (   
                                                                                                                    (player2_state == stactic) ? (
                                                                                                                        (h>=(13+player2_h_dis) && h<(27+player2_h_dis) && v>=(200-player2_v_dis) && v<(230-player2_v_dis)) ? (
                                                                                                                            (h+148-player2_h_dis) + (v+player2_v_dis-141) * 320
                                                                                                                        ) : (
                                                                                                                            12900
                                                                                                                        )
                                                                                                                    ) : (
                                                                                                                        (player2_state == left) ? (
                                                                                                                            (h>=(10+player2_h_dis) && h<(33+player2_h_dis) && v>=(200-player2_v_dis) && v<(229-player2_v_dis)) ? (
                                                                                                                                (h+151-player2_h_dis) + (v+player2_v_dis-110) * 320
                                                                                                                            ) : (
                                                                                                                                12900
                                                                                                                            )
                                                                                                                        ) : (
                                                                                                                            (player2_state == right) ? (
                                                                                                                                (h>=(1+player2_h_dis) && h<(33+player2_h_dis) && v>=(200-player2_v_dis) && v<(230-player2_v_dis)) ? (
                                                                                                                                    (h+175-player2_h_dis) + (v+player2_v_dis-142) * 320
                                                                                                                                ) : (
                                                                                                                                    12900
                                                                                                                                )
                                                                                                                            ) : (
                                                                                                                                (player2_state == up) ? (
                                                                                                                                    (player2_jump == 1) ? (
                                                                                                                                        (h>=(9+player2_h_dis) && h<(25+player2_h_dis) && v>=(200-player2_v_dis) && v<(229-player2_v_dis)) ? (
                                                                                                                                            (h+175-player2_h_dis) + (v+player2_v_dis-110) * 320
                                                                                                                                        ) : (
                                                                                                                                            12900
                                                                                                                                        )
                                                                                                                                    ) : (
                                                                                                                                        (h>=(13+player2_h_dis) && h<(27+player2_h_dis) && v>=(200-player2_v_dis) && v<(230-player2_v_dis)) ? (
                                                                                                                                            (h+148-player2_h_dis) + (v+player2_v_dis-141) * 320
                                                                                                                                        ) : (
                                                                                                                                            12900
                                                                                                                                        )                                                                                                  
                                                                                                                                    )
                                                                                                                                ) : (
                                                                                                                                    12900
                                                                                                                                )
                                                                                                                            )
                                                                                                                        )
                                                                                                                    )
                                                                                                                )
                                                                                                            )
                                                                                                        ) : (
                                                                                                            12900
                                                                                                        )
                                                                                                    )
                                                                                                )
                                                                                            )        
                                                                                        )
                                                                                    )                                                                          
                                                                                )
                                                                            )
                                                                        )
                                                                    )          
                                                                )                                               
                                                            )
                                                        )
                                                    )
                                                )
                                            
                                        )
                                    )
                                )
                            )
                        )
                    )
                )
            )
        )
    );

    always @(posedge clk) begin
        if(rst || !en) begin
            fail_flag <= 1;
        end else begin
            if(fail_flag && fail) fail_flag <= 0;
            else fail_flag <= fail_flag;
        end
    end

    always @(posedge clk) begin
        if(rst || !en) begin
            dimond1_flag <= 1;
        end else begin
            if(dimond1_flag && dimond1_touch) dimond1_flag <= 0;
            else dimond1_flag <= dimond1_flag;
        end
    end

    always @(posedge clk) begin
        if(rst || !en) begin
            dimond2_flag <= 1;
        end else begin
            if(dimond2_flag && dimond2_touch) dimond2_flag <= 0;
            else dimond2_flag <= dimond2_flag;
        end
    end

    always @(posedge clk) begin
        if(rst || !en) begin
            botton1_flag <= 1;
        end else begin
            if(botton1_flag && button1_tounch) botton1_flag <= 0;
            else botton1_flag <= botton1_flag;
        end
    end

    always @(posedge clk) begin
        if(rst || !en) begin
            botton2_flag <= 1;
        end else begin
            if(botton2_flag && button2_tounch) botton2_flag <= 0;
            else botton2_flag <= botton2_flag;
        end
    end

    always @(posedge clk) begin
        if(rst || !en) begin
            mech_1_v_displacement <= 0;
            mech_cnt_v <= 0;
        end else begin
            if(button1_tounch) begin
                if(mech_cnt_v < 25'd2000000) begin
                    mech_cnt_v <= mech_cnt_v + 1;
                    mech_1_v_displacement <= mech_1_v_displacement;
                end
                else begin
                    if(mech_1_v_displacement < 22) mech_1_v_displacement <= mech_1_v_displacement + 1;
                    else mech_1_v_displacement <= mech_1_v_displacement;
                    mech_cnt_v <= 0;
                end
            end else begin
                    mech_1_v_displacement <= mech_1_v_displacement;
                    mech_cnt_v <= 0;         
            end
        end
    end

    always @(posedge clk) begin
        if(rst || !en) begin
            mech_2_h_displacement <= 0;
            mech_2_cnt_h <= 0;
        end else begin
            if(button2_tounch) begin
                if(mech_2_cnt_h < 25'd2000000) begin
                    mech_2_cnt_h <= mech_2_cnt_h + 1;
                    mech_2_h_displacement <= mech_2_h_displacement;
                end
                else begin
                    if(mech_2_h_displacement < 15) mech_2_h_displacement <= mech_2_h_displacement + 1;
                    else mech_2_h_displacement <= mech_2_h_displacement;
                    mech_2_cnt_h <= 0;
                end
            end else begin
                    mech_2_h_displacement <= mech_2_h_displacement;
                    mech_2_cnt_h <= 0;         
            end
        end
    end

    always @(posedge clk) begin
        if(rst || !en) begin
            player_horizontal_displacement <= 0;
            player_vertical_displacement <= 0;
            player_cnt_horizontal <= 25'b0;
            player_cnt_vertical <= 25'b0;
        end else begin
            if(player_state == 4'd6) begin
                player_vertical_displacement <= player_vertical_displacement;
                player_horizontal_displacement <= player_horizontal_displacement;
                player_cnt_horizontal <= 0;
            end
            else if(player_state == 4'd9) begin
                if(player_jump == 0) begin
                    player_vertical_displacement <= player_vertical_displacement;
                    player_cnt_vertical <= 0;
                end
                else if(player_jump == 1) begin
                    if(player_cnt_vertical < 25'd2000000) begin
                        player_cnt_vertical <= player_cnt_vertical + 1;
                        player_vertical_displacement <= player_vertical_displacement; 
                    end
                    else begin
                        player_vertical_displacement <= player_vertical_displacement + 1;
                        player_cnt_vertical <= 0;
                    end
                end
                else if(player_jump == 2) begin
                    if(player_cnt_vertical < 25'd2000000) begin
                        player_cnt_vertical <= player_cnt_vertical + 1;
                        player_vertical_displacement <= player_vertical_displacement; 
                    end
                    else begin
                        if(player_vertical_displacement > 0) player_vertical_displacement <= player_vertical_displacement - 1;
                        else player_vertical_displacement <= player_vertical_displacement;
                        player_cnt_vertical <= 0;
                    end
                end
            end
            else if(player_state == 4'd7) begin
                if(player_cnt_horizontal < 25'd1500000) begin
                    player_cnt_horizontal <= player_cnt_horizontal + 1;
                    player_horizontal_displacement <= player_horizontal_displacement;
                end 
                else begin
                    if(player_horizontal_displacement <= 282 && !p1_collision) begin
                        player_horizontal_displacement <= player_horizontal_displacement + 1;
                        player_cnt_horizontal <= 0;
                    end else begin
                        player_horizontal_displacement <= player_horizontal_displacement;
                        player_cnt_horizontal <= 0;                   
                    end
                end
                if(player_jump == 0) begin
                    player_vertical_displacement <= player_vertical_displacement;
                    player_cnt_vertical <= 0;
                end
                else if(player_jump == 1) begin
                    if(player_cnt_vertical < 25'd2000000) begin
                        player_cnt_vertical <= player_cnt_vertical + 1;
                        player_vertical_displacement <= player_vertical_displacement; 
                    end
                    else begin
                        player_vertical_displacement <= player_vertical_displacement + 1;
                        player_cnt_vertical <= 0;
                    end
                end
                else if(player_jump == 2) begin
                    if(player_cnt_vertical < 25'd2000000) begin
                        player_cnt_vertical <= player_cnt_vertical + 1;
                        player_vertical_displacement <= player_vertical_displacement; 
                    end
                    else begin
                        if(player_vertical_displacement > 0) player_vertical_displacement <= player_vertical_displacement - 1;
                        else player_vertical_displacement <= player_vertical_displacement;
                        player_cnt_vertical <= 0;
                    end
                end
            end
            else if(player_state == 4'd8) begin
                if(player_cnt_horizontal < 25'd1500000) begin
                    player_cnt_horizontal <= player_cnt_horizontal + 1;
                    player_horizontal_displacement <= player_horizontal_displacement;
                end else begin
                    if(player_horizontal_displacement >= 1 && !p1_collision) begin
                        player_horizontal_displacement <= player_horizontal_displacement - 1;
                        player_cnt_horizontal <= 0;
                    end else begin
                        player_horizontal_displacement <= player_horizontal_displacement;
                        player_cnt_horizontal <= 0;                   
                    end         
                end
                if(player_jump == 0) begin
                    player_vertical_displacement <= player_vertical_displacement;
                    player_cnt_vertical <= 0;
                end
                else if(player_jump == 1) begin
                    if(player_cnt_vertical < 25'd2000000) begin
                        player_cnt_vertical <= player_cnt_vertical + 1;
                        player_vertical_displacement <= player_vertical_displacement; 
                    end
                    else begin
                        player_vertical_displacement <= player_vertical_displacement + 1;
                        player_cnt_vertical <= 0;
                    end
                end
                else if(player_jump == 2) begin
                    if(player_cnt_vertical < 25'd2000000) begin
                        player_cnt_vertical <= player_cnt_vertical + 1;
                        player_vertical_displacement <= player_vertical_displacement; 
                    end
                    else begin
                        if(player_vertical_displacement > 0) player_vertical_displacement <= player_vertical_displacement - 1;
                        else player_vertical_displacement <= player_vertical_displacement;
                        player_cnt_vertical <= 0;
                    end
                end
            end
            else begin
                player_horizontal_displacement <= player_horizontal_displacement;
                player_vertical_displacement <= player_vertical_displacement;
            end
        end
    end

    always @(posedge clk) begin
        if(rst || !en) begin
            player2_h_dis <= 0;
            player2_v_dis <= 0;
            player2_cnt_h <= 0;
            player2_cnt_v <= 0;
        end else begin
            if(player2_state == 4'd6) begin
                player2_h_dis <= player2_h_dis;
                player2_v_dis <= player2_v_dis;
                player2_cnt_h <= 0;
            end
            else if(player2_state == 4'd9) begin
                if(player2_jump == 0) begin
                    player2_v_dis <= player2_v_dis;
                    player2_cnt_v <= 0;
                end
                else if(player2_jump == 1) begin
                    if(player2_cnt_v < 25'd2000000) begin
                        player2_cnt_v <= player2_cnt_v + 1;
                        player2_v_dis <= player2_v_dis; 
                    end
                    else begin
                        player2_v_dis <= player2_v_dis + 1;
                        player2_cnt_v <= 0;
                    end
                end
                else if(player2_jump == 2) begin
                    if(player2_cnt_v < 25'd2000000) begin
                        player2_cnt_v <= player2_cnt_v + 1;
                        player2_v_dis <= player2_v_dis; 
                    end
                    else begin
                        if(player2_v_dis > 0) player2_v_dis <= player2_v_dis - 1;
                        else player2_v_dis <= player2_v_dis;
                        player2_cnt_v <= 0;
                    end
                end
            end
            else if(player2_state == 4'd7) begin
                if(player2_cnt_h < 25'd1500000) begin
                    player2_cnt_h <= player2_cnt_h + 1;
                    player2_h_dis <= player2_h_dis;
                end 
                else begin
                    if(player2_h_dis <= 282 && !p2_collision) begin
                        player2_h_dis <= player2_h_dis + 1;
                        player2_cnt_h <= 0;
                    end else begin
                        player2_h_dis <= player2_h_dis;
                        player2_cnt_h <= 0;                   
                    end
                end
                if(player2_jump == 0) begin
                    player2_v_dis <= player2_v_dis;
                    player2_cnt_v <= 0;
                end
                else if(player2_jump == 1) begin
                    if(player2_cnt_v < 25'd2000000) begin
                        player2_cnt_v <= player2_cnt_v + 1;
                        player2_v_dis <= player2_v_dis; 
                    end
                    else begin
                        player2_v_dis <= player2_v_dis + 1;
                        player2_cnt_v <= 0;
                    end
                end
                else if(player2_jump == 2) begin
                    if(player2_cnt_v < 25'd2000000) begin
                        player2_cnt_v <= player2_cnt_v + 1;
                        player2_v_dis <= player2_v_dis; 
                    end
                    else begin
                        if(player2_v_dis > 0) player2_v_dis <= player2_v_dis - 1;
                        else player2_v_dis <= player2_v_dis;
                        player2_cnt_v <= 0;
                    end
                end
            end
            else if(player2_state == 4'd8) begin
                if(player2_cnt_h < 25'd1500000) begin
                    player2_cnt_h <= player2_cnt_h + 1;
                    player2_h_dis <= player2_h_dis;
                end else begin
                    if(player2_h_dis >= 1 && !p2_collision) begin
                        player2_h_dis <= player2_h_dis - 1;
                        player2_cnt_h <= 0;
                    end else begin
                        player2_h_dis <= player2_h_dis;
                        player2_cnt_h <= 0;                   
                    end         
                end
                if(player2_jump == 0) begin
                    player2_v_dis <= player2_v_dis;
                    player2_cnt_v <= 0;
                end
                else if(player2_jump == 1) begin
                    if(player2_cnt_v < 25'd2000000) begin
                        player2_cnt_v <= player2_cnt_v + 1;
                        player2_v_dis <= player2_v_dis; 
                    end
                    else begin
                        player2_v_dis <= player2_v_dis + 1;
                        player2_cnt_v <= 0;
                    end
                end
                else if(player2_jump == 2) begin
                    if(player2_cnt_v < 25'd2000000) begin
                        player2_cnt_v <= player2_cnt_v + 1;
                        player2_v_dis <= player2_v_dis; 
                    end
                    else begin
                        if(player2_v_dis > 0) player2_v_dis <= player2_v_dis - 1;
                        else player2_v_dis <= player2_v_dis;
                        player2_cnt_v <= 0;
                    end
                end
            end
            else begin
                player2_h_dis <= player2_h_dis;
                player2_v_dis <= player2_v_dis;
            end
        end
    end

endmodule
