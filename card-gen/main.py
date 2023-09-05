
import os
from PIL import Image, ImageDraw, ImageFont
import math


assets_folder = "./assets/sets"

card_sets = os.listdir(assets_folder)


card_size = (378, 526)
suit_size = (118, 118)
suit_size_ace = (118, 118)
suit_size_normal = (80, 80)
cards_per_suit = 13
suits = 4

sym_t = 0.25
sym_tc = sym_t + 0.125
sym_c = 0.5
sym_b = 0.75
sym_bc = sym_b - 0.125
sym_tt = sym_t + (0.5/3)
sym_bb = sym_t + (0.5/3)*2


symbol_locs = [
    # 2
    [
        (sym_c, sym_b),
        (sym_c, sym_t)
    ],
    # 3
    [
        (sym_t, sym_t),
        (sym_c, sym_c),
        (sym_b, sym_b)
    ],
    # 4
    [
        (sym_t, sym_t),
        (sym_b, sym_t),
        (sym_t, sym_b),
        (sym_b, sym_b)
    ],
    # 5
    [
        (sym_t, sym_t),
        (sym_b, sym_t),
        (sym_t, sym_b),
        (sym_b, sym_b),
        (sym_c, sym_c),
    ],
    # 6
    [
        (sym_t, sym_t),
        (sym_b, sym_t),
        (sym_t, sym_b),
        (sym_b, sym_b),
        (sym_t, sym_c),
        (sym_b, sym_c)
    ],
    # 7
    [
        (sym_t, sym_t),
        (sym_b, sym_t),
        (sym_t, sym_b),
        (sym_b, sym_b),
        (sym_t, sym_c),
        (sym_b, sym_c),
        (sym_c, sym_tc)
    ],
    # 8
    [
        (sym_t, sym_t),
        (sym_b, sym_t),
        (sym_t, sym_b),
        (sym_b, sym_b),
        (sym_t, sym_c),
        (sym_b, sym_c),
        (sym_c, sym_tc),
        (sym_c, sym_bc)
    ],
    # 9
    [
        (sym_t, sym_t),
        (sym_b, sym_t),
        (sym_t, sym_b),
        (sym_b, sym_b),
        (sym_t, sym_tt),
        (sym_b, sym_tt),
        (sym_t, sym_bb),
        (sym_b, sym_bb),
        (sym_c, sym_c)
    ],
    # 10
    [
        (sym_t, sym_t),
        (sym_b, sym_t),
        (sym_t, sym_b),
        (sym_b, sym_b),
        (sym_t, sym_tt),
        (sym_b, sym_tt),
        (sym_t, sym_bb),
        (sym_b, sym_bb),
        (sym_c, sym_tc),
        (sym_c, sym_bc)
    ]
]

value_map = ["A","2","3","4","5","6","7","8","9","10","J","Q","K"]


suit_assets = ['club.png', 'diamond.png','spade.png', 'heart.png', ]

font = ImageFont.truetype("assets/OpenSans-Bold.ttf", math.floor(card_size[0]*0.18))


for card_set in card_sets:
    print("Getting card set", card_set)

    asset_path = "{}/{}".format(assets_folder, card_set)

    card_back = Image.open("{}/{}".format(asset_path, "card-back.png"))
    card_front = Image.open("{}/{}".format(asset_path, "card-front.png"))

    suit_images = []
    little_suit_images = []
    for suit in suit_assets:
        suit_images.append(Image.open("{}/{}".format(asset_path, suit)))
        little_suit_images.append(Image.open(
            "{}/{}".format(asset_path, suit)).resize(suit_size_normal))

    out_sheet = Image.new(
        "RGBA", (card_size[0]*cards_per_suit, card_size[1]*(suits+1)))
    
    for value in range(cards_per_suit):
        for suit in range(suits):
            out_x = value*card_size[0]
            out_y = suit*card_size[1]

            out_sheet.paste(card_front, (out_x, out_y))
            if (value == 0 or value > len(symbol_locs)):
                suit_pos = (out_x + math.floor(card_size[0]/2 - suit_size[0]/2), out_y+math.floor(
                    card_size[1]/2 - suit_size[1]/2))
                out_sheet.paste(suit_images[suit], suit_pos, suit_images[suit])
            elif (value <= len(symbol_locs)):
                for symbol in symbol_locs[value-1]:
                    suit_pos_x = math.floor(
                        out_x + card_size[0]*symbol[0] - suit_size_normal[0]/2)
                    suit_pos_y = math.floor(
                        out_y + card_size[1]*symbol[1] - suit_size_normal[1]/2)
                    out_sheet.paste(
                        little_suit_images[suit], (suit_pos_x, suit_pos_y), little_suit_images[suit])
            
            font_color = (0,0,0,255)
            if suit % 2 > 0:
                font_color = (255,0,0,255)

            text_image = Image.new("RGBA", (card_size[0], card_size[1]))
            draw = ImageDraw.Draw(text_image)
            draw.text((10, 5), text=value_map[value], fill=font_color, font=font)
            text_image = text_image.transpose(Image.Transpose.ROTATE_180)
            draw = ImageDraw.Draw(text_image)
            draw.text((10, 5), text=value_map[value], fill=font_color, font=font)
            out_sheet.paste(text_image, (out_x, out_y), text_image)
                


    out_sheet.paste(card_back, (0, card_size[1]*4))
    out_sheet.save("test.png")
