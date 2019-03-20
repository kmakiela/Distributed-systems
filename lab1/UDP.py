import socket
import sys
from threading import Thread
import time

my_ip_address = None
my_port = None
token_onwership = None
my_socket = None
next_ip_address = None
next_port = None
id = None
message_to_send = None
logger_ip_address = "230.1.1.1"
logger_port = 12345

NEW_NODE = "new_node"
NEW_NODE_ANSWER = "new_node_anwser"
TOKEN = "token"
MESSAGE = "message"


def read_parameters():
    global my_ip_address
    global my_port
    global token_onwership
    global my_socket
    global next_ip_address
    global next_port
    global id

    id = sys.argv[1]
    my_ip_address = sys.argv[2]
    my_port = int(sys.argv[3])
    next_ip_address = sys.argv[4]
    next_port = int(sys.argv[5])
    if len(sys.argv) > 6:
        token_onwership = True
    else:
        token_onwership = False

    print(my_ip_address + " " + str(my_port))


def create_message(type, destination_ip_address, message):
    return type + " " + destination_ip_address + " " + message;


def check_if_message_for_me(message):
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
    global my_socket
    global next_ip_address
    global token_onwership
    global next_port
    buff = []
    while True:
        buff, address = my_socket.recvfrom(1024)
        type = get_message_type(str(buff, 'utf-8'))
        if type == MESSAGE:
            if check_if_message_for_me(str(buff, 'utf-8')):
                print("Received message: " + str(buff, 'utf-8').split(" ")[2])
                print("Type: Destination + message:")
                Thread(target=deal_with_tokens).start()
            else:
                print("Message not for me, sending further")
                message_counter = get_message_counter(buff)
                if message_counter > 0:
                    buff = decrement_message_counter(buff)
                    my_socket.sendto(buff, (next_ip_address, next_port))
                else:
                    print("Message deleted, reached the limit of hops")
        elif type == TOKEN:
            Thread(target=deal_with_tokens).start()
        elif type == NEW_NODE:
            buff = NEW_NODE_ANSWER + " " + next_ip_address + " " + str(next_port)
            my_socket.sendto(bytes(buff, 'utf-8'), address)
            next_ip_address = address[0]
            next_port = address[1]
        else:
            next_ip_address = str(buff, 'utf-8').split(" ")[1]
            next_port = int(str(buff, 'utf-8').split(" ")[2])
            print("Connected")


def send_new_message():
    global my_socket
    global token_onwership
    while True:
        print("Type: Destination + message:")
        input_ = input()
        destination_ip_address = input_.split(" ")[0]
        message = input_.split(" ")[1]
        buff = MESSAGE + " " + destination_ip_address + " " + message + " " + str(10)
        while token_onwership is False:
            print("waiting for token")
            time.sleep(1)
        my_socket.sendto(bytes(buff, 'utf-8'), (next_ip_address, next_port))
        token_onwership = False


def deal_with_tokens():
    global token_onwership
    token_onwership = True
    time.sleep(3)
    token_onwership = False
    buff = TOKEN
    my_socket.sendto(bytes(buff, 'utf-8'), (next_ip_address, next_port))
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
    sock.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_TTL, 32)
    sock.sendto(bytes(id + " has token", 'utf-8'), (logger_ip_address, logger_port))


def create_new_node_without_token():
    buff = NEW_NODE + " " + my_ip_address + " " + str(my_port)
    my_socket.sendto(bytes(buff, 'utf-8'), (next_ip_address, next_port))


def main():
    global my_socket
    read_parameters()
    my_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    my_socket.bind((my_ip_address, my_port))
    if token_onwership == True:
        Thread(target=deal_with_tokens).start()
    else:
        create_new_node_without_token()

    Thread(target=receiving).start()
    Thread(target=send_new_message).start()


main()
