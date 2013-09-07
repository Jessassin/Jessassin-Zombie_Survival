proc(_run_on_interval,
	set_interval(1000,
		closure(_update_moneycount())
	)
)

proc(_parse_args,@args,
	assign(@argarray,reg_split(' ',@args))
return(@argarray)
)

proc(_admin_bank,@args,
	assign(@args,parse_args(@args))
	if(equals_ic(@args[0],'add'),
		_addbank(@args[1])
	)
	if(equals_ic(@args[0],'remove'),
		_removebank(@args[1])
	)
	msg(@args)
)

proc(_admin_store,@args,
	assign(@args,_parse_args(@args))
	if(equals_ic(@args[0],'add'),
		_addstore(@args[1])
	)
	if(equals_ic(@args[0],'remove'),
		_removestore(@args[1])
	)
	msg(@args)
)

proc(_update_moneycount,
	foreach(all_players(),@p,
		assign(@wsize,_wallet_size(@p))
		assign(@percent,divide(@wsize,100))
		if(gt(acc_balance(@p),@wsize),
			tmsg(@p,concat('You can only hold '@wsize' in your wallet!'))
			tmsg(@p,'Upgrade your wallet by typing /wallet upgrade')
			tmsg(@p,'Open a bank account to deposit excess money.')
			acc_set(@p,@wsize)
		)
		set_plevel(@p,round(acc_balance(@p)))
		set_pexp(@p,round(divide(acc_balance(@p),@percent)))
	)
)

#This detects a smelter (or unstitcher)
proc(_detect_smelter,@p,@block,@location,
	assign(@block2,array(@location[0],subtract(@location[1],1),@location[2]))
	assign(@block2block,get_block_at(@block2))
	assign(@item,pinv(@p,null))
	assign(@furnace,array('61:2','61:3','61:4','61:5'))
	assign(@dispenser,array('23:2','23:3','23:4','23:5'))
	if(not(is_array(@item)),
		return()
	)
	if(equals(@block,140),
		if(array_contains(@dispenser,@block2block),
			msg('dispenser')
			if(_is_unstitchable(@item),
				_unstitch_item(@item,@block2,@p)
			)
		)
		if(array_contains(@furnace,@block2block),
			if(not(_has_fuel(@block2)),
				msg('You need to put coal in the furnace!')
				return()
			)
			if(_is_meltable(@item),
				_melt_item(@item,@block2,@p)
			)
		)
	)
)

proc(_has_fuel,@pos,
	assign(@item,get_inventory_item(@pos,1))
	if(is_array(@item),
		assign(@item,@item[type])
		if(equals_ic(@item,263),
			return(true)
		)
	)
	return(false)
)

proc(_is_meltable,@item,
	assign(@item,@item[type])
	assign(@smeltable,
		array(
			302,303,304,305,306,307,308,309,310,311,312,313,314,315,316,317
		)
	)
	if(array_contains(@smeltable,@item),
		return(true),
		return(false)
	)
)

proc(_is_unstitchable,@item,
	assign(@item,@item[type])
	assign(@unstitchable,
		array(
			298,299,300,301
		)
	)
	if(array_contains(@unstitchable,@item),
		return(true),
		return(false)
	)
)

proc(_melt_item,@item,@block2,@player,
	assign(@damage,@item[data])
	assign(@item,@item[type])
	assign(@maxhealth,_get_item_health(@item))
	assign(@health,subtract(@maxhealth,@damage))
	assign(@percent,divide(@health,@maxhealth))
	assign(@itemcount,_get_item_count(@item))
	assign(@material,_get_item_material(@item))
	assign(@returnamount,floor(multiply(@itemcount,@percent)))
	msg(concat('This item is worth '@returnamount' ingots.'))
	assign(@currentfuel,get_inventory_item(@block2,1))
	assign(@returnfuel,subtract(@currentfuel['qty'],1))
	if(equals(@returnfuel,0),
		assign(@fuelitem,null),
		assign(@fuelitem,array(data:0,enchants:array(),meta:null,qty:@returnfuel,type:263))
	)
	set_inventory_item(@block2,1,@fuelitem)
	assign(@pinv,pinv(@player))
	foreach(@pinv,@slot,
		if(and(not(is_null(@slot)),equals_ic(@slot[type],@item)),
			if(equals_ic(@slot[data],@damage),
				assign(@index,array_index(@pinv,@slot))
				assign(@entity,pinfo(@player,13))
				set_inventory_item(@entity,@index,null)
				
			)
		)
	)
	pgive_item(@player,@material,@returnamount)
)

