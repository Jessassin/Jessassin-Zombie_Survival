_run_on_interval()

bind(player_death, null, null, @event,
	assign(@p,@event[player])
	assign(@bal,acc_balance(@p))
	broadcast(concat(@p' died, losing $'@bal'!'))
	set_timeout(300,
		closure(acc_set(@p,0))
	)
	lightning(ploc(@event[player]),true)
)

bind(player_interact, null, null, @event,
	if(equals_ic(@event[action],'right_click_block'),
		assign(@wallsigns,array('68:2','68:3','68:4','68:5'))
		assign(@p,@event[player])
		assign(@block,@event[block])
		assign(@location,@event[location])
		assign(@blocksouth,array(@location[0],@location[1],add(@location[2],1)))
		assign(@blocknorth,array(@location[0],@location[1],add(@location[2],-1)))
		assign(@blockeast,array(add(@location[0],1),@location[1],@location[2]))
		assign(@blockwest,array(add(@location[0],-1),@location[1],@location[2]))
		_detect_smelter(@p,@block,@location)
		if(equals_ic(@block,'69:4'),
			if(equals(get_block_at(@blocksouth),'58:0'),
				set_timeout(500,
					closure(set_block_at(@location,'69:4'))
				)
			)
		)
		foreach(@wallsigns,@sign,
			if(equals_ic(@sign,@block),
				if(equals_ic(get_sign_text(@location)[0],'[wallet1]'),
					_tutorial_wallet(1,@p)
				)
				if(equals_ic(get_sign_text(@location)[0],'[wallet2]'),
					_tutorial_wallet(2,@p)
				)
				if(equals_ic(get_sign_text(@location)[0],'[wallet3]'),
					_tutorial_wallet(3,@p)
				)
				if(equals_ic(get_sign_text(@location)[0],'[finish]'),
					_finish_tutorial(@p)
				)
				if(equals_ic(get_sign_text(@location)[0],'[premium]'),
					_bank_premium_tp(@p,@location)
				)
			)
		)
	)
)
