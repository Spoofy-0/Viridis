SMODS.Atlas {
	key = "Viridis_Jokers",
	path = "Viridis_Jokers.png",
	px = 71,
	py = 95
}


SMODS.Sound {
	key = 'viridis',
	path = {
		['default'] = 'meow.wav'
	}
}


SMODS.Joker {
	key = "yrag",
	loc_txt = {
		name = "yraG",
		text = {
			"Played {C:attention}6s{} give",
			"{C:mult}+#1#{} Mult when scored"
		}
	},
    config = { extra = {mult = 6}}, 
	blueprint_compat = true,
	rarity = 1,
	atlas = "Viridis_Jokers",
	pos = {x = 0, y = 0},
	cost = 6,
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.mult } }
	end,
	calculate = function(self, card, context)
		if context.individual and context.cardarea == G.play then
			if context.other_card:get_id() == 6 then
				return {
					juice_card = card, --im not sure if this is necessary but im not bothered to check
					mult = card.ability.extra.mult
				}
			end
		end
	end
}


SMODS.Joker {
	key = 'counting',
	loc_txt = {
		name = 'Counting',
		text = {
			"Gains {X:mult,C:white}X#2#{} Mult",
			"if played hand",
			"contains a {C:attention}Straight{}",
			"{C:inactive}(Currently {X:mult,C:white}X#1#{C:inactive} Mult)"
		}
	},
	config = { extra = { Xmult = 1, Xmult_gain = 0.123 } },
	blueprint_compat = true,
	rarity = 3,
	atlas = 'Viridis_Jokers',
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


SMODS.Joker {
	key = 'gold_gary',
	loc_txt = {
		name = 'Golden Gary',
		text = { 
			"Earn {C:money}$#1#{} at end of round,",
		    "payout increases by {C:money}$#2#{}",
			"when a {C:attention}4{} is scored, halved",
			"when a {C:attention}Boss Blind{} is defeated"
		}
	},
	config = { extra = {money = 0, increase = 4}},
	rarity = 4,
	atlas = 'Viridis_Jokers',
	pos = { x = 2, y = 0},
	soul_pos = { x = 3, y = 0},
	cost = 20,
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.money, card.ability.extra.increase } }
	end,
	calculate = function(self, card, context)
		if context.individual and context.cardarea == G.play then
			if context.other_card:get_id() == 4 then
				card.ability.extra.money = card.ability.extra.money + card.ability.extra.increase
				return {
					message = 'Upgrade!',
					colour = G.C.MONEY,
					card = card
				}
			end	
		end	
		if G.GAME.blind.boss and context.end_of_round and context.main_eval and card.ability.extra.money > 0  then
			card.ability.extra.money = math.floor((card.ability.extra.money)/2)
			return {
				message = 'Halved!',
				colour = G.C.MONEY
			}	
		end 
	end,
	calc_dollar_bonus = function(self, card)
		local bonus = card.ability.extra.money
		if bonus > 0 then return bonus end
	end
}


SMODS.Joker {
	key = 'spinach',
	loc_txt = {
		name = 'Spinach',
		text = {
			"Create {C:attention}#1#{C:dark_edition} Negative{} copies of",
			"{C:tarot}Strength{} when sold, amount",
			"increases by {C:attention}1{} at {C:attention}end of round"
		}
	},
	rarity = 2,
	blueprint_compat = true,
	atlas = 'Viridis_Jokers',
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


SMODS.Joker {
	key = 'tennis_ball',
	loc_txt = {
		name = 'Tennis Ball',
		text = {
			"{C:mult}+#1#{} Mult, eaten in {C:attention}3{} rounds",
			"{C:inactive}(Currently {C:attention}#2#{C:inactive}/3)"
		}
	},
	rarity = 1,
	blueprint_compat = true,
	atlas = "Viridis_Jokers",
	pos = {x = 5, y = 0},
	eternal_compat = false,
	config = {extra = {mult = 25, tennis_rounds = 0}},
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.mult, card.ability.extra.tennis_rounds } } 
	end,
	calculate = function(self, card, context)
		if context.end_of_round and context.main_eval and not context.blueprint then
			if card.ability.tennis_rounds == 3 then
				G.E_MANAGER:add_event(Event({
					trigger = 'after',
					delay = 0.3,
					blockable = false,
					func = function()
						G.jokers:remove_card(card)
						card:remove()
						play_sound('viridis_meow', 0.96+math.random()*0.08)
						card = nil
						return true;
					end
				}))
			end
			card.ability.extra.tennis_rounds = card.ability.extra.tennis_rounds + 1
		end
		if context.joker_main then
			return {
				mult_mod = card.ability.extra.mult,
				message = localize { type = 'variable', key = 'a_mult', vars = { card.ability.extra.mult } }
			}
		end
	end
}