import json
import subprocess
import yaml

def get_minions():
	cmd = "sudo salt-key --out=json"
	try:
		result = json.loads(subprocess.check_output(cmd, shell=True))
	except:
		result = {}
	
	minions = []
	for minion in result.setdefault("minions", []):
		minions.append(str(minion))

	return minions

def get_nodes():
	minions = get_minions()

	if minions:
		update_stage = False
		try:
			stream = file('salt/stage.yml', 'r')
			stages = yaml.load(stream)['stages']
			#with open('salt/stage.yml', 'r') as f:
			#	stages = yaml.load(f.readlines())['stages']

			for minion in minions:
				if minion not in stages['nodes'].keys():
					stages['nodes'][minion] = 0
					update_stage = True
		except IOError:
				update_stage = True
				controller = {}
				controller['docker'] = 0
				controller['rabbitmq'] = 0
				controller['mariadb'] = 0
				controller['keystone'] = 0
				controller['admin'] = 0
				controller['glance'] = 0
				controller['cinder'] = 0
				controller['nova'] = 0
				controller['neutron'] = 0
				controller['horizon'] = 0

				nodes = {}
				for minion in minions:
					nodes[minion] = 0

				stages = {}
				stages['controller'] = controller
				stages['nodes'] = nodes

		if update_stage:
			with open('salt/stage.yml', 'w') as f:
				f.write(yaml.dump({'stages':stages}, default_flow_style=False))

		nodes = {}
		for hostname, state in stages['nodes'].items():
			try:
				newstate = int(state)
				if newstate <= 0:
					newstate = 'Waiting'
				elif newstate < 100:
					newstate = 'Installing'
				else:
					newstate = 'Finished'
			except:
				newstate = 'Unknown'
			nodes[hostname] = newstate
			
		return nodes
		
	return {}