proc(_unstitch_item,@item,@block2,@player,
	assign(@damage,@item[data])
	assign(@item,@item[type])
	assign(@maxhealth,_get_item_health(@item))
	assign(@health,subtract(@maxhealth,@damage))
	assign(@percent,divide(@health,@maxhealth))
	assign(@itemcount,_get_item_count(@item))
	assign(@material,_get_item_material(@item))
	assign(@returnamount,floor(multiply(@itemcount,@percent)))
	msg(concat('This item is worth '@returnamount' leather.'))
	#if(not(is_null(get_inventory_item(@block2,4))),
	#	die('Take your items from the dispenser first!')
	#)
	#assign(@returnitemarray,array(data:0,enchants:array(),meta:null,qty:@returnamount,type:@material))
	#set_inventory_item(@block2,4,@returnitemarray)
	assign(@pinv,pinv(@player))
	foreach(@pinv,@slot,
		if(and(not(is_null(@slot)),equals_ic(@slot[type],@item)),
			assign(@index,array_index(@pinv,@slot))
			assign(@entity,pinfo(@player,13))
			set_inventory_item(@entity,@index,null)
		)
	)
	set_timeout(10,
		closure(
			pgive_item(@material,@returnamount)
		)
	)
)

proc(_get_item_health,@item,
		assign(@healtharray,
		array(
		298:55,299:80,300:75,301:65,
		302:165,303:240,304:225,305:195,
		306:165,307:240,308:225,309:195,
		310:363,311:528,312:495,313:429,
		314:77,315:112,316:105,317:91
		)
	)
	return(@healtharray[@item])
)

proc(_get_item_material,@item,
	assign(@materialarray,
		array(
		298:334,299:334,300:334,301:334,
		302:265,303:265,304:265,305:265,
		306:265,307:265,308:265,309:265	,
		310:264,311:264,312:264,313:264,
		314:266,315:266,316:266,317:266
		)
	)
	return(@materialarray[@item])
)

proc(_get_item_count,@item,
	assign(@counts,
		array(
			298:5,299:8,300:7,301:4,
			302:5,303:8,304:7,305:4,
			306:5,307:8,308:7,309:4	,
			310:5,311:8,312:7,313:4,
			314:5,315:8,316:7,317:4
		)
	)
	return(@counts[@item])
)

proc(_finish_tutorial,@p,
	msg('Congrats on completing the tutorial!')
	msg('Good luck surviving!')
	runas(~console,concat('/pex user ',@p,' group remove newbies'))
	runas(~console,concat('/pex user ',@p,' group add member'))
	sudo('/spawn')
)

proc(_tutorial_wallet,@num,@p,
	if(equals(@num,1),
		msg('Starting wallet tutorial')
		set_ploc(@p,array(-481.5,13,117.5))
		pgive_item(@p,'298:40',1)
	)
	if(equals(@num,2),
		msg('Wallet tutorial part 2')
		if(not(phas_item(@p,334)),
			msg('You need to have leather in your inventory to continue'),
			set_ploc(@p,array(-477.5,13,117.5))
		)
	)
	if(equals(@num,3),
		msg('Wallet tutorial complete!')
		if(not(gt(_wallet_size(@p),250)),
			msg('You need to upgrade your wallet beyond $250 to continue!'),
			set_ploc(@p,array(-472.5,15,119.5))
		)
	)
)

proc(_wallet_reset,@p,
	clear_value(players.@p.walletsize)
	msg(concat('Wallet reset for: ',@p))
)

proc(_wallet_size,@p,
	if(not(has_value(concat(players.@p,walletsize))),
		store_value(players.@p.walletsize,250)
	)
	assign(@size,get_value(players.@p.walletsize))
	return(@size)
)

proc(_wallet_space,@p,
	assign(@size,_wallet_size(@p))
	assign(@amt,acc_balance(@p))
	assign(@return,subtract(@size,@amt))
	return(@return)
)
	

proc(_upgrade_wallet,@p,
	assign(@currentsize,_wallet_size(@p))
	assign(@newsize,add(_wallet_size(@p),250))
	if(not(phas_item(@p,334)),
		die('You must have leather in order to upgrade your wallet!'),
		ptake_item(@p,334,1)
		store_value(players.@p.walletsize,@newsize)
		msg('Wallet upgraded!')
		msg(concat('New capacity: $',@newsize))
		return()
	)
)

proc(_bank_balance,@p,
	assign(@bal,get_value(players.@p.bank))
	msg(concat('Balance: $',@bal))
	return(@bal)
)

