KT2KMH = 1.852;
FPM2MPS = 0.00508;
var message_queue = [];
var cur_main_func = nil;
var rq_alt = 0;

var obstat = 0;

var state = {
	altprop: props.globals.getNode("/instrumentation/altimeter/indicated-altitude-ft"),
	spdprop: props.globals.getNode("/fdm/jsbsim/instrumentation/pitot/airspeed-kts"),
	vsprop: props.globals.getNode("/instrumentation/gps/indicated-vertical-speed"),
	alt: func() {return altprop.getValue() * FT2M;},
	speed: func() {return spdprop.getValue() * KT2KMH;},
	vs: func() {return}
}

var climb = func() {
	if (objstat == 0){
		addmsg("We are going to start by climbing to " ~ rq_alt ~ " meters.");
		if (state.speed() < 50) {
			addmsg("Go ahead and get in the air, and start a safe climb.");
		}
		addmsg("Aim for between 10 and 15 meters per second.");
	}
}

var main_loop = maketimer(0.1, func() {
	if (cur_main_func == nil) {
		obstat = 0;
		rq_alt = (math.floor(rand() * 5) + 1) * 1000;
		cur_main_func = climb;
	}
    if (cur_main_func != nil) {
        call(cur_main_func, nil, nil);
    }
});

var addmsg = func(msg) {
	append(message_queue, msg);
}

var remmsg = func(msg) {
  forindex (var index; message_queue) {
    if ( message_queue[index] == msg ) {
      message_queue = subvec(message_queue, 0, index) ~ subvec(message_queue, index + 1);
    }
  }
}

var msg_send = maketimer(5, func() {
	if (size(message_queue) > 0){
		screen.log.write(message_queue[0]);
		message_queue = subvec(message_queue,1);
	}
});


var trainerinit = setlistener("/sim/signals/fdm-initialized", func() {
	msg_send.start();
	#main_loop.start();
	addmsg("Hello, and thanks for using MyTrainer!");
});