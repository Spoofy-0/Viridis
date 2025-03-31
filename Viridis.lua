SMODS.Atlas { key = "Jokers", path = "Jokers.png", px = 71, py = 95}
SMODS.Atlas { key = 'lc_cards', path = 'leaves.png', px = 71, py = 95 }
SMODS.Atlas { key = 'hc_cards', path = 'leaves_hc.png', px = 71, py = 95 }
SMODS.Atlas { key = 'lc_ui', path = 'ui_assets.png', px = 18, py = 18 }
SMODS.Atlas { key = 'hc_ui', path = 'ui_assets_hc.png', px = 18, py = 18 }
SMODS.Atlas { key = 'Tarot', path = 'Tarots.png', px = 71, py = 95 }
SMODS.Atlas { key = 'Enhancements', path = 'Enhancements.png', px = 71, py = 95 }
SMODS.Sound({key = 'meow', path = 'meow.ogg'})

-- Leaves
local leaf_suit = SMODS.Suit {
    key = 'Leaves',
    card_key = 'leaf',
    hc_atlas = 'hc_cards',
    lc_atlas = 'lc_cards',
    hc_ui_atlas = 'hc_ui',
    lc_ui_atlas = 'lc_ui',
    pos = { y = 0 },
    ui_pos = { x = 0, y = 0 },
    hc_colour = HEX('B9FF81'),
    lc_colour = HEX('98CD6E'),
	in_pool = false,
}

-- Tarots
SMODS.Consumable{ --Nature
	set = 'Tarot',
    key = 'nature',
	loc_txt = {
		name = 'Nature',
		text = {
			'Converts up to',
			'{C:attention}#1#{} selected',
			'cards to {V:1}Leaves{}'
		}
	},
	discovered = false,
    config = {max_highlighted = 3, suit_conv = leaf_suit.key},
    atlas = 'Tarot',
    pos = { x = 0, y = 0 },
    loc_vars = function(self)
        return {
            vars = {
                self.config.max_highlighted,
                localize(self.config.suit_conv, 'suits_plural'),
        	    colours = { G.C.SUITS[self.config.suit_conv] },
            },
        }
    end
}

SMODS.Consumable{  --The Clan
    set = 'Tarot', atlas = 'Tarot',
    key = 'clan',
	loc_txt = {
		name = "The Clan",
		text = {
			'Enhances up to {C:attention}#1#{}',
            'selected card to',
            '{C:attention}#2#{} Cards'
		}
	},
    discovered = false,
    effect = 'Enhance',
    config = {mod_conv = 'm_vrds_moss', max_highlighted = 1},
    pos = {x = 1, y=0},
	loc_vars = function(self, info_queue)
        info_queue[#info_queue+1] = G.P_CENTERS.m_vrds_moss
        return {vars = {self.config.max_highlighted, localize{type = 'name_text', set = 'Enhanced', key = self.config.mod_conv}}}
    end,
}

--Enhancements
SMODS.Enhancement({ --Moss
    key = 'moss',
	loc_txt = {
		name = 'Moss',
		text = {
			"Gains {X:mult,C:white}X#2#{} Mult for",
			"each Moss Card in",
			"played hand",
			"{C:inactive} Currently {X:mult,C:white}X#1#{C:inactive} Mult"
		}
	},
    atlas = "Enhancements",
    pos = {x = 0, y = 0},
    discovered = false,
    config = {extra = { x_gain = 0.15, x_mult = 1 }},
    loc_vars = function(self, info_queue, card)
        return {
            vars = { card.ability.extra.x_mult, card.ability.extra.x_gain }
        }
    end,
    calculate = function(self, card, context)
		if context.main_scoring and context.cardarea == G.play then
			local played_moss = 0
			for i, v in ipairs(G.play.cards) do
			    if v.config.center.key == 'm_vrds_moss' then
					played_moss = played_moss + 1
			    end
			end
			return {
			  xmult = card.ability.extra.x_mult + (played_moss * card.ability.extra.x_gain)
			}
		end
    end
})

--Jokers
SMODS.Joker { --Gary
	key = "gary",
	loc_txt = {
		name = "Gary",
		text = {
			"All played {C:attention}4s{} turn into",
			"{C:attention}Moss{} Cards and {C:vrds_leaf}Leaf{}",
			"suit when scored"
		}
	},
	discovered = false,
	blueprint_compat = false,
	rarity = 3,
	atlas = "Jokers",
	pos = {x = 6, y = 0},
	cost = 8,
	calculate = function(self, card, context)
		if context.before and not context.blueprint then
			local fours = {}
			for k,v in ipairs(G.play.cards) do
     	       if v:get_id() == 4 then
				fours[#fours+1] = v
				v:set_ability(G.P_CENTERS.m_vrds_moss, nil, true)
				v:change_suit('vrds_Leaves')
   	             G.E_MANAGER:add_event(Event({
    	                func = function()
            	            v:juice_up()
                	        return true
    	                end
        	        }))
      	        end
			end
			if #fours > 0 then
	         return {
    	            message = 'Meow!',
					play_sound('vrds_meow'),
    		        colour = G.C.GREEN,
					card = card
    	        }
    	    end
		end
	end
}

SMODS.Joker { --yraG
	key = "yrag",
	loc_txt = {
		name = "yraG",
		text = {
			"Played {C:attention}6s{} give {C:chips}+#2#{} Chips",
			"and {C:mult}+#1#{} Mult when scored"
		}
	},
	discovered = false,
    config = { extra = {mult = 6, chips = 16}},
	blueprint_compat = true,
	rarity = 1,
	atlas = "Jokers",
	pos = {x = 0, y = 0},
	cost = 6,
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.mult, card.ability.extra.chips } }
	end,
	calculate = function(self, card, context)
		if context.individual and context.cardarea == G.play then
			if context.other_card:get_id() == 6 then
				return {
					juice_card = card, --im not sure if this is necessary but im not bothered to check
					mult = card.ability.extra.mult,
					chips = card.ability.extra.chips
				}
			end
		end
	end
}

