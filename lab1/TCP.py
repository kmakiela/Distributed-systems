import socket
import sys
from threading import Thread
import time
import random
import struct

my_ip_address = None
receiving_port = None
token_onwership = None
receiving_socket = None
sending_socket = None
new_token_socket = None
next_ip_address = None
next_port = None
id = None
token_to_delete = None
token_id = None
token_sender = False
token_to_set = None

NEW_SOCKET_MULTICAST_ADDRESS = "230.1.1.2"
NEW_SOCKET_PORT = 12346
LOGGER_IP_ADDRESS = "230.1.1.1"
LOGGER_PORT = 12345
BUFFER_SIZE = 40
NEW_NODE = "new_node"
NEW_NODE_ANSWER = "new_node_answer"
TOKEN = "token"
MESSAGE = "message"
NEW_TOKEN = "new_token"
DELETE_TOKEN = "delete_token"


def read_parameters():
    global my_ip_address
    global receiving_port
    global new_node_port
    global token_onwership
    global receiving_socket
    global sending_socket
    global new_node_socket
    global next_ip_address
    global next_port
    global id

    id = sys.argv[1]
    my_ip_address = sys.argv[2]
    receiving_port = int(sys.argv[3])
    next_ip_address = sys.argv[4]
    next_port = int(sys.argv[5])
    if len(sys.argv) > 6:
        token_onwership = True
    else:
        token_onwership = False

    print("My address:  " + my_ip_address + "    receiving on port:  " + str(receiving_port))
    print("Next hop:    " + next_ip_address + "    next port:          " + str(next_port) + "\n")


def create_message(type, destination_ip_address, message):
    return type + " " + destination_ip_address + " " + message


def is_message_for_me(message):
    if message.split()[1] == my_ip_address:
        return True
    else:
        return False


def get_message_type(message):
    return message.split(" ")[0]


def get_message_counter(buff):
    message = str(buff, 'utf-8')
    return int(message.split(" ")[3])


def decrement_message_counter(buff):
    message = str(buff, 'utf-8')
    message_as_list = message.split(" ")
    destination_ip_address = message_as_list[1]
    content = message_as_list[2]
    counter = int(message_as_list[3])
    counter = counter - 1
    return bytes(MESSAGE + " " + destination_ip_address + " " + content + " " + str(counter), 'utf-8')


def receiving():
    global next_ip_address
    global next_port
    global token_id
    buff_1 = []
    buff_2 = []
    while True:
        connection, address = receiving_socket.accept()
        buff_1 = connection.recv(BUFFER_SIZE)
        type = get_message_type(str(buff_1, 'utf-8'))
        if type == MESSAGE:
            if is_message_for_me(str(buff_1, 'utf-8')):
                print("Received message: " + str(buff_1, 'utf-8').split(" ")[2])
                print("Type: Destination: + Message:")
            else:
                print("Message not for me, sending further")
                message_counter = get_message_counter(buff_1)
                if message_counter > 0:
                    buff_1 = decrement_message_counter(buff_1)
                    sending_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                    sending_socket.connect((next_ip_address, next_port))
                    sending_socket.send(buff_1)
                    sending_socket.close()
                else:
                    print("Message deleted, reached the limit of hops")
        elif type == TOKEN:
            if token_id is None:
                token_id = int(str(buff_1, 'utf-8').split(" ")[1])
            Thread(target=deal_with_tokens).start()
        elif type == NEW_NODE:
            buff_2 = NEW_NODE_ANSWER + " " + next_ip_address + " " + str(next_port)
            next_ip_address = str(buff_1, 'utf-8').split(" ")[1]
            next_port = int(str(buff_1, 'utf-8').split(" ")[2])
            connection.send(bytes(buff_2, 'utf-8'))


def send_new_message():
    global sending_socket
    global token_onwership
    while True:
        print("Type: Destination + message:")
        input_ = input()
        destination_ip_address = input_.split(" ")[0]
        message = input_.split(" ")[1]
        buff = MESSAGE + " " + destination_ip_address + " " + message + " " + str(10)
        while token_onwership is False:
            print("Waiting for token")
            time.sleep(1)
        sending_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sending_socket.connect((next_ip_address, next_port))
        sending_socket.send(bytes(buff, 'utf-8'))
        sending_socket.close()
        token_onwership = False