proc(_bank_deposit,@p,@amt,
	if(not(_in_bank(@p)),
		msg('You need to be in a bank to deposit money')
		return()
	)
	assign(@amt,abs(@amt))
	if(not(gte(acc_balance(@p),@amt)),
		tmsg(@p,'Not enough money!')
		return()
	)
	assign(@newbalance,add(@amt,get_value(players.@p.bank)))
	store_value(players.@p.bank,@newbalance)
	acc_subtract(@p,@amt)
	assign(@amt,floor(@amt))
	msg(concat('$',@amt,' Deposited'))
	return()
)

proc(_bank_withdraw,@p,@amt,
	if(not(_in_bank(@p)),
		msg('You need to be in a bank to withdraw money')
		return()
	)
	if(not(gte(_wallet_space(@p),@amt)),
		msg('Your wallet is not big enough!')
		return()
	)
	assign(@amt,abs(@amt))
	assign(@balance,get_value(players.@p.bank))
	if(not(gte(@balance,@amt)),
		tmsg(@p,'Not enough money!')
		return()
	)
	assign(@newbalance,subtract(@balance,@amt))
	store_value(players.@p.bank,@newbalance)
	acc_add(@p,@amt)
	assign(@amt,floor(@amt))
	msg(concat('$',@amt,' Withdrawn'))
	return()
)

proc(_bank_getpremium,@p,
	if(not(_in_bank(@p)),
		msg('You need to be in a bank to upgrade your account')
		return()
	)
	if(not(gt(_bank_balance(@p),5000)),
		msg('You do not have enough money in your bank account!')
		msg('You need at least $5,000 to upgrade your account.')
		return()
	)
	assign(@balance,get_value(players.@p.bank))
	assign(@newbalance,subtract(@balance,5000))
	store_value(players.@p.bank,@newbalance)
	store_value(players.@p.bankpremium,'true')
	msg('Your account has been upgraded!')
	_bank_balance(@p)
)

proc(_bank_premium,@p,
	if(not(has_value(players.@p.bankpremium)),
		store_value(players.@p.bankpremium,'false')
	)
	assign(@premium,get_value(players.@p.bankpremium))
	if(equals(@premium,'true'),
		return(true)
	)
	return(false)
)

proc(_bank_premium_tp,@p,@loc,
	#msg(get_block_at(@loc))
	assign(@move,2)
	assign(@tploc,array(add(@loc[0],.5),subtract(@loc[1],1.5),add(@loc[2],.5)))
	if(not(_in_bank(@p)),
		return()
	)
	if(not(_bank_premium(@p)),
		msg('You must be a premium bank member to use this sign')
		return()
	)
	if(equals_ic(get_block_at(@loc),'68:3'),
		set_ploc(@tploc[0],@tploc[1],subtract(@tploc[2],@move))
	)
	if(equals_ic(get_block_at(@loc),'68:2'),
		set_ploc(@tploc[0],@tploc[1],add(@tploc[2],@move))
	)
	if(equals_ic(get_block_at(@loc),'68:4'),
		set_ploc(add(@tploc[0],@move),@tploc[1],@tploc[2])
	)
	if(equals_ic(get_block_at(@loc),'68:5'),
		set_ploc(subtract(@tploc[0],@move),@tploc[1],@tploc[2])
	)
	#3 = z-
	#2 = z+
	#4 = x+
	#5 = x-
)

proc(_addbank,@name,
	assign(@banks,get_value(world.banks))
	if(not(is_array(@banks)),
		assign(@banks,array())
	)
	array_push(@banks,@name)
	store_value(world.banks,@banks)
)

proc(_addstore,@name,
	assign(@stores,get_value(world.stores))
	if(not(is_array(@stores)),
		assign(@stores,array())
	)
	array_push(@stores,@name)
	store_value(world.stores,@stores)
)

proc(_removebank,@name,
	assign(@banks,get_value(world.banks))
	if(not(is_array(@banks)),
		assign(@banks,array())
	)
	array_remove(@banks,@name)
	store_value(world.banks,@banks)
	msg(concat('Bank removed: ',@name))
)

proc(_removestore,@name,

)

proc(_list_banks,
	assign(@banks,get_value(world.banks))
	broadcast(@banks)
)

proc(_list_stores,
	assign(@stores,get_value(world.stores))
	broadcast(@stores)
)

proc(_in_bank,@p,
	assign(@banks,get_value(world.banks))
	assign(@regions,sk_current_regions(@p))
	foreach(@regions,@loc,
		if(array_contains_ic(@banks,@loc),
			return(true)
		)
	)
	return(false)
)

proc(_in_store,@p,
	assign(@stores,get_value(world.stores))
	assign(@regions,sk_current_regions(@p))
	foreach(@regions,@loc,
		if(array_contains_ic(@stores,@loc),
			return(true)
		)
	)
	return(false)
)