SMODS.Joker { --Counting
	key = 'counting',
	loc_txt = {
		name = 'Counting',
		text = {
			"This Joker gains {X:mult,C:white}X#2#{} Mult",
			"if played hand",
			"contains a {C:attention}Straight{}",
			"{C:inactive}(Currently {X:mult,C:white}X#1#{C:inactive} Mult)"
		}
	},
	discovered = false,
	config = { extra = { Xmult = 1, Xmult_gain = 0.123 } },
	blueprint_compat = true,
	rarity = 3,
	atlas = 'Jokers',
	pos = { x = 1, y = 0 },
	cost = 8,
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.Xmult, card.ability.extra.Xmult_gain } }
	end,
	calculate = function(self, card, context)
		if context.joker_main then
			return {
				Xmult_mod = card.ability.extra.Xmult,
				message = localize { type = 'variable', key = 'a_xmult', vars = { card.ability.extra.Xmult } }
			}
		end
		if context.before and next(context.poker_hands['Straight']) and not context.blueprint then
			card.ability.extra.Xmult = card.ability.extra.Xmult + card.ability.extra.Xmult_gain
			return {
				message = 'Upgraded!',
				colour = G.C.RED,
				card = card
			}
		end
	end
}

SMODS.Joker { --GOlden Gary
	key = 'gold_gary',
	loc_txt = {
		name = 'Golden Gary',
		text = {
			"Earn {C:money}$#1#{} at end of",
		    "round, payout increases",
			"by {C:money}$#2#{} when a {C:attention}4{} is",
			"scored, quartered when a",
			"{C:attention}Boss Blind{} is defeated"
		}
	},
	discovered = false,
	config = { extra = {money = 0, increase = 4}},
	blueprint_compat = false,
	rarity = 4,
	atlas = 'Jokers',
	pos = { x = 2, y = 0},
	soul_pos = { x = 3, y = 0},
	cost = 20,
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.money, card.ability.extra.increase } }
	end,
	calculate = function(self, card, context)
		if context.individual and context.cardarea == G.play and not context.blueprint then
			if context.other_card:get_id() == 4 then
				card.ability.extra.money = card.ability.extra.money + card.ability.extra.increase
				return {
					message = 'Upgrade!',
					colour = G.C.MONEY,
					card = card
				}
			end
		end
		if G.GAME.blind.boss and context.end_of_round and context.main_eval and not context.blueprint and card.ability.extra.money > 0  then
			card.ability.extra.money = math.floor((card.ability.extra.money)/4)
			return {
				message = 'Quartered!',
				colour = G.C.MONEY
			}
		end
	end,
	calc_dollar_bonus = function(self, card)
		local bonus = card.ability.extra.money
		if bonus > 0 then return bonus end
	end
}

