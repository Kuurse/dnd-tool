import math

base_party_size = 4
actual_party_size = 7
player_levels = 4


class Monster:
    def __init__(self, name, armor_class, hitpoints, att_bonus, avg_dmg_per_round, att_per_round=1, save_dc=0, xp=0):
        self.name = name
        self.armor_class = armor_class
        self.hitpoints = hitpoints
        self.att_bonus = att_bonus
        self.avg_dmg_per_round = avg_dmg_per_round
        self.old_dpr = avg_dmg_per_round
        self.att_per_round = att_per_round
        self.save_dc = save_dc
        self.xp = xp

    def scale_to_party_size(self, party_size):
        new_hitpoints = round((self.hitpoints/base_party_size)*party_size)
        new_att_per_round = self.att_per_round*(party_size/base_party_size)
        new_xp = self.xp*(party_size/base_party_size)
        return Monster(self.name, self.armor_class, new_hitpoints, self.att_bonus, self.avg_dmg_per_round, new_att_per_round, self.save_dc, new_xp)

    def scale_to_party_level(self, party_level, designed_party_level):
        # modifier = party_level/designed_party_level
        # diff = party_level - designed_party_level
        # new_hitpoints = self.hitpoints + (diff*10)
        new_avg_dmg_per_round = self.avg_dmg_per_round+(diff*2)
        # new_save_dc = 0
        # if self.save_dc != 0:
        #     new_save_dc = self.save_dc+(math.ceil(diff/2))
        # new_armor_class = self.armor_class+(math.ceil(diff/2))
        # new_att_bonus = self.att_bonus+(round(diff/4))
        new_xp = self.xp*modifier
        return Monster(self.name, new_armor_class, new_hitpoints, new_att_bonus, new_avg_dmg_per_round, self.att_per_round, new_save_dc, new_xp)

    def process_apr(self):
        full_apr = math.floor(self.att_per_round)
        rem = self.att_per_round - full_apr
        result = "{}".format(full_apr)
        if rem >= 0.5:
            result += ", 1 with disadvantage"
        return result

    def process_dpr(self):
        dpr_diff = (self.avg_dmg_per_round-self.old_dpr)
        msg = "{}".format(self.avg_dmg_per_round)
        if dpr_diff != 0:
            msg += " ({})".format(dpr_diff)
        return msg

    def __str__(self):
        return "{}:\nhp {}\nattaques par tour {}\navg_dmg {}\ndc {}\narmor {}\n{} att bonus\n{} save dc\nxp {}\n".format(self.name, self.hitpoints, self.process_apr(), self.process_dpr(), self.save_dc, self.armor_class, self.att_bonus, self.save_dc, self.xp)


# monster = Monster("Ghoul", 1, 2, 12, 22, 4, 11, 1)
# print(monster)
# monster.scale_to_party_size(actual_party_size)
# print(monster)
# monster.scale_to_party_level(4, 3)
# print(monster)

# monster.scale_to_party_level(3, 4)
# print(monster)

# ban = Monster("Banshee", 4, 2, 12, 58, 4, 12)
# print(ban)
# ban.scale_to_party_size(7)
# print(ban)
# ban.scale_to_party_level(6, 3)
# print(ban)

# dragon = Monster("jeune dragon blanc", 17, 133, 7, 15, 3, 15, 2300)
# print(dragon)
# dragon_7 = dragon.scale_to_party_size(7)
# print(dragon_7)
# dragon_lv4 = dragon.scale_to_party_level(10, 6)
# print(dragon_lv4)

sanglier = Monster("Sanglier", 15, 73, 5, 19, 2, 15, 2300)
print(sanglier)
print(sanglier.scale_to_party_size(7))
print(sanglier.scale_to_party_level(9, 6))