def deal_with_tokens():
    global token_onwership
    global sending_socket
    global token_sender
    global token_to_delete
    global token_id
    global token_to_set

    token_onwership = True
    time.sleep(3)
    token_onwership = False
    buff = TOKEN + " " + str(token_id)
    if token_sender == True and token_to_delete == token_id:
        print("token " + str(token_id) + " will stop circulating")
        token_sender = False
        token_to_delete = None
        token_id = token_to_set
        token_to_set = None
        create_new_node_without_token()
        print("Type: destination IP + message")
    else:
        sending_socket.close()
        sending_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sending_socket.connect((next_ip_address, next_port))
        sending_socket.send(bytes(buff, 'utf-8'))

        sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
        sock.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_TTL, 32)
        sock.sendto(bytes(id + " has token", 'utf-8'), (LOGGER_IP_ADDRESS, LOGGER_PORT))


def create_new_node_without_token():
    global sending_socket
    global next_ip_address
    global next_port
    buff = NEW_NODE + " " + my_ip_address + " " + str(receiving_port)
    sending_socket.connect((next_ip_address, next_port))
    sending_socket.send(bytes(buff, 'utf-8'))
    data = sending_socket.recv(BUFFER_SIZE)
    next_ip_address = str(data, 'utf-8').split(" ")[1]
    next_port = int(str(data, 'utf-8').split(" ")[2])
    print("Connected")
    sending_socket.close()


def log_new_token_information():
    print("New token " + str(token_id) + " in network")
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
    sock.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_TTL, 2)
    sock.sendto(bytes(NEW_TOKEN + " " + str(token_id), 'utf-8'), (NEW_SOCKET_MULTICAST_ADDRESS, NEW_SOCKET_PORT))


def listen_for_new_token():
    global token_to_delete
    global token_id
    global token_to_set
    buff = []
    while True:
        buff = new_token_socket.recv(30)
        if str(buff, 'utf-8').split(" ")[0] == NEW_TOKEN:
            if token_sender == True:
                new_token = int(str(buff, 'utf-8').split(" ")[1])
                if new_token != token_id:
                    token_to_delete = new_token
                    print("Token " + str(token_to_delete) + " must be deleted")
                    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
                    sock.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_TTL, 2)
                    sock.sendto(
                        bytes(DELETE_TOKEN + " " + str(token_to_delete) + " " + str(token_id), 'utf-8'),
                        (NEW_SOCKET_MULTICAST_ADDRESS, NEW_SOCKET_PORT))
        if str(buff, 'utf-8').split(" ")[0] == DELETE_TOKEN:
            if token_sender == True:
                if token_id == int(str(buff, 'utf-8').split(" ")[1]):
                    token_to_delete = token_id
                    token_to_set = int(str(buff, 'utf-8').split(" ")[2])


def main():
    global receiving_socket
    global sending_socket
    global new_node_socket
    global token_onwership
    global token_id
    global new_token_socket
    global token_sender
    global my_ip_address

    read_parameters()

    receiving_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    receiving_socket.bind((my_ip_address, receiving_port))
    receiving_socket.listen(1)

    sending_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

    new_token_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
    new_token_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    new_token_socket.bind((NEW_SOCKET_MULTICAST_ADDRESS, NEW_SOCKET_PORT))
    mreq = struct.pack("4sl", socket.inet_aton(NEW_SOCKET_MULTICAST_ADDRESS), socket.INADDR_ANY)
    new_token_socket.setsockopt(socket.IPPROTO_IP, socket.IP_ADD_MEMBERSHIP, mreq)

    if token_onwership == True:
        token_sender = True
        token_id = random.randint(100, 999)
        Thread(target=deal_with_tokens).start()
        log_new_token_information()
    else:
        create_new_node_without_token()

    Thread(target=listen_for_new_token).start()
    Thread(target=receiving).start()
    Thread(target=send_new_message).start()


if __name__ == '__main__':
    main()