SMODS.Joker { --Spinach
	key = 'spinach',
	loc_txt = {
		name = 'Spinach',
		text = {
			"Create {C:attention}#1#{C:dark_edition} Negative{}",
			"copies of {C:tarot}Strength{} when sold,",
			"amount increases by {C:attention}1{}",
			"at {C:attention}end of round"
		}
	},
	discovered = false,
	rarity = 2,
	blueprint_compat = true,
	atlas = 'Jokers',
	pos = {x = 4, y = 0},
	cost = 6,
	eternal_compat = false, --you need to be able to sell this
	config = {extra = {spn_strng = 1}},
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue+1] = G.P_CENTERS.c_strength
		info_queue[#info_queue+1] = G.P_CENTERS.e_negative
		return { vars = { card.ability.extra.spn_strng } }
    end,
	calculate = function(self, card, context)
		if context.end_of_round and context.main_eval and not context.blueprint then
			card.ability.extra.spn_strng = card.ability.extra.spn_strng + 1
			return{
				message = 'Upgrade!',
			}
		end
		if context.selling_self then
				for i=1, (card.ability.extra.spn_strng) do
					G.E_MANAGER:add_event(Event({
						trigger = 'before',
						delay = 0.0,
						func = (function()
							local card = create_card('Tarot',G.consumeables, nil, nil, nil, nil, 'c_strength')
							card:set_edition('e_negative', true)
							card:add_to_deck()
							G.consumeables:emplace(card)
							card:juice_up(0.5, 0.5)
							return true
						end
					)}))

			end
		end
	end
}

SMODS.Joker { --Tennis Ball
	key = 'tennis_ball',
	loc_txt = {
		name = 'Tennis Ball',
		text = {
			"Earn {C:money}$#1# in #2# round#<s>2#,",
			"{C:red,E:2}self destructs{}",
		}
	},
	discovered = false,
	rarity = 1,
	cost = 4,
	blueprint_compat = true,
	atlas = "Jokers",
	pos = {x = 5, y = 0},
	eternal_compat = false,
	config = {extra = {money = 44, rounds_remaining = 4}},
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.money, card.ability.extra.round_remaining } }
	end,
	calculate = function(self, card, context)
		if
			context.end_of_round
			and not context.blueprint
			and not context.individual
			and not context.repetition
			and not context.retrigger_joker
		then
			card.ability.extra.rounds_remaining = card.ability.extra.rounds_remaining - 1
			if card.ability.extra.rounds_remaining > 0 then
				return {
					message = { "Gary is coming..." },
					colour = G.C.FILTER,
				}
			else
				ease_dollars(card.ability.extra.money)
				G.E_MANAGER:add_event(Event({
					func = function()
						play_sound("tarot1")
						card.T.r = -0.2
						card:juice_up(0.3, 0.4)
						card.states.drag.is = true
						card.children.center.pinch.x = true
						G.E_MANAGER:add_event(Event({
							trigger = "after",
							delay = 0.3,
							blockable = false,
							func = function()
								G.jokers:remove_card(card)
								card:remove()
								card = nil
								return true
							end,
						}))
						return true
					end,
				}))
				return {
					message = "Eaten by Gary!",
					play_sound("vrds_meow"),
					colour = G.C.MONEY,
				}
			end
		end
	end,
}

