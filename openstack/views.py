from django.shortcuts import render

from saltstack import get_minions, get_nodes
from config import gen_config
from install import install_controller, get_controller, get_stages

# Create your views here.
def nodes_list(request):
	nodes = get_nodes()
	return render(request, 'nodes_list.html', {'nodes':nodes})

def openstack_settings(request):
	nodes = get_minions()
	return render(request, 'openstack_settings.html', {'nodes':nodes})

def generate_config(request):
	args = {}
	args['passwd'] = str(request.POST["passwd"])
	args['email'] = str(request.POST["email"])
	args['controller'] = str(request.POST['controller'])
	args['computes'] = str(request.POST['computes'])
	args['protocol'] = str(request.POST['protocol'])
	args['domainname'] = str(request.POST['domainname'])

	response = 'Finished' if gen_config(args) else 'Error'
	return render(request, 'generate_config.html', {'config_state':response})

def controller_installation(request):
	try:
		start_install = True if request.POST["start"] == "true" else False
	except:
		start_install = False

	controller = get_controller()

	if start_install:
		stages , response = install_controller()
	else:
		stages = get_stages()['stages']['controller']

	done = sum(stages.values())*5
	for key in stages.keys():
		try:
			stages[key] = {0: 'Non-install', 1: 'Installing', 2: 'Installed'}[stages[key]]
		except:
			stages[key] = 'Unknown'
	
	response = {'stages': stages, 'node': controller, 'done': done}
	return render(request, 'controller_installation.html', response)
