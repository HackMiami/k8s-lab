import requests
import argparse
import ping3
import time

argparser = argparse.ArgumentParser(description='Create a new ansible config file')
argparser.add_argument('--token', required=True, help='Linode API Token')
argparser.add_argument('--id', required=True, help='Linode id')
argparser.add_argument('--ip', help='Linode ip')
argparser.add_argument('--reboot', action='store_true', help='reboot')
argparser.add_argument('--shutdown', action='store_true', help='shutdown')
argparser.add_argument('--boot', action='store_true', help='boot')
argparser.add_argument('--ping', action='store_true', help='ping')
args = argparser.parse_args()


def print_help():
    print('Please provide a reboot, shutdown, or boot option')
    print('Example: python3 linode_reboot.py --token <token> --id <id> --reboot')
    print('Example: python3 linode_reboot.py --token <token> --id <id> --shutdown')
    print('Example: python3 linode_reboot.py --token <token> --id <id> --boot')
    print('Example: python3 linode_reboot.py --token <token> --id <id> --ping --ip <ip> --reboot')
    print(' --ping will try to ping the server 60 seconds if fails will reboot the server again.')
    exit(1)


def check_down():
    while True:
        response = ping3.ping(args.ip)
        if not response:
            print('Server is down')
            break
        else:
            print('Server is still up')
            time.sleep(1)


def check_up():
    count = 0
    while True:
        response = ping3.ping(args.ip)
        if response:
            print('Server is up')
            break
        else:
            print('Server is still down')
            time.sleep(5)
            count += 1
            if count == 12:
                print('Server did not startup')
                url = 'https://api.linode.com/v4/linode/instances/' + args.id + '/reboot'
                send_request(url)
                count = 0


def send_request(url):
    headers = {'Authorization': 'Bearer ' + args.token}
    try:
        requests.post(url, headers=headers)
    except requests.exceptions.RequestException as e:
        print(e)
        exit(1)


if args.token and args.id:
    if args.reboot:
        url = 'https://api.linode.com/v4/linode/instances/' + args.id + '/reboot'
    elif args.shutdown:
        url = 'https://api.linode.com/v4/linode/instances/' + args.id + '/shutdown'
    elif args.boot:
        url = 'https://api.linode.com/v4/linode/instances/' + args.id + '/boot'
    else:
        print_help()
else:
    print_help()

if args.ping and not args.ip:
    print('Please provide an ip address to ping')
    print_help()
    exit(1)

if args.shutdown:
    send_request(url)
    print('Waiting for server to shutdown')
    if args.ping and args.ip:
        check_down()

if args.boot:
    send_request(url)
    print('Waiting for server to boot')
    if args.ping and args.ip:
        check_up()

if args.reboot:
    send_request(url)
    print('Waiting for server to reboot')
    if args.ping and args.ip:
        check_down()
        check_up()