SMODS.Joker { --Moss Joker
	key = "moss_joker",
	loc_txt = {
		name = "Moss Joker",
		text = {
			"Played {C:attention}Moss{} cards have",
			"a {C:green}#1# in #2#{} chance to turn",
			"a random card {C:attention}held in{}",
			"{C:attention}hand{} into a {C:attention}Moss{} card",
			"when scored"
		}
	},
	discovered = false,
	config = {extra = {odds = 5}},
	custom_in_pool = function()
        local condition = false
        if G.playing_cards then
            for k, v in pairs(G.playing_cards) do
                if v.config.center == G.P_CENTERS.m_vrds_moss then condition = true break end
            end
        end
        return condition
    end,
	rarity = 2,
	cost = 7,
	blueprint_compat = true,
	atlas = "Jokers",
	pos = {x = 7, y = 0},
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue + 1] = G.P_CENTERS.m_vrds_moss
		return { vars = {(G.GAME.probabilities.normal or 1), card.ability.extra.odds } }
	end,
	calculate = function(self, card, context)
		if context.cardarea == G.play and context.individual then
			if SMODS.has_enhancement(context.other_card, "m_vrds_moss") and pseudorandom('moss_joker') < G.GAME.probabilities.normal / card.ability.extra.odds then
					G.E_MANAGER:add_event(Event({
						func = function()
							local card = pseudorandom_element(G.hand.cards, pseudoseed('moss_joker'))
							card:set_ability(G.P_CENTERS.m_vrds_moss, nil, true)
							card:juice_up(0.5, 0.5)
							return true
						end
					}))
			end
		end
	end
}

SMODS.Joker { --Spoofy
	key = "spoofy",
	loc_txt = {
		name = "Spoofy",
		text = {
			"Played {C:attention}Lucky{} cards",
			"permanently gain {C:mult}+#1#{} mult",
			"when scored",
			"{C:inactive}(Huge thanks to Nevernamed{}",
			"{C:inactive}for the art!){}"
		}
	},
	discovered = false,
	config = {extra = {mult_gain = 1}},
	rarity = 1,
	cost = 5,
	atlas = "Jokers",
	pos = {x = 8, y = 0},
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue + 1] = G.P_CENTERS.m_lucky
		return { vars = {card.ability.extra.mult_gain} }
	end,
	calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
			if SMODS.has_enhancement(context.other_card, "m_lucky") then
	            context.other_card.ability.perma_mult = context.other_card.ability.perma_mult or 0
    	        context.other_card.ability.perma_mult = context.other_card.ability.perma_mult + card.ability.extra.mult_gain
        	    return {
	                extra = { message = localize('k_upgrade_ex'), colour = G.C.MULT },
    	            card = card
        	    }
  
			end
		end
	end
}

SMODS.Joker { --Envious Joker
    key = 'envious_joker',
	loc_txt = {
		name = "Envious Joker",
		text = {
			"Played cards with",
			"{C:vrds_leaf}Leaf{} suit give",
			"{C:mult}+#1#{} Mult when scored"
		}
	},
	effect = 'Suit Mult',
    config = {
        extra = {
            s_mult = 4,
            suit = leaf_suit.key
        },
    },
	discovered = false,
    atlas = 'Jokers',
    pos = { x = 9, y = 0 },
    cost = 5,
    loc_vars = function(self, info_queue, card)
        return {
            vars = { card.ability.extra.s_mult}
        }
    end
}

SMODS.Joker { --Zan
	key = "zan",
	loc_txt = {
		name = "Zan",
		text = {
			"This Joker gains {C:chips}+1{}",
			"Chip for each iteration",
			"of {C:vrds_leaf}Viridis {C:attention}Zan{}",
			"has tested",
			"{C:inactive}(Currently{C:chips} +#1#{C:inactive} Chips)",
			"{C:inactive}(Huge thanks to Nevernamed{}",
			"{C:inactive}for the art!){}"
		}
	},
	discovered = false,
	rarity = 3,
	cost = 9,
	atlas = 'Jokers',
	pos = {x = 10, y = 0},
	config = {extra = {chips = 135}},
	loc_vars = function(self, info_queue, card)
        return {
            vars = { card.ability.extra.chips}
        }
    end,
	calculate = function(self,card,context)
		if context.joker_main then
			return {
				chips = card.ability.extra.chips,
				message = localize { type = 'variable', key = 'a_chips', vars = { card.ability.extra.chips } }
			}
		end
	end
}