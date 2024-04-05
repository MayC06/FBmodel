README for FBmodel7.m

Example script:

load('Exp1_5_stims.mat') % this is a struct of stimuli
load('PFNa_params.mat') % these are the parameters for PFNa
load('PFNd_params.mat') % these are the parameters for PFNd
load('PFNpc_params.mat') % these are the parameters for PFNp_c
load('PFNv_params.mat') % these are the parameters for PFNv
res = FBmodel7(stims(1),PFNd_p,PFNv_p,PFNpc_p,PFNa_p,0,0);

The model code has three main parts.

First, it generates timecourses of intensity/amplitude responses for the different neuron types. The method you call, FBmodel7, will call a neuron-type-specific integration function twice for each type: once for each protocerebral bridge (PB) half. That integration function (e.g. PFNd_integ) determines how the PB half (Left or Right) for that neuron type will respond to the multimodal stimuli specified by the first argument to FBmodel7. The integration function calls a differential equation function, e.g. 'D_PC_response_de', twice, once for each type of stimulus, using stimulus- and neuron-specific parameter values found in the second through fifth arguments to FBmodel7 (each parameter array has two rows: first row is for AF response; second row is for OF response).

FBmodel7 then takes these amplitude response timecourses and applies them to sinusoids that represent the activity patterns for each neuron type across each PB half. Reminder: the PB halves are columnar, and they have a bump of activity that can move across the columns. The sinusoid/bump in each half is shifted (or not, depending on neuron type) based on the bump position model 'bumpmdl_de'.

The second to last arg toggles whether you want vector outputs (=0) or sinusoid array outputs (=1). My understanding is that you want vector outputs. That produces 16 total vector outputs: bump positions and amplitudes for the left and right halves of activity for four neuron types (PFNd, PFNp_c, PFNa, and PFNv). I'm currently setting the bump positions as where they go in the FB, but this matters and may change after my meeting with Kathy on Monday.

Then there's a bunch of plotting code (final arg = 1) to take a look at the heatmap inputs and the outputs to the model. The second figure shows the bumps of activity as heatmaps in the PB or FB.

Each stims.mat file loads as a matlab struct of sensory experience vectors that I have used in real experiments. ('vanbreugel_trajs.mat' is the sensory experience vectors pulled from 'laminar_orco_flash.csv', with appropriate coordinate transforms I think.) Each row of the structure has six fields: heading, airflow direction, airspeed, optic flow direction, optic flow speed, and time in seconds per frame of imaging data used to fit the model. If you want, you can run through all the stimuli I gave and see what the model produces.

** IMPORTANT NOTE **
I have made a model of PFNv, because they are well characterized in the literature and very similar to PFNd types, but I have not actually recorded from them myself. We may try to record from them or we may end up leaving them out of the model, but we have the option to do either.


If you have any questions, just slack me!