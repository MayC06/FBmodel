README for FBmodel7.m

Example script:

load('Exp1_5_stims.mat') % this is a struct of stimuli/inputs
load('PFNa_params.mat') % these are the parameters for PFNa
load('PFNd_params.mat') % these are the parameters for PFNd
load('PFNpc_params.mat') % these are the parameters for PFNp_c
load('PFNv_params.mat') % these are the parameters for PFNv
res = FBmodel7(stims(1),PFNd_p,PFNv_p,PFNpc_p,PFNa_p,1,1);

(final arg is plotting; second to last is whether to grab column outputs (heatmaps) (=1) vs. summary bump location and amplitude (=0))

The model code has three main parts.

First, it generates timecourses of intensity/amplitude responses for the different neuron types. The method you call, FBmodel7, will call a neuron-type-specific integration function twice for each type: once for each protocerebral bridge (PB) half. That integration function (e.g. PFNd_integ) determines how the PB half (Left or Right) for that neuron type will respond to the multimodal stimuli specified by the first argument to FBmodel7. The integration function calls a differential equation function, e.g. 'D_response_de', twice, once for each type of stimulus, using stimulus- and neuron-specific parameter values found in the second through fifth arguments to FBmodel7 (each parameter array has two rows: first row is for AF response; second row is for OF response).

FBmodel7 then takes these amplitude response timecourses and applies them to sinusoids that represent the activity patterns for each neuron type across each PB half. Reminder: the PB halves are columnar, and they have a bump of activity that can move across the columns. The sinusoid/bump in each half is shifted (or not, depending on neuron type) based on the bump position model 'bumpmdl_de'.

Then there's a bunch of plotting code (final arg = 1) to take a look at the inputs and the outputs to the model. The second figure shows the bumps of activity as heatmaps in the PB or FB.

Each stims.mat file loads as a matlab struct of sensory experience vectors that I have used in real experiments. ('vanbreugel_trajs.mat' is the sensory experience vectors pulled from 'laminar_orco_flash.csv', with appropriate coordinate transforms afaik.) Each row of the structure has six fields:
	heading, 
	airflow direction, 
	airspeed, 
	optic flow direction, 
	optic flow speed, 
	and time in seconds per frame of imaging data used to fit the model. 

If you want, you can run through all the stimuli I gave and see what the model produces.

** IMPORTANT NOTE **
I have made a model of PFNv, because they are well characterized in the literature for optic flow and generally very similar to PFNd, but I have not actually recorded from them myself. It is possible they do not respond to airflow as PFNd does. We may try to record from them or we may end up leaving them out of the model, but we have the option to do either.


If you have any questions, just slack me!