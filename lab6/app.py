import sys
import logging
import subprocess
from operator import itemgetter

from kazoo.client import KazooClient, KazooState
from kazoo.exceptions import NoNodeError
from tree_format import format_tree


ports = ['localhost:2181', 'localhost:2182', 'localhost:2183']
znode = '/z'
application = None

def start_app():
	global application
	if application is None or application.poll() is not None:
		application = subprocess.Popen(sys.argv[1:])

def stop_app():
	global application
	if application is not None:
		application.kill()

# logging.basicConfig()
zk = KazooClient(hosts=','.join(ports))

@zk.add_listener
def listener(state):
	if state == KazooState.SUSPENDED:
		print('Connection lost')
	if state == KazooState.CONNECTED:
		print('Connected, alive and well')

def watch_children(children):
	print('Node {0} has {1} children: {2}'.format(znode, len(children), children))

@zk.DataWatch(znode)
def watch_node(data, stat):
	if stat is None:
		print('Node {} does not exist'.format(znode))
		stop_app()
	else:
		print('Node {} created'.format(znode))
		zk.ChildrenWatch(znode, watch_children)
		start_app()

zk.start()

def collect_tree(path=znode):
	return (
		path.split('/')[-1],
		[collect_tree(path + '/' + child) for child in zk.get_children(path)]
	)

def command_tree():
	try:
		print(format_tree(collect_tree(), itemgetter(0), itemgetter(1)))
	except NoNodeError:
		print('Node {} does not exist'.format(znode))

commands = {
	'tree': command_tree,
	'quit': sys.exit
}

print("Commands: {}".format(','.join(commands.keys())))
while True:
	cmd = input()
	if cmd in commands.keys():
		commands[cmd]()
	else:
		print('Wrong command: {}'.format(cmd))
