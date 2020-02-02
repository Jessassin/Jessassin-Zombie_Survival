bind('entity_damage', null, array(type: 'ZOMBIE'), @event,
#If there is no "damager" listed, die. prevents running on damage by fall or sun. prevents noIndexExists exception
	if(not(array_index_exists(@event,'damager')),
		die()
	)
#If the damage amount equals 0, cancel. Prevents errors when dividing by 0
	if(equals(@event['amount'],0),
		die()
	)
	assign(@player,@event['damager'])
	assign(@damage,@event['amount'])
	assign(@random,rand(1,7))
	assign(@fraction,divide(@random,10))
	assign(@money,multiply(@fraction,@damage))
	assign(@rounded,round(@money))
	_acc_add(@player,@rounded)
)