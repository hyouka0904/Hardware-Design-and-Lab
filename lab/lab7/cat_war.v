`define silence   32'd1
`define low_low_do   32'd66
`define low_low_re   32'd74
`define low_low_mi   32'd83
`define low_low_fa   32'd87
`define low_low_so   32'd98
`define low_low_la   32'd110
`define low_low_si   32'd124
`define low_do   32'd131
`define low_re   32'd147
`define low_mi   32'd165
`define low_fa   32'd174
`define low_so   32'd196
`define low_la   32'd220
`define low_si   32'd247
`define do   32'd262   
`define re   32'd294
`define mi   32'd330
`define fa   32'd349
`define so   32'd392   
`define la   32'd440
`define si   32'd494   
`define high_do  32'd524   
`define high_re  32'd588   
`define high_mi  32'd660   
`define high_fa  32'd698   
`define high_so  32'd784   
`define high_la  32'd880
`define high_si  32'd988
module cat_war (
	input [11:0] ibeatNum,
	input en,
	output reg [31:0] toneL,
    output reg [31:0] toneR
);
    always @* begin
        if(en == 1) begin
            case(ibeatNum)
                12'd0: toneR = `silence;      12'd1: toneR = `silence;      12'd2: toneR = `silence;      12'd3: toneR = `silence;      
                12'd4: toneR = `silence;      12'd5: toneR = `silence;      12'd6: toneR = `silence;      12'd7: toneR = `silence;
                12'd8: toneR = `silence;      12'd9: toneR = `silence;      12'd10: toneR = `silence;      12'd11: toneR = `silence;
                12'd12: toneR = `silence;      12'd13: toneR = `silence;      12'd14: toneR = `silence;      12'd15: toneR = `silence;
                12'd16: toneR = `mi;      12'd17: toneR = `mi;      12'd18: toneR = `mi;      12'd19: toneR = `mi;
                12'd20: toneR = `mi;      12'd21: toneR = `mi;      12'd22: toneR = `mi;      12'd23: toneR = `mi;      
                12'd24: toneR = `mi;      12'd25: toneR = `mi;      12'd26: toneR = `mi;      12'd27: toneR = `silence;
                12'd28: toneR = `mi;      12'd29: toneR = `mi;      12'd30: toneR = `mi;      12'd31: toneR = `silence;
                12'd32: toneR = `mi;      12'd33: toneR = `mi;      12'd34: toneR = `mi;      12'd35: toneR = `mi;
                12'd36: toneR = `mi;      12'd37: toneR = `mi;      12'd38: toneR = `mi;      12'd39: toneR = `mi;
                12'd40: toneR = `mi;      12'd41: toneR = `mi;      12'd42: toneR = `mi;      12'd43: toneR = `silence;
                12'd44: toneR = `mi;      12'd45: toneR = `mi;      12'd46: toneR = `mi;      12'd47: toneR = `mi;      
                12'd48: toneR = `do;      12'd49: toneR = `do;      12'd50: toneR = `do;      12'd51: toneR = `do;
                12'd52: toneR = `do;      12'd53: toneR = `do;      12'd54: toneR = `do;      12'd55: toneR = `do;
                12'd56: toneR = `do;      12'd57: toneR = `do;      12'd58: toneR = `do;      12'd59: toneR = `do;
                12'd60: toneR = `do;      12'd61: toneR = `do;      12'd62: toneR = `do;      12'd63: toneR = `do;      
                12'd64: toneR = `mi;      12'd65: toneR = `mi;      12'd66: toneR = `mi;      12'd67: toneR = `mi;
                12'd68: toneR = `mi;      12'd69: toneR = `mi;      12'd70: toneR = `mi;      12'd71: toneR = `mi;
                12'd72: toneR = `mi;      12'd73: toneR = `mi;      12'd74: toneR = `mi;      12'd75: toneR = `mi;      
                12'd76: toneR = `mi;      12'd77: toneR = `mi;      12'd78: toneR = `mi;      12'd79: toneR = `mi;
                12'd80: toneR = `la;      12'd81: toneR = `la;      12'd82: toneR = `la;      12'd83: toneR = `la;
                12'd84: toneR = `la;      12'd85: toneR = `la;      12'd86: toneR = `la;      12'd87: toneR = `la;
                12'd88: toneR = `la;      12'd89: toneR = `la;      12'd90: toneR = `la;      12'd91: toneR = `la;      
                12'd92: toneR = `la;      12'd93: toneR = `la;      12'd94: toneR = `la;      12'd95: toneR = `la;
                12'd96: toneR = `so;      12'd97: toneR = `so;      12'd98: toneR = `so;      12'd99: toneR = `so;
                12'd100: toneR = `so;      12'd101: toneR = `so;      12'd102: toneR = `so;      12'd103: toneR = `so;
                12'd104: toneR = `so;      12'd105: toneR = `so;      12'd106: toneR = `so;      12'd107: toneR = `so;
                12'd108: toneR = `so;      12'd109: toneR = `so;      12'd110: toneR = `so;      12'd111: toneR = `so;      
                12'd112: toneR = `so;      12'd113: toneR = `so;      12'd114: toneR = `so;      12'd115: toneR = `so;
                12'd116: toneR = `so;      12'd117: toneR = `so;      12'd118: toneR = `so;      12'd119: toneR = `so;
                12'd120: toneR = `so;      12'd121: toneR = `so;      12'd122: toneR = `so;      12'd123: toneR = `so;
                12'd124: toneR = `so;      12'd125: toneR = `so;      12'd126: toneR = `so;      12'd127: toneR = `so;      
                12'd128: toneR = `silence;      12'd129: toneR = `silence;      12'd130: toneR = `silence;      12'd131: toneR = `silence;
                12'd132: toneR = `silence;      12'd133: toneR = `silence;      12'd134: toneR = `silence;      12'd135: toneR = `silence;
                12'd136: toneR = `fa;      12'd137: toneR = `fa;      12'd138: toneR = `fa;      12'd139: toneR = `fa;
                12'd140: toneR = `fa;      12'd141: toneR = `fa;      12'd142: toneR = `fa;      12'd143: toneR = `fa;      
                12'd144: toneR = `fa;      12'd145: toneR = `fa;      12'd146: toneR = `fa;      12'd147: toneR = `fa;
                12'd148: toneR = `fa;      12'd149: toneR = `fa;      12'd150: toneR = `fa;      12'd151: toneR = `fa;
                12'd152: toneR = `fa;      12'd153: toneR = `fa;      12'd154: toneR = `fa;      12'd155: toneR = `fa;
                12'd156: toneR = `fa;      12'd157: toneR = `fa;      12'd158: toneR = `fa;      12'd159: toneR = `silence;
                12'd160: toneR = `fa;      12'd161: toneR = `fa;      12'd162: toneR = `fa;      12'd163: toneR = `fa;
                12'd164: toneR = `fa;      12'd165: toneR = `fa;      12'd166: toneR = `fa;      12'd167: toneR = `fa;
                12'd168: toneR = `fa;      12'd169: toneR = `fa;      12'd170: toneR = `fa;      12'd171: toneR = `fa;
                12'd172: toneR = `fa;      12'd173: toneR = `fa;      12'd174: toneR = `fa;      12'd175: toneR = `fa;      
                12'd176: toneR = `re;      12'd177: toneR = `re;      12'd178: toneR = `re;      12'd179: toneR = `re;
                12'd180: toneR = `re;      12'd181: toneR = `re;      12'd182: toneR = `re;      12'd183: toneR = `re;
                12'd184: toneR = `re;      12'd185: toneR = `re;      12'd186: toneR = `re;      12'd187: toneR = `re;
                12'd188: toneR = `re;      12'd189: toneR = `re;      12'd190: toneR = `re;      12'd191: toneR = `re;      
                12'd192: toneR = `do;      12'd193: toneR = `do;      12'd194: toneR = `do;      12'd195: toneR = `do;
                12'd196: toneR = `do;      12'd197: toneR = `do;      12'd198: toneR = `do;      12'd199: toneR = `do;
                12'd200: toneR = `do;      12'd201: toneR = `do;      12'd202: toneR = `do;      12'd203: toneR = `do;
                12'd204: toneR = `do;      12'd205: toneR = `do;      12'd206: toneR = `do;      12'd207: toneR = `do;
                12'd208: toneR = `mi;      12'd209: toneR = `mi;      12'd210: toneR = `mi;      12'd211: toneR = `mi;      
                12'd212: toneR = `mi;      12'd213: toneR = `mi;      12'd214: toneR = `mi;      12'd215: toneR = `mi;
                12'd216: toneR = `mi;      12'd217: toneR = `mi;      12'd218: toneR = `mi;      12'd219: toneR = `mi;
                12'd220: toneR = `mi;      12'd221: toneR = `mi;      12'd222: toneR = `mi;      12'd223: toneR = `mi;
                12'd224: toneR = `low_so;      12'd225: toneR = `low_so;      12'd226: toneR = `low_so;      12'd227: toneR = `low_so;
                12'd228: toneR = `low_so;      12'd229: toneR = `low_so;      12'd230: toneR = `low_so;      12'd231: toneR = `low_so;
                12'd232: toneR = `low_so;      12'd233: toneR = `low_so;      12'd234: toneR = `low_so;      12'd235: toneR = `low_so;      
                12'd236: toneR = `low_so;      12'd237: toneR = `low_so;      12'd238: toneR = `low_so;      12'd239: toneR = `low_so;
                12'd240: toneR = `low_so;      12'd241: toneR = `low_so;      12'd242: toneR = `low_so;      12'd243: toneR = `low_so;
                12'd244: toneR = `low_so;      12'd245: toneR = `low_so;      12'd246: toneR = `low_so;      12'd247: toneR = `low_so;
                12'd248: toneR = `low_so;      12'd249: toneR = `low_so;      12'd250: toneR = `low_so;      12'd251: toneR = `low_so;
                12'd252: toneR = `low_so;      12'd253: toneR = `low_so;      12'd254: toneR = `low_so;      12'd255: toneR = `low_so;
                12'd256: toneR = `silence;      12'd257: toneR = `silence;      12'd258: toneR = `silence;      12'd259: toneR = `silence;      
                12'd260: toneR = `silence;      12'd261: toneR = `silence;      12'd262: toneR = `silence;      12'd263: toneR = `silence;
                12'd264: toneR = `silence;      12'd265: toneR = `silence;      12'd266: toneR = `silence;      12'd267: toneR = `silence;
                12'd268: toneR = `silence;      12'd269: toneR = `silence;      12'd270: toneR = `silence;      12'd271: toneR = `silence;
                12'd272: toneR = `mi;      12'd273: toneR = `mi;      12'd274: toneR = `mi;      12'd275: toneR = `mi;
                12'd276: toneR = `mi;      12'd277: toneR = `mi;      12'd278: toneR = `mi;      12'd279: toneR = `mi;
                12'd280: toneR = `mi;      12'd281: toneR = `mi;      12'd282: toneR = `mi;      12'd283: toneR = `mi;      
                12'd284: toneR = `mi;      12'd285: toneR = `mi;      12'd286: toneR = `mi;      12'd287: toneR = `silence;
                12'd288: toneR = `mi;      12'd289: toneR = `mi;      12'd290: toneR = `mi;      12'd291: toneR = `mi;
                12'd292: toneR = `mi;      12'd293: toneR = `mi;      12'd294: toneR = `mi;      12'd295: toneR = `mi;
                12'd296: toneR = `mi;      12'd297: toneR = `mi;      12'd298: toneR = `mi;      12'd299: toneR = `silence;
                12'd300: toneR = `mi;      12'd301: toneR = `mi;      12'd302: toneR = `mi;      12'd303: toneR = `mi;      
                12'd304: toneR = `do;      12'd305: toneR = `do;      12'd306: toneR = `do;      12'd307: toneR = `do;
                12'd308: toneR = `do;      12'd309: toneR = `do;      12'd310: toneR = `do;      12'd311: toneR = `do;
                12'd312: toneR = `do;      12'd313: toneR = `do;      12'd314: toneR = `do;      12'd315: toneR = `do;
                12'd316: toneR = `do;      12'd317: toneR = `do;      12'd318: toneR = `do;      12'd319: toneR = `do;
                12'd320: toneR = `mi;      12'd321: toneR = `mi;      12'd322: toneR = `mi;      12'd323: toneR = `mi;      
                12'd324: toneR = `mi;      12'd325: toneR = `mi;      12'd326: toneR = `mi;      12'd327: toneR = `mi;
                12'd328: toneR = `mi;      12'd329: toneR = `mi;      12'd330: toneR = `mi;      12'd331: toneR = `mi;
                12'd332: toneR = `mi;      12'd333: toneR = `mi;      12'd334: toneR = `mi;      12'd335: toneR = `mi;
                12'd336: toneR = `la;      12'd337: toneR = `la;      12'd338: toneR = `la;      12'd339: toneR = `la;      
                12'd340: toneR = `la;      12'd341: toneR = `la;      12'd342: toneR = `la;      12'd343: toneR = `la;
                12'd344: toneR = `la;      12'd345: toneR = `la;      12'd346: toneR = `la;      12'd347: toneR = `la;
                12'd348: toneR = `la;      12'd349: toneR = `la;      12'd350: toneR = `la;      12'd351: toneR = `la;
                12'd352: toneR = `so;      12'd353: toneR = `so;      12'd354: toneR = `so;      12'd355: toneR = `so;
                12'd356: toneR = `so;      12'd357: toneR = `so;      12'd358: toneR = `so;      12'd359: toneR = `so;      
                12'd360: toneR = `so;      12'd361: toneR = `so;      12'd362: toneR = `so;      12'd363: toneR = `so;
                12'd364: toneR = `so;      12'd365: toneR = `so;      12'd366: toneR = `so;      12'd367: toneR = `so;
                12'd368: toneR = `so;      12'd369: toneR = `so;      12'd370: toneR = `so;      12'd371: toneR = `so;
                12'd372: toneR = `so;      12'd373: toneR = `so;      12'd374: toneR = `so;      12'd375: toneR = `so;
                12'd376: toneR = `so;      12'd377: toneR = `so;      12'd378: toneR = `so;      12'd379: toneR = `so;      
                12'd380: toneR = `so;      12'd381: toneR = `so;      12'd382: toneR = `so;      12'd383: toneR = `so;
                12'd384: toneR = `silence;      12'd385: toneR = `silence;      12'd386: toneR = `silence;      12'd387: toneR = `silence;
                12'd388: toneR = `silence;      12'd389: toneR = `silence;      12'd390: toneR = `silence;      12'd391: toneR = `silence;
                12'd392: toneR = `silence;      12'd393: toneR = `silence;      12'd394: toneR = `silence;      12'd395: toneR = `silence;
                12'd396: toneR = `silence;      12'd397: toneR = `silence;      12'd398: toneR = `silence;      12'd399: toneR = `silence;      
                12'd400: toneR = `fa;      12'd401: toneR = `fa;      12'd402: toneR = `fa;      12'd403: toneR = `fa;
                12'd404: toneR = `fa;      12'd405: toneR = `fa;      12'd406: toneR = `fa;      12'd407: toneR = `fa;
                12'd408: toneR = `fa;      12'd409: toneR = `fa;      12'd410: toneR = `fa;      12'd411: toneR = `silence;
                12'd412: toneR = `fa;      12'd413: toneR = `fa;      12'd414: toneR = `fa;      12'd415: toneR = `fa;
                12'd416: toneR = `so;      12'd417: toneR = `so;      12'd418: toneR = `so;      12'd419: toneR = `so;      
                12'd420: toneR = `so;      12'd421: toneR = `so;      12'd422: toneR = `so;      12'd423: toneR = `so;
                12'd424: toneR = `so;      12'd425: toneR = `so;      12'd426: toneR = `so;      12'd427: toneR = `so;
                12'd428: toneR = `so;      12'd429: toneR = `so;      12'd430: toneR = `so;      12'd431: toneR = `so;
                12'd432: toneR = `si;      12'd433: toneR = `si;      12'd434: toneR = `si;      12'd435: toneR = `si;
                12'd436: toneR = `si;      12'd437: toneR = `si;      12'd438: toneR = `si;      12'd439: toneR = `si;      
                12'd440: toneR = `si;      12'd441: toneR = `si;      12'd442: toneR = `si;      12'd443: toneR = `si;
                12'd444: toneR = `si;      12'd445: toneR = `si;      12'd446: toneR = `si;      12'd447: toneR = `si;
                12'd448: toneR = `high_do;      12'd449: toneR = `high_do;      12'd450: toneR = `high_do;      12'd451: toneR = `high_do;
                12'd452: toneR = `high_do;      12'd453: toneR = `high_do;      12'd454: toneR = `high_do;      12'd455: toneR = `high_do;
                12'd456: toneR = `high_do;      12'd457: toneR = `high_do;      12'd458: toneR = `high_do;      12'd459: toneR = `high_do;      
                12'd460: toneR = `high_do;      12'd461: toneR = `high_do;      12'd462: toneR = `high_do;      12'd463: toneR = `high_do;
                12'd464: toneR = `high_do;      12'd465: toneR = `high_do;      12'd466: toneR = `high_do;      12'd467: toneR = `high_do;
                12'd468: toneR = `high_do;      12'd469: toneR = `high_do;      12'd470: toneR = `high_do;      12'd471: toneR = `high_do;
                12'd472: toneR = `high_do;      12'd473: toneR = `high_do;      12'd474: toneR = `high_do;      12'd475: toneR = `high_do;      
                12'd476: toneR = `high_do;      12'd477: toneR = `high_do;      12'd478: toneR = `high_do;      12'd479: toneR = `high_do;
                12'd480: toneR = `high_do;      12'd481: toneR = `high_do;      12'd482: toneR = `high_do;      12'd483: toneR = `high_do;
                12'd484: toneR = `high_do;      12'd485: toneR = `high_do;      12'd486: toneR = `high_do;      12'd487: toneR = `high_do;
                12'd488: toneR = `high_do;      12'd489: toneR = `high_do;      12'd490: toneR = `high_do;      12'd491: toneR = `high_do;
                12'd492: toneR = `high_do;      12'd493: toneR = `high_do;      12'd494: toneR = `high_do;      12'd495: toneR = `high_do;      
                12'd496: toneR = `high_do;      12'd497: toneR = `high_do;      12'd498: toneR = `high_do;      12'd499: toneR = `high_do;
                12'd500: toneR = `high_do;      12'd501: toneR = `high_do;      12'd502: toneR = `high_do;      12'd503: toneR = `high_do;
                12'd504: toneR = `high_do;      12'd505: toneR = `high_do;      12'd506: toneR = `high_do;      12'd507: toneR = `high_do;
                12'd508: toneR = `high_do;      12'd509: toneR = `high_do;      12'd510: toneR = `high_do;      12'd511: toneR = `high_do;
                default: toneR = `silence;
            endcase
        end else begin
            toneR = `silence;
        end
    end

    always @* begin
        if(en == 1) begin
            case (ibeatNum)
                12'd0: toneL = `low_do;      12'd1: toneL = `low_do;      12'd2: toneL = `low_do;      12'd3: toneL = `low_do;      
                12'd4: toneL = `low_do;      12'd5: toneL = `low_do;      12'd6: toneL = `low_do;      12'd7: toneL = `low_do;
                12'd8: toneL = `low_do;      12'd9: toneL = `low_do;      12'd10: toneL = `low_do;      12'd11: toneL = `low_do;
                12'd12: toneL = `low_do;      12'd13: toneL = `low_do;      12'd14: toneL = `low_do;      12'd15: toneL = `low_do;
                12'd16: toneL = `low_so;      12'd17: toneL = `low_so;      12'd18: toneL = `low_so;      12'd19: toneL = `low_so;
                12'd20: toneL = `low_so;      12'd21: toneL = `low_so;      12'd22: toneL = `low_so;      12'd23: toneL = `low_so;
                12'd24: toneL = `low_so;      12'd25: toneL = `low_so;      12'd26: toneL = `low_so;      12'd27: toneL = `low_so;      
                12'd28: toneL = `low_so;      12'd29: toneL = `low_so;      12'd30: toneL = `low_so;      12'd31: toneL = `low_so;
                12'd32: toneL = `low_low_so;      12'd33: toneL = `low_low_so;      12'd34: toneL = `low_low_so;      12'd35: toneL = `low_low_so;      
                12'd36: toneL = `low_low_so;      12'd37: toneL = `low_low_so;      12'd38: toneL = `low_low_so;      12'd39: toneL = `low_low_so;
                12'd40: toneL = `low_low_so;      12'd41: toneL = `low_low_so;      12'd42: toneL = `low_low_so;      12'd43: toneL = `low_low_so;
                12'd44: toneL = `low_low_so;      12'd45: toneL = `low_low_so;      12'd46: toneL = `low_low_so;      12'd47: toneL = `low_low_so;      
                12'd48: toneL = `low_so;      12'd49: toneL = `low_so;      12'd50: toneL = `low_so;      12'd51: toneL = `low_so;
                12'd52: toneL = `low_so;      12'd53: toneL = `low_so;      12'd54: toneL = `low_so;      12'd55: toneL = `low_so;
                12'd56: toneL = `low_so;      12'd57: toneL = `low_so;      12'd58: toneL = `low_so;      12'd59: toneL = `low_so;
                12'd60: toneL = `low_so;      12'd61: toneL = `low_so;      12'd62: toneL = `low_so;      12'd63: toneL = `low_so;
                12'd64: toneL = `low_do;      12'd65: toneL = `low_do;      12'd66: toneL = `low_do;      12'd67: toneL = `low_do;      
                12'd68: toneL = `low_do;      12'd69: toneL = `low_do;      12'd70: toneL = `low_do;      12'd71: toneL = `low_do;
                12'd72: toneL = `low_do;      12'd73: toneL = `low_do;      12'd74: toneL = `low_do;      12'd75: toneL = `low_do;
                12'd76: toneL = `low_do;      12'd77: toneL = `low_do;      12'd78: toneL = `low_do;      12'd79: toneL = `low_do;
                12'd80: toneL = `low_so;      12'd81: toneL = `low_so;      12'd82: toneL = `low_so;      12'd83: toneL = `low_so;
                12'd84: toneL = `low_so;      12'd85: toneL = `low_so;      12'd86: toneL = `low_so;      12'd87: toneL = `low_so;      
                12'd88: toneL = `low_so;      12'd89: toneL = `low_so;      12'd90: toneL = `low_so;      12'd91: toneL = `low_so;
                12'd92: toneL = `low_so;      12'd93: toneL = `low_so;      12'd94: toneL = `low_so;      12'd95: toneL = `low_so;
                12'd96: toneL = `low_low_so;      12'd97: toneL = `low_low_so;      12'd98: toneL = `low_low_so;      12'd99: toneL = `low_low_so;
                12'd100: toneL = `low_low_so;      12'd101: toneL = `low_low_so;      12'd102: toneL = `low_low_so;      12'd103: toneL = `low_low_so;
                12'd104: toneL = `low_low_so;      12'd105: toneL = `low_low_so;      12'd106: toneL = `low_low_so;      12'd107: toneL = `low_low_so;      
                12'd108: toneL = `low_low_so;      12'd109: toneL = `low_low_so;      12'd110: toneL = `low_low_so;      12'd111: toneL = `low_low_so;
                12'd112: toneL = `low_so;      12'd113: toneL = `low_so;      12'd114: toneL = `low_so;      12'd115: toneL = `low_so;
                12'd116: toneL = `low_so;      12'd117: toneL = `low_so;      12'd118: toneL = `low_so;      12'd119: toneL = `low_so;
                12'd120: toneL = `low_so;      12'd121: toneL = `low_so;      12'd122: toneL = `low_so;      12'd123: toneL = `low_so;
                12'd124: toneL = `low_so;      12'd125: toneL = `low_so;      12'd126: toneL = `low_so;      12'd127: toneL = `low_so;
                12'd128: toneL = `low_low_fa;      12'd129: toneL = `low_low_fa;      12'd130: toneL = `low_low_fa;      12'd131: toneL = `low_low_fa;      
                12'd132: toneL = `low_low_fa;      12'd133: toneL = `low_low_fa;      12'd134: toneL = `low_low_fa;      12'd135: toneL = `low_low_fa;
                12'd136: toneL = `low_low_fa;      12'd137: toneL = `low_low_fa;      12'd138: toneL = `low_low_fa;      12'd139: toneL = `low_low_fa;
                12'd140: toneL = `low_low_fa;      12'd141: toneL = `low_low_fa;      12'd142: toneL = `low_low_fa;      12'd143: toneL = `low_low_fa;
                12'd144: toneL = `low_fa;      12'd145: toneL = `low_fa;      12'd146: toneL = `low_fa;      12'd147: toneL = `low_fa;
                12'd148: toneL = `low_fa;      12'd149: toneL = `low_fa;      12'd150: toneL = `low_fa;      12'd151: toneL = `low_fa;      
                12'd152: toneL = `low_fa;      12'd153: toneL = `low_fa;      12'd154: toneL = `low_fa;      12'd155: toneL = `low_fa;
                12'd156: toneL = `low_fa;      12'd157: toneL = `low_fa;      12'd158: toneL = `low_fa;      12'd159: toneL = `low_fa;
                12'd160: toneL = `low_low_fa;      12'd161: toneL = `low_low_fa;      12'd162: toneL = `low_low_fa;      12'd163: toneL = `low_low_fa;
                12'd164: toneL = `low_low_fa;      12'd165: toneL = `low_low_fa;      12'd166: toneL = `low_low_fa;      12'd167: toneL = `low_low_fa;
                12'd168: toneL = `low_low_fa;      12'd169: toneL = `low_low_fa;      12'd170: toneL = `low_low_fa;      12'd171: toneL = `low_low_fa;
                12'd172: toneL = `low_low_fa;      12'd173: toneL = `low_low_fa;      12'd174: toneL = `low_low_fa;      12'd175: toneL = `low_low_fa;      
                12'd176: toneL = `low_fa;      12'd177: toneL = `low_fa;      12'd178: toneL = `low_fa;      12'd179: toneL = `low_fa;
                12'd180: toneL = `low_fa;      12'd181: toneL = `low_fa;      12'd182: toneL = `low_fa;      12'd183: toneL = `low_fa;
                12'd184: toneL = `low_fa;      12'd185: toneL = `low_fa;      12'd186: toneL = `low_fa;      12'd187: toneL = `low_fa;
                12'd188: toneL = `low_fa;      12'd189: toneL = `low_fa;      12'd190: toneL = `low_fa;      12'd191: toneL = `low_fa;
                12'd192: toneL = `low_do;      12'd193: toneL = `low_do;      12'd194: toneL = `low_do;      12'd195: toneL = `low_do;      
                12'd196: toneL = `low_do;      12'd197: toneL = `low_do;      12'd198: toneL = `low_do;      12'd199: toneL = `low_do;
                12'd200: toneL = `low_do;      12'd201: toneL = `low_do;      12'd202: toneL = `low_do;      12'd203: toneL = `low_do;
                12'd204: toneL = `low_do;      12'd205: toneL = `low_do;      12'd206: toneL = `low_do;      12'd207: toneL = `low_do;
                12'd208: toneL = `low_low_so;      12'd209: toneL = `low_low_so;      12'd210: toneL = `low_low_so;      12'd211: toneL = `low_low_so;
                12'd212: toneL = `low_low_so;      12'd213: toneL = `low_low_so;      12'd214: toneL = `low_low_so;      12'd215: toneL = `low_low_so;      
                12'd216: toneL = `low_low_so;      12'd217: toneL = `low_low_so;      12'd218: toneL = `low_low_so;      12'd219: toneL = `low_low_so;
                12'd220: toneL = `low_low_so;      12'd221: toneL = `low_low_so;      12'd222: toneL = `low_low_so;      12'd223: toneL = `low_low_so;
                12'd224: toneL = `low_low_la;      12'd225: toneL = `low_low_la;      12'd226: toneL = `low_low_la;      12'd227: toneL = `low_low_la;
                12'd228: toneL = `low_low_la;      12'd229: toneL = `low_low_la;      12'd230: toneL = `low_low_la;      12'd231: toneL = `low_low_la;      
                12'd232: toneL = `low_low_la;      12'd233: toneL = `low_low_la;      12'd234: toneL = `low_low_la;      12'd235: toneL = `low_low_la;
                12'd236: toneL = `low_low_la;      12'd237: toneL = `low_low_la;      12'd238: toneL = `low_low_la;      12'd239: toneL = `low_low_la;
                12'd240: toneL = `low_low_si;      12'd241: toneL = `low_low_si;      12'd242: toneL = `low_low_si;      12'd243: toneL = `low_low_si;
                12'd244: toneL = `low_low_si;      12'd245: toneL = `low_low_si;      12'd246: toneL = `low_low_si;      12'd247: toneL = `low_low_si;      
                12'd248: toneL = `low_low_si;      12'd249: toneL = `low_low_si;      12'd250: toneL = `low_low_si;      12'd251: toneL = `low_low_si;
                12'd252: toneL = `low_low_si;      12'd253: toneL = `low_low_si;      12'd254: toneL = `low_low_si;      12'd255: toneL = `low_low_si;
                12'd256: toneL = `low_do;      12'd257: toneL = `low_do;      12'd258: toneL = `low_do;      12'd259: toneL = `low_do;
                12'd260: toneL = `low_do;      12'd261: toneL = `low_do;      12'd262: toneL = `low_do;      12'd263: toneL = `low_do;      
                12'd264: toneL = `low_do;      12'd265: toneL = `low_do;      12'd266: toneL = `low_do;      12'd267: toneL = `low_do;
                12'd268: toneL = `low_do;      12'd269: toneL = `low_do;      12'd270: toneL = `low_do;      12'd271: toneL = `low_do;
                12'd272: toneL = `low_so;      12'd273: toneL = `low_so;      12'd274: toneL = `low_so;      12'd275: toneL = `low_so;
                12'd276: toneL = `low_so;      12'd277: toneL = `low_so;      12'd278: toneL = `low_so;      12'd279: toneL = `low_so;      
                12'd280: toneL = `low_so;      12'd281: toneL = `low_so;      12'd282: toneL = `low_so;      12'd283: toneL = `low_so;
                12'd284: toneL = `low_so;      12'd285: toneL = `low_so;      12'd286: toneL = `low_so;      12'd287: toneL = `low_so;
                12'd288: toneL = `low_low_so;      12'd289: toneL = `low_low_so;      12'd290: toneL = `low_low_so;      12'd291: toneL = `low_low_so;
                12'd292: toneL = `low_low_so;      12'd293: toneL = `low_low_so;      12'd294: toneL = `low_low_so;      12'd295: toneL = `low_low_so;      
                12'd296: toneL = `low_low_so;      12'd297: toneL = `low_low_so;      12'd298: toneL = `low_low_so;      12'd299: toneL = `low_low_so;
                12'd300: toneL = `low_low_so;      12'd301: toneL = `low_low_so;      12'd302: toneL = `low_low_so;      12'd303: toneL = `low_low_so;
                12'd304: toneL = `low_so;      12'd305: toneL = `low_so;      12'd306: toneL = `low_so;      12'd307: toneL = `low_so;
                12'd308: toneL = `low_so;      12'd309: toneL = `low_so;      12'd310: toneL = `low_so;      12'd311: toneL = `low_so;      
                12'd312: toneL = `low_so;      12'd313: toneL = `low_so;      12'd314: toneL = `low_so;      12'd315: toneL = `low_so;
                12'd316: toneL = `low_so;      12'd317: toneL = `low_so;      12'd318: toneL = `low_so;      12'd319: toneL = `low_so;
                12'd320: toneL = `low_do;      12'd321: toneL = `low_do;      12'd322: toneL = `low_do;      12'd323: toneL = `low_do;      
                12'd324: toneL = `low_do;      12'd325: toneL = `low_do;      12'd326: toneL = `low_do;      12'd327: toneL = `low_do;
                12'd328: toneL = `low_do;      12'd329: toneL = `low_do;      12'd330: toneL = `low_do;      12'd331: toneL = `low_do;
                12'd332: toneL = `low_do;      12'd333: toneL = `low_do;      12'd334: toneL = `low_do;      12'd335: toneL = `low_do;
                12'd336: toneL = `low_so;      12'd337: toneL = `low_so;      12'd338: toneL = `low_so;      12'd339: toneL = `low_so;
                12'd340: toneL = `low_so;      12'd341: toneL = `low_so;      12'd342: toneL = `low_so;      12'd343: toneL = `low_so;
                12'd344: toneL = `low_so;      12'd345: toneL = `low_so;      12'd346: toneL = `low_so;      12'd347: toneL = `low_so;      
                12'd348: toneL = `low_so;      12'd349: toneL = `low_so;      12'd350: toneL = `low_so;      12'd351: toneL = `low_so;
                12'd352: toneL = `low_low_so;      12'd353: toneL = `low_low_so;      12'd354: toneL = `low_low_so;      12'd355: toneL = `low_low_so;
                12'd356: toneL = `low_low_so;      12'd357: toneL = `low_low_so;      12'd358: toneL = `low_low_so;      12'd359: toneL = `low_low_so;
                12'd360: toneL = `low_low_so;      12'd361: toneL = `low_low_so;      12'd362: toneL = `low_low_so;      12'd363: toneL = `low_low_so;
                12'd364: toneL = `low_low_so;      12'd365: toneL = `low_low_so;      12'd366: toneL = `low_low_so;      12'd367: toneL = `low_low_so;      
                12'd368: toneL = `low_so;      12'd369: toneL = `low_so;      12'd370: toneL = `low_so;      12'd371: toneL = `low_so;
                12'd372: toneL = `low_so;      12'd373: toneL = `low_so;      12'd374: toneL = `low_so;      12'd375: toneL = `low_so;
                12'd376: toneL = `low_so;      12'd377: toneL = `low_so;      12'd378: toneL = `low_so;      12'd379: toneL = `low_so;      
                12'd380: toneL = `low_so;      12'd381: toneL = `low_so;      12'd382: toneL = `low_so;      12'd383: toneL = `low_so;
                12'd384: toneL = `low_low_fa;      12'd385: toneL = `low_low_fa;      12'd386: toneL = `low_low_fa;      12'd387: toneL = `low_low_fa;
                12'd388: toneL = `low_low_fa;      12'd389: toneL = `low_low_fa;      12'd390: toneL = `low_low_fa;      12'd391: toneL = `low_low_fa;
                12'd392: toneL = `low_low_fa;      12'd393: toneL = `low_low_fa;      12'd394: toneL = `low_low_fa;      12'd395: toneL = `low_low_fa;      
                12'd396: toneL = `low_low_fa;      12'd397: toneL = `low_low_fa;      12'd398: toneL = `low_low_fa;      12'd399: toneL = `low_low_fa;
                12'd400: toneL = `low_fa;      12'd401: toneL = `low_fa;      12'd402: toneL = `low_fa;      12'd403: toneL = `low_fa;
                12'd404: toneL = `low_fa;      12'd405: toneL = `low_fa;      12'd406: toneL = `low_fa;      12'd407: toneL = `low_fa;      
                12'd408: toneL = `low_fa;      12'd409: toneL = `low_fa;      12'd410: toneL = `low_fa;      12'd411: toneL = `low_fa;
                12'd412: toneL = `low_fa;      12'd413: toneL = `low_fa;      12'd414: toneL = `low_fa;      12'd415: toneL = `low_fa;      
                12'd416: toneL = `low_low_so;      12'd417: toneL = `low_low_so;      12'd418: toneL = `low_low_so;      12'd419: toneL = `low_low_so;
                12'd420: toneL = `low_low_so;      12'd421: toneL = `low_low_so;      12'd422: toneL = `low_low_so;      12'd423: toneL = `low_low_so;      
                12'd424: toneL = `low_low_so;      12'd425: toneL = `low_low_so;      12'd426: toneL = `low_low_so;      12'd427: toneL = `low_low_so;
                12'd428: toneL = `low_low_so;      12'd429: toneL = `low_low_so;      12'd430: toneL = `low_low_so;      12'd431: toneL = `low_low_so;
                12'd432: toneL = `low_so;      12'd433: toneL = `low_so;      12'd434: toneL = `low_so;      12'd435: toneL = `low_so;
                12'd436: toneL = `low_so;      12'd437: toneL = `low_so;      12'd438: toneL = `low_so;      12'd439: toneL = `low_so;
                12'd440: toneL = `low_so;      12'd441: toneL = `low_so;      12'd442: toneL = `low_so;      12'd443: toneL = `low_so;
                12'd444: toneL = `low_so;      12'd445: toneL = `low_so;      12'd446: toneL = `low_so;      12'd447: toneL = `low_so;      
                12'd448: toneL = `low_do;      12'd449: toneL = `low_do;      12'd450: toneL = `low_do;      12'd451: toneL = `low_do;
                12'd452: toneL = `low_do;      12'd453: toneL = `low_do;      12'd454: toneL = `low_do;      12'd455: toneL = `low_do;      
                12'd456: toneL = `low_do;      12'd457: toneL = `low_do;      12'd458: toneL = `low_do;      12'd459: toneL = `low_do;
                12'd460: toneL = `low_do;      12'd461: toneL = `low_do;      12'd462: toneL = `low_do;      12'd463: toneL = `low_do;      
                12'd464: toneL = `low_low_so;      12'd465: toneL = `low_low_so;      12'd466: toneL = `low_low_so;      12'd467: toneL = `low_low_so;
                12'd468: toneL = `low_low_so;      12'd469: toneL = `low_low_so;      12'd470: toneL = `low_low_so;      12'd471: toneL = `low_low_so;      
                12'd472: toneL = `low_low_so;      12'd473: toneL = `low_low_so;      12'd474: toneL = `low_low_so;      12'd475: toneL = `low_low_so;
                12'd476: toneL = `low_low_so;      12'd477: toneL = `low_low_so;      12'd478: toneL = `low_low_so;      12'd479: toneL = `low_low_so;      
                12'd480: toneL = `low_low_do;      12'd481: toneL = `low_low_do;      12'd482: toneL = `low_low_do;      12'd483: toneL = `low_low_do;
                12'd484: toneL = `low_low_do;      12'd485: toneL = `low_low_do;      12'd486: toneL = `low_low_do;      12'd487: toneL = `low_low_do;
                12'd488: toneL = `low_low_do;      12'd489: toneL = `low_low_do;      12'd490: toneL = `low_low_do;      12'd491: toneL = `low_low_do;
                12'd492: toneL = `low_low_do;      12'd493: toneL = `low_low_do;      12'd494: toneL = `low_low_do;      12'd495: toneL = `low_low_do;
                12'd496: toneL = `low_low_do;      12'd497: toneL = `low_low_do;      12'd498: toneL = `low_low_do;      12'd499: toneL = `low_low_do;
                12'd500: toneL = `low_low_do;      12'd501: toneL = `low_low_do;      12'd502: toneL = `low_low_do;      12'd503: toneL = `low_low_do;
                12'd504: toneL = `low_low_do;      12'd505: toneL = `low_low_do;      12'd506: toneL = `low_low_do;      12'd507: toneL = `low_low_do;
                12'd508: toneL = `low_low_do;      12'd509: toneL = `low_low_do;      12'd510: toneL = `low_low_do;      12'd511: toneL = `low_low_do;
                default : toneL = `silence;
            endcase
        end else begin
            toneL = `silence;
        end
    end

endmodule
