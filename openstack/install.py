import yaml
import subprocess

def install_controller():
	stream = file('salt/config.yml', 'r')
	controller = yaml.load(stream)['openstack']['controller']

	stream = file('salt/stage.yml', 'r')
	stages = yaml.load(stream)['stages']

	opsctl = stages['controller']

	result, response = exec_salt_state(controller, 'openstack.cloudrepo')

	response = {}
	if opsctl['docker'] != 2:
		result , response['docker'] = exec_salt_state(controller, 'docker')
		opsctl['docker'] = 2 if result else 0

	if opsctl['docker'] == 2:
		for target in ['mariadb', 'rabbitmq']:
			if opsctl[target] != 2:
				result, response[target] = exec_salt_state(controller, target)
				opsctl[target] = 2 if result else 0
				if target = 'mariadb' and result:
					cmd = 'sudo service salt-minion restart'
					subprocess.check_output(cmd, shell=True)
	
	if opsctl['mariadb'] == 2:
		if opsctl['keystone'] != 2:
			result = response['keystone'] = exec_salt_state(controller, 'openstack.keystone')
			if result:
				opsctl['keystone'] = 2 
				cmd = 'sudo service salt-minion restart'
				subprocess.check_output(cmd, shell=True)

	if opsctl['keystone'] == 2:
		if opsctl['admin'] != 2:
			result, response['admin'] = exec_salt_state(controller, 'openstack.admin')
			opsctl['admin'] = 2 if result else 0

	if opsctl['admin'] == 2:
		if opsctl['glance'] != 2:
			result, response['glance'] = exec_salt_state(controller, 'openstack.glance')
			opsctl['glance'] = 2 if result else 0

		if opsctl['rabbitmq'] == 2:
			for target in ['cinder', 'nova']:
				if opsctl[target] != 2:
					state = 'openstack.%s.controller' % target
					result, response[target] = exec_salt_state(controller, state)
					opsctl[target] = 2 if result else 0

			if opsctl['neutron'] != 2:
				result = True
				for target in ['server', 'network']:
					state = 'openstack.neutron.%s' % (target)
					result, response['neutron'] = exec_salt_state(controller, state)
					if not result:
						break
				opsctl['neutron'] = 2 if result else 0

	if opsctl['horizon'] != 2:
		result, response['horizon'] = exec_salt_state(controller, 'openstack.horizon')
		opsctl['horizon'] = 2 if result else 0

	opsctl.pop('total')	
	opsctl['total'] = sum(opsctl.values())

	stages['controller'] = opsctl

	with open('salt/stage.yml', 'w') as f:
		f.write(yaml.dump({'stages': stages}, default_flow_style=False))
	
	return (opsctl, response)

def exec_salt_state(tgt, states):
	cmd = "sudo salt --out=json '%s' state.sls %s -v" % (tgt, states)
	try:
		response = subprocess.check_output(cmd, shell=True)
		result = True
	except Exception, err:
		response = "Error: %s" % str(err)
		result = False

	return (result, response)
