from uuid import uuid4

import yaml

def gen_config(args):
	admin = {}
	admin['token'] = str(uuid4())
	admin['password'] = args.setdefault('passwd', str(uuid4())[:8])
	admin['email'] = args.setdefault('email', 'admin@localhost')

	public = {}
	public['protocol'] = args['protocol']
	public['domianname'] = args['domainname']

	openstack = {}
	openstack['admin'] = admin
	openstack['controller'] = args['controller']
	openstack['computes'] = args['computes']
	openstack['public'] = public

	try:
		with open('salt/config.yml', 'w') as f:
			f.write(yaml.dump({'openstack':openstack}, default_flow_style=False))

		return True

	except:
		return False
